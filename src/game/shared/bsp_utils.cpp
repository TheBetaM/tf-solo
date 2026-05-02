//========= Copyright Valve Corporation, All rights reserved. ============//
//
// Purpose: Exposes bsp tools to game for e.g. workshop use
//
// $NoKeywords: $
//===========================================================================//

#include "cbase.h"
#include <tier2/tier2.h>
#include <tier1/utlhashtable.h>
#include "filesystem.h"
#include "bsp_utils.h"
#include "utlbuffer.h"
#include "igamesystem.h"
#include "workshop/ugc_utils.h"
#include "../public/zip_utils.h"
#include "../public/zip_utils.cpp"
#include "bspfile.h"
#ifdef CLIENT_DLL
#include "tier1/lzmaDecoder.h"
#include "lzma/lzma.h"
#endif

// memdbgon must be the last include file in a .cpp file!!!
#include "tier0/memdbgon.h"

#ifdef CLIENT_DLL
bool BSP_SyncRepack( const char *pszInputMapFile,
                     const char *pszOutputMapFile,
                     IBSPPack::eRepackBSPFlags eRepackFlags )
{
	// load the bsppack dll
	IBSPPack *libBSPPack = NULL;
	CSysModule *pModule = g_pFullFileSystem->LoadModule( "bsppack" );
	if ( pModule )
	{
		CreateInterfaceFn BSPPackFactory = Sys_GetFactory( pModule );
		if ( BSPPackFactory )
		{
			libBSPPack = ( IBSPPack * )BSPPackFactory( IBSPPACK_VERSION_STRING, NULL );
		}
	}
	if( !libBSPPack )
	{
		Warning( "Can't load bsppack library - unable to compress bsp\n" );
		return false;
	}

	Msg( "Repacking %s -> %s\n", pszInputMapFile, pszOutputMapFile );

	if ( !g_pFullFileSystem->FileExists( pszInputMapFile ) )
	{
		Warning( "Couldn't open input file %s - BSP recompress failed\n", pszInputMapFile );
		return false;
	}

	CUtlBuffer inputBuffer;
	if ( !g_pFullFileSystem->ReadFile( pszInputMapFile, NULL, inputBuffer ) )
	{
		Warning( "Couldn't read file %s - BSP compression failed\n", pszInputMapFile );
		return false;
	}

	CUtlBuffer outputBuffer;

	if ( !libBSPPack->RepackBSP( inputBuffer, outputBuffer, eRepackFlags ) )
	{
		Warning( "Internal error compressing BSP\n" );
		return false;
	}

	g_pFullFileSystem->WriteFile( pszOutputMapFile, NULL, outputBuffer );

	Msg( "Successfully repacked %s as %s -- %u -> %u bytes\n",
	     pszInputMapFile, pszOutputMapFile, inputBuffer.TellPut(), outputBuffer.TellPut() );

	return true;
}

// Helper to create a thread that calls SyncCompressMap, and clean it up when it exists
void BSP_BackgroundRepack( const char *pszInputMapFile,
                           const char *pszOutputMapFile,
                           IBSPPack::eRepackBSPFlags eRepackFlags )
{
	// Make this a gamesystem and thread, so it can check for completion each frame and clean itself up. Run() is the
	// background thread, Update() is the main thread tick.
	class BackgroundBSPRepackThread : public CThread, public CAutoGameSystemPerFrame
	{
	public:
		BackgroundBSPRepackThread( const char *pszInputFile, const char *pszOutputFile, IBSPPack::eRepackBSPFlags eRepackFlags )
			: m_strInput( pszInputFile )
			, m_strOutput( pszOutputFile )
			, m_eRepackFlags( eRepackFlags )
		{
			Start();
		}

		// CThread job - returns 0 for success
		virtual int Run() OVERRIDE
		{
			return BSP_SyncRepack( m_strInput.Get(), m_strOutput.Get(), m_eRepackFlags ) ? 0 : 1;
		}

		// GameSystem
		virtual const char* Name( void ) OVERRIDE { return "BackgroundBSPRepackThread"; }

		// Runs on main thread
		void CheckFinished()
		{
			if ( !IsAlive() )
			{
				// Thread finished
				if ( GetResult() != 0 )
				{
					Warning( "Map compression thread failed :(\n" );
				}

				// AutoGameSystem deregisters itself on destruction, we're done
				delete this;
			}
		}

		#ifdef CLIENT_DLL
		virtual void Update( float frametime ) OVERRIDE { CheckFinished(); }
        #else // GAME DLL
		virtual void FrameUpdatePostEntityThink() OVERRIDE { CheckFinished(); }
		#endif
	private:
		CUtlString                m_strInput;
		CUtlString                m_strOutput;
		IBSPPack::eRepackBSPFlags m_eRepackFlags;
	};

	Msg( "Starting BSP repack job %s -> %s\n", pszInputMapFile, pszOutputMapFile );

	// Deletes itself up when done
	new BackgroundBSPRepackThread( pszInputMapFile, pszOutputMapFile, eRepackFlags );
}

CON_COMMAND( bsp_repack, "Repack and output a (re)compressed version of a bsp file" )
{
	// Handle -nocompress
	bool bCompress = true;
	const char *szInFilename = NULL;
	const char *szOutFilename = NULL;

	if ( args.ArgC() == 4 && V_strcasecmp( args.Arg( 1 ), "-nocompress" ) == 0 )
	{
		bCompress = false;
		szInFilename = args.Arg( 2 );
		szOutFilename = args.Arg( 3 );
	}
	else if ( args.ArgC() == 3 )
	{
		szInFilename = args.Arg( 1 );
		szOutFilename = args.Arg( 2 );
	}

	if ( !szInFilename || !szOutFilename || !strlen( szInFilename ) || !strlen( szOutFilename ) )
	{
		Msg( "Usage: bsp_repack [-nocompress] map.bsp output_map.bsp\n" );
		return;
	}

	if ( bCompress )
	{
		// Use default compress flags
		BSP_BackgroundRepack( szInFilename, szOutFilename );
	}
	else
	{
		// No compression
		BSP_BackgroundRepack( szInFilename, szOutFilename, (IBSPPack::eRepackBSPFlags)0 );
	}
}
#endif

CUtlHashtable<const char*, CMemoryFileBacking*> g_bspMemoryFiles;

inline bool IsValidDisplayNameForMap(const CUtlString& originalName)
{
	// Matching: ([a-z0-9]+_)*[a-z0-9]

	int len = originalName.Length();
	const unsigned int nMaxDisplayName = MAX_DISPLAY_MAP_NAME;
	if (len < 2 || len > nMaxDisplayName)
	{
		Warning("Map display name must be at least 2 characters and not more than %u characters\n", nMaxDisplayName);
		return false;
	}

	for (int i = 0; i < len; i++)
	{
		char c = originalName[i];
		if (!(c >= 'a' && c <= 'z') && !(c >= '0' && c <= '9') && c != '_')
		{
			Warning("Invalid character %c in map name\n", c);
			return false;
		}

		if (c == '_' && (i == 0 || i == len - 1 || originalName[i - 1] == '_'))
		{
			Warning("Invalid map name: _ cannot appear consecutively nor at the beginning/end of a map name\n");
			return false;
		}
	}

	return true;
}

PublishedFileId_t MapIDFromName(CUtlString localMapName)
{
	localMapName.ToLower();
	const char szWorkshopPrefix[] = "workshop/";

	if (localMapName.Slice(0, sizeof(szWorkshopPrefix) - 1) != szWorkshopPrefix)
	{
		//Msg("Map '%s' does not appear to be a workshop map -- no workshop/ prefix\n", localMapName.Get());
		return k_PublishedFileIdInvalid;
	}

	// Check canonical format: workshop/cp_anyname.ugc1234
	// Find .ugc, ensure its followed by a number
	const char szUGCSuffix[] = ".ugc";
	const size_t nSuffixLen = sizeof(szUGCSuffix) - 1;

	CUtlString strID;

	char* pszUGCSuffix = V_strstr(localMapName.Get(), szUGCSuffix);
	if (pszUGCSuffix && strlen(pszUGCSuffix) >= nSuffixLen + 1)
	{
		// Need at least five for ".ugc1"
		strID = pszUGCSuffix + nSuffixLen;

		// Check that the name string is at least a valid workshop map name. It doesn't have to match the real name,
		// since IDs can update their display name at arbitrary points, but "workshop/\n\n\x1.ugc5" should not parse as
		// a valid alias for workshop/5
		CUtlString baseMapName = localMapName.Slice(sizeof(szWorkshopPrefix) - 1,
			(int32)((intptr_t)pszUGCSuffix - (intptr_t)localMapName.Get()));
		if (!IsValidDisplayNameForMap(baseMapName))
		{
			Msg("Map '%s' looks like a workshop map, but '%s' is not a legal workshop map name\n",
				localMapName.Get(), baseMapName.Get());
			return k_PublishedFileIdInvalid;
		}
	}
	else
	{
		// Assume workshop/12345 shorthand, we'll fail if we hit a non-number parsing it
		strID = localMapName.Slice(sizeof(szWorkshopPrefix) - 1);
	}

	int i;
	for (i = 0; i < strID.Length(); i++)
	{
		if (strID[i] < '0' || strID[i] > '9')
		{
			break;
		}
	}

	if (i != strID.Length())
	{
		return k_PublishedFileIdInvalid;
	}

	// Found ID and it was all numbers, sscanf it
	PublishedFileId_t nMapID = k_PublishedFileIdInvalid;
	sscanf(strID.Get(), "%llu", &nMapID);
	return nMapID;
}

inline bool IsValidOriginalFileNameForMap(const CUtlString& originalName)
{
	// Matching: ([a-z0-9]+_)*[a-z0-9]\.bsp

	int len = originalName.Length();
	const unsigned int nMaxFileName = MAX_DISPLAY_MAP_NAME + 4; // Map minus extension must be within MAX_DISPLAY_MAP_NAME
	if (len < 6 || len > nMaxFileName || originalName.Slice(len - 4) != ".bsp")
	{
		Warning("Map filename must be at least 6 characters and not more than %u characters ending in .bsp\n", nMaxFileName);
		return false;
	}

	CUtlString baseName = originalName.Slice(0, len - 4);
	return IsValidDisplayNameForMap(baseName);
}

bool CanonicalNameForMap(PublishedFileId_t fileID, const CUtlString& originalFileName, /* out */ CUtlString& strCanonName)
{
	if (!IsValidOriginalFileNameForMap(originalFileName))
	{
		Warning("Invalid workshop map name %llu [ %s ]\n", fileID, originalFileName.Get());
		return false;
	}

	// cp_mymap.bsp -> workshop/cp_mymap.ugc12345
	char szBase[MAX_PATH];
	V_FileBase(originalFileName.Get(), szBase, sizeof(szBase));

	int len = strCanonName.Format("workshop/%s.ugc%llu", szBase, fileID);
	if (len >= MAX_PATH)
	{
		Assert(len < MAX_PATH);
		// This should be caught by the name validator but
		return false;
	}

	return true;
}

bool BackgroundBSPCacheThread::BSP_CacheAssets(const char* pszInputMapFile)
{
	PublishedFileId_t nMapID = k_PublishedFileIdInvalid;
	CUtlString localName(pszInputMapFile);
	localName.ToLower();
	nMapID = MapIDFromName(localName);
	m_nFileID = nMapID;

	if (nMapID == k_PublishedFileIdInvalid)
	{
		// Local map, continue
		m_MapReadyStatus = MapReadyStatus_Ready;
	}
	else
	{
		KeyValuesAD workshopConfig( "workshop" );
		if ( !workshopConfig->LoadFromFile( g_pFullFileSystem, "workshop_localcache.txt", "GAME" ) )
		{
			Msg( "Unable to parse workshop_localcache.txt into keyvalues.\n" );
			g_bspCacheJobsRunning--;
			g_BspPackLock = false;
			return false;
		}
		char mapIDstr[MAX_PATH] = { 0 };
		Q_snprintf( mapIDstr, sizeof( mapIDstr ), "%llu", nMapID );
		if ( workshopConfig->FindKey( mapIDstr ) )
		{
			pszInputMapFile = V_strdup( workshopConfig->GetString( mapIDstr ) );
		}
		else
		{
			// Workshop map
			uint64 nUGCSize = 0;
			uint32 nTimestamp = 0;
			char szFolder[MAX_PATH * 2] = { 0 };

			m_MapReadyStatus = MapReadyStatus_FetchingUGC;

			auto steamUGC = GetSteamUGC();
			UGCQueryHandle_t ugcQuery = steamUGC->CreateQueryUGCDetailsRequest(&nMapID, 1);
			bool setMeta = steamUGC->SetReturnMetadata(ugcQuery, true);
			bool setCache = steamUGC->SetAllowCachedResponse(ugcQuery, 0);
			if (ugcQuery == k_UGCQueryHandleInvalid || !setMeta || !setCache)
			{
				Warning("Failed to create UGC details request for map [ %llu ]\n", nMapID);
				g_bspCacheJobsRunning--;
				g_BspPackLock = false;
				return false;
			}
			SteamAPICall_t hSteamAPICall = steamUGC->SendQueryUGCRequest(ugcQuery);
			m_callbackQueryUGCDetails.Set(hSteamAPICall, this, &BackgroundBSPCacheThread::Steam_OnQueryUGCDetails);

			while (m_MapReadyStatus == MapReadyStatus_FetchingUGC)
			{
				Sleep(100);
			}
			while (m_MapReadyStatus == MapReadyStatus_Downloading)
			{
				// TODO
				//Sleep(100);
				Warning("Download callback not yet implemeted\n");
				g_bspCacheJobsRunning--;
				g_BspPackLock = false;
				return false;
			}
			if (m_MapReadyStatus == MapReadyStatus_Error)
			{
				g_bspCacheJobsRunning--;
				g_BspPackLock = false;
				return false;
			}

			if (!GetSteamUGC()->GetItemInstallInfo(nMapID, &nUGCSize, szFolder, sizeof(szFolder), &nTimestamp))
			{
				Msg("BSP cache failed: GetItemInstallInfo failed for item, map not usable [ %s ]\n", m_strCanonicalName);
				g_bspCacheJobsRunning--;
				g_BspPackLock = false;
				return false;
			}

			char szFullPath[MAX_PATH * 2] = { 0 };
			V_MakeAbsolutePath(szFullPath, sizeof(szFullPath), m_strMapName, szFolder);
			pszInputMapFile = szFullPath;
		}
	}

	if (!g_pFullFileSystem->FileExists(pszInputMapFile))
	{
		Warning("BSP cache failed: Couldn't open input file %s\n", pszInputMapFile);
		g_bspCacheJobsRunning--;
		g_BspPackLock = false;
		return false;
	}

	while (g_BspPackLock)
	{
		// Too fast, too quick
		Sleep(100);
	}
	g_BspPackLock = true;

	// read the file
	FileHandle_t file = g_pFullFileSystem->Open(pszInputMapFile, "rb");
	if (!file)
	{
		Warning("BSP cache failed: Can't open map file\n");
		return false;
	}
	g_pFullFileSystem->Seek(file, 8 + (sizeof(lump_t) * LUMP_PAKFILE), FILESYSTEM_SEEK_HEAD);
	lump_t lumpHeader;
	g_pFullFileSystem->Read(&lumpHeader, sizeof(lump_t), file);
	g_pFullFileSystem->Seek(file, lumpHeader.fileofs, FILESYSTEM_SEEK_HEAD);
	byte* pakData = new unsigned char[lumpHeader.filelen];
	int pakSize = lumpHeader.filelen;
	if (pakSize == 0)
	{
		Warning("BSP cache failed: No files inside map\n");
		return false;
	}
	g_pFullFileSystem->Read(pakData, pakSize, file);
	g_pFullFileSystem->Close(file);

	// Get file from lump
	auto zip = IZip::CreateZip();
	zip->ParseFromBuffer(pakData, pakSize);

	FOR_EACH_HASHTABLE(m_FileTable, FileIter)
	{
		const char* pszInputAsset = m_FileTable.Key(FileIter);
		const char* pszOutputAsset = m_FileTable[FileIter];

		char outName[MAX_PATH * 2];
		V_strcpy_safe(outName, pszOutputAsset);
		V_StripTrailingSlash(outName);
		V_FixSlashes(outName);

		// PakFile only uses / slashes
		char inNameFix[MAX_PATH * 2];
		V_strcpy_safe(inNameFix, pszInputAsset);
		V_StripTrailingSlash(inNameFix);
		V_FixSlashes(inNameFix, '/');
		V_FixDoubleSlashes(inNameFix);
		pszInputAsset = inNameFix;

		if (g_bspMemoryFiles.HasElement(outName))
		{
			DevWarning("BSP cache: File %s already exists in cache\n", outName);
			continue;
		}
#ifndef _DEBUG
		if (g_pFullFileSystem->IsFileCacheFileLoaded(NULL, outName))
		{
			DevWarning("BSP cache: File %s already exists in internal cache\n", outName);
			continue;
		}
#endif // !_DEBUG


		if (!zip->FileExistsInZip(pszInputAsset))
		{
			Warning("BSP cache failed: Couldn't find file %s in PakFile lump\n", pszInputAsset);
			continue;
		}
		CUtlBuffer outputBuffer;
		zip->ReadFileFromZip(pszInputAsset, false, outputBuffer);
		//Msg("File size %d\n", outputBuffer.TellPut());

		// Allocate memory for the file, copy data to it
		int inFileSize = outputBuffer.TellPut();
		//void* pMemLen = MemAlloc_Alloc(sizeof(int));
		//V_memset(pMemLen, inFileSize, sizeof(int));

		void* pMem = MemAlloc_Alloc(inFileSize);
		outputBuffer.SeekGet(outputBuffer.SEEK_HEAD, 0);
		V_memcpy(pMem, outputBuffer.AccessForDirectRead(inFileSize), inFileSize);

		void* outNameMem = MemAlloc_Alloc((MAX_PATH * 2));
		V_memcpy(outNameMem, outName, (MAX_PATH * 2));

		// Add file to filesystem
		CMemoryFileBacking* memfile = g_bspMemoryFiles[g_bspMemoryFiles.Insert((const char*)outNameMem, new CMemoryFileBacking(g_pFullFileSystem))];
		CMemoryFileBacking* existingFile;
		memfile->m_nLength = inFileSize;
		memfile->m_pData = (const char*)pMem;
		memfile->m_pFileName = (const char*)outNameMem;
		if (!g_pFullFileSystem->RegisterMemoryFile(memfile, &existingFile))
		{
			DevWarning("BSP cache failed: File %s already exists in internal cache\n", outName);
			continue;
		}
	}

	IZip::ReleaseZip(zip);
	Msg("Successfully cached %s\n", pszInputMapFile);
	g_BspPackLock = false;
	g_bspCacheJobsRunning--;
	return true;
}

void BackgroundBSPCacheThread::Steam_OnQueryUGCDetails(SteamUGCQueryCompleted_t* pResult, bool bError)
{
	if (pResult->m_eResult != k_EResultOK)
	{
		bError = true;
	}

	ISteamUGC* steamUGC = GetSteamUGC();

	SteamUGCDetails_t details = { 0 };
	if (!bError && !(steamUGC->GetQueryUGCResult(pResult->m_handle, 0, &details) && details.m_eResult == k_EResultOK))
	{
		Warning("Error fetching updated information for map\n");
		bError = true;
	}

	char szMeta[k_cchDeveloperMetadataMax] = { 0 };
	if (!bError && !steamUGC->GetQueryUGCMetadata(pResult->m_handle, 0, szMeta, sizeof(szMeta)))
	{
		bError = true;
		Warning("Failed to get metadata for UGC file\n");
	}

	if (bError)
	{
		Warning("Info lookup failed for workshop file\n");
		m_MapReadyStatus = MapReadyStatus_Error;
		return;
	}

	// Succeeded, re-evalute
	m_MapReadyStatus = MapReadyStatus_Error;

	// Our workshop maps use the metadata field for the canonical map filename
	CUtlString baseName = CUtlString(szMeta);
	m_strMapName = baseName;

	if (!baseName.Length())
	{
		Warning("Tracked map has no filename and will not sync\n");
		return;
	}

	if (!CanonicalNameForMap(m_nFileID, baseName, m_strCanonicalName))
	{
		Warning("Failed to make filename for tracked map, map will not be usuable [ baseName: %s ]\n", baseName.Get());
		return;
	}

	uint32 state = steamUGC->GetItemState(m_nFileID);
	if ((state & k_EItemStateNeedsUpdate) ||
		!(state & (k_EItemStateDownloading | k_EItemStateDownloadPending | k_EItemStateInstalled)))
	{
		m_MapReadyStatus = MapReadyStatus_Downloading;
		// Either out of date or not installed, downloading, or queued to download, ask UGC to do so. The latter happens
		// for maps added not from subscriptions that have no reason for UGC to initiate downloads on its own.
		if (!steamUGC->DownloadItem(m_nFileID, true))
		{
			Warning("DownloadItem failed for file, map will not be usable [ %s ]\n", m_strCanonicalName.Get());
			return;
		}

		Msg("New version available for map, download queued [ %s ]\n", m_strCanonicalName.Get());
	}
	else
	{
		Msg("Got updated information for map [ %s ]\n", m_strCanonicalName.Get());
		m_MapReadyStatus = MapReadyStatus_Ready;
	}
}

void BSP_RemoveAssetFromCache(const char* pszAsset)
{
	char outName[MAX_PATH * 2];
	V_strcpy_safe(outName, pszAsset);
	V_StripTrailingSlash(outName);
	V_FixSlashes(outName);
	if (g_bspMemoryFiles.HasElement(outName))
	{
		auto mFileHandle = g_bspMemoryFiles.Find(outName);
		auto mFile = g_bspMemoryFiles[mFileHandle];
		g_pFullFileSystem->UnregisterMemoryFile(mFile);
		g_bspMemoryFiles.Remove(outName);
	}
}

void BSP_ClearCache()
{
	FOR_EACH_HASHTABLE(g_bspMemoryFiles, mFileHandle)
	{
		auto mFile = g_bspMemoryFiles[mFileHandle];
		g_pFullFileSystem->UnregisterMemoryFile(mFile);
	}
	g_bspMemoryFiles.RemoveAll();
}

#ifdef CLIENT_DLL
CON_COMMAND( bsp_cache, "Load an asset from a BSP file into the internal filesystem" )
{
	const char* szInFilename = NULL;
	const char* szOutFilename = NULL;
	const char* szOutFilename2 = NULL;

	if (args.ArgC() == 4)
	{
		szInFilename = args.Arg(1);
		szOutFilename = args.Arg(2);
		szOutFilename2 = args.Arg(3);
	}
	else if (args.ArgC() == 3)
	{
		szInFilename = args.Arg(1);
		szOutFilename = args.Arg(2);
		szOutFilename2 = szOutFilename;
	}

	if (!szInFilename || !szOutFilename || !strlen(szInFilename) || !strlen(szOutFilename))
	{
		Msg("Usage: bsp_cache mapPath assetPath [targetAssetPath]\n");
		return;
	}

	BackgroundBSPCacheThread* thread = new BackgroundBSPCacheThread(szInFilename);
	thread->AddFile(szOutFilename, szOutFilename2);
	thread->Start();
}

CON_COMMAND( bsp_cache_dump, "Dump BSP cache contents to console." )
{
	Msg("Cache count: %d\n", g_bspMemoryFiles.Count());
	FOR_EACH_HASHTABLE(g_bspMemoryFiles, fileid)
	{
		auto file = g_bspMemoryFiles[fileid];
		Msg("%s (Size: %d)\n", file->m_pFileName, file->m_nLength);
		//Msg("%s (Size: %d) (DataSize: %d)\n", file->m_pFileName, file->m_nLength, strlen(file->m_pData));
	}
}

CON_COMMAND( bsp_cache_clear, "Clear BSP cache." )
{
	BSP_ClearCache();
}

CON_COMMAND( lzma_compress, "Compress a file using LZMA" )
{
	const char* szInFilename = NULL;
	const char* szOutFilename = NULL;

	if ( args.ArgC() == 3 )
	{
		szInFilename = args.Arg(1);
		szOutFilename = args.Arg(2);
	}

	if ( !szInFilename || !szOutFilename || !strlen(szInFilename) || !strlen(szOutFilename) )
	{
		Msg( "Usage: lzma_compress inFile outFile\n" );
		return;
	}

	CUtlBuffer bufFileContents;
	if ( !g_pFullFileSystem->ReadFile( szInFilename, NULL, bufFileContents ) )
	{
		Warning( "Error: Failed to open file\n" );
		return;
	}

	if ( CLZMA::IsCompressed( (unsigned char*)bufFileContents.Base() ) )
	{
		Warning( "Error: File is already LZMA compressed\n" );
		return;
	}

	int outLength = bufFileContents.TellPut();
	unsigned int compressedSize = 0;
	unsigned char* pCompressedOutput = LZMA_Compress( (unsigned char*)bufFileContents.Base(), outLength, &compressedSize );
	if ( !pCompressedOutput || compressedSize < sizeof(lzma_header_t) )
	{
		Warning( "Error: LZMA compression failed\n" );
		return;
	}

	CUtlBuffer compressionBuffer;
	compressionBuffer.EnsureCapacity( compressedSize );
	compressionBuffer.Put( pCompressedOutput, compressedSize );

	if ( !filesystem->WriteFile( szOutFilename, "MOD", compressionBuffer ) )
	{
		free( pCompressedOutput );
		pCompressedOutput = NULL;
		Warning( "Error: Failed to write file\n" );
		return;
	}

	free( pCompressedOutput );
	pCompressedOutput = NULL;
}

CON_COMMAND( lzma_decompress, "Decompress a compressed file using LZMA" )
{
	const char* szInFilename = NULL;
	const char* szOutFilename = NULL;

	if ( args.ArgC() == 3 )
	{
		szInFilename = args.Arg(1);
		szOutFilename = args.Arg(2);
	}

	if ( !szInFilename || !szOutFilename || !strlen(szInFilename) || !strlen(szOutFilename) )
	{
		Msg( "Usage: lzma_decompress inFile outFile\n" );
		return;
	}

	CUtlBuffer bufFileContents;
	if ( !g_pFullFileSystem->ReadFile( szInFilename, NULL, bufFileContents ) )
	{
		Warning( "Error: Failed to open file\n" );
		return;
	}

	if ( CLZMA::IsCompressed( (unsigned char*)bufFileContents.Base() ) )
	{
		int originalSize = CLZMA::GetActualSize( (unsigned char*)bufFileContents.Base() );
		unsigned char* pOriginalData = new unsigned char[originalSize];
		CLZMA::Uncompress( (unsigned char*)bufFileContents.Base(), pOriginalData );
		bufFileContents.AssumeMemory( pOriginalData, originalSize, originalSize, CUtlBuffer::READ_ONLY );
		g_pFullFileSystem->WriteFile( szOutFilename, "MOD", bufFileContents );
	}
	else
	{
		Warning( "Error: File is not LZMA compressed\n" );
		return;
	}
}
#endif

#ifdef GAME_DLL
CON_COMMAND( bsp_cache_server, "Load an asset from a BSP file into the internal filesystem" )
{
	if (!UTIL_IsCommandIssuedByServerAdmin())
		return;

	const char* szInFilename = NULL;
	const char* szOutFilename = NULL;
	const char* szOutFilename2 = NULL;

	if (args.ArgC() == 4)
	{
		szInFilename = args.Arg(1);
		szOutFilename = args.Arg(2);
		szOutFilename2 = args.Arg(3);
	}
	else if (args.ArgC() == 3)
	{
		szInFilename = args.Arg(1);
		szOutFilename = args.Arg(2);
		szOutFilename2 = szOutFilename;
	}

	if (!szInFilename || !szOutFilename || !strlen(szInFilename) || !strlen(szOutFilename))
	{
		Msg("Usage: bsp_cache mapPath assetPath [targetAssetPath]\n");
		return;
	}

	BackgroundBSPCacheThread* thread = new BackgroundBSPCacheThread(szInFilename);
	thread->AddFile(szOutFilename, szOutFilename2);
	thread->Start();
}

CON_COMMAND( bsp_cache_dump_server, "Dump BSP cache contents to console." )
{
	if (!UTIL_IsCommandIssuedByServerAdmin())
		return;

	Msg("Cache count: %d\n", g_bspMemoryFiles.Count());
	FOR_EACH_HASHTABLE(g_bspMemoryFiles, fileid)
	{
		auto file = g_bspMemoryFiles[fileid];
		Msg("%s (Size: %d)\n", file->m_pFileName, file->m_nLength);
		//Msg("%s (Size: %d) (DataSize: %d)\n", file->m_pFileName, file->m_nLength, strlen(file->m_pData));
	}
}

CON_COMMAND( bsp_cache_clear_server, "Clear BSP cache." )
{
	if (!UTIL_IsCommandIssuedByServerAdmin())
		return;

	BSP_ClearCache();
}
#endif