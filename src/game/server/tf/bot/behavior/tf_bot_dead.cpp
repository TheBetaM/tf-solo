//========= Copyright Valve Corporation, All rights reserved. ============//
// tf_bot_dead.cpp
// Push up daisies
// Michael Booth, May 2009

#include "cbase.h"
#include "tf_player.h"
#include "tf_gamerules.h"
#include "bot/tf_bot.h"
#include "bot/behavior/tf_bot_dead.h"
#include "bot/behavior/tf_bot_behavior.h"
#include "bot/tf_bot_manager.h"

#include "nav_mesh.h"

ConVar tf_bot_mvm_buyback( "tf_bot_mvm_buyback", "1", FCVAR_NONE, "Allow defender bots to buyback" );

//---------------------------------------------------------------------------------------------
ActionResult< CTFBot >	CTFBotDead::OnStart( CTFBot *me, Action< CTFBot > *priorAction )
{
	m_deadTimer.Start();

	return Continue();
}


//---------------------------------------------------------------------------------------------
ActionResult< CTFBot >	CTFBotDead::Update( CTFBot *me, float interval )
{
	if ( me->IsAlive() )
	{
		// how did this happen?
		return ChangeTo( new CTFBotMainAction, "This should not happen!" );
	}

	if ( m_deadTimer.IsGreaterThen( 5.0f ) )
	{
		if ( me->HasAttribute( CTFBot::REMOVE_ON_DEATH ) )
		{
			// remove dead bots
			engine->ServerCommand( UTIL_VarArgs( "kickid %d\n", me->GetUserID() ) );
			if ( me->HasAttribute( CTFBot::QUOTA_MANANGED ) )
			{
				TheTFBots().OnForceKickedBots(1);
			}
		}
		else if ( me->HasAttribute( CTFBot::BECOME_SPECTATOR_ON_DEATH ) )
		{
			me->ChangeTeam( TEAM_SPECTATOR, false, true );
			return Done();
		}
	}

	if ( TFGameRules()->IsPVEModeActive() && tf_bot_mvm_buyback.GetBool() && me->GetTeamNumber() == TF_TEAM_PVE_DEFENDERS && !me->IsPlayerClass( TF_CLASS_SCOUT ) && m_deadTimer.IsGreaterThen( 1.0f ) )
	{
		float flNextRespawn = TFGameRules()->GetNextRespawnWave( me->GetTeamNumber(), me );
		if ( flNextRespawn )
		{
			int iRespawnWait = ( flNextRespawn - gpGlobals->curtime );
			int iEnemiesAlive = 0;
			for ( int i = 1; i <= gpGlobals->maxClients; i++ )
			{
				CTFPlayer* pTFPlayer = ToTFPlayer( UTIL_PlayerByIndex( i ) );
				if ( !pTFPlayer )
					continue;
				if ( pTFPlayer->GetTeamNumber() == TF_TEAM_PVE_DEFENDERS || !pTFPlayer->IsAlive() )
					continue;

				iEnemiesAlive++;
				if ( pTFPlayer->IsMiniBoss() )
				{
					iEnemiesAlive += 10;
				}
			}

			if ( iRespawnWait > 2.0f && iEnemiesAlive >= 10 )
			{
				CCommand args;
				args.Tokenize( "td_buyback\n" );
				me->ClientCommand( args );
				m_deadTimer.Reset();
			}
		}
	}

#ifdef TF_RAID_MODE
	if ( TFGameRules()->IsRaidMode() && me->GetTeamNumber() == TF_TEAM_RED )
	{
		// dead defenders go to spectator for recycling
		me->ChangeTeam( TEAM_SPECTATOR, false, true );
	}
#endif // TF_RAID_MODE

	return Continue();
}

