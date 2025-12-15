//========= Copyright Valve Corporation, All rights reserved. ============//
// tf_bot_scenario_monitor.h
// Behavior layer that interrupts for scenario rules (picked up flag, drop what you're doing and capture, etc)
// Michael Booth, May 2011

#include "cbase.h"
#include "fmtstr.h"

#include "tf_gamerules.h"
#include "tf_weapon_pipebomblauncher.h"
#include "trigger_area_capture.h"
#include "NextBot/NavMeshEntities/func_nav_prerequisite.h"

#include "bot/tf_bot.h"
#include "bot/tf_bot_manager.h"
#include "bot/behavior/nav_entities/tf_bot_nav_ent_destroy_entity.h"
#include "bot/behavior/nav_entities/tf_bot_nav_ent_move_to.h"
#include "bot/behavior/nav_entities/tf_bot_nav_ent_wait.h"
#include "bot/behavior/tf_bot_tactical_monitor.h"
#include "bot/behavior/tf_bot_retreat_to_cover.h"
#include "bot/behavior/tf_bot_get_health.h"
#include "bot/behavior/tf_bot_get_ammo.h"
#include "bot/behavior/sniper/tf_bot_sniper_lurk.h"
#include "bot/behavior/scenario/capture_point/tf_bot_capture_point.h"
#include "bot/behavior/scenario/capture_point/tf_bot_defend_point.h"
#include "bot/behavior/scenario/payload/tf_bot_payload_guard.h"
#include "bot/behavior/scenario/payload/tf_bot_payload_push.h"
#include "bot/behavior/scenario/capture_the_flag/tf_bot_defend_flag_capzone.h"
#include "bot/behavior/tf_bot_use_teleporter.h"
#include "bot/behavior/training/tf_bot_training.h"
#include "bot/behavior/tf_bot_destroy_enemy_sentry.h"
#include "bot/behavior/engineer/tf_bot_engineer_building.h"
#include "bot/behavior/spy/tf_bot_spy_infiltrate.h"
#include "bot/behavior/spy/tf_bot_spy_leave_spawn_room.h"
#include "bot/behavior/medic/tf_bot_medic_heal.h"
#include "bot/behavior/engineer/tf_bot_engineer_build.h"
#include "bot/map_entities/tf_bot_hint_sentrygun.h"

#ifdef TF_RAID_MODE
#include "bot/behavior/scenario/raid/tf_bot_wander.h"
#include "bot/behavior/scenario/raid/tf_bot_companion.h"
#include "bot/behavior/scenario/raid/tf_bot_squad_attack.h"
#include "bot/behavior/scenario/raid/tf_bot_guard_area.h"
#endif // TF_RAID_MODE

#include "bot/behavior/tf_bot_attack.h"
#include "bot/behavior/tf_bot_seek_and_destroy.h"
#include "bot/behavior/tf_bot_taunt.h"
#include "bot/behavior/tf_bot_escort.h"
#include "bot/behavior/scenario/capture_the_flag/tf_bot_fetch_flag.h"
#include "bot/behavior/scenario/capture_the_flag/tf_bot_deliver_flag.h"
#include "bot/behavior/scenario/passtime/tf_bot_passtime_ball.h"
#include "bot/behavior/scenario/passtime/tf_bot_passtime_roam.h"
#include "bot/behavior/tf_bot_move_to_vantage_point.h"

#include "bot/behavior/missions/tf_bot_mission_suicide_bomber.h"
#include "bot/behavior/squad/tf_bot_escort_squad_leader.h"
#include "bot/behavior/engineer/mvm_engineer/tf_bot_mvm_engineer_idle.h"
#include "bot/behavior/missions/tf_bot_mission_reprogrammed.h"

#include "bot/behavior/tf_bot_scenario_monitor.h"


extern ConVar tf_bot_health_ok_ratio;
extern ConVar tf_bot_health_critical_ratio;


//-----------------------------------------------------------------------------------------
// Returns the initial Action we will run concurrently as a child to us
Action< CTFBot > *CTFBotScenarioMonitor::InitialContainedAction( CTFBot *me )
{
	m_roamer = false;
	if ( me->IsInASquad() )
	{
		if ( me->GetSquad()->IsLeader( me ) )
		{
			// I'm the leader of this Squad, so I can do what I want and the other Squaddies will support me
			return DesiredScenarioAndClassAction( me );
		}

		// Medics are the exception - they always heal, and have special squad logic in their heal logic
		if ( me->IsPlayerClass( TF_CLASS_MEDIC ) )
		{
			return new CTFBotMedicHeal;
		}

		// I'm in a Squad but not the leader, do "escort and support" Squad behavior
		// until the Squad disbands, and then do my normal thing
		return new CTFBotEscortSquadLeader( DesiredScenarioAndClassAction( me ) );
	}

	return DesiredScenarioAndClassAction( me );
}


//-----------------------------------------------------------------------------------------
// Returns Action specific to the scenario and my class
Action< CTFBot > *CTFBotScenarioMonitor::DesiredScenarioAndClassAction( CTFBot *me )
{
	switch( me->GetMission() )
	{
	case CTFBot::MISSION_SEEK_AND_DESTROY:
		break;

	case CTFBot::MISSION_DESTROY_SENTRIES:
		return new CTFBotMissionSuicideBomber;

	case CTFBot::MISSION_SNIPER:
		return new CTFBotSniperLurk;

	}

#ifdef TF_RAID_MODE
	if ( me->HasAttribute( CTFBot::IS_NPC ) )
	{
		// map-spawned guardians
		return new CTFBotGuardian;
	}
#endif // TF_RAID_MODE

#ifdef TF_RAID_MODE
	if ( TFGameRules()->IsBossBattleMode() )
	{
		if ( me->GetTeamNumber() == TF_TEAM_BLUE )
		{
			// bot teammates
			return new CTFBotCompanion;
		}
		
		if ( me->IsPlayerClass( TF_CLASS_SNIPER ) )
		{
			return new CTFBotSniperLurk;
		}

		if ( me->IsPlayerClass( TF_CLASS_SPY ) )
		{
			return new CTFBotSpyInfiltrate;
		}

		if ( me->IsPlayerClass( TF_CLASS_MEDIC ) )
		{
			return new CTFBotMedicHeal;
		}

		if ( me->IsPlayerClass( TF_CLASS_ENGINEER ) )
		{
			return new CTFBotEngineerBuild;
		}

		return new CTFBotEscort( TFGameRules()->GetActiveBoss() );
	}
	else if ( TFGameRules()->IsRaidMode() )
	{
		if ( me->GetTeamNumber() == TF_TEAM_BLUE )
		{
			// bot teammates
			return new CTFBotCompanion;
		}

		if ( me->IsInASquad() )
		{
			// squad behavior
			return new CTFBotSquadAttack;
		}

		if ( me->IsPlayerClass( TF_CLASS_SCOUT ) || me->HasAttribute( CTFBot::AGGRESSIVE ) )
		{
			return new CTFBotWander;
		}

		if ( me->IsPlayerClass( TF_CLASS_SNIPER ) )
		{
			return new CTFBotSniperLurk;
		}

		if ( me->IsPlayerClass( TF_CLASS_SPY ) )
		{
			return new CTFBotSpyInfiltrate;
		}

		return new CTFBotGuardArea;
	}
#endif // TF_RAID_MODE	

	if ( TFGameRules()->IsMannVsMachineMode() && me->GetTeamNumber() != TF_TEAM_PVE_DEFENDERS )
	{
		if ( me->IsPlayerClass( TF_CLASS_SPY ) )
		{
			return new CTFBotSpyLeaveSpawnRoom;
		}

		if ( me->IsPlayerClass( TF_CLASS_MEDIC ) )
		{
			// if I'm being healed by another medic, I should do something else other than healing
			bool bIsBeingHealedByAMedic = false;
			int nNumHealers = me->m_Shared.GetNumHealers();
			for ( int i=0; i<nNumHealers; ++i )
			{
				CBaseEntity *pHealer = me->m_Shared.GetHealerByIndex(i);
				if ( pHealer && pHealer->IsPlayer() )
				{
					bIsBeingHealedByAMedic = true;
					break;
				}
			}

			if ( !bIsBeingHealedByAMedic )
			{
				return new CTFBotMedicHeal;
			}
		}

		if ( me->IsPlayerClass( TF_CLASS_ENGINEER ) )
		{
			return new CTFBotMvMEngineerIdle;
		}

		// NOTE: Snipers are intentionally left out so they go after the flag. Actual sniping behavior is done as a mission.

		if ( me->HasAttribute( CTFBot::AGGRESSIVE ) )
		{
			// push for the point first, then attack
			return new CTFBotPushToCapturePoint( new CTFBotFetchFlag );
		}

		// capture the flag
		return new CTFBotFetchFlag;
	}

	if ( me->IsPlayerClass( TF_CLASS_SPY ) )
	{
		return new CTFBotSpyInfiltrate;
	}

	if ( !TheTFBots().IsMeleeOnly() && !TFGameRules()->IsInMedievalMode() && !me->HasWeaponRestriction( 1 ) )
	{
		if ( me->IsPlayerClass( TF_CLASS_SNIPER ) )
		{
			return new CTFBotSniperLurk;
		}

		if ( me->IsPlayerClass( TF_CLASS_MEDIC ) )
		{
			return new CTFBotMedicHeal;
		}

		if ( me->IsPlayerClass( TF_CLASS_ENGINEER ) )
		{
			return new CTFBotEngineerBuild;
		}
	}

	if ( me->GetFlagToFetch() )
	{
		// capture the flag
		return new CTFBotFetchFlag;
	}
	else if ( TFGameRules()->GetGameType() == TF_GAMETYPE_ESCORT && TFGameRules()->GetHUDType() != TF_HUDTYPE_CP )
	{
		if ( TFGameRules()->HasMultipleTrains() )
		{
			return new CTFBotPayloadPush;
		}
		else
		{
			if ( me->GetTeamNumber() == TF_TEAM_BLUE )
			{
				// blu is pushing
				return new CTFBotPayloadPush;
			}
			else if ( me->GetTeamNumber() == TF_TEAM_RED )
			{
				for ( int i = 0; i < ITriggerAreaCaptureAutoList::AutoList().Count(); ++i )
				{
					CTriggerAreaCapture* pArea = static_cast< CTriggerAreaCapture *>( ITriggerAreaCaptureAutoList::AutoList()[i] );
					if ( pArea && pArea->TeamCanCap( TF_TEAM_RED ) )
					{
						// Tug of War
						return new CTFBotPayloadPush;
					}
				}

				// red is blocking
				return new CTFBotPayloadGuard;
			}
		}
	}
	else if ( TFGameRules()->GetGameType() == TF_GAMETYPE_CP || TFGameRules()->GetHUDType() == TF_HUDTYPE_CP )
	{
		// if we have a point we can capture - do it
		CUtlVector< CTeamControlPoint * > captureVector;
		TFGameRules()->CollectCapturePoints( me, &captureVector );

		if ( captureVector.Count() > 0 )
		{
			return new CTFBotCapturePoint;
		}

		// otherwise, defend our point(s) from capture
		CUtlVector< CTeamControlPoint * > defendVector;
		TFGameRules()->CollectDefendPoints( me, &defendVector );

		if ( defendVector.Count() > 0 )
		{
			return new CTFBotDefendPoint;
		}

		// likely KotH mode and/or all points are locked - assume capture
		DevMsg( "%3.2f: %s: Gametype is CP, but I can't find a point to capture or defend!\n", gpGlobals->curtime, me->GetDebugIdentifier() );
		return new CTFBotCapturePoint;
	}
	else
	{
		// MvM Defenders
		if ( TFGameRules()->IsMannVsMachineMode() )
		{
			return new CTFBotDefendFlagCapzone( true );
		}

		// Attack/Defend CTF
		if ( TFGameRules()->GetHUDType() == TF_HUDTYPE_CTF && me->GetEnemyFlagCaptureZone() )
		{
			if ( TFGameRules()->IsAttackDefenseMode() && me->GetTeamNumber() == TF_TEAM_RED )
			{
				// Red is defending
				return new CTFBotDefendFlagCapzone;
			}
		}

		// TOW / Arena PLR
		if ( TFGameRules()->GetPayloadToPush( me->GetTeamNumber() ) || TFGameRules()->HasMultipleTrains() )
		{
			return new CTFBotPayloadPush;
		}

		// if we have a point we can capture - do it
		CUtlVector< CTeamControlPoint * > captureVector;
		TFGameRules()->CollectCapturePoints( me, &captureVector );

		if ( captureVector.Count() > 0 )
		{
			return new CTFBotCapturePoint;
		}

		// otherwise, defend our point(s) from capture
		CUtlVector< CTeamControlPoint * > defendVector;
		TFGameRules()->CollectDefendPoints( me, &defendVector );

		if ( defendVector.Count() > 0 )
		{
			return new CTFBotDefendPoint;
		}

		m_roamer = true;
		// scenario not implemented yet - just fight
		return new CTFBotSeekAndDestroy( -1.0f, true );
	}

	return NULL;
}


//-----------------------------------------------------------------------------------------
ActionResult< CTFBot >	CTFBotScenarioMonitor::OnStart( CTFBot *me, Action< CTFBot > *priorAction )
{
	m_roamer = false;
	m_ignoreLostFlagTimer.Start( 5.0f );
	m_lostFlagTimer.Invalidate();
	return Continue();
}


ConVar tf_bot_fetch_lost_flag_time( "tf_bot_fetch_lost_flag_time", "10", FCVAR_CHEAT, "How long busy TFBots will ignore the dropped flag before they give up what they are doing and go after it" );
ConVar tf_bot_flag_kill_on_touch( "tf_bot_flag_kill_on_touch", "0", FCVAR_CHEAT, "If nonzero, any bot that picks up the flag dies. For testing." );


//-----------------------------------------------------------------------------------------
ActionResult< CTFBot >	CTFBotScenarioMonitor::Update( CTFBot *me, float interval )
{
	// CTF Scenario
	if ( me->HasTheFlag() )
	{
		if ( tf_bot_flag_kill_on_touch.GetBool() )
		{
			me->CommitSuicide( false, true );
			return Done( "Flag kill" );
		}

		// we just picked up the flag - drop what we're doing and take it in
		return SuspendFor( new CTFBotDeliverFlag, "I've picked up the flag! Running it in..." );
	}

	// PASS Time Scenario
	if ( me->m_Shared.HasPasstimeBall() )
	{
		// we just picked up the ball - drop what we're doing and take it in
		return SuspendFor( new CTFBotDeliverBall, "I've picked up the ball! Running it in..." );
	}

	if ( me->HasMission( CTFBot::NO_MISSION ) )
	{
		if ( m_ignoreLostFlagTimer.IsElapsed() && me->IsAllowedToPickUpFlag() )
		{
			CCaptureFlag *flag = me->GetFlagToFetch();

			if ( flag )
			{
				CTFPlayer *carrier = ToTFPlayer( flag->GetOwnerEntity() );
				if ( carrier )
				{
					m_lostFlagTimer.Invalidate();
				}
				else
				{
					// flag is loose
					if ( flag->GetType() == TF_FLAGTYPE_PLAYER_DESTRUCTION )
					{
						// if we're a Medic an actively healing someone, don't interrupt
						if ( !me->MedicGetHealTarget() )
						{
							// we better go get the flag
							return SuspendFor( new CTFBotFetchFlag( TEMPORARY_FLAG_FETCH ), "Fetching lost flag..." );
						}
					}
					else if ( !m_lostFlagTimer.HasStarted() )
					{
						m_lostFlagTimer.Start( tf_bot_fetch_lost_flag_time.GetFloat() );
					}
					else if ( m_lostFlagTimer.IsElapsed() )
					{
						m_lostFlagTimer.Invalidate();

						// if we're a Medic an actively healing someone, don't interrupt
						if ( !me->MedicGetHealTarget() )
						{
							// we better go get the flag
							return SuspendFor( new CTFBotFetchFlag( TEMPORARY_FLAG_FETCH ), "Fetching lost flag..." );
						}
					}
				}
			}

			CPasstimeBall* ball = me->GetBallToFetch();
			if ( ball && !me->MedicGetHealTarget() && me->IsAllowedToPickUpFlag() && ball->GetBallState() == 1 )
			{
				if ( !m_lostFlagTimer.HasStarted() )
				{
					m_lostFlagTimer.Start( RandomFloat( 1.0f, 3.0f ) );
				}
				else if ( m_lostFlagTimer.IsElapsed() )
				{
					m_lostFlagTimer.Invalidate();

					// we better go get the ball
					return SuspendFor( new CTFBotFetchBall( TEMPORARY_FLAG_FETCH ), "Fetching lost ball..." );
				}
			}
		}

		if ( TFGameRules()->IsMannVsMachineMode() && me->GetTeamNumber() != TF_TEAM_PVE_DEFENDERS )
		{
			return Continue();
		}

		if ( m_roamer || !GetActiveChildAction() )
		{
			CCaptureFlag *flag = me->GetFlagToFetch();

			if ( flag && !me->MedicGetHealTarget() && me->IsAllowedToPickUpFlag() )
			{
				CTFPlayer* carrier = ToTFPlayer( flag->GetOwnerEntity() );
				if ( !carrier )
				{
					// we better go get the flag
					return SuspendFor( new CTFBotFetchFlag( TEMPORARY_FLAG_FETCH ), "Fetching lost flag..." );
				}
			}

			CPasstimeBall* ball = me->GetBallToFetch();

			if ( ball && !me->MedicGetHealTarget() && me->IsAllowedToPickUpFlag() && ball->GetBallState() == 1 )
			{
				// we better go get the ball
				return SuspendFor( new CTFBotFetchBall( TEMPORARY_FLAG_FETCH ), "Fetching lost ball..." );
			}

			// TOW / Arena PLR
			if ( TFGameRules()->GetPayloadToPush( me->GetTeamNumber() ) || TFGameRules()->HasMultipleTrains() )
			{
				m_roamer = false;
				return SuspendFor( new CTFBotPayloadPush, "Found payload" );
			}

			// if we have a point we can capture - do it
			CUtlVector< CTeamControlPoint* > captureVector;
			TFGameRules()->CollectCapturePoints( me, &captureVector );

			if ( captureVector.Count() > 0 )
			{
				m_roamer = false;
				return SuspendFor( new CTFBotCapturePoint, "Found capture points" );
			}

			// otherwise, defend our point(s) from capture
			CUtlVector< CTeamControlPoint* > defendVector;
			TFGameRules()->CollectDefendPoints( me, &defendVector );

			if ( defendVector.Count() > 0 )
			{
				m_roamer = false;
				return SuspendFor( new CTFBotDefendPoint, "Found defend points" );
			}

			if ( me->GetEnemyFlagCaptureZone() )
			{
				m_roamer = false;
				return SuspendFor( new CTFBotDefendFlagCapzone, "Found defend zone" );
			}
		}
	}

	return Continue();
}

//-----------------------------------------------------------------------------------------
Action< CTFBot >* CTFBotSituationMonitor::InitialContainedAction( CTFBot* me )
{
	m_bEscapeZone = false;
	return new CTFBotScenarioMonitor;
}

ActionResult< CTFBot >	CTFBotSituationMonitor::OnStart( CTFBot* me, Action< CTFBot >* priorAction )
{
	m_bEscapeZone = false;
	return Continue();
}

ActionResult< CTFBot >	CTFBotSituationMonitor::Update( CTFBot* me, float interval )
{
	if ( me->m_Shared.InCond( TF_COND_PURGATORY ) || me->m_Shared.InCond( TF_COND_HALLOWEEN_IN_HELL )
		|| !V_stricmp( me->GetScriptOverlayMaterial(), "effects/map_afterlife_soul_overlay ") || me->HasTag( "InPurg" ) )
	{
		return SuspendFor( new CTFBotMoveToVantagePoint( -1.0f, true, false ), "I gotta get out of here" );
	}
	else if ( m_bEscapeZone )
	{
		return SuspendFor( new CTFBotMoveToVantagePoint( -1.0f, true, true ), "I gotta get out of here" );
	}

	return Continue();
}

EventDesiredResult< CTFBot > CTFBotSituationMonitor::OnNavAreaChanged( CTFBot* me, CNavArea* newArea, CNavArea* oldArea )
{
	if ( newArea && newArea->HasAttributes( NAV_MESH_NO_HOSTAGES ) )
	{
		m_bEscapeZone = true;
	}
	else
	{
		m_bEscapeZone = false;
	}

	return TryContinue();
}