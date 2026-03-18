// Choreo system for recording/playing back player inputs

#include "cbase.h"
#include "igamesystem.h"
#include "filesystem.h"
#include <KeyValues.h>
#include "in_buttons.h"
#include "eventqueue.h"
#include "ChoreoSystem.h"
#include "tf_player.h"
#include "tf/bot/tf_bot.h"
#include "vscript_server.h"
#include "tier1/lzmaDecoder.h"
#include "lzma/lzma.h"

CChoreoSystem g_ChoreoSystem;

CON_COMMAND_F(choreo_record, "Start recording inputs.", FCVAR_CHEAT)
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_GetCommandClient() );
	if ( !pPlayer )
		return;

	const char* szInFilename = NULL;

	if ( args.ArgC() == 2 )
	{
		szInFilename = args.Arg(1);
	}
	else
	{
		tm timeValue;
		VCRHook_LocalTime( &timeValue );
		const tm* pLocalTime = &timeValue;
		szInFilename = CFmtStr1024( "%u-%u-%u-%u-%u-%u.txt", pLocalTime->tm_year + 1900, pLocalTime->tm_mon + 1, pLocalTime->tm_mday, pLocalTime->tm_hour, pLocalTime->tm_min, pLocalTime->tm_sec );
	}

	g_ChoreoSystem.RecordStart( pPlayer->entindex(), szInFilename );
}
CON_COMMAND_F(choreo_record_stop, "Ends recording inputs.", FCVAR_CHEAT)
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_GetCommandClient() );
	if ( !pPlayer )
		return;

	g_ChoreoSystem.RecordStop( pPlayer->entindex() );
}
CON_COMMAND_F(choreo_play_teleport, "Start playing back inputs from file. Player will be teleported to starting position from recording.", FCVAR_CHEAT)
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_GetCommandClient() );
	if ( !pPlayer )
		return;

	const char* szInFilename = NULL;

	if ( args.ArgC() == 2 )
	{
		szInFilename = args.Arg(1);
	}

	if ( !szInFilename || !strlen(szInFilename) )
	{
		Msg("Usage: choreo_play_teleport filename\n");
		return;
	}

	g_ChoreoSystem.Play( pPlayer->entindex(), szInFilename, true );
}
CON_COMMAND_F(choreo_play, "Start playing back inputs from file.", FCVAR_CHEAT)
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_GetCommandClient() );
	if ( !pPlayer )
		return;

	const char* szInFilename = NULL;

	if ( args.ArgC() == 2 )
	{
		szInFilename = args.Arg(1);
	}

	if ( !szInFilename || !strlen(szInFilename) )
	{
		Msg("Usage: choreo_play filename\n");
		return;
	}

	g_ChoreoSystem.Play( pPlayer->entindex(), szInFilename, false );
}
CON_COMMAND_F(choreo_stop, "Stops playing back inputs.", FCVAR_CHEAT)
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_GetCommandClient() );
	if ( !pPlayer )
		return;

	g_ChoreoSystem.Stop( pPlayer->entindex() );
}

ConVar choreo_record_compressed( "choreo_record_compressed", "1", FCVAR_NONE, "Recordings get LZMA compressed upon saving." );

BEGIN_DATADESC_NO_BASE( CChoreoSystem )
END_DATADESC()

void CChoreoSystem::PrePlayerRunCommand( CBasePlayer* pPlayer, CUserCmd* pUserCmds )
{
	if ( !pPlayer )
		return;

	auto iPlayerIndex = pPlayer->entindex();

	if ( !IsPlaying( iPlayerIndex ) && !IsRecording( iPlayerIndex ) )
		return;

	if ( !pPlayer->IsAlive() )
	{
		if ( GetTick( iPlayerIndex ) != 0 )
		{
			// Died during playback
			if ( IsRecording( iPlayerIndex ) )
			{
				RecordStop( iPlayerIndex );
			}
			else
			{
				Stop( iPlayerIndex );
			}
		}
		// Otherwise, waiting to spawn before advancing playback/recording
		m_PlayerChoreo[iPlayerIndex].RecordStartTick = (uint64_t)gpGlobals->tickcount;
		return;
	}

	if ( m_PlayerChoreo[iPlayerIndex].bIsPaused )
		return;

	if ( IsRecording( iPlayerIndex ) )
	{
		// Record this tick's command
		uint64_t tick = (uint64_t)gpGlobals->tickcount - m_PlayerChoreo[iPlayerIndex].RecordStartTick;
		CUserCmd* cmd = new CUserCmd;
		cmd->buttons = pUserCmds->buttons;
		cmd->command_number = pUserCmds->command_number;
		cmd->forwardmove = pUserCmds->forwardmove;
		cmd->hasbeenpredicted = pUserCmds->hasbeenpredicted;
		cmd->impulse = pUserCmds->impulse;
		cmd->mousedx = pUserCmds->mousedx;
		cmd->mousedy = pUserCmds->mousedy;
		cmd->random_seed = pUserCmds->random_seed;
		cmd->sidemove = pUserCmds->sidemove;
		cmd->tick_count = (int)tick;
		cmd->upmove = pUserCmds->upmove;
		cmd->viewangles = pUserCmds->viewangles;
		cmd->weaponselect = pUserCmds->weaponselect;
		cmd->weaponsubtype = pUserCmds->weaponsubtype;
		m_PlayerChoreo[iPlayerIndex].PlaybackTick = tick;
		m_PlayerChoreo[iPlayerIndex].CmdList->InsertOrReplace( tick, cmd );
		return;
	}

	if ( pPlayer->IsFakeClient() && m_PlayerChoreo[iPlayerIndex].bIsInterruptable )
	{
		CTFBot* pBot = dynamic_cast<CTFBot *>( pPlayer );
		if ( pBot )
		{
			const CKnownEntity* threat = pBot->GetVisionInterface()->GetPrimaryKnownThreat();
			if ( threat && threat->IsVisibleInFOVNow() )
			{
				Stop( iPlayerIndex );
				IScriptVM* pVM = g_pScriptVM;
				ScriptVariant_t varTable;
				pVM->CreateTable( varTable );
				pVM->SetValue( varTable, "player", ToHScript(pPlayer) );
				RunScriptHook( "choreo_interrupted", varTable );
				return;
			}
		}
	}

	int tick = pUserCmds->tick_count;
	pUserCmds->Reset();

	// Set this tick's command from recording
	int iIndex = m_PlayerChoreo[iPlayerIndex].CmdList->Find( m_PlayerChoreo[iPlayerIndex].PlaybackTick );
	if ( iIndex != m_PlayerChoreo[iPlayerIndex].CmdList->InvalidIndex() )
	{
		auto cmd = m_PlayerChoreo[iPlayerIndex].CmdList->Element(iIndex);
		pUserCmds->buttons = cmd->buttons;
		pUserCmds->command_number = cmd->command_number;
		pUserCmds->forwardmove = cmd->forwardmove;
		pUserCmds->hasbeenpredicted = cmd->hasbeenpredicted;
		pUserCmds->impulse = cmd->impulse;
		pUserCmds->mousedx = cmd->mousedx;
		pUserCmds->mousedy = cmd->mousedy;
		pUserCmds->random_seed = cmd->random_seed;
		pUserCmds->sidemove = cmd->sidemove;
		pUserCmds->tick_count = tick;
		pUserCmds->upmove = cmd->upmove;
		pUserCmds->viewangles = cmd->viewangles;
		pUserCmds->weaponselect = cmd->weaponselect;
		pUserCmds->weaponsubtype = cmd->weaponsubtype;
	}

	m_PlayerChoreo[iPlayerIndex].bIsBlockingCommands = false;

	// Run this tick's client commands
	int iCIndex = m_PlayerChoreo[iPlayerIndex].ClientCmdList->Find( m_PlayerChoreo[iPlayerIndex].PlaybackTick );
	if ( iCIndex != m_PlayerChoreo[iPlayerIndex].ClientCmdList->InvalidIndex() )
	{
		auto cmdtext = m_PlayerChoreo[iPlayerIndex].ClientCmdList->Element( iCIndex );
		CCommand cmd;
		cmd.Tokenize( V_strdup( cmdtext ) );
		TFGameRules()->ClientCommand( pPlayer, cmd );
	}

	m_PlayerChoreo[iPlayerIndex].bIsBlockingCommands = true;

	bool bLastTick = m_PlayerChoreo[iPlayerIndex].PlaybackTick > m_PlayerChoreo[iPlayerIndex].TickCount - 2;
	if ( m_PlayerChoreo[iPlayerIndex].bReversePlayback )
	{
		bLastTick = m_PlayerChoreo[iPlayerIndex].PlaybackTick < 1;
		if ( !bLastTick )
		{
			m_PlayerChoreo[iPlayerIndex].PlaybackTick--;
		}
	}
	else
	{
		if ( !bLastTick )
		{
			m_PlayerChoreo[iPlayerIndex].PlaybackTick++;
		}
	}

	if ( bLastTick )
	{
		switch ( m_PlayerChoreo[iPlayerIndex].iLoopMode )
		{
			default:
			case CHOREO_LOOP_NONE:
			{
				Stop( iPlayerIndex );
				IScriptVM* pVM = g_pScriptVM;
				ScriptVariant_t varTable;
				pVM->CreateTable( varTable );
				pVM->SetValue( varTable, "player", ToHScript(pPlayer) );
				RunScriptHook( "choreo_end", varTable );
				break;
			}
			case CHOREO_LOOP_LINEAR:
			{
				m_PlayerChoreo[iPlayerIndex].PlaybackTick = 0;
				break;
			}
			case CHOREO_LOOP_PINGPONG:
			{
				m_PlayerChoreo[iPlayerIndex].bReversePlayback = !m_PlayerChoreo[iPlayerIndex].bReversePlayback;
				break;
			}
		}
	}
}

bool CChoreoSystem::ClientCommand( CBasePlayer* pPlayer, const CCommand& args )
{
	if ( !pPlayer )
		return true;

	auto iPlayerIndex = pPlayer->entindex();

	if ( IsRecording( iPlayerIndex ) )
	{
		// Recording the client command
		uint64_t tick = (uint64_t)gpGlobals->tickcount - m_PlayerChoreo[iPlayerIndex].RecordStartTick;
		m_PlayerChoreo[iPlayerIndex].ClientCmdList->InsertOrReplace( tick, V_strdup( args.GetCommandString() ) );
		return true;
	}
	else if ( IsPlaying( iPlayerIndex ) && IsBlockingCommands( iPlayerIndex ) )
	{
		return false;
	}
	return true;
}

void CChoreoSystem::LevelInitPreEntity()
{
	Q_memset( m_PlayerChoreo, 0, sizeof( m_PlayerChoreo ) );
}

void CChoreoSystem::LevelShutdownPreEntity()
{
	Q_memset( m_PlayerChoreo, 0, sizeof( m_PlayerChoreo ) );
}

void CChoreoSystem::RoundRestart()
{
	Q_memset( m_PlayerChoreo, 0, sizeof( m_PlayerChoreo ) );
}

void CChoreoSystem::Play( int entindex, const char* pszFile, bool bTeleport )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer || IsRecording( entindex ) )
		return;

	ResetChoreo( entindex );

	if ( !filesystem->FileExists( pszFile, "GAME" ) )
	{
		Msg("Unable to find keyvalues.\n");
		return;
	}
	KeyValuesAD rec( "choreo" );
	CUtlBuffer buffer;
	int size = filesystem->Size( pszFile, "GAME" );
	buffer.EnsureCapacity( size );
	if ( !filesystem->ReadFile( pszFile, "GAME", buffer ) )
	{
		Msg("Unable to parse keyvalues.\n");
		return;
	}
	if ( CLZMA::IsCompressed( (unsigned char *)buffer.Base() ) )
	{
		int originalSize = CLZMA::GetActualSize( (unsigned char *)buffer.Base() );
		unsigned char *pOriginalData = new unsigned char[originalSize];
		CLZMA::Uncompress( (unsigned char *)buffer.Base(), pOriginalData );
		buffer.AssumeMemory( pOriginalData, originalSize, originalSize, CUtlBuffer::READ_ONLY );
		if ( !rec->ReadAsBinary( buffer ) )
		{
			Msg( "Unable to parse keyvalues.\n" );
			return;
		}
	}
	else
	{
		if ( !rec->LoadFromFile( g_pFullFileSystem, pszFile, "GAME" ) )
		{
			Msg( "Unable to parse keyvalues.\n" );
			return;
		}
	}

	m_PlayerChoreo[entindex].bIsPlaying = true;
	m_PlayerChoreo[entindex].bIsBlockingCommands = true;
	m_PlayerChoreo[entindex].TickCount = rec->GetInt( "ticks" );
	QAngle origin;
	UTIL_StringToVector( origin.Base(), rec->GetString( "origin" ) );
	m_PlayerChoreo[entindex].StartOrigin = Vector( origin.x, origin.y, origin.z );
	if ( rec->FindKey( "angles" ) )
	{
		QAngle angles;
		UTIL_StringToVector( angles.Base(), rec->GetString( "angles" ) );
		m_PlayerChoreo[entindex].StartAngles = QAngle( angles.x, angles.y, angles.z );
	}
	if ( rec->FindKey( "velocity" ) )
	{
		QAngle vel;
		UTIL_StringToVector( vel.Base(), rec->GetString( "velocity" ) );
		m_PlayerChoreo[entindex].StartVelocity = Vector( vel.x, vel.y, vel.z );
	}

	KeyValues* dataKey = rec->FindKey( "data" );
	KeyValues* tickKey = dataKey->GetFirstSubKey();
	while ( tickKey )
	{
		uint64_t tick = V_atoui64( tickKey->GetName() );

		CUserCmd* cmd = new CUserCmd;
		cmd->buttons = tickKey->GetInt( "btn" );
		cmd->command_number = tickKey->GetInt( "cmd" );
		cmd->forwardmove = tickKey->GetFloat( "fwd" );
		cmd->hasbeenpredicted = false;
		cmd->impulse = tickKey->GetInt( "imp" );
		cmd->mousedx = tickKey->GetInt( "mdx" );
		cmd->mousedy = tickKey->GetInt( "mdy" );
		cmd->random_seed = tickKey->GetInt( "seed" );
		cmd->sidemove = tickKey->GetFloat( "side" );
		cmd->tick_count = 0;
		cmd->upmove = tickKey->GetFloat( "up" );
		QAngle vangles;
		UTIL_StringToVector( vangles.Base(), tickKey->GetString( "view" ) );
		cmd->viewangles = QAngle( vangles.x, vangles.y, vangles.z );
		cmd->weaponselect = tickKey->GetInt( "wsel" );
		cmd->weaponsubtype = tickKey->GetInt( "wtyp" );
		m_PlayerChoreo[entindex].CmdList->InsertOrReplace( tick, cmd );
		if ( tickKey->FindKey( "ccmd" ) )
		{
			const char* ccmd = tickKey->GetString( "ccmd" );
			m_PlayerChoreo[entindex].ClientCmdList->InsertOrReplace( tick, V_strdup( ccmd ) );
		}

		tickKey = tickKey->GetNextKey();
	}

	if ( bTeleport )
	{
		pPlayer->Teleport( &m_PlayerChoreo[entindex].StartOrigin, &m_PlayerChoreo[entindex].StartAngles, &m_PlayerChoreo[entindex].StartVelocity );
	}

}

void CChoreoSystem::Pause( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return;

	m_PlayerChoreo[entindex].bIsPaused = true;
	m_PlayerChoreo[entindex].bIsBlockingCommands = false;
}

void CChoreoSystem::Resume( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return;

	m_PlayerChoreo[entindex].bIsPaused = false;
	m_PlayerChoreo[entindex].bIsBlockingCommands = true;
}

void CChoreoSystem::Seek( int entindex, int iTick )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return;

	m_PlayerChoreo[entindex].PlaybackTick = iTick;
}

void CChoreoSystem::Stop( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return;

	ResetChoreo( entindex );
}

void CChoreoSystem::RecordStart( int entindex, const char* pszFile )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer || IsPlaying( entindex ) )
		return;

	if ( IsRecording( entindex ) )
	{
		RecordStop( entindex );
		return;
	}

	ResetChoreo( entindex );
	m_PlayerChoreo[entindex].bIsRecording = true;
	m_PlayerChoreo[entindex].pszRecordFile = V_strdup( pszFile );
	m_PlayerChoreo[entindex].RecordStartTick = (uint64_t)gpGlobals->tickcount;
	m_PlayerChoreo[entindex].StartOrigin = pPlayer->GetAbsOrigin();
	m_PlayerChoreo[entindex].StartAngles = pPlayer->GetAbsAngles();
	m_PlayerChoreo[entindex].StartVelocity = pPlayer->GetAbsVelocity();
}

void CChoreoSystem::RecordStop( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer || !IsRecording( entindex ) )
		return;

	m_PlayerChoreo[entindex].TickCount = (uint64_t)gpGlobals->tickcount - m_PlayerChoreo[entindex].RecordStartTick;

	KeyValuesAD rec("choreo");
	
	rec->SetInt( "ticks", m_PlayerChoreo[entindex].TickCount );
	char szOrigin[1024];
	char szAngles[1024];
	char szVel[1024];
	Q_snprintf( szOrigin, 1024, "%f %f %f",
		m_PlayerChoreo[entindex].StartOrigin.x,
		m_PlayerChoreo[entindex].StartOrigin.y,
		m_PlayerChoreo[entindex].StartOrigin.z );
	Q_snprintf( szAngles, 1024, "%f %f %f",
		m_PlayerChoreo[entindex].StartAngles.x,
		m_PlayerChoreo[entindex].StartAngles.y,
		m_PlayerChoreo[entindex].StartAngles.z );
	Q_snprintf( szVel, 1024, "%f %f %f",
		m_PlayerChoreo[entindex].StartVelocity.x,
		m_PlayerChoreo[entindex].StartVelocity.y,
		m_PlayerChoreo[entindex].StartVelocity.z );
	rec->SetString( "origin", V_strdup( szOrigin ) );
	rec->SetString( "angles", V_strdup( szAngles ) );
	rec->SetString( "velocity", V_strdup( szVel ) );

	KeyValues* dataKey = new KeyValues( "data" );
	auto elemind = m_PlayerChoreo[entindex].CmdList->FirstInorder();
	auto elem = m_PlayerChoreo[entindex].CmdList->Element( elemind );
	auto elemkey = m_PlayerChoreo[entindex].CmdList->Key( elemind );
	while ( true )
	{
		char szAnsi[1024];
		Q_snprintf( szAnsi, 1024, "%llu", elemkey );

		KeyValues* tickKey = new KeyValues( szAnsi );
		tickKey->SetInt( "btn", elem->buttons );
		tickKey->SetInt( "cmd", elem->command_number );
		tickKey->SetFloat( "fwd", elem->forwardmove );
		tickKey->SetInt( "imp", elem->impulse );
		tickKey->SetInt( "mdx", elem->mousedx );
		tickKey->SetInt( "mdy", elem->mousedy );
		tickKey->SetInt( "seed", elem->random_seed );
		tickKey->SetFloat( "side", elem->sidemove );
		tickKey->SetFloat( "up", elem->upmove );
		char szVAngles[1024];
		Q_snprintf( szVAngles, 1024, "%f %f %f",
			elem->viewangles.x,
			elem->viewangles.y,
			elem->viewangles.z );
		tickKey->SetString( "view", V_strdup( szVAngles ) );
		tickKey->SetInt( "wsel", elem->weaponselect );
		tickKey->SetInt( "wtyp", elem->weaponsubtype );

		int iCIndex = m_PlayerChoreo[entindex].ClientCmdList->Find(elemkey);
		if ( iCIndex != m_PlayerChoreo[entindex].ClientCmdList->InvalidIndex() )
		{
			auto cmdtext = m_PlayerChoreo[entindex].ClientCmdList->Element( iCIndex );
			tickKey->SetString( "ccmd", V_strdup( cmdtext ) );
		}

		dataKey->AddSubKey( tickKey );

		elemind = m_PlayerChoreo[entindex].CmdList->NextInorder( elemind );
		if ( elemind != m_PlayerChoreo[entindex].CmdList->InvalidIndex() )
		{
			elem = m_PlayerChoreo[entindex].CmdList->Element( elemind );
			elemkey = m_PlayerChoreo[entindex].CmdList->Key( elemind );
		}
		else
		{
			break;
		}
	}
	rec->AddSubKey(dataKey);

	if ( choreo_record_compressed.GetBool() )
	{
		CUtlBuffer buffer;
		rec->WriteAsBinary( buffer );
		int outLength = buffer.TellPut();

		unsigned int compressedSize = 0;
		unsigned char* pCompressedOutput = LZMA_Compress( (unsigned char*)buffer.Base(), outLength, &compressedSize );
		if ( !pCompressedOutput || compressedSize < sizeof(lzma_header_t) )
		{
			Warning( "LZMA compression failed\n" );
			return;
		}

		CUtlBuffer compressionBuffer;
		compressionBuffer.EnsureCapacity( compressedSize );
		compressionBuffer.Put( pCompressedOutput, compressedSize );

		if ( !filesystem->WriteFile( m_PlayerChoreo[entindex].pszRecordFile, "MOD", compressionBuffer ) )
		{
			Warning( "Recording save failed\n" );
			return;
		}

		free( pCompressedOutput );
		pCompressedOutput = NULL;
	}
	else
	{
		rec->SaveToFile( g_pFullFileSystem, m_PlayerChoreo[entindex].pszRecordFile );
	}

	ResetChoreo( entindex );
}

uint64_t CChoreoSystem::GetTick( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return 0;

	return m_PlayerChoreo[entindex].PlaybackTick;
}

uint64_t CChoreoSystem::GetTickCount( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return 0;

	return m_PlayerChoreo[entindex].TickCount;
}

void CChoreoSystem::SetTickCount( int entindex, uint64_t count )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return;

	m_PlayerChoreo[entindex].TickCount = count;
}

bool CChoreoSystem::IsPlaying( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return false;

	return m_PlayerChoreo[entindex].bIsPlaying;
}

bool CChoreoSystem::IsRecording( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return false;

	return m_PlayerChoreo[entindex].bIsRecording;
}

bool CChoreoSystem::IsBlockingCommands( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return false;

	return m_PlayerChoreo[entindex].bIsBlockingCommands;
}

int CChoreoSystem::GetLoopMode( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return ChoreoLoopMode::CHOREO_LOOP_NONE;

	return m_PlayerChoreo[entindex].iLoopMode;
}

void CChoreoSystem::SetLoopMode( int entindex, int iLoopMode )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return;

	m_PlayerChoreo[entindex].iLoopMode = iLoopMode;
}

void CChoreoSystem::SetInterruptable( int entindex, bool bInterrupt )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return;

	m_PlayerChoreo[entindex].bIsInterruptable = bInterrupt;
}

void CChoreoSystem::Enqueue( int entindex, const char* pszFile, bool bInterrupt )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer || IsRecording( entindex ) )
		return;

	Play( entindex, pszFile, false );
	Pause( entindex );
	m_PlayerChoreo[entindex].bIsInterruptable = bInterrupt;

	if ( pPlayer->IsFakeClient() )
	{
		CTFBot* pBot = dynamic_cast< CTFBot* >( pPlayer );
		if ( pBot )
		{
			pBot->SetMission( CTFBot::MISSION_CHOREO, false );
		}
	}
}

Vector CChoreoSystem::GetStartOrigin( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return vec3_origin;

	return m_PlayerChoreo[entindex].StartOrigin;
}

QAngle CChoreoSystem::GetStartAngles( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return vec3_angle;

	return m_PlayerChoreo[entindex].StartAngles;
}

Vector CChoreoSystem::GetStartVelocity( int entindex )
{
	CTFPlayer* pPlayer = ToTFPlayer( UTIL_PlayerByIndex( entindex ) );
	if ( !pPlayer )
		return vec3_origin;

	return m_PlayerChoreo[entindex].StartVelocity;
}

void CChoreoSystem::ResetChoreo( int entindex )
{
	m_PlayerChoreo[entindex].bIsBlockingCommands = false;
	m_PlayerChoreo[entindex].bIsPaused = false;
	m_PlayerChoreo[entindex].bIsPlaying = false;
	m_PlayerChoreo[entindex].bIsRecording = false;
	m_PlayerChoreo[entindex].bReversePlayback = false;
	m_PlayerChoreo[entindex].bIsInterruptable = false;
	m_PlayerChoreo[entindex].iLoopMode = CHOREO_LOOP_NONE;
	m_PlayerChoreo[entindex].PlaybackTick = 0;
	m_PlayerChoreo[entindex].pszRecordFile = NULL;
	m_PlayerChoreo[entindex].StartOrigin = vec3_origin;
	m_PlayerChoreo[entindex].StartAngles = vec3_angle;
	m_PlayerChoreo[entindex].StartVelocity = vec3_origin;
	m_PlayerChoreo[entindex].TickCount = 0;
	m_PlayerChoreo[entindex].RecordStartTick = 0;
	m_PlayerChoreo[entindex].CmdList = new CUtlMap<uint64_t, CUserCmd*>();
	m_PlayerChoreo[entindex].CmdList->SetLessFunc( DefLessFunc( uint64_t ) );
	m_PlayerChoreo[entindex].CmdList->Purge();
	m_PlayerChoreo[entindex].ClientCmdList = new CUtlMap<uint64_t, const char*>();
	m_PlayerChoreo[entindex].ClientCmdList->SetLessFunc(DefLessFunc(uint64_t));
	m_PlayerChoreo[entindex].ClientCmdList->Purge();
}

BEGIN_SCRIPTDESC_ROOT_NAMED( CChoreoSystem, "CChoreo", SCRIPT_SINGLETON "Choreo system access" )

DEFINE_SCRIPTFUNC( Play, "" )
DEFINE_SCRIPTFUNC( Pause, "" )
DEFINE_SCRIPTFUNC( Resume, "" )
DEFINE_SCRIPTFUNC( Seek, "" )
DEFINE_SCRIPTFUNC( Stop, "" )
DEFINE_SCRIPTFUNC( RecordStart, "" )
DEFINE_SCRIPTFUNC( RecordStop, "" )
DEFINE_SCRIPTFUNC( GetTick, "" )
DEFINE_SCRIPTFUNC( GetTickCount, "" )
DEFINE_SCRIPTFUNC( SetTickCount, "" )
DEFINE_SCRIPTFUNC( IsPlaying, "" )
DEFINE_SCRIPTFUNC( IsRecording, "" )
DEFINE_SCRIPTFUNC( GetLoopMode, "" )
DEFINE_SCRIPTFUNC( SetLoopMode, "" )
DEFINE_SCRIPTFUNC( SetInterruptable, "" )
DEFINE_SCRIPTFUNC( Enqueue, "" )
DEFINE_SCRIPTFUNC( GetStartOrigin, "" )
DEFINE_SCRIPTFUNC( GetStartAngles, "" )
DEFINE_SCRIPTFUNC( GetStartVelocity, "" )

END_SCRIPTDESC();