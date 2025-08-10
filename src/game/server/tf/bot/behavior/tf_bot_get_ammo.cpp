//========= Copyright Valve Corporation, All rights reserved. ============//
// tf_bot_get_ammo.h
// Pick up any nearby ammo
// Michael Booth, May 2009

#include "cbase.h"
#include "tf_obj.h"
#include "tf_gamerules.h"
#include "bot/tf_bot.h"
#include "bot/behavior/tf_bot_get_ammo.h"
#include "tf_ammo_pack.h"
#include "halloween/tf_weapon_spellbook.h"
#include "entity_rune.h"

extern ConVar tf_bot_path_lookahead_range;

ConVar tf_bot_ammo_search_range( "tf_bot_ammo_search_range", "5000", FCVAR_CHEAT, "How far bots will search to find ammo around them" );
ConVar tf_bot_crumpkin_search_range( "tf_bot_crumpkin_search_range", "600", FCVAR_CHEAT, "How far bots will search to find crumpkins around them" );
ConVar tf_bot_spell_search_range( "tf_bot_spell_search_range", "1200", FCVAR_CHEAT, "How far bots will search to find spells around them" );
ConVar tf_bot_powerup_search_range( "tf_bot_powerup_search_range", "1200", FCVAR_CHEAT, "How far bots will search to find powerups around them" );
ConVar tf_bot_credits_search_range( "tf_bot_credits_search_range", "2400", FCVAR_CHEAT, "How far bots will search to find credits around them" );
ConVar tf_bot_core_search_range( "tf_bot_core_search_range", "2000", FCVAR_CHEAT, "How far bots will search to find cores around them" );
ConVar tf_bot_debug_ammo_scavenging( "tf_bot_debug_ammo_scavenging", "0", FCVAR_CHEAT );


//---------------------------------------------------------------------------------------------
CTFBotGetAmmo::CTFBotGetAmmo( void )
{
	m_path.Invalidate();
	m_ammo = NULL;
	m_isGoalDispenser = false;
	m_isGoalCrumpkin = false;
	m_isGoalSpell = false;
	m_isGoalPowerup = false;
	m_isGoalMerasmus = false;
	m_isGoalCredits = false;
	m_isGoalCores = false;
	m_isGoalGeneric = false;
}

CTFBotGetAmmo::CTFBotGetAmmo( bool crumpkin )
{
	m_path.Invalidate();
	m_ammo = NULL;
	m_isGoalDispenser = false;
	m_isGoalCrumpkin = crumpkin;
	m_isGoalSpell = false;
	m_isGoalPowerup = false;
	m_isGoalGeneric = false;
	m_isGoalMerasmus = false;
	m_isGoalCredits = false;
	m_isGoalCores = false;
}

CTFBotGetAmmo::CTFBotGetAmmo( bool crumpkin, bool powerup )
{
	m_path.Invalidate();
	m_ammo = NULL;
	m_isGoalDispenser = false;
	m_isGoalCrumpkin = false;
	m_isGoalSpell = false;
	m_isGoalPowerup = false;
	m_isGoalGeneric = true;
	m_isGoalMerasmus = false;
	m_isGoalCredits = false;
	m_isGoalCores = false;
}

//---------------------------------------------------------------------------------------------
class CAmmoFilter : public INextBotFilter
{
public:
	CAmmoFilter( CTFBot *me )
	{
		m_me = me;
		m_ammoArea = NULL;
		m_crumpkin = false;
		m_spell = false;
		m_powerup = false;
		m_credits = false;
		m_cores = false;
	}

	bool IsSelected( const CBaseEntity *constCandidate ) const
	{
		CBaseEntity *candidate = const_cast< CBaseEntity * >( constCandidate );

		m_ammoArea = (CTFNavArea *)TheNavMesh->GetNearestNavArea( candidate->WorldSpaceCenter() );
		if ( !m_ammoArea )
			return false;

		CClosestTFPlayer close( candidate );
		ForEachPlayer( close );

		// if the closest player to this candidate object is an enemy, don't use it
		if ( close.m_closePlayer && !m_me->InSameTeam( close.m_closePlayer ) )
			return false;

		if ( m_spell )
		{
			return candidate->ClassMatches( "tf_spell_pickup" ) && !candidate->IsEffectActive( EF_NODRAW );
		}

		if ( m_credits )
		{
			return candidate->ClassMatches( "item_currencypack*" ) && !candidate->IsEffectActive( EF_NODRAW );
		}

		if ( m_cores )
		{
			return candidate->ClassMatches( "item_bonuspack" ) && !candidate->IsEffectActive( EF_NODRAW ) && candidate->GetTeamNumber() == m_me->GetTeamNumber();
		}

		if ( m_powerup )
		{
			if ( candidate->ClassMatches( "item_powerup_rune" ) && !candidate->IsEffectActive( EF_NODRAW ) )
			{
				CTFRune* rune = dynamic_cast< CTFRune *>( candidate );
				if ( rune->GetRuneTeam() == TEAM_ANY || rune->GetRuneTeam() == m_me->GetTeamNumber() )
					return true;
				if ( m_me->IsPlayerClass( TF_CLASS_SPY ) && m_me->m_Shared.GetDisguiseTeam() == rune->GetRuneTeam() )
					return true;
			}
			return false;
		}

		// resupply cabinets (not assigned a team)
		if ( !m_crumpkin && candidate->ClassMatches( "func_regenerate" ) )
		{
			if ( !m_ammoArea->HasAttributeTF( TF_NAV_SPAWN_ROOM_BLUE | TF_NAV_SPAWN_ROOM_RED ) )
			{
				// Assume any resupply cabinets not in a teamed spawn room are inaccessible.
				// Ex: pl_upward has forward spawn rooms that neither team can use until 
				// certain checkpoints are reached.
				return false;
			}

			if ( ( m_me->GetTeamNumber() == TF_TEAM_RED && m_ammoArea->HasAttributeTF( TF_NAV_SPAWN_ROOM_RED ) ) ||
				 ( m_me->GetTeamNumber() == TF_TEAM_BLUE && m_ammoArea->HasAttributeTF( TF_NAV_SPAWN_ROOM_BLUE ) ) )
			{
				// the supply cabinet is in my spawn room, or not in any spawn room
				return true;
			}
			return false;
		}

		// ignore non-existent ammo to ensure we collect nearby existing ammo
		if ( candidate->IsEffectActive( EF_NODRAW ) )
			return false;

		if ( candidate->ClassMatches( "tf_ammo_pack" ) )
		{
			if ( m_crumpkin )
			{
				CTFAmmoPack* pack = dynamic_cast<CTFAmmoPack *>( candidate );
				return pack->GetPackType() == AP_HALLOWEEN;
			}
			return true;
		}

		if ( m_crumpkin )
			return false;

		if ( candidate->ClassMatches( "item_ammopack*" ) )
			return true;

		if ( m_me->InSameTeam( candidate ) )
		{
			// friendly engineer's dispenser
			if ( candidate->ClassMatches( "obj_dispenser*" ) )
			{
				// for now, assume Engineers want to go fetch ammo boxes unless their dispenser is fully upgraded
				// unless we have no sentry yet, then we need to leech off of buddy's dispenser to get started
				if ( !m_me->IsPlayerClass( TF_CLASS_ENGINEER ) || ( (CBaseObject *)candidate )->GetUpgradeLevel() >= 3 || !m_me->GetObjectOfType( OBJ_SENTRYGUN ) )
				{
					CBaseObject	*dispenser = (CBaseObject *)candidate;
					if ( !dispenser->IsBuilding() && !dispenser->IsDisabled() )
					{
						return true;
					}
				}
			}
		}

		return false;
	}

	CTFBot *m_me;
	mutable CTFNavArea *m_ammoArea;
	bool m_crumpkin;
	bool m_spell;
	bool m_powerup;
	bool m_credits;
	bool m_cores;
};


//---------------------------------------------------------------------------------------------
static CTFBot *s_possibleBot = NULL;
static CHandle< CBaseEntity > s_possibleAmmo = NULL;
static int s_possibleFrame = 0;


CTFBotGetAmmo::CTFBotGetAmmo( CTFBot* me, CBaseEntity* target )
{
	m_path.Invalidate();
	m_ammo = NULL;
	m_isGoalDispenser = false;
	m_isGoalCrumpkin = false;
	m_isGoalSpell = false;
	m_isGoalPowerup = false;
	m_isGoalGeneric = true;
	m_isGoalMerasmus = false;
	m_isGoalCredits = false;
	m_isGoalCores = false;
	s_possibleBot = me;
	s_possibleAmmo = target;
	s_possibleFrame = gpGlobals->framecount;
}

//---------------------------------------------------------------------------------------------
/**
 * Return true if this Action has what it needs to perform right now
 */
bool CTFBotGetAmmo::IsPossible( CTFBot *me )
{
	VPROF_BUDGET( "CTFBotGetAmmo::IsPossible", "NextBot" );

	if ( me->m_Shared.InCond( TF_COND_HALLOWEEN_GHOST_MODE ) )
		return false;

	int i;

	CUtlVector< CNavArea * > nearbyAreaVector;
	CollectSurroundingAreas( &nearbyAreaVector, me->GetLastKnownArea(), tf_bot_ammo_search_range.GetFloat(), me->GetLocomotionInterface()->GetStepHeight(), me->GetLocomotionInterface()->GetDeathDropHeight() );

	CAmmoFilter ammoFilter( me );

	const CUtlVector< CHandle< CBaseEntity > > &staticAmmoVector = TFGameRules()->GetAmmoEntityVector();
	CBaseEntity *closestAmmo = NULL;
	float closestAmmoTravelDistance = FLT_MAX;

	for( i=0; i<staticAmmoVector.Count(); ++i )
	{
		CBaseEntity *ammo = staticAmmoVector[i];
		if ( ammo )
		{
			if ( ammoFilter.IsSelected( ammo ) )
			{
				if ( ammoFilter.m_ammoArea && ammoFilter.m_ammoArea->IsMarked() )
				{
					// "cost so far" was computed during the breadth first search within CollectSurroundingAreas()
					// and is the travel distance from to this area
					if ( ammoFilter.m_ammoArea->GetCostSoFar() < closestAmmoTravelDistance )
					{
						closestAmmo = ammo;
						closestAmmoTravelDistance = ammoFilter.m_ammoArea->GetCostSoFar();
					}

					if ( tf_bot_debug_ammo_scavenging.GetBool() )
					{
						NDebugOverlay::Cross3D( ammo->WorldSpaceCenter(), 5.0f, 255, 255, 0, true, 999.9 );
					}
				}
			}
		}
	}

	// append nearby dropped weapons
	CBaseEntity *ammoPack = NULL;
	while( ( ammoPack = gEntList.FindEntityByClassname( ammoPack, "tf_ammo_pack" ) ) != NULL )
	{
		if ( ammoFilter.IsSelected( ammoPack ) )
		{
			if ( ammoFilter.m_ammoArea && ammoFilter.m_ammoArea->IsMarked() )
			{
				if ( ammoFilter.m_ammoArea->GetCostSoFar() < closestAmmoTravelDistance )
				{
					closestAmmo = ammoPack;
					closestAmmoTravelDistance = ammoFilter.m_ammoArea->GetCostSoFar();
				}

				if ( tf_bot_debug_ammo_scavenging.GetBool() )
				{
					NDebugOverlay::Cross3D( ammoPack->WorldSpaceCenter(), 5.0f, 255, 100, 0, true, 999.9 );
				}
			}
		}
	}

	if ( !closestAmmo )
	{
		if ( me->IsDebugging( NEXTBOT_BEHAVIOR ) )
		{
			Warning( "%3.2f: No ammo nearby\n", gpGlobals->curtime );
		}
		return false;
	}

	s_possibleBot = me;
	s_possibleAmmo = closestAmmo;
	s_possibleFrame = gpGlobals->framecount;

	return true;
}

bool CTFBotGetAmmo::IsCrumpkinPossible( CTFBot* me )
{
	VPROF_BUDGET("CTFBotGetAmmo::IsCrumpkinPossible", "NextBot");

	int i;

	CUtlVector< CNavArea* > nearbyAreaVector;
	CollectSurroundingAreas( &nearbyAreaVector, me->GetLastKnownArea(), tf_bot_crumpkin_search_range.GetFloat(), me->GetLocomotionInterface()->GetStepHeight(), me->GetLocomotionInterface()->GetDeathDropHeight() );

	CAmmoFilter ammoFilter( me );
	ammoFilter.m_crumpkin = true;
	CBaseEntity* closestAmmo = NULL;
	float closestAmmoTravelDistance = FLT_MAX;

	// append nearby crumpkins
	CBaseEntity* ammoPack = NULL;
	while ( ( ammoPack = gEntList.FindEntityByClassname( ammoPack, "tf_ammo_pack" ) ) != NULL )
	{
		if ( ammoFilter.IsSelected( ammoPack ) )
		{
			if ( ammoFilter.m_ammoArea && ammoFilter.m_ammoArea->IsMarked() )
			{
				if ( ammoFilter.m_ammoArea->GetCostSoFar() < closestAmmoTravelDistance )
				{
					closestAmmo = ammoPack;
					closestAmmoTravelDistance = ammoFilter.m_ammoArea->GetCostSoFar();
				}

				if ( tf_bot_debug_ammo_scavenging.GetBool() )
				{
					NDebugOverlay::Cross3D( ammoPack->WorldSpaceCenter(), 5.0f, 255, 100, 0, true, 999.9 );
				}
			}
		}
	}

	if ( !closestAmmo )
	{
		//if ( me->IsDebugging( NEXTBOT_BEHAVIOR ) )
		//{
		//	Log( "%3.2f: No crumpkin nearby\n", gpGlobals->curtime );
		//}
		return false;
	}

	s_possibleBot = me;
	s_possibleAmmo = closestAmmo;
	s_possibleFrame = gpGlobals->framecount;

	return true;
}

bool CTFBotGetAmmo::IsSpellPossible( CTFBot* me )
{
	VPROF_BUDGET("CTFBotGetAmmo::IsSpellPossible", "NextBot");

	int i;

	CUtlVector< CNavArea* > nearbyAreaVector;
	CollectSurroundingAreas( &nearbyAreaVector, me->GetLastKnownArea(), tf_bot_spell_search_range.GetFloat(), me->GetLocomotionInterface()->GetStepHeight(), me->GetLocomotionInterface()->GetDeathDropHeight() );

	CAmmoFilter ammoFilter( me );
	ammoFilter.m_spell = true;
	CBaseEntity* closestAmmo = NULL;
	float closestAmmoTravelDistance = FLT_MAX;

	// append nearby crumpkins
	CBaseEntity* ammoPack = NULL;
	while ( ( ammoPack = gEntList.FindEntityByClassname( ammoPack, "tf_spell_pickup" ) ) != NULL )
	{
		if ( ammoFilter.IsSelected( ammoPack ) )
		{
			if ( ammoFilter.m_ammoArea && ammoFilter.m_ammoArea->IsMarked() )
			{
				if ( ammoFilter.m_ammoArea->GetCostSoFar() < closestAmmoTravelDistance )
				{
					closestAmmo = ammoPack;
					closestAmmoTravelDistance = ammoFilter.m_ammoArea->GetCostSoFar();
				}

				if ( tf_bot_debug_ammo_scavenging.GetBool() )
				{
					NDebugOverlay::Cross3D(ammoPack->WorldSpaceCenter(), 5.0f, 255, 100, 0, true, 999.9);
				}
			}
		}
	}

	if ( !closestAmmo )
	{
		//if ( me->IsDebugging( NEXTBOT_BEHAVIOR ) )
		//{
		//	Log( "%3.2f: No crumpkin nearby\n", gpGlobals->curtime );
		//}
		return false;
	}

	s_possibleBot = me;
	s_possibleAmmo = closestAmmo;
	s_possibleFrame = gpGlobals->framecount;

	return true;
}

bool CTFBotGetAmmo::IsPowerupPossible( CTFBot* me )
{
	VPROF_BUDGET("CTFBotGetAmmo::IsPowerupPossible", "NextBot");

	int i;

	CUtlVector< CNavArea* > nearbyAreaVector;
	CollectSurroundingAreas( &nearbyAreaVector, me->GetLastKnownArea(), tf_bot_powerup_search_range.GetFloat(), me->GetLocomotionInterface()->GetStepHeight(), me->GetLocomotionInterface()->GetDeathDropHeight() );

	CAmmoFilter ammoFilter( me );
	ammoFilter.m_powerup = true;
	CBaseEntity* closestAmmo = NULL;
	float closestAmmoTravelDistance = FLT_MAX;

	// append nearby crumpkins
	CBaseEntity* ammoPack = NULL;
	while ( ( ammoPack = gEntList.FindEntityByClassname( ammoPack, "item_powerup_rune" ) ) != NULL )
	{
		if ( ammoFilter.IsSelected( ammoPack ) )
		{
			if ( ammoFilter.m_ammoArea && ammoFilter.m_ammoArea->IsMarked() )
			{
				if ( ammoFilter.m_ammoArea->GetCostSoFar() < closestAmmoTravelDistance )
				{
					closestAmmo = ammoPack;
					closestAmmoTravelDistance = ammoFilter.m_ammoArea->GetCostSoFar();
				}

				if ( tf_bot_debug_ammo_scavenging.GetBool() )
				{
					NDebugOverlay::Cross3D(ammoPack->WorldSpaceCenter(), 5.0f, 255, 100, 0, true, 999.9);
				}
			}
		}
	}

	if ( !closestAmmo )
	{
		//if ( me->IsDebugging( NEXTBOT_BEHAVIOR ) )
		//{
		//	Log( "%3.2f: No powerup nearby\n", gpGlobals->curtime );
		//}
		return false;
	}

	s_possibleBot = me;
	s_possibleAmmo = closestAmmo;
	s_possibleFrame = gpGlobals->framecount;

	return true;
}

bool CTFBotGetAmmo::IsCreditPossible( CTFBot* me )
{
	VPROF_BUDGET( "CTFBotGetAmmo::IsCreditPossible", "NextBot" );

	int i;

	CUtlVector< CNavArea* > nearbyAreaVector;
	CollectSurroundingAreas( &nearbyAreaVector, me->GetLastKnownArea(), tf_bot_credits_search_range.GetFloat(), me->GetLocomotionInterface()->GetStepHeight(), me->GetLocomotionInterface()->GetDeathDropHeight() );

	CAmmoFilter ammoFilter( me );
	ammoFilter.m_credits = true;
	CBaseEntity* closestAmmo = NULL;
	float closestAmmoTravelDistance = FLT_MAX;

	// append nearby crumpkins
	CBaseEntity* ammoPack = NULL;
	while ( ( ammoPack = gEntList.FindEntityByClassname( ammoPack, "item_currencypack*" ) ) != NULL )
	{
		if ( ammoFilter.IsSelected( ammoPack ) )
		{
			if ( ammoFilter.m_ammoArea && ammoFilter.m_ammoArea->IsMarked() )
			{
				if ( ammoFilter.m_ammoArea->GetCostSoFar() < closestAmmoTravelDistance )
				{
					closestAmmo = ammoPack;
					closestAmmoTravelDistance = ammoFilter.m_ammoArea->GetCostSoFar();
				}

				if ( tf_bot_debug_ammo_scavenging.GetBool() )
				{
					NDebugOverlay::Cross3D(ammoPack->WorldSpaceCenter(), 5.0f, 255, 100, 0, true, 999.9);
				}
			}
		}
	}

	if ( !closestAmmo )
	{
		//if ( me->IsDebugging( NEXTBOT_BEHAVIOR ) )
		//{
		//	Log( "%3.2f: No powerup nearby\n", gpGlobals->curtime );
		//}
		return false;
	}

	s_possibleBot = me;
	s_possibleAmmo = closestAmmo;
	s_possibleFrame = gpGlobals->framecount;

	return true;
}

bool CTFBotGetAmmo::IsCorePossible( CTFBot* me )
{
	VPROF_BUDGET( "CTFBotGetAmmo::IsCorePossible", "NextBot" );

	int i;

	CUtlVector< CNavArea* > nearbyAreaVector;
	CollectSurroundingAreas( &nearbyAreaVector, me->GetLastKnownArea(), tf_bot_core_search_range.GetFloat(), me->GetLocomotionInterface()->GetStepHeight(), me->GetLocomotionInterface()->GetDeathDropHeight() );

	CAmmoFilter ammoFilter( me );
	ammoFilter.m_cores = true;
	CBaseEntity* closestAmmo = NULL;
	float closestAmmoTravelDistance = FLT_MAX;

	// append nearby crumpkins
	CBaseEntity* ammoPack = NULL;
	while ( ( ammoPack = gEntList.FindEntityByClassname( ammoPack, "item_bonuspack" ) ) != NULL )
	{
		if ( ammoFilter.IsSelected( ammoPack ) )
		{
			if ( ammoFilter.m_ammoArea && ammoFilter.m_ammoArea->IsMarked() )
			{
				if ( ammoFilter.m_ammoArea->GetCostSoFar() < closestAmmoTravelDistance )
				{
					closestAmmo = ammoPack;
					closestAmmoTravelDistance = ammoFilter.m_ammoArea->GetCostSoFar();
				}

				if ( tf_bot_debug_ammo_scavenging.GetBool() )
				{
					NDebugOverlay::Cross3D(ammoPack->WorldSpaceCenter(), 5.0f, 255, 100, 0, true, 999.9);
				}
			}
		}
	}

	if ( !closestAmmo )
	{
		//if ( me->IsDebugging( NEXTBOT_BEHAVIOR ) )
		//{
		//	Log( "%3.2f: No powerup nearby\n", gpGlobals->curtime );
		//}
		return false;
	}

	s_possibleBot = me;
	s_possibleAmmo = closestAmmo;
	s_possibleFrame = gpGlobals->framecount;

	return true;
}

//---------------------------------------------------------------------------------------------
ActionResult< CTFBot >	CTFBotGetAmmo::OnStart( CTFBot *me, Action< CTFBot > *priorAction )
{
	VPROF_BUDGET( "CTFBotGetAmmo::OnStart", "NextBot" );

	m_path.SetMinLookAheadDistance( me->GetDesiredPathLookAheadRange() );

	// if IsPossible() has already been called, use its cached data
	if ( s_possibleFrame != gpGlobals->framecount || s_possibleBot != me )
	{
		if ( !IsPossible( me ) || s_possibleAmmo == NULL )
		{
			return Done( "Can't get ammo" );
		}
	}

	m_ammo = s_possibleAmmo;
	m_isGoalDispenser = m_ammo->ClassMatches( "obj_dispenser*" );
	m_isGoalMerasmus = m_ammo->ClassMatches( "merasmus" );
	m_isGoalSpell = m_ammo->ClassMatches( "tf_spell_pickup" );
	m_isGoalPowerup = m_ammo->ClassMatches( "item_powerup_rune" );
	m_isGoalCredits = m_ammo->ClassMatches( "item_currencypack*" );
	m_isGoalCores = m_ammo->ClassMatches( "item_bonuspack" );

	CTFBotPathCost cost( me, FASTEST_ROUTE );
	if ( !m_path.Compute( me, m_ammo->WorldSpaceCenter(), cost ) )
	{
		return Done( "No path to ammo!" );
	}

	// if I'm a spy, cloak and disguise
	if ( me->IsPlayerClass( TF_CLASS_SPY ) && !m_isGoalCrumpkin && !m_isGoalGeneric )
	{
		if ( !me->m_Shared.IsStealthed() )
		{
			me->PressAltFireButton();
		}
	}

	return Continue();
}


//---------------------------------------------------------------------------------------------
ActionResult< CTFBot >	CTFBotGetAmmo::Update( CTFBot *me, float interval )
{
	if ( me->IsAmmoFull() && !m_isGoalCrumpkin && !m_isGoalGeneric )
	{
		return Done( "My ammo is full" );
	}
	
	if ( m_isGoalSpell )
	{
		CTFSpellBook* pSpellBook = dynamic_cast<CTFSpellBook*>( me->GetEntityForLoadoutSlot( LOADOUT_POSITION_ACTION ) );
		if ( !pSpellBook || pSpellBook->HasASpellWithCharges() )
			return Done( "Don't need to look for spells anymore" );
	}

	if ( m_isGoalPowerup )
	{
		if ( me->m_Shared.IsCarryingRune() )
		{
			return Done( "Don't need to look for powerups anymore" );
		}
	}

	if ( m_isGoalMerasmus )
	{
		if ( !me->m_Shared.InCond( TF_COND_HALLOWEEN_BOMB_HEAD ) )
		{
			return Done( "Curse cleared" );
		}
	}

	if ( m_ammo == NULL ) // || ( m_ammo->IsEffectActive( EF_NODRAW ) && !FClassnameIs( m_ammo, "func_regenerate" ) ) )
	{
/*
		// engineers try to gather all the metal they can
		if ( me->IsPlayerClass( TF_CLASS_ENGINEER ) && CTFBotGetAmmo::IsPossible( me ) )
		{
			// more ammo to be had
			return ChangeTo( new CTFBotGetAmmo, "Not full yet - grabbing more ammo" );
		}
*/

		return Done( "Ammo I was going for has been taken" );
	}

	if ( m_isGoalDispenser )
	{
		// we need to get near and wait, not try to run over
		const float nearRange = 75.0f;
		if ( ( me->GetAbsOrigin() - m_ammo->GetAbsOrigin() ).IsLengthLessThan( nearRange ) )
		{
			if ( me->GetVisionInterface()->IsLineOfSightClearToEntity( m_ammo ) )
			{
				if ( me->IsAmmoFull() )
				{
					return Done( "Ammo refilled by the Dispenser" );
				}

				// don't wait if I'm in combat
				if ( !me->IsAmmoLow() && me->GetVisionInterface()->GetPrimaryKnownThreat() )
				{
					return Done( "No time to wait for more ammo, I must fight" );
				}

				// wait until the dispenser refills us
				return Continue();
			}
		}
	}

	if ( !m_path.IsValid() )
	{
		return Done( "My path became invalid" );
	}

/* TODO: Rethink this. Currently creates zombie behavior loop.
	// if the closest player to the item we're after is an enemy, give up
	CClosestTFPlayer close( m_ammo );
	ForEachPlayer( close );
	if ( close.m_closePlayer && !me->InSameTeam( close.m_closePlayer ) )
		return Done( "An enemy is closer to it" );
*/

	// may need to switch weapons due to out of ammo
	const CKnownEntity *threat = me->GetVisionInterface()->GetPrimaryKnownThreat();
	me->EquipBestWeaponForThreat( threat );

	m_path.Update( me );

	return Continue();
}


//---------------------------------------------------------------------------------------------
EventDesiredResult< CTFBot > CTFBotGetAmmo::OnContact( CTFBot *me, CBaseEntity *other, CGameTrace *result )
{
	return TryContinue();
}


//---------------------------------------------------------------------------------------------
EventDesiredResult< CTFBot > CTFBotGetAmmo::OnStuck( CTFBot *me )
{
	return TryDone( RESULT_CRITICAL, "Stuck trying to reach ammo" );
}


//---------------------------------------------------------------------------------------------
EventDesiredResult< CTFBot > CTFBotGetAmmo::OnMoveToSuccess( CTFBot *me, const Path *path )
{
	return TryContinue();
}


//---------------------------------------------------------------------------------------------
EventDesiredResult< CTFBot > CTFBotGetAmmo::OnMoveToFailure( CTFBot *me, const Path *path, MoveToFailureType reason )
{
	return TryDone( RESULT_CRITICAL, "Failed to reach ammo" );
}


//---------------------------------------------------------------------------------------------
QueryResultType CTFBotGetAmmo::ShouldHurry( const INextBot *me ) const
{
	// if we need ammo, we best hustle
	return ANSWER_YES;
}
