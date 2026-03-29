//====== Copyright  Valve Corporation, All rights reserved. =================
//
//=============================================================================
#include "cbase.h"
#include "maps_workshop.h"
#include "workshop/ugc_utils.h"

#include "tf_gamerules.h"

#include "rtime.h"
#include "tier2/fileutils.h"
#include "filesystem.h"

#include "icommandline.h"

#include "ServerBrowser/IServerBrowser.h"

#if defined( _WIN32 ) && !defined( _X360 )
#include <windows.h>
#elif defined( POSIX )
#include <unistd.h>
#define _chdir chdir
#define _access access
#endif

#if !defined ( _GAMECONSOLE ) && !defined ( NO_STEAM )

CTFMapsWorkshop g_TFMapsWorkshop;

CTFMapsWorkshop *TFMapsWorkshop()
{
	// Statically initialized right now, but don't assume infallible
	return &g_TFMapsWorkshop;
}

ConVar sv_workshop_mount_sfm( "sv_workshop_mount_sfm", "0", FCVAR_GAMEDLL, "Mount SFM workshop content if available" );

static_assert( sizeof( PublishedFileId_t ) == 8, "Various printfs in this file assuming PublishedFileId_t is a 64bit type (e.g. %llu)" );

static CDllDemandLoader g_ServerBrowser( "ServerBrowser" );
static IServerBrowser *GetServerBrowser()
{
	if ( engine->IsDedicatedServer() )
	{
		return NULL;
	}

	static IServerBrowser *pServerBrowser = NULL;
	if ( pServerBrowser == NULL )
	{
		int iReturnCode;
		pServerBrowser = (IServerBrowser *)g_ServerBrowser.GetFactory()( SERVERBROWSER_INTERFACE_VERSION, &iReturnCode );
		Assert( pServerBrowser );
	}
	return pServerBrowser;
}

bool PublishedFileId_t_Less( const PublishedFileId_t &a, const PublishedFileId_t &b )
{
	return a < b;
}

// Get and possibly init UGC
static ISteamUGC *GetWorkshopUGC()
{
	static bool bInitUGC = false;
	ISteamUGC *pUGC = GetSteamUGC();

	// The first time we successfully get a steam context we should call the init
	if ( pUGC && !bInitUGC )
	{

		// For the dedicated server API, honor -ugcpath
		int i = CommandLine()->FindParm( "-ugcpath" );
		if ( engine->IsDedicatedServer() && i )
		{

			const char *pUGCPath = CommandLine()->GetParm( i + 1 );
			if ( pUGCPath )
			{
				g_pFullFileSystem->CreateDirHierarchy( pUGCPath, UGC_PATHID );
				char szFullPath[MAX_PATH] = { 0 };
				g_pFullFileSystem->RelativePathToFullPath( pUGCPath, UGC_PATHID, szFullPath, sizeof( szFullPath ) );
				if ( *szFullPath )
				{
					// NOTE we use our own AppID here as the workshop depot id, but this should match the workshopdepotid in our steam config
					pUGC->BInitWorkshopForGameServer( engine->GetAppID(), szFullPath );
				}
				else
				{
					TFWorkshopWarning( "Could not resolve -ugcpath to absolute path: %s\n", pUGCPath );
				}
			}
			else
			{
				TFWorkshopWarning( "Empty -ugcpath passed, using default\n" );
			}
		}
		else if ( i )
		{
			TFWorkshopWarning( "-ugcpath is ignored for listen servers\n" );
		}

		bInitUGC = true;
	}

	return pUGC;
}

CTFWorkshopMap::CTFWorkshopMap( PublishedFileId_t fileID )
	: m_nFileID( fileID ),
	  m_rtimeUpdated( 0 ),
	  m_nFileSize( 0 ),
	  m_eState( eState_Refreshing ),
	  m_bHighPriority( false ),
	  m_bIsLocal( false )
{
	TFWorkshopDebug( "Created TFWorkshopMap for [ %llu ]\n", (uint64)fileID );

	Refresh();
}

CTFWorkshopMap::CTFWorkshopMap( PublishedFileId_t fileID, bool local )
	: m_nFileID( fileID ),
	m_rtimeUpdated( 1 ),
	m_nFileSize( 1 ),
	m_eState( eState_Downloaded ),
	m_bHighPriority( false ),
	m_bIsLocal( true )
{
	
}

void CTFWorkshopMap::Refresh( eRefreshType refreshType )
{
	if ( m_bIsLocal )
		return;

	ISteamUGC *steamUGC = GetWorkshopUGC();

	if ( !steamUGC )
	{
		TFWorkshopWarning( "Failed to get Steam UGC context, map will not sync [ %llu ]\n", m_nFileID );
		m_eState = eState_Error;
		return;
	}

	m_eState = eState_Refreshing;

	// Cancel in-flight request
	if ( m_callbackQueryUGCDetails.IsActive() )
	{
		m_callbackQueryUGCDetails.Cancel();
	}

	UGCQueryHandle_t ugcQuery = steamUGC->CreateQueryUGCDetailsRequest( &m_nFileID, 1 );
	bool setMeta = steamUGC->SetReturnMetadata( ugcQuery, true );
	bool setCache = steamUGC->SetAllowCachedResponse( ugcQuery, 0 );
	if ( ugcQuery == k_UGCQueryHandleInvalid || !setMeta || !setCache )
	{
		TFWorkshopWarning( "Failed to create UGC details request for map [ %llu ]\n", m_nFileID );
		return;
	}
	SteamAPICall_t hSteamAPICall = steamUGC->SendQueryUGCRequest( ugcQuery );
	m_callbackQueryUGCDetails.Set( hSteamAPICall, this, &CTFWorkshopMap::Steam_OnQueryUGCDetails );

	if ( refreshType == eRefresh_HighPriority )
	{
		m_bHighPriority = true;
	}
}

void CTFWorkshopMap::Steam_OnQueryUGCDetails( SteamUGCQueryCompleted_t *pResult, bool bError )
{
	if ( pResult->m_eResult != k_EResultOK )
	{
		bError = true;
	}

	ISteamUGC *steamUGC = GetWorkshopUGC();

	SteamUGCDetails_t details = { 0 };
	if ( !bError && !( steamUGC->GetQueryUGCResult( pResult->m_handle, 0, &details ) && details.m_eResult == k_EResultOK ) )
	{
		TFWorkshopWarning( "Error fetching updated information for map id %llu\n", m_nFileID );
		bError = true;
	}

	char szMeta[k_cchDeveloperMetadataMax] = { 0 };
	if ( !bError && !steamUGC->GetQueryUGCMetadata( pResult->m_handle, 0, szMeta, sizeof( szMeta ) ) )
	{
		bError = true;
		TFWorkshopWarning( "Failed to get metadata for UGC file %llu\n", m_nFileID );
	}

	Assert( details.m_nPublishedFileId == m_nFileID );

	if ( bError )
	{
		TFWorkshopWarning( "Info lookup failed for workshop file %llu ( EResult %i )\n", (uint64)m_nFileID, (int)pResult->m_eResult );
		m_eState = eState_Error;

		return;
	}

	// Succeeded, re-evalute
	m_eState = eState_Error;
	m_nFileSize = details.m_nFileSize;
	m_rtimeUpdated = details.m_rtimeUpdated;

	// Our workshop maps use the metadata field for the canonical map filename
	CUtlString baseName = CUtlString( szMeta );
	m_strMapName = baseName;

	if ( !baseName.Length() )
	{
		TFWorkshopWarning( "Tracked map %llu has no filename and will not sync\n", m_nFileID );
		return;
	}

	if ( !g_TFMapsWorkshop.CanonicalNameForMap( m_nFileID, baseName, m_strCanonicalName ) )
	{
		TFWorkshopWarning( "Failed to make filename for tracked map, map will not be usuable [ baseName: %s ]\n", baseName.Get() );
		return;
	}

	if ( g_TFMapsWorkshop.IsSubscribed( m_nFileID ) )
	{
		// Tell serverbrowser about new subscription
		IServerBrowser *pServerBrowser = GetServerBrowser();
		if ( pServerBrowser )
		{
			TFWorkshopDebug( "Informing server browser of map\n" );
			// The server browser lists maps relative to maps/ without extension
			if ( baseName.GetExtension() != "bsp" )
			{
				TFWorkshopWarning( "Map with bogus extension, declining to track [ %s ]\n", m_strCanonicalName.Get() );
				return;
			}
			baseName = baseName.StripExtension();
			pServerBrowser->AddWorkshopSubscribedMap( m_strCanonicalName.Get() );
		}
	}

	uint32 state = steamUGC->GetItemState( m_nFileID );
	if (( state & k_EItemStateNeedsUpdate ) ||
	    !( state & ( k_EItemStateDownloading | k_EItemStateDownloadPending | k_EItemStateInstalled ) ) )
	{
		// Either out of date or not installed, downloading, or queued to download, ask UGC to do so. The latter happens
		// for maps added not from subscriptions that have no reason for UGC to initiate downloads on its own.
		if ( !steamUGC->DownloadItem( m_nFileID, m_bHighPriority ) )
		{
			TFWorkshopWarning( "DownloadItem failed for file, map will not be usable [ %s ]\n", m_strCanonicalName.Get() );
			return;
		}

		TFWorkshopMsg( "New version available for map, download queued [ %s ]\n", m_strCanonicalName.Get() );
		m_eState = eState_Downloading;
	}
	else if ( engine->IsDedicatedServer() &&
	          ( state & k_EItemStateInstalled ) &&
	          !( state & k_EItemStateDownloading ) &&
	          steamUGC->DownloadItem( m_nFileID, m_bHighPriority ) )
	{
		// TODO This is working around a ISteamUGC bug, wherein it sends us the result of the query for a newer revision
		//      of the file, but GetItemState() does not see an update available yet. This only seems to occur using the
		//      gameserver API. Once that is fixed this is only needed if the first DownloadItem() call wasn't high
		//      priority.
		// NOTE There is another bug where calling DownloadItem() on the *non-gameserver* api on a fully up to date item
		//      sometimes sets it to DownloadPending but never begins the download, causing us to wait
		//      forever. (Triggered by being subscribed to the file?)
		uint32 newState = steamUGC->GetItemState( m_nFileID );
		DevMsg( "[TF Workshop] UGC state %u\n", newState );
		// It's unclear if DownloadItem() is supposed to be a no-op on downloaded things, or is meant to return
		// false, but either way we'll now get a downloaded callback when things are good.
		m_eState = eState_Downloading;
	}
	else
	{
		TFWorkshopMsg( "Got updated information for map [ %s ]\n", m_strCanonicalName.Get() );
		m_eState = Downloaded() ? eState_Downloaded : eState_Downloading;
	}

	// Notify gamerules of the udpate
	TFGameRules()->OnWorkshopMapUpdated( m_nFileID );
}

bool CTFWorkshopMap::GetLocalFile( /* out */ CUtlString &strLocalFile )
{
	if (m_bIsLocal)
	{
		char szFullPath[ MAX_PATH ] = { 0 };
		V_MakeAbsolutePath( szFullPath, sizeof( szFullPath ), m_strMapName, m_strLocalFolder );
		strLocalFile = szFullPath;
		return true;
	}
	uint64 nUGCSize = 0;
	uint32 nTimestamp = 0;
	char szFolder[MAX_PATH] = { 0 };
	if ( !GetWorkshopUGC()->GetItemInstallInfo( m_nFileID, &nUGCSize, szFolder, sizeof( szFolder ), &nTimestamp ) )
	{
		TFWorkshopWarning( "GetItemInstallInfo failed for item, map not usable [ %s ]\n", CanonicalName() ? CanonicalName() : "" );
		return false;
	}

	char szFullPath[MAX_PATH] = { 0 };
	V_MakeAbsolutePath( szFullPath, sizeof( szFullPath ), m_strMapName, szFolder );
	strLocalFile = szFullPath;
	return true;
}

bool CTFWorkshopMap::Downloaded( float *flProgress )
{
	uint32 state = GetWorkshopUGC()->GetItemState( m_nFileID );
	if (( state & k_EItemStateInstalled ) &&
	    !( state & ( k_EItemStateNeedsUpdate |
	                 k_EItemStateDownloadPending |
	                 k_EItemStateDownloading )))
	{
		if ( flProgress )
		{
			*flProgress = 1.f;
		}
		return true;
	}

	if ( !flProgress )
	{
		// No need to calculate
		return false;
	}

	uint64 unDownloaded = 0;
	uint64 unTotal = 0;
	*flProgress = 0.f;
	if ( GetWorkshopUGC()->GetItemDownloadInfo( m_nFileID, &unDownloaded, &unTotal ) && unTotal > 0 )
	{
		*flProgress = (float)unDownloaded / (float)unTotal;
	}

	return false;
}

void CTFWorkshopMap::OnUGCDownload( DownloadItemResult_t *pResult )
{
	if ( m_eState == eState_Refreshing )
	{
		// This can happen if we Refresh while downloading. The info callback will check download state when it arrives,
		// so it's safe to drop.
		TFWorkshopDebug( "Download callback for map in refresh state [ %llu ]\n", m_nFileID );
		return;
	}

	if ( m_eState != eState_Downloading )
	{
		TFWorkshopWarning( "Got download callback for item in invalid state [ %llu, state %i ]\n", m_nFileID, (int)m_eState );
		return;
	}

	if ( pResult->m_eResult == k_EResultOK )
	{
		// TODO Due to the bug workaround in Steam_OnQueryUGCDetails (see TODO there) we trigger no-op downloads for
		//      even fully prepared maps, so don't spam this.

		// TFWorkshopMsg( "Map download completed [ %s ]\n", m_strCanonicalName.Get() );
		m_eState = eState_Downloaded;
	}
	else
	{
		TFWorkshopWarning( "Map download failed with result %u [ %s ]\n", pResult->m_eResult, m_strCanonicalName.Get() );
		m_eState = eState_Error;
	}
}

void CTFWorkshopMap::OnUGCItemInstalled( ItemInstalled_t *pResult )
{
	// It's not clear this should ever happen for a map we already requested download of, but if we add a
	// have-metadata-but-didnt-download state in the future this would let us short-circuit to already-downloaded,
	// triggered by e.g. a user subscribing outside the game.
	TFWorkshopMsg( "Installed subscribed map [ %s ]\n", m_strCanonicalName.Get() );
}

//-----------------------------------------------------------------------------
// Purpose: Main maps workshop constructor
//-----------------------------------------------------------------------------
CTFMapsWorkshop::CTFMapsWorkshop()
	: m_callbackDownloadItem( NULL, NULL )
	, m_callbackItemInstalled( NULL, NULL )
	, m_callbackDownloadItem_GameServer( NULL, NULL )
	, m_callbackItemInstalled_GameServer( NULL, NULL )
	, m_mapMaps( 0, 0, PublishedFileId_t_Less )
	, m_nPreparingMap( k_PublishedFileIdInvalid )
{
}

//-----------------------------------------------------------------------------
// Purpose: Initialize workshop and start any background tasks
//-----------------------------------------------------------------------------
bool CTFMapsWorkshop::Init( void )
{
	if ( !engine->IsDedicatedServer() )
	{
		IServerBrowser *pServerBrowser = GetServerBrowser();
		if ( pServerBrowser )
		{
			pServerBrowser->SetWorkshopEnabled( true );
		}

		// Refresh for dedicated servers will happen in GameServerAPIActivated.
		Refresh();
	}

	if ( engine->IsDedicatedServer() )
	{
		m_callbackDownloadItem_GameServer.Register( this, &CTFMapsWorkshop::Steam_OnUGCDownload );
		m_callbackItemInstalled_GameServer.Register( this, &CTFMapsWorkshop::Steam_OnUGCItemInstalled );
	}
	else
	{
		m_callbackDownloadItem.Register( this, &CTFMapsWorkshop::Steam_OnUGCDownload );
		m_callbackItemInstalled.Register( this, &CTFMapsWorkshop::Steam_OnUGCItemInstalled );
	}

	return true;
}

//-----------------------------------------------------------------------------
// Purpose: Stop & cleanup any tasks in progress
//-----------------------------------------------------------------------------
void CTFMapsWorkshop::Shutdown( void )
{
	m_mapMaps.PurgeAndDeleteElements();

	if ( engine->IsDedicatedServer() )
	{
		m_callbackDownloadItem_GameServer.Unregister();
		m_callbackItemInstalled_GameServer.Unregister();
	}
	else
	{
		m_callbackDownloadItem.Unregister();
		m_callbackItemInstalled.Unregister();
	}
}

//-----------------------------------------------------------------------------
// Purpose: Callback for a DownloadItem() call by us completing, mark map as finished
//-----------------------------------------------------------------------------
void CTFMapsWorkshop::Steam_OnUGCDownload( DownloadItemResult_t *pResult )
{
	// This is a generic callback for any downloads happening, we're listening to handle any relevant to us
	PublishedFileId_t nFileID = pResult->m_nPublishedFileId;
	if ( nFileID == k_PublishedFileIdInvalid )
	{
		TFWorkshopWarning( "Got UGCDownload notice for invalid item ID\n" );
		return;
	}

	unsigned short nInd = m_mapMaps.Find( nFileID );
	if ( nInd != m_mapMaps.InvalidIndex() )
	{
		// This is a map of ours, notify it
		TFWorkshopDebug( "Got DownloadItemResult for %llu\n", nFileID );
		m_mapMaps[ nInd ]->OnUGCDownload( pResult );
	}
}

//-----------------------------------------------------------------------------
// Purpose: Handle steam-initiated item installs
//-----------------------------------------------------------------------------
void CTFMapsWorkshop::Steam_OnUGCItemInstalled( ItemInstalled_t *pResult )
{
	// This is a generic callback for any downloads happening, we're listening to handle any relevant to us
	PublishedFileId_t nFileID = pResult->m_nPublishedFileId;
	if ( nFileID == k_PublishedFileIdInvalid )
	{
		TFWorkshopWarning( "Got ItemInstalled notice for invalid item ID\n" );
		return;
	}

	unsigned short nInd = m_mapMaps.Find( nFileID );
	if ( nInd != m_mapMaps.InvalidIndex() )
	{
		// This is a map of ours, notify it
		TFWorkshopDebug( "Got ItemInstalled for %llu\n", nFileID );
		m_mapMaps[ nInd ]->OnUGCItemInstalled( pResult );
	}
}

//-----------------------------------------------------------------------------
// Purpose: Rebuild our subscriptions.
//-----------------------------------------------------------------------------
void CTFMapsWorkshop::Refresh()
{
	TFWorkshopDebug( "Refresh\n" );

	// Ensure directory for maps exists
	g_pFullFileSystem->CreateDirHierarchy( "maps/workshop", UGC_PATHID );

	UpdateLocalTF2WorkshopCache();
	UpdateLocalSFMWorkshopCache();

	ISteamUGC *steamUGC = GetWorkshopUGC();

	if ( !steamUGC )
	{
		TFWorkshopWarning( "Failed to get Steam UGC service, refresh failed\n" );
		return;
	}

	// Check existing maps
	FOR_EACH_MAP( m_mapMaps, i )
	{
		m_mapMaps[i]->Refresh();
	}

	// Servers are on the steamgameserver API without subscriptions
	if ( !engine->IsDedicatedServer() )
	{
		// Get new subscriptions
		m_vecSubscribedMaps.RemoveAll();

		uint32 maxResults = steamUGC->GetNumSubscribedItems();
		m_vecSubscribedMaps.AddMultipleToTail( maxResults );
		uint32 numResults = steamUGC->GetSubscribedItems( m_vecSubscribedMaps.Base(), maxResults );
		if ( numResults < maxResults )
		{
			m_vecSubscribedMaps.RemoveMultipleFromTail( maxResults - numResults );
		}

		// Check new subscriptions for maps we're not tracking, queue info requests
		int newMaps = 0;
		FOR_EACH_VEC( m_vecSubscribedMaps, i )
		{
			// Ignore maps we're already tracking
			PublishedFileId_t fileID = m_vecSubscribedMaps[i];

			if ( m_mapMaps.Find( fileID ) == m_mapMaps.InvalidIndex() )
			{
				CTFWorkshopMap *newMap = new CTFWorkshopMap( fileID );
				m_mapMaps.Insert( fileID, newMap );

				TFWorkshopDebug( "Created workshop map %llu\n", fileID );
				newMaps++;
			}
		}

		TFWorkshopMsg( "Got %u subscribed maps, %u new\n", m_vecSubscribedMaps.Count(), newMaps );
	}
}

//-----------------------------------------------------------------------------
// Purpose: Check if a map is in our subscribed list
//-----------------------------------------------------------------------------
bool CTFMapsWorkshop::IsSubscribed( PublishedFileId_t nFileID )
{
	return ( m_vecSubscribedMaps.Find( nFileID ) != m_vecSubscribedMaps.InvalidIndex() || m_vecLocalWorkshopMaps.Find( nFileID ) != m_vecLocalWorkshopMaps.InvalidIndex() );
}

//-----------------------------------------------------------------------------
// Purpose: Check if a map is in our subscribed list
//-----------------------------------------------------------------------------
bool CTFMapsWorkshop::IsLocallyDownloaded( PublishedFileId_t nFileID )
{
	return ( m_vecLocalWorkshopMaps.Find( nFileID ) != m_vecLocalWorkshopMaps.InvalidIndex() );
}

//-----------------------------------------------------------------------------
// Purpose: Hook from BaseClientDLL to allow us to catch and prepare a workshop map load
//-----------------------------------------------------------------------------
IServerGameDLL::ePrepareLevelResourcesResult
CTFMapsWorkshop::AsyncPrepareLevelResources( /* in/out */ char *pMapName, size_t nMaxMapNameLen,
                                             /* in/out */ char *pMapFileToUse, size_t nMaxMapFileLen,
                                             float *flProgress /* = NULL */ )
{
	// Files from this hook start with maps/
	PublishedFileId_t nMapID = k_PublishedFileIdInvalid;
	CUtlString localName( pMapName );
	localName.ToLower();
	nMapID = MapIDFromName( localName );

	// Doesn't look like a workshop map load
	if ( nMapID == k_PublishedFileIdInvalid )
	{
		if ( flProgress )
		{
			*flProgress = 1.f;
		}
		m_nPreparingMap = k_PublishedFileIdInvalid;
		return IServerGameDLL::ePrepareLevelResources_Prepared;
	}

	bool bNewPrepare = ( m_nPreparingMap != nMapID );
	m_nPreparingMap = nMapID;

	TFWorkshopDebug( "OnClientPrepareLevelResources for [ %s ]\n", pMapName );

	unsigned int nIndex = m_mapMaps.Find( nMapID );
	CTFWorkshopMap *pMap = NULL;
	if ( nIndex == m_mapMaps.InvalidIndex() )
	{
		TFWorkshopMsg( "Map ID %llu isn't tracked, adding\n", nMapID );
		pMap = new CTFWorkshopMap( nMapID );
		m_mapMaps.Insert( nMapID, pMap );
	}
	else
	{
		pMap = m_mapMaps[ nIndex ];
	}

	if ( bNewPrepare )
	{
		// Even if map is up to date, it could be stale, so always start a new prepare with a re-check
		pMap->Refresh( CTFWorkshopMap::eRefresh_HighPriority );
	}

	if ( pMap->State() == CTFWorkshopMap::eState_Refreshing )
	{
		if ( flProgress )
		{
			*flProgress = 0.f;
		}
		return IServerGameDLL::ePrepareLevelResources_InProgress;
	}

	if ( pMap->State() == CTFWorkshopMap::eState_Downloading )
	{
		// Get download %
		if ( flProgress )
		{
			pMap->Downloaded( flProgress );
		}

		return IServerGameDLL::ePrepareLevelResources_InProgress;
	}

	if ( pMap->State() == CTFWorkshopMap::eState_Downloaded )
	{
		// Get file name & canonical name
		CUtlString fileName;
		if ( pMap->GetLocalFile( fileName ) )
		{
			TFWorkshopMsg( "Successfully prepared client map from workshop [ %s ]\n", pMap->CanonicalName() );
			V_strncpy( pMapFileToUse, fileName.Get(), nMaxMapFileLen );
			V_strncpy( pMapName, pMap->CanonicalName(), nMaxMapNameLen );
		}
		else
		{
		    // Tell engine we're done so it can go on and fail. It should be using maps/workshop/foo.ugc1234.bsp as a fallback...
			TFWorkshopWarning( "Map synced, but failed to resolve local file [ %s ]\n", pMap->CanonicalName() ? pMap->CanonicalName() : "" );
		}
	}
	else
	{
		Assert ( pMap->State() == CTFWorkshopMap::eState_Error );
		TFWorkshopWarning( "Map failed to sync, load will not go well :(\n" );
		// Tell engine we're done so it can go on and fail
	}

	if ( flProgress )
	{
		*flProgress = 1.f;
	}

	// New calls to this map ID are new loads
	m_nPreparingMap = k_PublishedFileIdInvalid;

	return IServerGameDLL::ePrepareLevelResources_Prepared;
}

//-----------------------------------------------------------------------------
// Purpose: Hook from ServerGameDLL to allow us to catch and prepare a workshop map load
//-----------------------------------------------------------------------------
void CTFMapsWorkshop::PrepareLevelResources( /* in/out */ char *pszMapName, size_t nMapNameSize,
                                             /* in/out */ char *pszMapFile, size_t nMapFileSize )
{
	// Prepare the map if necessary
	PublishedFileId_t nWorkshopID = MapIDFromName( pszMapName );
	if ( nWorkshopID == k_PublishedFileIdInvalid )
	{
		return;
	}

	// If we are a dedicated server, we're using the special steam gameserver UGC context, and need to make sure
	// we're logged in first.
	if ( engine->IsDedicatedServer() )
	{
		if ( !steamgameserverapicontext || !steamgameserverapicontext->SteamGameServer() )
		{
			TFWorkshopWarning( "No steam connection in PrepareLevelResources, workshop map loads will fail\n" );
			return;
		}

		// Wait for login to finish, which is async and may not be done yet on initial map load
		if ( !steamgameserverapicontext->SteamGameServer()->BLoggedOn() )
		{
			TFWorkshopMsg( "Waiting for steam connection\n" );
			while ( !steamgameserverapicontext->SteamGameServer()->BLoggedOn() )
			{
				ThreadSleep( 10 );
			}
		}
	}

	TFWorkshopMsg( "Preparing map ID %llu\n", nWorkshopID );

	while ( AsyncPrepareLevelResources( pszMapName, nMapNameSize, pszMapFile, nMapFileSize ) == \
	        IServerGameDLL::ePrepareLevelResources_InProgress )
	{
		ThreadSleep( 10 );
		if ( engine->IsDedicatedServer() )
		{
			SteamGameServer_RunCallbacks();
		}
		else
		{
			SteamAPI_RunCallbacks();
		}
	}
}

//-----------------------------------------------------------------------------
// Purpose: Hook from ServerGameDLL to ask if we can provide a level as a workshop map
//-----------------------------------------------------------------------------
IServerGameDLL::eCanProvideLevelResult
CTFMapsWorkshop::OnCanProvideLevel( /* in/out */ char *pMapName, int nMapNameMax )
{
	// Prepare the map if necessary
	PublishedFileId_t nWorkshopID = MapIDFromName( pMapName );
	if ( nWorkshopID != k_PublishedFileIdInvalid )
	{
		auto index = m_mapMaps.Find( nWorkshopID );
		if ( index == m_mapMaps.InvalidIndex() )
		{
			// Looks like a workshop map, but it's not currently available
			return IServerGameDLL::eCanProvideLevel_Possibly;
		}

		const char *szCanonicalName = m_mapMaps[ index ]->CanonicalName();
		// A workshop map that we know about
		// Provide canonical map name if known.
		if ( szCanonicalName && szCanonicalName[0] )
		{
			V_strncpy( pMapName, szCanonicalName, nMapNameMax );
		}

		if ( m_mapMaps[ index ]->State() != CTFWorkshopMap::eState_Downloaded )
		{
			return IServerGameDLL::eCanProvideLevel_Possibly;
		}

		AssertMsg( !GetWorkshopUGC() || m_mapMaps[ index ]->Downloaded(), "Map in state Downloaded isn't" );

		// Should have canonical name if it is downloaded
		if ( !szCanonicalName || !szCanonicalName[0] )
		{
			TFWorkshopWarning( "Map is marked available but has no proper name configured [ %llu ]\n", nWorkshopID );
			return IServerGameDLL::eCanProvideLevel_Possibly;
		}
		return IServerGameDLL::eCanProvideLevel_CanProvide;
	}

	return IServerGameDLL::eCanProvideLevel_CannotProvide;
}

//-----------------------------------------------------------------------------
// Purpose: Hook from ServerGameDLL to tell us the steam API is alive
//-----------------------------------------------------------------------------
void CTFMapsWorkshop::GameServerSteamAPIActivated()
{
	if ( engine->IsDedicatedServer() )
	{
		Refresh();
	}
}

//-----------------------------------------------------------------------------
// Purpose: Backend for tf_workshop_map_status
//-----------------------------------------------------------------------------
void CTFMapsWorkshop::PrintStatusToConsole()
{
	// Find longest map name
	unsigned int nMapLen = 12; // minimum for column header and padding
	FOR_EACH_MAP_FAST( m_mapMaps, idx )
	{
		CUtlString mapName;
		GetMapName( m_mapMaps[idx]->FileID(), mapName );
		nMapLen = Max( nMapLen, (unsigned int)mapName.Length() );
	}

	char szHeaderFmt[128] = { 0 };
	char szLineFmt[128] = { 0 };
	V_snprintf( szHeaderFmt, sizeof( szHeaderFmt ), "%%20s  %%%us  %%12s\n", nMapLen );
	V_snprintf( szLineFmt, sizeof( szLineFmt ), "%%20llu  %%%us  %%12s\n", nMapLen );

	Msg( szHeaderFmt, "FileID", "Map Name", "Status" );
	Msg( szHeaderFmt, "---", "---", "---" );

	FOR_EACH_MAP_FAST( m_mapMaps, idx )
	{
		const CTFWorkshopMap &map = *m_mapMaps[idx];
		const char *pState = "unknown";
		switch ( map.State() )
		{
		case CTFWorkshopMap::eState_Refreshing:
			pState = "refreshing";
			break;
		case CTFWorkshopMap::eState_Error:
			pState = "error";
			break;
		case CTFWorkshopMap::eState_Downloading:
			pState = "downloading";
			break;
		case CTFWorkshopMap::eState_Downloaded:
			pState = "ready";
			break;
		}

		CUtlString mapName;
		GetMapName( map.FileID(), mapName );
		Msg( szLineFmt, map.FileID(), mapName.Get(), pState );
	}

	Msg( "%u tracked maps\n", m_mapMaps.Count() );
}

bool CTFMapsWorkshop::GetWorkshopMapDesc( uint32 uIndex, WorkshopMapDesc_t* pDesc )
{
	if ( !m_vecSubscribedMaps.IsValidIndex( uIndex ) && !m_vecLocalWorkshopMaps.IsValidIndex( uIndex ) )
		return false;

	PublishedFileId_t id = 0;
	if ( m_vecSubscribedMaps.IsValidIndex( uIndex ) )
	{
		id = m_vecSubscribedMaps[uIndex];
	}
	else
	{
		id = m_vecLocalWorkshopMaps[uIndex];
	}

	V_sprintf_safe( pDesc->szMapName, "workshop/%llu", id );
	pDesc->uTimestamp  = 0;
	pDesc->bDownloaded = false;
	
	auto index = m_mapMaps.Find( id );
	if ( index != m_mapMaps.InvalidIndex() )
	{
		const char* pszOriginalName = m_mapMaps[index]->OriginalName();
		if ( !pszOriginalName )
			pszOriginalName = pDesc->szMapName;

		V_strcpy_safe( pDesc->szOriginalMapName, pszOriginalName );
		V_StripExtension( pDesc->szOriginalMapName, pDesc->szOriginalMapName, sizeof( pDesc->szOriginalMapName ) );
		pDesc->uTimestamp  = m_mapMaps[ index ]->TimeUpdated();
		pDesc->bDownloaded = m_mapMaps[ index ]->Downloaded();
	}

	return true;
}

//-----------------------------------------------------------------------------
bool CTFMapsWorkshop::CanonicalNameForMap( PublishedFileId_t fileID, const CUtlString &originalFileName, /* out */ CUtlString &strCanonName )
{
	if ( !IsValidOriginalFileNameForMap( originalFileName ) )
	{
		TFWorkshopWarning( "Invalid workshop map name %llu [ %s ]\n", fileID, originalFileName.Get() );
		return false;
	}

	// cp_mymap.bsp -> workshop/cp_mymap.ugc12345
	char szBase[MAX_PATH];
	V_FileBase( originalFileName.Get(), szBase, sizeof( szBase ) );

	int len = strCanonName.Format( "workshop/%s.ugc%llu", szBase, fileID );
	if ( len >= MAX_PATH )
	{
		Assert( len < MAX_PATH );
		// This should be caught by the name validator but
		return false;
	}

	return true;
}

//-----------------------------------------------------------------------------
CTFMapsWorkshop::eNameType CTFMapsWorkshop::GetMapName( PublishedFileId_t nMapID, /* out */ CUtlString &mapName )
{
	auto index = m_mapMaps.Find( nMapID );
	if ( index != m_mapMaps.InvalidIndex() )
	{
		const char *pCanonName = m_mapMaps[ index ]->CanonicalName();
		if ( pCanonName )
		{
			mapName = pCanonName;
			return CTFMapsWorkshop::eName_Canon;
		}
	}

	// Default stub name
	mapName.Format( "workshop/%llu", nMapID );
	return CTFMapsWorkshop::eName_Incomplete;
}

//-----------------------------------------------------------------------------
CTFWorkshopMap *CTFMapsWorkshop::FindMapByName( const char *pMapName )
{
	PublishedFileId_t nWorkshopID = MapIDFromName( pMapName );
	if ( nWorkshopID != k_PublishedFileIdInvalid )
	{
		auto index = m_mapMaps.Find( nWorkshopID );
		if ( index != m_mapMaps.InvalidIndex() )
		{
			return m_mapMaps[ index ];
		}
	}

	return NULL;
}

//-----------------------------------------------------------------------------
CTFWorkshopMap *CTFMapsWorkshop::FindOrCreateMapByName( const char *pMapName )
{
	PublishedFileId_t nWorkshopID = MapIDFromName( pMapName );
	if ( nWorkshopID != k_PublishedFileIdInvalid )
	{
		auto index = m_mapMaps.Find( nWorkshopID );
		if ( index != m_mapMaps.InvalidIndex() )
		{
			return m_mapMaps[ index ];
		}

		// Not found, but valid-looking workshop name, create
		CTFWorkshopMap *pMap = new CTFWorkshopMap( nWorkshopID );
		m_mapMaps.Insert( nWorkshopID, pMap );
		return pMap;
	}

	return NULL;
}

//-----------------------------------------------------------------------------
// Purpose: Synchronously prepare a map for use, assuming it has been subscribed to
//-----------------------------------------------------------------------------
PublishedFileId_t CTFMapsWorkshop::MapIDFromName( CUtlString localMapName )
{
	localMapName.ToLower();
	const char szWorkshopPrefix[] = "workshop/";

	if ( localMapName.Slice( 0, sizeof( szWorkshopPrefix ) - 1 ) != szWorkshopPrefix )
	{
		TFWorkshopDebug( "Map '%s' does not appear to be a workshop map -- no workshop/ prefix\n", localMapName.Get() );
		return k_PublishedFileIdInvalid;
	}

	// Check canonical format: workshop/cp_anyname.ugc1234
	// Find .ugc, ensure its followed by a number
	const char szUGCSuffix[] = ".ugc";
	const size_t nSuffixLen = sizeof( szUGCSuffix ) - 1;

	CUtlString strID;

	char *pszUGCSuffix = V_strstr( localMapName.Get(), szUGCSuffix );
	if ( pszUGCSuffix && strlen( pszUGCSuffix ) >= nSuffixLen + 1 )
	{
		// Need at least five for ".ugc1"
		strID = pszUGCSuffix + nSuffixLen;

		// Check that the name string is at least a valid workshop map name. It doesn't have to match the real name,
		// since IDs can update their display name at arbitrary points, but "workshop/\n\n\x1.ugc5" should not parse as
		// a valid alias for workshop/5
		CUtlString baseMapName = localMapName.Slice( sizeof( szWorkshopPrefix ) - 1,
		                                             (int32)((intptr_t)pszUGCSuffix - (intptr_t)localMapName.Get()) );
		if ( !IsValidDisplayNameForMap( baseMapName ) )
		{
			TFWorkshopDebug( "Map '%s' looks like a workshop map, but '%s' is not a legal workshop map name\n",
			                 localMapName.Get(), baseMapName.Get() );
			return k_PublishedFileIdInvalid;
		}
	}
	else
	{
		// Assume workshop/12345 shorthand, we'll fail if we hit a non-number parsing it
		strID = localMapName.Slice( sizeof( szWorkshopPrefix ) - 1 );
	}

	int i;
	for ( i = 0; i < strID.Length(); i ++ )
	{
		if ( strID[i] < '0' || strID[i] > '9' )
		{
			break;
		}
	}

	if ( i != strID.Length() )
	{
		return k_PublishedFileIdInvalid;
	}

	// Found ID and it was all numbers, sscanf it
	PublishedFileId_t nMapID = k_PublishedFileIdInvalid;
	sscanf( strID.Get(), "%llu", &nMapID );
	return nMapID;
}

//-----------------------------------------------------------------------------
// Purpose: Add this map to our list for this session, triggering download/etc as if it were subscribed
//-----------------------------------------------------------------------------
bool CTFMapsWorkshop::AddMap( PublishedFileId_t nMapID )
{
	unsigned int nIndex = m_mapMaps.Find( nMapID );
	if ( nIndex == m_mapMaps.InvalidIndex() )
	{
		m_mapMaps.Insert( nMapID, new CTFWorkshopMap( nMapID ) );
		return true;
	}

	return false;
}

// From https://github.com/ValveSoftware/source-sdk-2013/pull/1510
static const char* GetSteamInstallationPath()
{
	// Steam path to pass over
	static char szSteamPath[1024] = {};
#ifdef WIN32
	// Open the registry to look for the Steam installation.
	HKEY hKey = nullptr;
	LSTATUS status = RegOpenKeyEx(
		HKEY_CURRENT_USER,
		TEXT("SOFTWARE\\Valve\\Steam"),
		0,
		KEY_READ,
		&hKey);

	// Check result
	if ( status != ERROR_SUCCESS )
		return nullptr;

	// Query the SteamPath key
	char szPathBuf[1024] = {};
	DWORD dwBufSize = sizeof( szPathBuf );
	DWORD dwType = 0;
	LSTATUS result = RegQueryValueEx(
		hKey,
		"SteamPath",
		NULL,
		&dwType,
		reinterpret_cast<BYTE*>( szPathBuf ),
		&dwBufSize);

	// check for the result
	if ( result != ERROR_SUCCESS )
		return nullptr;

	// Close the registry key, we're done with it
	RegCloseKey( hKey );

	// Put this in the steam path var.
	Q_strncpy( szSteamPath, szPathBuf, sizeof( szSteamPath ) );
#else
	// No registry on Linux, look for the symlink.
	const char* pszHomeDir = getenv("HOME");
	const char* pszSteamPath = "/.steam/steam";
	Q_snprintf( szSteamPath, sizeof( szSteamPath ), "%s%s", pszHomeDir, pszSteamPath );
#endif // WIN32 ELSE !WIN32
	return szSteamPath;
}

KeyValues* ReadVDFKeyValuesFile( const char* pFilename )
{
	// Read in the gameinfo.txt file and null-terminate it.
	FILE* fp = fopen( pFilename, "rb" );
	if ( !fp )
		return NULL;
	CUtlVector<char> buf;
	fseek( fp, 0, SEEK_END );
	buf.SetSize( ftell( fp ) + 1 );
	fseek( fp, 0, SEEK_SET );
	fread( buf.Base(), 1, buf.Count() - 1, fp );
	fclose( fp );
	buf[ buf.Count() - 1 ] = 0;

	KeyValues* kv = new KeyValues( "" );
	if ( !kv->LoadFromBuffer( pFilename, buf.Base() ) )
	{
		kv->deleteThis();
		return NULL;
	}

	return kv;
}

// Based on https://github.com/ValveSoftware/source-sdk-2013/pull/1510
static KeyValues* GetAppWorkshopManifest( int nAppID )
{
	// First, get the Steam installation.
	char szSteamPath[1024] = {};
	V_strncpy( szSteamPath, GetSteamInstallationPath(), sizeof( szSteamPath ) );
	if ( !szSteamPath || szSteamPath[0] == '\0' )
		return nullptr;

	// Second, go to the libraryfolders.vdf and look if the appid is in them.
	char szLibraryFoldersFile[1024] = {};
	V_snprintf( szLibraryFoldersFile, sizeof( szLibraryFoldersFile ), "%s%s", szSteamPath, "/config/libraryfolders.vdf" );

	// NOTE: ReadKeyValuesFile already deletes the KV if it doesn't exist
	// read the libraryfolders.vdf file
	KeyValues* pRootKV = ReadVDFKeyValuesFile( szLibraryFoldersFile );
	if (!pRootKV)
		return nullptr;

	// Get a string representation of the Steam AppID passed
	char szAppID[32] = {};
	V_snprintf( szAppID, sizeof( szAppID ), "%d", nAppID );

	// Path KV
	KeyValues* pPathKV = nullptr;

	// Go thru each possible install path until we find the app.
	FOR_EACH_TRUE_SUBKEY( pRootKV, pKVPath )
	{
		// Check for the apps subkey
		KeyValues* pApps = pKVPath->FindKey( "apps" );
		if ( !pApps )
			continue;

		// Try to find the appid path
		if ( pApps->FindKey( szAppID ) )
		{
			// Okay, we found the app id key. now use the path key from the root KV
			pPathKV = pKVPath->FindKey( "path" ); // This is null checked below.
			break;
		}
	}

	// Error out if we can't find it
	if ( !pPathKV )
		return nullptr;

	// Look for the game that this mod asked for
	char szInstallationPath[1024] = {};
	// copy this string over since we're gonna delete the KV
	V_strncpy( szInstallationPath, pPathKV->GetString(), sizeof( szInstallationPath ) );
	// If it's empty somehow, error out
	if ( !szInstallationPath || szInstallationPath[0] == '\0' )
	{
		// Clear this keyvalue.
		pRootKV->deleteThis();
		pRootKV = nullptr;
		return nullptr;
	}

	// we no longer need this KV
	pRootKV->deleteThis();
	pRootKV = nullptr;

	// get the appworkshop_APPID.acf file
	char szAppManifestPath[1024] = {};
	V_snprintf( szAppManifestPath, sizeof( szAppManifestPath ), "%s%s%s.acf", szInstallationPath, "/steamapps/workshop/appworkshop_", szAppID );
	// Reuse the root pointer to open the appmanifest file
	pRootKV = ReadVDFKeyValuesFile( szAppManifestPath );
	if ( !pRootKV )
	{
		return nullptr;
	}

	// Add workshop folder path
	char szWorkshopFoldersPath[1024] = {};
	V_snprintf( szWorkshopFoldersPath, sizeof( szWorkshopFoldersPath ), "%s%s%s%s", szInstallationPath, "/steamapps/workshop/content/", szAppID, "/" );
	pRootKV->SetString( "ws", szWorkshopFoldersPath );

	return pRootKV;
}

// From https://github.com/ValveSoftware/source-sdk-2013/pull/1510
static const char* GetAppInstallDirNoSteam( int nAppID )
{
	// First, get the Steam installation.
	char szSteamPath[1024] = {};
	V_strncpy( szSteamPath, GetSteamInstallationPath(), sizeof( szSteamPath ) );
	if ( !szSteamPath || szSteamPath[0] == '\0' )
		return nullptr;

	// Second, go to the libraryfolders.vdf and look if the appid is in them.
	char szLibraryFoldersFile[1024] = {};
	V_snprintf( szLibraryFoldersFile, sizeof( szLibraryFoldersFile ), "%s%s", szSteamPath, "/config/libraryfolders.vdf" );

	// NOTE: ReadKeyValuesFile already deletes the KV if it doesn't exist
	// read the libraryfolders.vdf file
	KeyValues* pRootKV = ReadVDFKeyValuesFile( szLibraryFoldersFile );
	if ( !pRootKV )
		return nullptr;

	// Get a string representation of the Steam AppID passed
	char szAppID[32] = {};
	V_snprintf( szAppID, sizeof( szAppID ), "%d", nAppID );

	// Path KV
	KeyValues* pPathKV = nullptr;

	// Go thru each possible install path until we find the app.
	FOR_EACH_TRUE_SUBKEY( pRootKV, pKVPath )
	{
		// Check for the apps subkey
		KeyValues* pApps = pKVPath->FindKey( "apps" );
		if ( !pApps )
			continue;

		// Try to find the appid path
		if ( pApps->FindKey( szAppID ) )
		{
			// Okay, we found the app id key. now use the path key from the root KV
			pPathKV = pKVPath->FindKey( "path" ); // This is null checked below.
			break;
		}
	}

	// Error out if we can't find it
	if ( !pPathKV )
		return nullptr;

	// Look for the game that this mod asked for
	char szInstallationPath[1024] = {};
	// copy this string over since we're gonna delete the KV
	V_strncpy( szInstallationPath, pPathKV->GetString(), sizeof( szInstallationPath ) );
	// If it's empty somehow, error out
	if ( !szInstallationPath || szInstallationPath[0] == '\0' )
	{
		// Clear this keyvalue.
		pRootKV->deleteThis();
		pRootKV = nullptr;
		return nullptr;
	}

	// we no longer need this KV
	pRootKV->deleteThis();
	pRootKV = nullptr;

	// get the appmanifest_APPID.acf file
	char szAppManifestPath[1024] = {};
	V_snprintf( szAppManifestPath, sizeof( szAppManifestPath ), "%s%s%s.acf", szInstallationPath, "/steamapps/appmanifest_", szAppID );
	// Reuse the root pointer to open the appmanifest file
	pRootKV = ReadVDFKeyValuesFile( szAppManifestPath );

	// Error out if this file can't be found
	if ( !pRootKV )
		return nullptr;

	// Find the install dir
	KeyValues* pInstallDirKV = pRootKV->FindKey( "installdir" );

	// Error out if we can't find this key
	if ( !pInstallDirKV )
		return nullptr;

	// Get the game name to get it from the common dir.
	// Again, deleting the KV after this
	char szGameName[256] = {};
	V_strncpy( szGameName, pInstallDirKV->GetString(), sizeof( szGameName ) );

	if ( !szGameName || szGameName[0] == '\0' )
		return nullptr;

	// Not needed anymore
	pRootKV->deleteThis();
	pRootKV = nullptr;

	// Now that we got everything, put it all together
	static char szAbsoluteGameDirPath[1024] = {};
	V_snprintf( szAbsoluteGameDirPath, sizeof( szAbsoluteGameDirPath ), "%s%s%s", szInstallationPath, "/steamapps/common/", szGameName );

	// Fix the slashes before passing it
	V_FixDoubleSlashes( szAbsoluteGameDirPath );
	V_FixSlashes( szAbsoluteGameDirPath );
	return szAbsoluteGameDirPath;
}

//-----------------------------------------------------------------------------
// Purpose: Update
//-----------------------------------------------------------------------------
void CTFMapsWorkshop::UpdateLocalTF2WorkshopCache()
{
	TFWorkshopDebug( "UpdateLocalTF2Cache\n" );
	KeyValuesAD cachefile( "workshop" );

	KeyValues* TF2_KV = GetAppWorkshopManifest( 440 );
	KeyValues* TF2_GR_KV = NULL; //GetAppWorkshopManifest( 3826520 );
	KeyValues* CF_KV = NULL; //GetAppWorkshopManifest( 3768450 );
	//const char* TF2C_Path = GetAppInstallDirNoSteam( 3545060 );
	//KeyValues* TF2C_W_KV = GetAppWorkshopManifest( 3545060 );
	if ( !TF2_KV )
	{
		TFWorkshopMsg( "TF2 workshop manifest not found\n" );
	}
	if ( !TF2_KV && !TF2_GR_KV && !CF_KV )
	{
		cachefile->SaveToFile( g_pFullFileSystem, "workshop_localcache.txt", "GAME" );
		return;
	}

	int mapCount = 0;
	m_vecLocalWorkshopMaps.RemoveAll();

	// TF2 Workshop
	if ( TF2_KV )
	{
		const char* rootPath = TF2_KV->GetString( "ws" );

		KeyValues* items = TF2_KV->FindKey( "WorkshopItemsInstalled" );
		if ( !items )
		{
			TFWorkshopMsg( "TF2 workshop manifest parse error\n" );
			cachefile->SaveToFile( g_pFullFileSystem, "workshop_localcache.txt", "GAME" );
			return;
		}

		KeyValues* key = items->GetFirstSubKey();
		while ( key )
		{
			const char* itemID = key->GetName();

			FileFindHandle_t hFind = NULL;
			const char* pszSearch = CFmtStr( "%s%s/*.bsp", rootPath, itemID );
			const char* pszRootFolder = CFmtStr( "%s%s/", rootPath, itemID );
			char const* szFileName = g_pFullFileSystem->FindFirstEx( pszSearch, "GAME", &hFind );
			while ( szFileName )
			{
				// Map file found, let's add it to the map list
				PublishedFileId_t fileID = V_atoui64( itemID );
				m_vecLocalWorkshopMaps.AddToTail( (uint64)itemID );
				if ( m_mapMaps.Find( fileID ) == m_mapMaps.InvalidIndex() )
				{
					CTFWorkshopMap* newMap = new CTFWorkshopMap( fileID, true );
					newMap->m_strMapName = V_strdup( szFileName );
					newMap->m_strCanonicalName = V_strdup( szFileName );
					CanonicalNameForMap( fileID, szFileName, newMap->m_strCanonicalName );
					newMap->m_strLocalFolder = V_strdup( pszRootFolder );
					m_mapMaps.Insert( fileID, newMap );
					cachefile->SetString( itemID, CFmtStr( "%s%s", pszRootFolder, szFileName ) );
				}

				mapCount++;
				szFileName = g_pFullFileSystem->FindNext( hFind );
			}

			g_pFullFileSystem->FindClose( hFind );
			key = key->GetNextKey();
		}
	}

	// TF2: Gold Rush Workshop
	if ( TF2_GR_KV )
	{
		const char* rootPath = TF2_GR_KV->GetString( "ws" );

		KeyValues* items = TF2_GR_KV->FindKey( "WorkshopItemsInstalled" );
		if ( !items )
		{
			TFWorkshopMsg( "TF2GR workshop manifest parse error\n" );
			cachefile->SaveToFile( g_pFullFileSystem, "workshop_localcache.txt", "GAME" );
			return;
		}

		KeyValues* key = items->GetFirstSubKey();
		while ( key )
		{
			const char* itemID = key->GetName();

			FileFindHandle_t hFind = NULL;
			const char* pszSearch = CFmtStr( "%s%s/*.bsp", rootPath, itemID );
			const char* pszRootFolder = CFmtStr( "%s%s/", rootPath, itemID );
			char const* szFileName = g_pFullFileSystem->FindFirstEx( pszSearch, "GAME", &hFind );
			while ( szFileName )
			{
				// Map file found, let's add it to the map list
				PublishedFileId_t fileID = V_atoui64( itemID );
				m_vecLocalWorkshopMaps.AddToTail( (uint64)itemID );
				if ( m_mapMaps.Find( fileID ) == m_mapMaps.InvalidIndex() )
				{
					CTFWorkshopMap* newMap = new CTFWorkshopMap( fileID, true );
					newMap->m_strMapName = V_strdup( szFileName );
					newMap->m_strCanonicalName = V_strdup( szFileName );
					CanonicalNameForMap( fileID, szFileName, newMap->m_strCanonicalName );
					newMap->m_strLocalFolder = V_strdup( pszRootFolder );
					m_mapMaps.Insert( fileID, newMap );
					cachefile->SetString( itemID, CFmtStr( "%s%s", pszRootFolder, szFileName ) );
				}

				mapCount++;
				szFileName = g_pFullFileSystem->FindNext( hFind );
			}

			g_pFullFileSystem->FindClose( hFind );
			key = key->GetNextKey();
		}
	}

	// Custom Fortress Workshop
	if ( CF_KV )
	{
		const char* rootPath = CF_KV->GetString( "ws" );

		KeyValues* items = CF_KV->FindKey( "WorkshopItemsInstalled" );
		if ( !items )
		{
			TFWorkshopMsg( "CF workshop manifest parse error\n" );
			cachefile->SaveToFile( g_pFullFileSystem, "workshop_localcache.txt", "GAME" );
			return;
		}

		KeyValues* key = items->GetFirstSubKey();
		while ( key )
		{
			const char* itemID = key->GetName();

			FileFindHandle_t hFind = NULL;
			const char* pszSearch = CFmtStr( "%s%s/maps/*.bsp", rootPath, itemID );
			const char* pszRootFolder = CFmtStr( "%s%s/maps/", rootPath, itemID );
			char const* szFileName = g_pFullFileSystem->FindFirstEx( pszSearch, "GAME", &hFind );
			while ( szFileName )
			{
				// Map file found, let's add it to the map list
				PublishedFileId_t fileID = V_atoui64( itemID );
				m_vecLocalWorkshopMaps.AddToTail( (uint64)itemID );
				if ( m_mapMaps.Find( fileID ) == m_mapMaps.InvalidIndex() )
				{
					CTFWorkshopMap* newMap = new CTFWorkshopMap( fileID, true );
					newMap->m_strMapName = V_strdup( szFileName );
					newMap->m_strCanonicalName = V_strdup( szFileName );
					CanonicalNameForMap( fileID, szFileName, newMap->m_strCanonicalName );
					newMap->m_strLocalFolder = V_strdup( pszRootFolder );
					m_mapMaps.Insert( fileID, newMap );
					cachefile->SetString( itemID, CFmtStr( "%s%s", pszRootFolder, szFileName ) );
				}

				mapCount++;
				szFileName = g_pFullFileSystem->FindNext( hFind );
			}

			g_pFullFileSystem->FindClose( hFind );
			key = key->GetNextKey();
		}
	}

	// TF2 Classified
	/*
	if ( TF2C_Path && TF2C_Path[0] )
	{
		static char szMapsPath[1024] = {};
		V_snprintf( szMapsPath, sizeof( szMapsPath ), "%s%s", TF2C_Path, "/tf2classified/maps/" );

		FileFindHandle_t hFind = NULL;
		const char* pszSearch = CFmtStr( "%s*.bsp", szMapsPath );
		const char* pszRootFolder = CFmtStr( "%s", szMapsPath );
		char const* szFileName = g_pFullFileSystem->FindFirstEx( pszSearch, "GAME", &hFind );
		while ( szFileName )
		{
			// Map file found, let's add it to the map list
			const char* pszMapID = CFmtStr( "%s%s", "tf2c_", szFileName );
			m_vecLocalModMaps.AddToTail( V_strdup( pszMapID ) );

			CTFWorkshopMap* newMap = new CTFWorkshopMap( true );
			newMap->m_strMapName = V_strdup( szFileName );
			newMap->m_strCanonicalName = V_strdup( szFileName );
			//CanonicalNameForMap( fileID, szFileName, newMap->m_strCanonicalName );
			newMap->m_strLocalFolder = V_strdup( pszRootFolder );
			m_mapMaps.Insert( fileID, newMap );
			cachefile->SetString( pszMapID, CFmtStr( "%s%s", pszRootFolder, szFileName ) );

			mapCount++;
			szFileName = g_pFullFileSystem->FindNext( hFind );
		}

		g_pFullFileSystem->FindClose( hFind );
	}
	*/

	// TF2 Classified Workshop
	//if ( TF2C_W_KV )
	//{
	//}

	TFWorkshopMsg( "Local workshop maps found: %u\n", mapCount );
	cachefile->SaveToFile( g_pFullFileSystem, "workshop_localcache.txt", "GAME" );
}

//-----------------------------------------------------------------------------
// Purpose: Update
//-----------------------------------------------------------------------------
void CTFMapsWorkshop::UpdateLocalSFMWorkshopCache()
{
	if ( !sv_workshop_mount_sfm.GetBool() )
		return;

	TFWorkshopDebug ( "UpdateLocalSFMCache\n" );

	const char* SFM_Path = GetAppInstallDirNoSteam( 1840 );
	if ( !SFM_Path || !SFM_Path[0] )
	{
		TFWorkshopMsg( "SFM install path not found\n" );
		return;
	}

	static char szWorkshopPath[1024] = {};
	V_snprintf( szWorkshopPath, sizeof( szWorkshopPath ), "%s%s", SFM_Path, "/game/workshop/" );
	if ( g_pFullFileSystem->IsDirectory( szWorkshopPath ) )
	{
		g_pFullFileSystem->AddSearchPath( szWorkshopPath, "GAME" );
	}

	TFWorkshopMsg( "SFM workshop content mounted.\n" );
}

//-----------------------------------------------------------------------------
// Purpose: Command to trigger refresh
//-----------------------------------------------------------------------------
CON_COMMAND( tf_workshop_refresh, "tf_workshop_refresh" )
{
#ifdef GAME_DLL
	if ( !UTIL_IsCommandIssuedByServerAdmin() )
		return;
#endif

	if ( args.ArgC() != 1 )
	{
		TFWorkshopMsg( "Usage: tf_workshop_refresh - Trigger a recheck subscriptions and tracked maps\n" );
		return;
	}

	TFWorkshopMsg( "Requesting maps refresh\n" );
	g_TFMapsWorkshop.Refresh();
}

//-----------------------------------------------------------------------------
// Purpose: Command to sync prepare map
//-----------------------------------------------------------------------------
CON_COMMAND( tf_workshop_map_sync, "Add a map to the workshop auto-sync list" )
{
#ifdef GAME_DLL
	if ( !UTIL_IsCommandIssuedByServerAdmin() )
		return;
#endif

	PublishedFileId_t nTargetID = 0;
	if ( args.ArgC() == 2 )
	{
		sscanf( args[1], "%llu", &nTargetID );
	}

	if ( !nTargetID )
	{
		TFWorkshopMsg( "Usage: tf_workshop_map_sync <map ugc id> - Add a map to the workshop auto-sync list\n" );
		return;
	}

	if ( g_TFMapsWorkshop.AddMap( nTargetID ) )
	{
		TFWorkshopMsg( "Added %llu to tracked maps\n", nTargetID );
	}
	else
	{
		TFWorkshopMsg( "Map %llu is already tracked\n", nTargetID );
	}
}

CON_COMMAND( tf_workshop_map_status, "Print information about workshop maps and their status" )
{
#ifdef GAME_DLL
	if ( !UTIL_IsCommandIssuedByServerAdmin() )
		return;
#endif

	g_TFMapsWorkshop.PrintStatusToConsole();
}

#endif // !_GAMECONSOLE
