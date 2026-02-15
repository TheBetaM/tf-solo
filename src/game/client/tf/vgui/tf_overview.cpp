//========= Copyright Valve Corporation, All rights reserved. ============//
//
// Purpose: 
//
// $NoKeywords: $
//=============================================================================//

#include "cbase.h"
#include <vgui/ISurface.h>
#include <vgui/ILocalize.h>
#include "tf_shareddefs.h"
#include "tf_overview.h"
#include "c_playerresource.h"	
#include "c_tf_objective_resource.h"
#include "usermessages.h"
#include "coordsize.h"
#include "clientmode.h"
#include <vgui_controls/AnimationController.h>
#include "voice_status.h"
#include "spectatorgui.h"
#include "c_team_objectiveresource.h"
#include "solo/propertydamage_prop.h"
#include "tf_gamerules.h"
#include "filesystem.h"

using namespace vgui;

static const char* pszTeamPropertyIcons[] = {
	"sprites/obj_icons/icon_obj_neutral",
	"sprites/obj_icons/icon_obj_neutral",
	"sprites/obj_icons/icon_obj_red",
	"sprites/obj_icons/icon_obj_blu",
	"sprites/obj_icons/icon_obj_neutral",
	"sprites/obj_icons/icon_obj_neutral",
	"sprites/obj_icons/icon_obj_neutral",
	"sprites/obj_icons/icon_obj_neutral",
	"sprites/obj_icons/icon_obj_neutral",
	"sprites/obj_icons/icon_obj_neutral",
	"sprites/obj_icons/icon_obj_neutral",
	"sprites/obj_icons/icon_obj_neutral",
	"sprites/obj_icons/icon_obj_neutral",
};

void __MsgFunc_UpdateRadar( bf_read &msg )
{
	if ( !g_pMapOverview )
		return;

	int iPlayerEntity = msg.ReadByte();

	while ( iPlayerEntity > 0 )
	{
		int x = msg.ReadSBitLong( COORD_INTEGER_BITS-1 ) * 4;
		int y = msg.ReadSBitLong( COORD_INTEGER_BITS-1 ) * 4;
		int a = msg.ReadSBitLong( 9 );

		Vector origin( x, y, 0 );
		QAngle angles( 0, a, 0 );

		g_pMapOverview->SetPlayerPositions( iPlayerEntity-1, origin, angles );

		iPlayerEntity = msg.ReadByte(); // read index for next player
	}
}

extern ConVar tf_overview_scoreboard;
extern ConVar tf_overview_knowledge;
extern ConVar tfsolo_mapentry;
extern ConVar tf_scoreboard_allow;
extern ConVar tf_mirrormode;
ConVar _cl_minimapzoom( "_cl_minimapzoom", "1", FCVAR_ARCHIVE );


CTFMapOverview *GetTFOverview( void )
{
	return dynamic_cast<CTFMapOverview *>( g_pMapOverview );
}

// overview_togglezoom rotates through 3 levels of zoom for the small map
//-----------------------------------------------------------------------
void ToggleZoom( void )
{
	if ( !GetTFOverview() )
		return;

	GetTFOverview()->ToggleZoom();
}
//static ConCommand overview_togglezoom( "overview_togglezoom", ToggleZoom );

// overview_largemap toggles showing the large map
//------------------------------------------------
void ShowLargeMap( void )
{
	if ( !GetTFOverview() )
		return;

	GetTFOverview()->ShowLargeMap();
}
//static ConCommand overview_showlargemap( "+overview_largemap", ShowLargeMap );

void HideLargeMap( void )
{
	if ( !GetTFOverview() )
		return;

	GetTFOverview()->HideLargeMap();
}
//static ConCommand overview_hidelargemap( "-overview_largemap", HideLargeMap );

CON_COMMAND( tf_overview_drawing_save, "Saves overview drawing to file" )
{
	if ( !GetTFOverview() || !GetTFOverview()->m_pDrawingPanel )
		return;

	const char* path;
	if ( args.ArgC() <= 1 )
	{
		path = "overview_drawing.txt";
	}
	else
	{
		path = args.Arg(1);
	}

	GetTFOverview()->m_pDrawingPanel->SaveLinesToFile( path );
}
CON_COMMAND( tf_overview_drawing_load, "Loads overview drawing from file" )
{
	if ( !GetTFOverview() || !GetTFOverview()->m_pDrawingPanel )
		return;

	const char* path = args.Arg(1);
	GetTFOverview()->m_pDrawingPanel->LoadLinesFromFile( path );
}
CON_COMMAND( tf_overview_drawing_clear, "Clears overview drawing" )
{
	if (!GetTFOverview() || !GetTFOverview()->m_pDrawingPanel)
		return;
	GetTFOverview()->m_pDrawingPanel->ClearAllLines();
}

//--------------------------------
// map border ?
// icon minimum zoom
// flag swipes
// chatting icon
// voice com icon
//---------------------------------

DECLARE_HUDELEMENT( CTFMapOverview );

ConVar tf_overview_voice_icon_size( "tf_overview_voice_icon_size", "64", FCVAR_ARCHIVE );
ConVar tf_overview_pause( "tf_overview_pause", "0", FCVAR_ARCHIVE );

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
CTFMapOverview::CTFMapOverview( const char *pElementName ) : BaseClass( pElementName )
{
	InitTeamColorsAndIcons();
	m_flIconSize = 96.0f;
	m_iLastMode = MAP_MODE_OFF;
	m_iNavigationMode = TF_OVERVIEW_MODE_PAN;
	m_bDisabled = false;
	m_nMapTextureOverlayID = -1;
	usermessages->HookMessage( "UpdateRadar", __MsgFunc_UpdateRadar );
	RegisterForRenderGroup( "overview" );
	UnregisterForRenderGroup( "global" );
	m_TeamProperty.SetLessFunc( DefLessFunc(int) );
	m_TeamProperty.Purge();
	m_bIsPanning = false;
	m_vLastMousePos = Vector2D( 512, 512 );

	/*m_pDrawingPanel = new CDrawingPanel( this, "DrawingPanel" );
	CExButton* button1 = new CExButton( this, "PanButton", "", this );
	CExButton* button2 = new CExButton( this, "DrawButton", "", this );
	CExButton* button3 = new CExButton( this, "DrawClearButton", "", this );
	CExButton* button4 = new CExButton( this, "ZoomPlusButton", "", this );
	CExButton* button5 = new CExButton( this, "ZoomMinusButton", "", this );
	CExButton* button6 = new CExButton( this, "ZoomCenterButton", "", this );*/
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::ResetRound()
{
	BaseClass::ResetRound();

	m_TeamProperty.Purge();

	KeyValuesAD config( "maps_config" );
	if ( !config->LoadFromFile( g_pFullFileSystem, "cfg/solo/maps_config.txt", "GAME" ) )
	{
		Msg( "MapOverview: Unable to parse maps_config.txt into keyvalues.\n" );
		return;
	}
	KeyValues* maps = config->FindKey( "maps" );
	if ( !maps )
	{
		return;
	}

	if ( m_pTitleLabel )
	{
		const char* pszMapName = tfsolo_mapentry.GetString();
		if ( pszMapName && pszMapName[0] )
		{
			KeyValues* map = maps->FindKey(pszMapName);
			if ( map )
			{
				m_pTitleLabel->SetText( map->GetString("name") );
			}
			else
			{
				m_pTitleLabel->SetText( GetMapDisplayName( pszMapName ) );
			}
		}
		else
		{
			m_pTitleLabel->SetText( engine->GetLevelName() );
		}
	}
	if ( m_pDrawingPanel )
	{
		m_pDrawingPanel->ClearAllLines();
		m_pDrawingPanel->SetType( DRAWING_PANEL_TYPE_OVERVIEW );
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::Update()
{
	UpdateCapturePoints();

	UpdateTeamProperty();

	BaseClass::Update();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::VidInit( void )
{
	BaseClass::VidInit();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::UpdateCapturePoints()
{
	if ( !g_pObjectiveResource )
		return;

	Color colorGreen( 0,255,0,255 );

	for( int i = 0 ; i < g_pObjectiveResource->GetNumControlPoints() ; i++ )
	{
		// check if CP is visible at all
		if( !g_pObjectiveResource->IsCPVisible( i ) )
		{
			if ( m_CapturePoints[i] != 0 )
			{
				// remove capture point from map
				RemoveObject( m_CapturePoints[i] );
				m_CapturePoints[i] = 0;
			}

			continue;
		}

		// ok, show CP
		int iOwningTeam = g_pObjectiveResource->GetOwningTeam(i);
		int iCappingTeam = g_pObjectiveResource->GetCappingTeam(i);

		int iOwningIcon = g_pObjectiveResource->GetIconForTeam( i, iOwningTeam );
		if ( iOwningIcon <= 0 )
			continue;	// baah

		const char *textureName = GetMaterialNameFromIndex( iOwningIcon );

		int objID = m_CapturePoints[i];

		if ( objID == 0 )
		{
			// add object if not already there
			objID = m_CapturePoints[i] = AddObject( textureName, 0, -1 );

			// objective positions never change (so far)
			SetObjectPosition( objID, g_pObjectiveResource->GetCPPosition(i), vec3_angle );

			AddObjectFlags( objID, MAP_OBJECT_ALIGN_TO_MAP );
		}

		SetObjectIcon( objID, textureName, 128.0 );

		// draw cap percentage
		if( iCappingTeam != TEAM_UNASSIGNED )
		{
			SetObjectStatus( objID, g_pObjectiveResource->GetCPCapPercentage(i), colorGreen );
		}
		else
		{
			SetObjectStatus( objID, -1, colorGreen ); // turn it off
		}
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::UpdateTeamProperty()
{
	int propCount = 0;
	propCount += ITFSOLOPropertyDamageProp::AutoList().Count();
	propCount += ITFSOLOPropertyDamagePhysicsProp::AutoList().Count();
	propCount += ITFSOLOPropertyDamageBrush::AutoList().Count();
	propCount += ITFSOLOPropertyDamageNextBot::AutoList().Count();

	if ( propCount == 0 )
		return;

	Color colorGreen( 0, 255, 0, 255 );

	for ( int i = 0; i < ITFSOLOPropertyDamageProp::AutoList().Count(); ++i )
	{
		CTFSOLOPropertyDamageProp* pObj = static_cast<CTFSOLOPropertyDamageProp*>( ITFSOLOPropertyDamageProp::AutoList()[i] );
		int iOwningTeam = pObj->GetTeamNumber();
		const char* textureName = pszTeamPropertyIcons[ iOwningTeam ];
		int objID = m_TeamProperty.Find( pObj->entindex() );
		if ( objID == m_TeamProperty.InvalidIndex() )
		{
			objID = AddObject( textureName, pObj->entindex(), -1 );
			m_TeamProperty.InsertOrReplace( pObj->entindex(), objID );
			SetObjectPosition( objID, pObj->GetAbsOrigin(), vec3_angle );
			AddObjectFlags( objID, MAP_OBJECT_ALIGN_TO_MAP );
		}
		else
		{
			objID = m_TeamProperty[ objID ];
		}
		SetObjectIcon( objID, textureName, 128.0 );
		if ( pObj->m_flCurrentDamage > 0.0 )
		{
			float flHealth = MAX( 1, ( pObj->m_flLastMaxDamage - pObj->m_flCurrentDamage ) );
			float flMaxHealth = MAX( 1, pObj->m_flLastMaxDamage );
			SetObjectStatus( objID, flHealth / flMaxHealth, colorGreen );
		}
		else
		{
			SetObjectStatus( objID, -1, colorGreen );
		}
	}
	for ( int i = 0; i < ITFSOLOPropertyDamagePhysicsProp::AutoList().Count(); ++i )
	{
		CTFSOLOPropertyDamagePhysicsProp* pObj = static_cast<CTFSOLOPropertyDamagePhysicsProp*>( ITFSOLOPropertyDamagePhysicsProp::AutoList()[i] );
		int iOwningTeam = pObj->GetTeamNumber();
		const char* textureName = pszTeamPropertyIcons[ iOwningTeam ];
		int objID = m_TeamProperty.Find( pObj->entindex() );
		if ( objID == m_TeamProperty.InvalidIndex() )
		{
			objID = AddObject( textureName, pObj->entindex(), -1);
			m_TeamProperty.InsertOrReplace( pObj->entindex(), objID );
			SetObjectPosition( objID, pObj->GetAbsOrigin(), vec3_angle );
			AddObjectFlags( objID, MAP_OBJECT_ALIGN_TO_MAP );
		}
		else
		{
			objID = m_TeamProperty[ objID ];
		}
		SetObjectIcon( objID, textureName, 128.0 );
		if ( pObj->m_flCurrentDamage > 0.0 )
		{
			float flHealth = MAX( 1, ( pObj->m_flLastMaxDamage - pObj->m_flCurrentDamage ) );
			float flMaxHealth = MAX( 1, pObj->m_flLastMaxDamage );
			SetObjectStatus( objID, flHealth / flMaxHealth, colorGreen );
		}
		else
		{
			SetObjectStatus( objID, -1, colorGreen );
		}
	}
	for ( int i = 0; i < ITFSOLOPropertyDamageBrush::AutoList().Count(); ++i )
	{
		CTFSOLOPropertyDamageBrush* pObj = static_cast<CTFSOLOPropertyDamageBrush*>( ITFSOLOPropertyDamageBrush::AutoList()[i] );
		int iOwningTeam = pObj->GetTeamNumber();
		const char* textureName = pszTeamPropertyIcons[ iOwningTeam ];
		int objID = m_TeamProperty.Find( pObj->entindex() );
		if ( objID == m_TeamProperty.InvalidIndex() )
		{
			objID = AddObject( textureName, pObj->entindex(), -1 );
			m_TeamProperty.InsertOrReplace( pObj->entindex(), objID );
			SetObjectPosition( objID, pObj->GetAbsOrigin(), vec3_angle );
			AddObjectFlags( objID, MAP_OBJECT_ALIGN_TO_MAP );
		}
		else
		{
			objID = m_TeamProperty[ objID ];
		}
		SetObjectIcon( objID, textureName, 128.0 );
		if ( pObj->m_flCurrentDamage > 0.0 )
		{
			float flHealth = MAX( 1, ( pObj->m_flLastMaxDamage - pObj->m_flCurrentDamage ) );
			float flMaxHealth = MAX( 1, pObj->m_flLastMaxDamage );
			SetObjectStatus( objID, flHealth / flMaxHealth, colorGreen );
		}
		else
		{
			SetObjectStatus( objID, -1, colorGreen );
		}
	}
	for ( int i = 0; i < ITFSOLOPropertyDamageNextBot::AutoList().Count(); ++i )
	{
		CTFSOLOPropertyDamageNextBot* pObj = static_cast<CTFSOLOPropertyDamageNextBot*>( ITFSOLOPropertyDamageNextBot::AutoList()[i] );
		int iOwningTeam = pObj->GetTeamNumber();
		const char* textureName = pszTeamPropertyIcons[ iOwningTeam ];
		int objID = m_TeamProperty.Find( pObj->entindex() );
		if ( objID == m_TeamProperty.InvalidIndex() )
		{
			objID = AddObject( textureName, pObj->entindex(), -1 );
			m_TeamProperty.InsertOrReplace( pObj->entindex(), objID );
			SetObjectPosition( objID, pObj->GetAbsOrigin(), vec3_angle );
			AddObjectFlags( objID, MAP_OBJECT_ALIGN_TO_MAP );
		}
		else
		{
			objID = m_TeamProperty[ objID ];
		}
		SetObjectIcon( objID, textureName, 128.0 );
		if ( pObj->m_flCurrentDamage > 0.0 )
		{
			float flHealth = MAX( 1, ( pObj->m_flLastMaxDamage - pObj->m_flCurrentDamage ) );
			float flMaxHealth = MAX( 1, pObj->m_flLastMaxDamage );
			SetObjectStatus( objID, flHealth / flMaxHealth, colorGreen );
		}
		else
		{
			SetObjectStatus( objID, -1, colorGreen );
		}
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::InitTeamColorsAndIcons()
{
	BaseClass::InitTeamColorsAndIcons();

	Q_memset( m_TeamPropertyIcons, 0, sizeof(m_TeamPropertyIcons) );

	m_TeamColors[TF_TEAM_RED] = COLOR_TF_RED;
	m_TeamIcons[TF_TEAM_RED] = AddIconTexture( "sprites/minimap_icons/red_player" );
	m_CameraIcons[TF_TEAM_RED] = AddIconTexture( "sprites/minimap_icons/red_camera" );
	m_TeamPropertyIcons[TF_TEAM_RED] = AddIconTexture( "sprites/obj_icons/icon_obj_red" );

	m_TeamColors[TF_TEAM_BLUE] = COLOR_TF_BLUE;
	m_TeamIcons[TF_TEAM_BLUE] = AddIconTexture( "sprites/minimap_icons/blue_player" );
	m_CameraIcons[TF_TEAM_BLUE] = AddIconTexture( "sprites/minimap_icons/blue_camera" );
	m_TeamPropertyIcons[TF_TEAM_BLUE] = AddIconTexture( "sprites/obj_icons/icon_obj_blu" );

	m_TeamPropertyIcons[0] = AddIconTexture( "sprites/obj_icons/icon_obj_neutral" );
	m_TeamPropertyIcons[1] = AddIconTexture( "sprites/obj_icons/icon_obj_neutral" );
	m_TeamPropertyIcons[4] = AddIconTexture( "sprites/obj_icons/icon_obj_neutral" );
	m_TeamPropertyIcons[5] = AddIconTexture( "sprites/obj_icons/icon_obj_neutral" );

	Q_memset( m_flPlayerChatTime, 0, sizeof(m_flPlayerChatTime ) );
	m_iVoiceIcon = AddIconTexture( "voice/icntlk_pl" );
	m_iChatIcon = AddIconTexture( "sprites/minimap_icons/voiceIcon" );

	Q_memset( m_CapturePoints, 0, sizeof(m_CapturePoints) );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::DrawCamera()
{
	C_BasePlayer *localPlayer = C_BasePlayer::GetLocalPlayer();

	if ( !localPlayer )
		return;

	int iTexture = m_CameraIcons[localPlayer->GetTeamNumber()];

	if ( localPlayer->IsObserver() || iTexture <= 0 )
	{
		BaseClass::DrawCamera();
	}
	else
	{
		MapObject_t obj;
		memset( &obj, 0, sizeof(MapObject_t) );

		obj.icon = iTexture;
		obj.position = localPlayer->GetAbsOrigin();
		obj.size = m_flIconSize * 1.5;
		obj.angle = localPlayer->EyeAngles();
		obj.status = -1;

		DrawIcon( &obj );

		DrawVoiceIconForPlayer( localPlayer->entindex() - 1 );
	}
}

void CTFMapOverview::ApplySchemeSettings( vgui::IScheme* scheme )
{
	BaseClass::ApplySchemeSettings( scheme );

	LoadControlSettings( "resource/UI/TFOverview.res" );

	m_pTitleLabel = dynamic_cast<CExLabel *>( FindChildByName( "TitleLabel" ) );
	m_pDrawingPanel = dynamic_cast<CDrawingPanel *>( FindChildByName( "DrawingPanel" ) );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::FireGameEvent( IGameEvent *event )
{
	const char * type = event->GetName();

	if ( Q_strcmp( type, "player_death" ) == 0 )
	{
		MapPlayer_t *player = GetPlayerByUserID( event->GetInt( "userid" ) );

		if ( player && CanPlayerBeSeen( player ) )
		{
			// create skull icon for 3 seconds
			int handle = AddObject( "sprites/minimap_icons/death", 0, 3 );
			SetObjectText( handle, player->name, player->color );
			SetObjectPosition( handle, player->position, player->angle );
		}
	}
	else if ( Q_strcmp( type, "game_newmap" ) == 0 )
	{
		SetMode( MAP_MODE_OFF );
	}

	BaseClass::FireGameEvent( event	);
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::OnCommand( const char* command )
{
	if ( FStrEq( "mode_pan", command ) )
	{
		m_iNavigationMode = TF_OVERVIEW_MODE_PAN;
		if ( m_pDrawingPanel )
		{
			m_pDrawingPanel->SetViewOnly( true );
		}
		return;
	}
	else if ( FStrEq( "mode_draw", command ) )
	{
		m_iNavigationMode = TF_OVERVIEW_MODE_DRAW;
		if ( m_pDrawingPanel )
		{
			m_pDrawingPanel->SetViewOnly( false );
		}
		return;
	}
	else if ( FStrEq( "mode_drawclear", command ) )
	{
		if ( m_pDrawingPanel )
		{
			m_pDrawingPanel->ClearLines( 1 );
		}
		return;
	}
	else if ( FStrEq( "zoom_plus", command ) )
	{
		if ( m_fZoom >= 2.0f )
		{
			return;
		}
		float zoom = m_fZoom + 0.2f;
		float time = 0.2f;
		float desiredViewSize = 0.0f;
		desiredViewSize = ( zoom * OVERVIEW_MAP_SIZE * g_pMapOverview->GetFullZoom() ) / g_pMapOverview->GetMapScale();
		g_pMapOverview->SetPlayerPreferredViewSize( desiredViewSize );
		if ( engine->IsPaused() )
		{
			m_fZoom = zoom;
		}
		else
		{
			m_fZoom = zoom;
			//g_pClientMode->GetViewportAnimationController()->RunAnimationCommand( g_pMapOverview->GetAsPanel(), "zoom", zoom, 0.0, time, vgui::AnimationController::INTERPOLATOR_LINEAR );
		}
		return;
	}
	else if ( FStrEq( "zoom_minus", command ) )
	{
		if ( m_fZoom <= 0.3f )
		{
			return;
		}
		float zoom = m_fZoom - 0.2f;
		float time = 0.2f;
		float desiredViewSize = 0.0f;
		desiredViewSize = ( zoom * OVERVIEW_MAP_SIZE * g_pMapOverview->GetFullZoom() ) / g_pMapOverview->GetMapScale();
		g_pMapOverview->SetPlayerPreferredViewSize( desiredViewSize );
		if ( engine->IsPaused() )
		{
			m_fZoom = zoom;
		}
		else
		{
			m_fZoom = zoom;
			//g_pClientMode->GetViewportAnimationController()->RunAnimationCommand( g_pMapOverview->GetAsPanel(), "zoom", zoom, 0.0, time, vgui::AnimationController::INTERPOLATOR_LINEAR );
		}
		return;
	}
	else if ( FStrEq( "zoom_center", command ) )
	{
		Vector center = Vector( 0, 0, 0 );
		SetMapOrigin( center );
		return;
	}

	BaseClass::OnCommand( command );
}

void CTFMapOverview::OnMousePressed( vgui::MouseCode code )
{
	if ( code != MOUSE_LEFT )
		return;

	if ( m_iNavigationMode == TF_OVERVIEW_MODE_PAN )
	{
		m_bIsPanning = true;
	}
}

void CTFMapOverview::OnMouseReleased( vgui::MouseCode code )
{
	if ( code != MOUSE_LEFT )
		return;

	m_bIsPanning = false;
}

void CTFMapOverview::OnCursorExited()
{
	m_bIsPanning = false;
}

void CTFMapOverview::OnCursorMoved( int x, int y )
{
	if ( m_iNavigationMode == TF_OVERVIEW_MODE_PAN && m_bIsPanning )
	{
		Vector src = GetMapOrigin();
		Vector center = Vector( src.x, src.y, 0 );
		center.x -= (x - m_vLastMousePos.x) * 1.5f;
		center.y += (y - m_vLastMousePos.y) * 1.5f;
		SetMapOrigin( center );
	}
	m_vLastMousePos = Vector2D( x, y );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
bool CTFMapOverview::CanPlayerBeSeen( MapPlayer_t *player )
{
	// rules that define if you can see a player on the overview or not
    C_BasePlayer *localPlayer = C_BasePlayer::GetLocalPlayer();

	if ( !localPlayer || !player )
		return false;

	// don't draw ourselves
	if ( localPlayer->entindex() == (player->index+1) )
		return false;

	// if local player is on spectator team, he can see everyone
	if ( localPlayer->GetTeamNumber() <= TEAM_SPECTATOR )
		return true;

	// we never track unassigned or real spectators
	if ( player->team <= TEAM_SPECTATOR )
		return false;

	if ( tf_overview_knowledge.GetInt() == 2 )
		return true;

	// ingame and as dead player we can only see our own teammates
	return ( localPlayer->GetTeamNumber() == player->team );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::ShowLargeMap( void )
{
	if ( IsDisabled() )
	{
		return;
	}

	// remember old mode
	m_iLastMode = GetMode();

	// if we hit the toggle while full, set to disappear when we release
	if ( m_iLastMode == MAP_MODE_FULL )
	{
        m_iLastMode = MAP_MODE_OFF;
	}

	SetMode( MAP_MODE_FULL );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::HideLargeMap( void )
{
	if ( IsDisabled() )
	{
		return;
	}

	SetMode( m_iLastMode );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::ToggleZoom( void )
{
	if ( IsDisabled() )
	{
		return;
	}

	if ( GetMode() != MAP_MODE_INSET )
		return;

	int iZoomLevel = ( _cl_minimapzoom.GetInt() + 1 ) % TF_MAP_ZOOM_LEVELS;

	_cl_minimapzoom.SetValue( iZoomLevel );

	switch( _cl_minimapzoom.GetInt() )
	{
	case 0:
		g_pClientMode->GetViewportAnimationController()->StartAnimationSequence( "MapZoomLevel1" );
		break;
	case 1:
	default:
		g_pClientMode->GetViewportAnimationController()->StartAnimationSequence( "MapZoomLevel2" );
		break;
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::SetMode( int mode )
{
	if ( IsDisabled() )
	{
		return;
	}

	m_flChangeSpeed = 0; // change size instantly

	int iRenderGroup = gHUD.LookupRenderGroupIndexByName( "global" );

	if ( mode == MAP_MODE_OFF )
	{
		ShowPanel( false );

		g_pClientMode->GetViewportAnimationController()->StartAnimationSequence( "MapOff" );
		gHUD.UnlockRenderGroup( iRenderGroup );
		if ( tf_overview_pause.GetBool() && engine->IsPaused() )
		{
			engine->ClientCmd( "pause" );
		}
		if ( m_pDrawingPanel )
		{
			m_pDrawingPanel->SetVisible( false );
		}
	}
	else if ( mode == MAP_MODE_INSET )
	{
		switch( _cl_minimapzoom.GetInt() )
		{
		case 0:
			g_pClientMode->GetViewportAnimationController()->StartAnimationSequence( "MapZoomLevel1" );
			break;
		case 1:
			g_pClientMode->GetViewportAnimationController()->StartAnimationSequence( "MapZoomLevel2" );
			break;
		case 2:
		default:
			g_pClientMode->GetViewportAnimationController()->StartAnimationSequence( "MapZoomLevel3" );
			break;
		}

		C_BasePlayer *pPlayer = C_BasePlayer::GetLocalPlayer();

		if ( pPlayer )
			SetFollowEntity( pPlayer->entindex() );

		ShowPanel( true );

		if ( m_nMode == MAP_MODE_FULL )
			g_pClientMode->GetViewportAnimationController()->StartAnimationSequence( "MapScaleToSmall" );
		else
			g_pClientMode->GetViewportAnimationController()->StartAnimationSequence( "SnapToSmall" );
	}
	else if ( mode == MAP_MODE_FULL )
	{
		if ( !tf_scoreboard_allow.GetBool() )
		{
			return;
		}

		SetFollowEntity( 0 );

		ShowPanel( true );

		if ( m_nMode == MAP_MODE_INSET )
			g_pClientMode->GetViewportAnimationController()->StartAnimationSequence( "ZoomToLarge" );
		else
            g_pClientMode->GetViewportAnimationController()->StartAnimationSequence( "SnapToLarge" );

		MakePopup( false, true );
		SetKeyBoardInputEnabled( false );
		ConVarRef sv_pausable( "sv_pausable" );
		if ( tf_overview_pause.GetBool() && sv_pausable.GetBool() )
		{
			SetKeyBoardInputEnabled( true );
		}
		SetMouseInputEnabled( true );
		gHUD.LockRenderGroup( iRenderGroup );
		if ( m_pDrawingPanel )
		{
			m_pDrawingPanel->SetVisible( true );
			m_pDrawingPanel->SetMouseInputEnabled( true );
			if ( m_iNavigationMode == TF_OVERVIEW_MODE_DRAW )
			{
				m_pDrawingPanel->SetViewOnly( false );
			}
			else
			{
				m_pDrawingPanel->SetViewOnly( true );
			}
		}
		if ( tf_overview_pause.GetBool() && !engine->IsPaused() )
		{
			engine->ClientCmd( "pause" );
		}
	}

	// finally set mode
	m_nMode = mode;

	UpdateSizeAndPosition();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::UpdateSizeAndPosition()
{
	int x,y,w,h;

	GetBounds( x,y,w,h );

	//y = YRES(5);	// hax, align to top of the screen
	w = ScreenWidth();
	h = ScreenHeight();

	SetBounds( x,y,w,h );
}

ConVar cl_voicetest( "cl_voicetest", "0", FCVAR_CHEAT );
ConVar cl_overview_chat_time( "cl_overview_chat_time", "2.0", FCVAR_ARCHIVE );

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::PlayerChat( int index )
{
	index = index-1;

	if ( !IsIndexIntoPlayerArrayValid(index) )
		return;
		
	m_flPlayerChatTime[index] = gpGlobals->curtime + cl_overview_chat_time.GetFloat();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::DrawMapPlayers()
{
	BaseClass::DrawMapPlayers();

	C_BasePlayer *localPlayer = C_BasePlayer::GetLocalPlayer();

	Assert( localPlayer );

	int iLocalPlayer = localPlayer->entindex() - 1;

	for ( int i = 0 ; i < MAX_PLAYERS ; i++ )
	{
		if ( i == iLocalPlayer )
			continue;

		MapPlayer_t *player = &m_Players[i];

		if ( !CanPlayerBeSeen( player ) )
			continue;

		if ( player->health <= 0 )	// don't draw dead players / spectators
			continue;

		DrawVoiceIconForPlayer( i );
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::DrawVoiceIconForPlayer( int playerIndex )
{
	Assert( playerIndex >= 0 && playerIndex < MAX_PLAYERS );

	MapPlayer_t *player = &m_Players[playerIndex];

	// if they just sent a chat msg, or are using voice, or did a hand signal or voice command
	// draw a chat icon

	if ( cl_voicetest.GetInt() || GetClientVoiceMgr()->IsPlayerSpeaking( player->index+1 ) )
	{
		MapObject_t obj;
		memset( &obj, 0, sizeof(MapObject_t) );

		obj.icon = m_iVoiceIcon;
		obj.position = player->position;
		obj.size = tf_overview_voice_icon_size.GetFloat();
		obj.status = -1;

		DrawIcon( &obj );
	}
	else if ( m_flPlayerChatTime[player->index] > gpGlobals->curtime )
	{
		MapObject_t obj;
		memset( &obj, 0, sizeof(MapObject_t) );

		obj.icon = m_iChatIcon;
		obj.position = player->position;
		obj.size = tf_overview_voice_icon_size.GetFloat();
		obj.status = -1;

		DrawIcon( &obj );
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
bool CTFMapOverview::DrawIcon( MapObject_t *obj )
{
	for ( int i = 0 ; i < MAX_CONTROL_POINTS ; i++ )
	{
		if ( obj->objectID == m_CapturePoints[i] && obj->objectID != 0 )
		{
			return DrawCapturePoint( i, obj );
		}
	}

	if ( obj->index > 0 )
	{
		int iInd = m_TeamProperty.Find(obj->index);
		if ( iInd != m_TeamProperty.InvalidIndex() )
		{
			return DrawTeamProperty( obj );
		}
	}

	return  BaseClass::DrawIcon( obj );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::DrawQuad( Vector pos, int scale, float angle, int textureID, int alpha )
{
	Vector offset;
	offset.z = 0;

	offset.x = -scale;	offset.y = scale;
	VectorYawRotate( offset, angle, offset );
	Vector2D pos1 = WorldToMap( pos + offset );

	offset.x = scale;	offset.y = scale;
	VectorYawRotate( offset, angle, offset );
	Vector2D pos2 = WorldToMap( pos + offset );

	offset.x = scale;	offset.y = -scale;
	VectorYawRotate( offset, angle, offset );
	Vector2D pos3 = WorldToMap( pos + offset );

	offset.x = -scale;	offset.y = -scale;
	VectorYawRotate( offset, angle, offset );
	Vector2D pos4 = WorldToMap( pos + offset );

	Vertex_t points[4] =
	{
		Vertex_t( MapToPanel ( pos1 ), Vector2D(0,0) ),
		Vertex_t( MapToPanel ( pos2 ), Vector2D(1,0) ),
		Vertex_t( MapToPanel ( pos3 ), Vector2D(1,1) ),
		Vertex_t( MapToPanel ( pos4 ), Vector2D(0,1) )
	};

	surface()->DrawSetColor( 255, 255, 255, alpha );
	surface()->DrawSetTexture( textureID );
	surface()->DrawTexturedPolygon( 4, points );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
bool CTFMapOverview::DrawCapturePoint( int iCP, MapObject_t *obj )
{
	int textureID = obj->icon;
	Vector pos = obj->position;
	float scale = obj->size;

	Vector2D pospanel = WorldToMap( pos );
	pospanel = MapToPanel( pospanel );

	if ( !IsInPanel( pospanel ) )
		return false; // player is not within overview panel

	// draw capture swipe
	DrawQuad( pos, scale, 0, textureID, 255 );

	int iCappingTeam = g_pObjectiveResource->GetCappingTeam( iCP );

	if ( iCappingTeam != TEAM_UNASSIGNED )
	{
		int iCapperIcon = g_pObjectiveResource->GetCPCappingIcon( iCP );
		const char *textureName = GetMaterialNameFromIndex( iCapperIcon );

		float flCapPercent = g_pObjectiveResource->GetCPCapPercentage(iCP);
		bool bSwipeLeft = ( iCappingTeam == TF_TEAM_RED ) ? true : false;

		DrawHorizontalSwipe( pos, scale, AddIconTexture( textureName ), flCapPercent, bSwipeLeft );
	}

	// fixup for noone is capping, but someone is in the area
	int iNumBlue = g_pObjectiveResource->GetNumPlayersInArea( iCP, TF_TEAM_BLUE );
	int iNumRed = g_pObjectiveResource->GetNumPlayersInArea( iCP, TF_TEAM_RED );

	int iOwningTeam = g_pObjectiveResource->GetOwningTeam( iCP );
	if ( iCappingTeam == TEAM_UNASSIGNED )
	{
		if ( iNumBlue > 0 && iNumRed == 0 && iOwningTeam != TF_TEAM_BLUE )
		{
			iCappingTeam = TF_TEAM_BLUE;
		}
		else if ( iNumRed > 0 && iNumBlue == 0 && iOwningTeam != TF_TEAM_RED )
		{
			iCappingTeam = TF_TEAM_RED;
		}
	}

	if ( iCappingTeam != TEAM_UNASSIGNED )
	{
		// Draw the number of cappers below the icon
		int numPlayers = g_pObjectiveResource->GetNumPlayersInArea( iCP, iCappingTeam );
		int requiredPlayers = g_pObjectiveResource->GetRequiredCappers( iCP, iCappingTeam );

		if ( requiredPlayers > 1 )
		{
			numPlayers = MIN( numPlayers, requiredPlayers );

			wchar_t wText[6];
			_snwprintf( wText, sizeof(wText)/sizeof(wchar_t), L"%d", numPlayers );

			int wide, tall;
			surface()->GetTextSize( m_hIconFont, wText, wide, tall );

			int x = pospanel.x-(wide/2);
			int y = pospanel.y;

			// match the offset that MapOverview uses
			y += GetPixelOffset( scale ) + 4;

			// draw black shadow text
			surface()->DrawSetTextColor( 0, 0, 0, 255 );
			surface()->DrawSetTextPos( x+1, y );
			surface()->DrawPrintText( wText, wcslen(wText) );

			// draw name in color 
			surface()->DrawSetTextColor( g_PR->GetTeamColor( iCappingTeam ) );
			surface()->DrawSetTextPos( x, y );
			surface()->DrawPrintText( wText, wcslen(wText) );
		}
	}

	return true;
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
bool CTFMapOverview::DrawTeamProperty( MapObject_t *obj )
{
	int textureID = obj->icon;
	Vector pos = obj->position;
	float scale = obj->size;

	Vector2D pospanel = WorldToMap( pos );
	pospanel = MapToPanel( pospanel );

	if ( !IsInPanel( pospanel ) )
		return false; // player is not within overview panel

	// draw capture swipe
	DrawQuad( pos, scale, 0, textureID, 255 );

	C_BaseEntity* pEnt = ClientEntityList().GetEnt( obj->index );
	if ( !pEnt )
		return false;

	CTFSOLOPropertyDamageProp* pPDAProp1 = dynamic_cast<CTFSOLOPropertyDamageProp*>( pEnt );
	CTFSOLOPropertyDamagePhysicsProp* pPDAProp2 = dynamic_cast<CTFSOLOPropertyDamagePhysicsProp*>( pEnt );
	CTFSOLOPropertyDamageBrush* pPDAProp3 = dynamic_cast<CTFSOLOPropertyDamageBrush*>( pEnt );
	CTFSOLOPropertyDamageNextBot* pPDAProp4 = dynamic_cast<CTFSOLOPropertyDamageNextBot*>( pEnt );
	if ( pPDAProp1 && pPDAProp1->m_flCurrentDamage > 0.0 )
	{
		float flHealth = MAX( 1, ( pPDAProp1->m_flLastMaxDamage - pPDAProp1->m_flCurrentDamage ) );
		float flMaxHealth = MAX( 1, pPDAProp1->m_flLastMaxDamage );
		bool bSwipeLeft = ( pEnt->GetTeamNumber() == TF_TEAM_RED ) ? true : false;
		int iEnemyTeam = pEnt->GetTeamNumber() == TF_TEAM_RED ? TF_TEAM_BLUE : TF_TEAM_RED;
		DrawHorizontalSwipe( pos, scale, m_TeamPropertyIcons[iEnemyTeam], flHealth / flMaxHealth, bSwipeLeft );
	}
	else if ( pPDAProp2 && pPDAProp2->m_flCurrentDamage > 0.0 )
	{
		float flHealth = MAX( 1, ( pPDAProp2->m_flLastMaxDamage - pPDAProp2->m_flCurrentDamage ) );
		float flMaxHealth = MAX( 1, pPDAProp2->m_flLastMaxDamage );
		bool bSwipeLeft = ( pEnt->GetTeamNumber() == TF_TEAM_RED ) ? true : false;
		int iEnemyTeam = pEnt->GetTeamNumber() == TF_TEAM_RED ? TF_TEAM_BLUE : TF_TEAM_RED;
		DrawHorizontalSwipe( pos, scale, m_TeamPropertyIcons[iEnemyTeam], flHealth / flMaxHealth, bSwipeLeft );
	}
	else if ( pPDAProp3 && pPDAProp3->m_flCurrentDamage > 0.0 )
	{
		float flHealth = MAX( 1, ( pPDAProp3->m_flLastMaxDamage - pPDAProp3->m_flCurrentDamage ) );
		float flMaxHealth = MAX( 1, pPDAProp3->m_flLastMaxDamage );
		bool bSwipeLeft = ( pEnt->GetTeamNumber() == TF_TEAM_RED ) ? true : false;
		int iEnemyTeam = pEnt->GetTeamNumber() == TF_TEAM_RED ? TF_TEAM_BLUE : TF_TEAM_RED;
		DrawHorizontalSwipe( pos, scale, m_TeamPropertyIcons[iEnemyTeam], flHealth / flMaxHealth, bSwipeLeft );
	}
	else if ( pPDAProp4 && pPDAProp4->m_flCurrentDamage > 0.0 )
	{
		float flHealth = MAX( 1, ( pPDAProp4->m_flLastMaxDamage - pPDAProp4->m_flCurrentDamage ) );
		float flMaxHealth = MAX( 1, pPDAProp4->m_flLastMaxDamage );
		bool bSwipeLeft = ( pEnt->GetTeamNumber() == TF_TEAM_RED ) ? true : false;
		int iEnemyTeam = pEnt->GetTeamNumber() == TF_TEAM_RED ? TF_TEAM_BLUE : TF_TEAM_RED;
		DrawHorizontalSwipe( pos, scale, m_TeamPropertyIcons[iEnemyTeam], flHealth / flMaxHealth, bSwipeLeft );
	}

	return true;
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::DrawHorizontalSwipe( Vector pos, int scale, int textureID, float flCapPercentage, bool bSwipeLeft )
{
	float flIconSize = scale * 2;
	float width = ( flIconSize * flCapPercentage );

	float uv1 = 0.0f;
	float uv2 = 1.0f;

	Vector2D uv11( uv1, uv2 );
	Vector2D uv21( flCapPercentage, uv2 );
	Vector2D uv22( flCapPercentage, uv1 );
	Vector2D uv12( uv1, uv1 );

	// reversing the direction of the swipe effect
	if ( bSwipeLeft )
	{
		uv11.x = uv2 - flCapPercentage;
		uv21.x = uv2;
		uv22.x = uv2;
		uv12.x = uv2 - flCapPercentage;
	}

	float flXPos = pos.x - scale;
	float flYPos = pos.y - scale;

	Vector upperLeft( flXPos,			flYPos, 0 );
	Vector upperRight( flXPos + width,	flYPos, 0 );
	Vector lowerRight( flXPos + width,	flYPos + flIconSize, 0 );
	Vector lowerLeft ( flXPos,			flYPos + flIconSize, 0 );

	/// reversing the direction of the swipe effect
	if ( bSwipeLeft )
	{
		upperLeft.x  = flXPos + flIconSize - width;
		upperRight.x = flXPos + flIconSize;
		lowerRight.x = flXPos + flIconSize;
		lowerLeft.x  = flXPos + flIconSize - width;
	}

	vgui::Vertex_t vert[4];	

	Vector2D pos0 = WorldToMap( upperLeft );
	vert[0].Init( MapToPanel( pos0 ), uv11 );

	Vector2D pos3 = WorldToMap( lowerLeft );
	vert[1].Init( MapToPanel( pos3 ), uv12 );

	Vector2D pos2 = WorldToMap( lowerRight );
	vert[2].Init( MapToPanel( pos2 ), uv22 );

	Vector2D pos1 = WorldToMap( upperRight );
	vert[3].Init( MapToPanel( pos1 ), uv21 );

	surface()->DrawSetColor( 255, 255, 255, 255 );
	surface()->DrawSetTexture( textureID );
	surface()->DrawTexturedPolygon( 4, vert );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::SetMap( const char * levelname )
{
	BaseClass::SetMap( levelname );

	if ( m_nMapTextureID != -1 )
	{
		// we found a texture for this map
		SetDisabled( false );
		SetMode( m_nMode );
	}
	else
	{
		// we failed to load a map image
		//SetDisabled( true );
		SetDisabled( false );
		SetMode( m_nMode );
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
bool CTFMapOverview::ShouldDraw( void )
{
	if ( IsDisabled() )
	{
		return false;
	}

	return BaseClass::ShouldDraw();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::Paint()
{
	UpdateMapOverlayTexture();

	UpdateSizeAndPosition();

	UpdateFollowEntity();

	UpdateObjects();

	UpdatePlayers();

//	UpdatePlayerTrails();

	DrawMapTexture();

	DrawMapOverlayTexture();

//	DrawMapPlayerTrails();

	DrawObjects();

	DrawMapPlayers();

	DrawCamera();

	EditablePanel::Paint();
}

extern ConVar overview_alpha;

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::DrawMapOverlayTexture()
{
	// now draw a box around the outside of this panel
	int x0, y0, x1, y1;
	int wide, tall;

	GetSize( wide, tall );
	x0 = 0; y0 = 0; x1 = wide - 2; y1 = tall - 2;

	if ( m_nMapTextureOverlayID < 0 )
	{
		return;
	}

	Vertex_t points[4] =
	{
		Vertex_t( MapToPanel ( Vector2D(0,0) ), Vector2D(0,0) ),
			Vertex_t( MapToPanel ( Vector2D(OVERVIEW_MAP_SIZE-1,0) ), Vector2D(1,0) ),
			Vertex_t( MapToPanel ( Vector2D(OVERVIEW_MAP_SIZE-1,OVERVIEW_MAP_SIZE-1) ), Vector2D(1,1) ),
			Vertex_t( MapToPanel ( Vector2D(0,OVERVIEW_MAP_SIZE-1) ), Vector2D(0,1) )
	};

	int alpha = 255.0f * overview_alpha.GetFloat(); clamp( alpha, 1, 255 );

	surface()->DrawSetColor( 255,255,255, alpha );
	surface()->DrawSetTexture( m_nMapTextureOverlayID );
	surface()->DrawTexturedPolygon( 4, points );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::UpdateMapOverlayTexture()
{


/*
	char tempfile[MAX_PATH];
	Q_snprintf( tempfile, sizeof( tempfile ), "overviews/%s_%s_%s_%s", levelname, roundname, capname, teamname );

	// TODO release old texture ?

	m_nMapTextureOverlayID = surface()->CreateNewTextureID();

	//if we have not uploaded yet, lets go ahead and do so
	surface()->DrawSetTextureFile( m_nMapTextureOverlayID, tempfile, true, false );

	int wide, tall;

	surface()->DrawGetTextureSize( m_nMapTextureOverlayID, wide, tall );

	if ( wide != tall )
	{
		DevMsg( 1, "Error! CTFMapOverview::UpdateMapOverlayTexture: map overlay image must be a square.\n" );
		m_nMapTextureOverlayID = -1;
		return;
	}
*/
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFMapOverview::SetVisible( bool state )
{
	BaseClass::SetVisible( state );
}

void CTFMapOverview::OnKeyCodePressed( vgui::KeyCode code )
{
	if ( !IsVisible() )
		return;

	if ( code == KEY_E )
	{
		OnCommand( "zoom_plus" );
	}
	else if ( code == KEY_Q )
	{
		OnCommand( "zoom_minus" );
	}
	else if ( code == KEY_R )
	{
		OnCommand( "mode_draw" );
	}
	else if ( code == KEY_F )
	{
		OnCommand( "mode_pan" );
	}
	else if ( code == KEY_C )
	{
		OnCommand( "zoom_center" );
	}
	else
	{
		BaseClass::OnKeyCodePressed( code );
	}
}

void CTFMapOverview::OnMouseWheeled( int delta )
{
	if ( !IsVisible() )
		return;

	if ( delta > 0 )
	{
		OnCommand( "zoom_plus" );
	}
	else if ( delta < 0 )
	{
		OnCommand( "zoom_minus" );
	}
	
	BaseClass::OnMouseWheeled( delta );
}

//-----------------------------------------------------------------------------
// Purpose: Event handler
//-----------------------------------------------------------------------------
int	CTFMapOverview::HudElementKeyInput( int down, ButtonCode_t keynum, const char* pszCurrentBinding )
{
	if ( !IsVisible() )
		return 1;

	//OnMousePressed( keynum == MOUSE_LEFT ? MouseCode::MOUSE_LEFT : MouseCode::MOUSE_RIGHT );
	if ( keynum == KEY_E )
	{
		OnCommand( "zoom_plus" );
		return 0;
	}
	else if ( keynum == KEY_Q )
	{
		OnCommand( "zoom_minus" );
		return 0;
	}
	else if ( keynum == KEY_R )
	{
		OnCommand( "mode_draw" );
		return 0;
	}
	else if ( keynum == KEY_F )
	{
		OnCommand( "mode_pan" );
		return 0;
	}
	else if ( keynum == KEY_C )
	{
		OnCommand( "zoom_center" );
		return 0;
	}

	return 1;
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
bool ShouldMapOverviewHandleKeyInput( int down, ButtonCode_t keynum, const char *pszCurrentBinding )
{
	// We're only looking for specific mouse input
	//if ( keynum == MOUSE_LEFT || keynum == MOUSE_RIGHT || keynum == MOUSE_WHEEL_UP || keynum == MOUSE_WHEEL_DOWN )
	//{
		//CTFMapOverview *pMapOverview = dynamic_cast<CTFMapOverview* >( gViewPortInterface->FindPanelByName( PANEL_OVERVIEW ) );
		//if ( pMapOverview )
		//{
			//return !pMapOverview->HudElementKeyInput( down, keynum, pszCurrentBinding );
		//}
	//}

	return false;
}