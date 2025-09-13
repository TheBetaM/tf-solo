//========= Copyright Valve Corporation, All rights reserved. ============//
//
// Purpose: CTF CurrencyPack.
//
//=============================================================================//
#include "cbase.h"
#include "items.h"
#include "tf_gamerules.h"
#include "tf_shareddefs.h"
#include "tf_player.h"
#include "tf_team.h"
#include "engine/IEngineSound.h"
#include "entity_currencypack.h"
#include "tf_gamestats.h"
#include "tf_mann_vs_machine_stats.h"
#include "world.h"
#include "particle_parse.h"
#include "player_vs_environment/tf_population_manager.h"
#include "collisionutils.h"
#include "func_respawnroom.h"
#include "tf_objective_resource.h"
#include "tf_logic_robot_destruction.h"
#include "tf_fx.h"

//=============================================================================
//
// CTF CurrencyPack defines.
//

#define TF_CURRENCYPACK_PICKUP_SOUND	"MVM.MoneyPickup"
#define TF_CURRENCYPACK_VANISH_SOUND	"MVM.MoneyVanish"

#define TF_CURRENCYPACK_BLINK_PERIOD	5.0f		// how long pack blinks before it vanishes
#define TF_CURRENCYPACK_BLINK_DURATION  0.25f		// how long a blink lasts

#define TF_CURRENCYPACK_GLOW_THINK_TIME	0.1f		// how often should we check if cash should glow

#define TF_BONUSPACK_BLINK_TIME 5.f
#define TF_BONUSPACK_REMOVE_TIME 20.f
#define TF_BONUSPACK_PICKUP_TIME 0.5f
#define TF_BONUSPACK_BLINK_CONTEXT "blink_think"
#define TF_BONUSPACK_RED_PICKUP "powercore_embers_red"
#define TF_BONUSPACK_BLUE_PICKUP "powercore_embers_blue"

extern ConVar tf_bonuspack_score;

LINK_ENTITY_TO_CLASS( item_currencypack_large, CCurrencyPack );
LINK_ENTITY_TO_CLASS( item_currencypack_medium, CCurrencyPackMedium );
LINK_ENTITY_TO_CLASS( item_currencypack_small, CCurrencyPackSmall );
LINK_ENTITY_TO_CLASS( item_bonuspack, CCurrencyPackBonus );

LINK_ENTITY_TO_CLASS( item_currencypack_custom, CCurrencyPackCustom );

IMPLEMENT_SERVERCLASS_ST( CCurrencyPack, DT_CurrencyPack )
	SendPropBool( SENDINFO( m_bDistributed ) ),
END_SEND_TABLE()

IMPLEMENT_AUTO_LIST( ICurrencyPackAutoList );


//=============================================================================
//
// CTF CurrencyPack functions.
//

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
CCurrencyPack::CCurrencyPack()
{
	m_nAmount = 0;
	m_nWaveNumber = MannVsMachineStats_GetCurrentWave();
	m_bTouched = false;
	m_bClaimed = false;
	m_bDistributed = false;
	if ( IsBonusPack() )
	{
		m_bAutoMaterialize = false;
	}
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
CCurrencyPack::~CCurrencyPack()
{
}


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCurrencyPack::UpdateOnRemove( void )
{
	BaseClass::UpdateOnRemove();

	if ( IsBonusPack() )
		return;

	if ( g_pPopulationManager && !m_bTouched )
	{
		if ( !m_bDistributed )
		{
			g_pPopulationManager->OnCurrencyPackFade();
		}

		DispatchParticleEffect( "mvm_cash_explosion", GetAbsOrigin(), GetAbsAngles() );
	}

	if ( !m_bDistributed && TFObjectiveResource() )
	{
		TFObjectiveResource()->AddMvMWorldMoney( -m_nAmount );
	}
}


//-----------------------------------------------------------------------------
// Purpose: Always transmitted to clients
//-----------------------------------------------------------------------------
int CCurrencyPack::UpdateTransmitState( void )
{
	return SetTransmitState( FL_EDICT_ALWAYS );
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
int CCurrencyPack::ShouldTransmit( const CCheckTransmitInfo *pInfo )
{
	return FL_EDICT_ALWAYS;
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCurrencyPack::Spawn( void )
{
	BaseClass::Spawn();

	if ( IsBonusPack() )
	{
		PostSpawn();
		return;
	}

	m_blinkCount = 0;
	m_blinkTimer.Invalidate();
	SetContextThink( &CCurrencyPack::BlinkThink, gpGlobals->curtime + GetLifeTime() - TF_CURRENCYPACK_BLINK_PERIOD - RandomFloat( 0.0, TF_CURRENCYPACK_BLINK_DURATION ), "CurrencyPackWaitingToBlinkThink" );
	
	// Force collision size to see if this fixes a bunch of stuck-in-geo issues goes away
	SetCollisionBounds( Vector( -10, -10, -10 ), Vector( 10, 10, 10 ) );

	if ( m_bDistributed )
	{
		DispatchParticleEffect( "mvm_cash_embers_red", PATTACH_ABSORIGIN_FOLLOW, this );
	}
	else
	{
		DispatchParticleEffect( "mvm_cash_embers", PATTACH_ABSORIGIN_FOLLOW, this );
	}

	// Store when this drops for time-based accounting - like with wave collection bonus
	m_nWaveNumber = MannVsMachineStats_GetCurrentWave();

	// if m_nAmount != 0, we already call SetAmount
	m_nAmount = m_nAmount == 0 ? TFGameRules()->CalculateCurrencyAmount_ByType( GetPackSize() ) : m_nAmount;
	MannVsMachineStats_RoundEvent_CreditsDropped( m_nWaveNumber, m_nAmount );
	if ( !m_bDistributed && TFObjectiveResource() )
	{
		TFObjectiveResource()->AddMvMWorldMoney( m_nAmount );
	}
}

//-----------------------------------------------------------------------------
// Purpose: Blink off/on when about to expire and play expire sound
//-----------------------------------------------------------------------------
void CCurrencyPack::BlinkThink( void )
{
	// This means the pack was claimed by a player via Radius Currency Collection and
	// is likely flying toward them.  Regardless, one second later it fires Touch().
	if ( IsClaimed() )
		return;

	++m_blinkCount;

	SetRenderMode( kRenderTransAlpha );

	if ( m_blinkCount & 0x1 )
	{
		SetRenderColorA( 25 );
	}
	else
	{
		SetRenderColorA( 255 );
	}

	SetContextThink( &CCurrencyPack::BlinkThink, gpGlobals->curtime + TF_CURRENCYPACK_BLINK_DURATION, "CurrencyPackBlinkThink" );
}


//-----------------------------------------------------------------------------
// Become touchable when we are at rest
//-----------------------------------------------------------------------------
void CCurrencyPack::ComeToRest( void )
{
	BaseClass::ComeToRest();

	if ( IsClaimed() || m_bDistributed )
		return;

	// if we've come to rest in an area with no nav, just grant the money to the player
	if ( TheNavMesh->GetNavArea( GetAbsOrigin() ) == NULL )
	{
		ForceCollect();
		return;
	}

	// See if we've come to rest in a trigger_hurt
	for ( int i = 0; i < ITriggerHurtAutoList::AutoList().Count(); i++ )
	{
		CTriggerHurt *pTrigger = static_cast<CTriggerHurt*>( ITriggerHurtAutoList::AutoList()[i] );
		if ( !pTrigger->m_bDisabled && pTrigger->PointIsWithin( GetAbsOrigin() ) )
		{
			ForceCollect();
			return;
		}
	}

	// Or a func_respawnroom (robots can drop money in their own spawn)
	for ( int i = 0; i < IFuncRespawnRoomAutoList::AutoList().Count(); i++ )
	{
		CFuncRespawnRoom *pRespawnRoom = static_cast<CFuncRespawnRoom *>( IFuncRespawnRoomAutoList::AutoList()[ i ] );
		if ( pRespawnRoom->PointIsWithin( GetAbsOrigin() ) )
		{
			ForceCollect();
			return;
		}
	}
}

//-----------------------------------------------------------------------------
// Purpose: Forces the pack to be collected
//-----------------------------------------------------------------------------
void CCurrencyPack::ForceCollect( void )
{
	if ( IsBonusPack() )
	{
		if ( CTFRobotDestructionLogic::GetRobotDestructionLogic() )
		{
			CTFRobotDestructionLogic::GetRobotDestructionLogic()->ScorePoints( GetTeamNumber()
				, tf_bonuspack_score.GetInt()
				, SCORE_CORES_COLLECTED
				, NULL );
		}
	}
	else
	{
		TFGameRules()->DistributeCurrencyAmount( m_nAmount );
	}

	m_bTouched = true;
	UTIL_Remove( this );
}

//-----------------------------------------------------------------------------
// Purpose: Sets the value of a custom pack
//-----------------------------------------------------------------------------
void CCurrencyPack::SetAmount( float nAmount )
{
	Assert( GetPackSize() == TF_CURRENCY_PACK_CUSTOM );	// Never set an amount unless we're custom
	m_nAmount = nAmount;
}

//-----------------------------------------------------------------------------
// Purpose: Distribute the money right away
//-----------------------------------------------------------------------------
void CCurrencyPack::DistributedBy( CBasePlayer* pMoneyMaker )
{
	TFGameRules()->DistributeCurrencyAmount( m_nAmount );

	if ( pMoneyMaker )
	{
		CTF_GameStats.Event_PlayerCollectedCurrency( pMoneyMaker, m_nAmount );
	}

	m_bDistributed = true;
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCurrencyPack::Precache( void )
{
	PrecacheScriptSound( TF_CURRENCYPACK_PICKUP_SOUND );
	PrecacheScriptSound( TF_CURRENCYPACK_VANISH_SOUND );
	PrecacheParticleSystem( "mvm_cash_embers" );
	PrecacheParticleSystem( "mvm_cash_explosion" );
	if ( IsBonusPack() )
	{
		PrecacheParticleSystem( TF_BONUSPACK_RED_PICKUP );
		PrecacheParticleSystem( TF_BONUSPACK_BLUE_PICKUP );
		PrecacheParticleSystem( "powercore_alert_blue" );
		PrecacheParticleSystem( "powercore_alert_red" );
	}
	BaseClass::Precache();
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
bool CCurrencyPack::MyTouch( CBasePlayer *pPlayer )
{
	if ( ValidTouch( pPlayer ) && !m_bTouched )
	{
		CTFPlayer *pTFTouchPlayer = ToTFPlayer( pPlayer );
		if ( !pTFTouchPlayer )
			return false;

		if ( TFGameRules() && TFGameRules()->IsMannVsMachineMode() )
		{
			if ( pTFTouchPlayer->IsBot() && pTFTouchPlayer->GetTeamNumber() != TF_TEAM_PVE_DEFENDERS )
				return false;

			// Prevent losing team from grabbing money - screws up stats in checkpoints
			if ( TFGameRules()->State_Get() == GR_STATE_TEAM_WIN )
			{
				if ( TFGameRules()->GetWinningTeam() != pTFTouchPlayer->GetTeamNumber() )
					return false;
			}

			// Scouts gain health when grabbing currency packs
			if ( pTFTouchPlayer->GetPlayerClass()->GetClassIndex() == TF_CLASS_SCOUT )
			{
				const int nCurHealth = pTFTouchPlayer->GetHealth();
				const int nMaxHealth = pTFTouchPlayer->GetMaxHealth();
				int nHealth = nCurHealth < nMaxHealth ? 50 : 25;

				// If we cross the border into insanity, scale the reward
				const int nHealthCap = nMaxHealth * 4;
				if ( nCurHealth > nHealthCap )
				{
					nHealth = RemapValClamped( nCurHealth, nHealthCap, (nHealthCap * 1.5f), 20, 5 );
				}

				pTFTouchPlayer->TakeHealth( nHealth, DMG_IGNORE_MAXHEALTH );
			}

			MannVsMachineStats_PlayerEvent_PickedUpCredits( pTFTouchPlayer, m_nWaveNumber, m_nAmount );

			IGameEvent *event = gameeventmanager->CreateEvent( "mvm_pickup_currency" );
			if ( event )
			{
				event->SetInt( "player", pTFTouchPlayer->entindex() );
				event->SetInt( "currency", m_nAmount );
				gameeventmanager->FireEvent( event );
			}

			// is the money blinking and about to burn up?
			if ( !pTFTouchPlayer->IsBot() && m_blinkCount > 0 )
			{
				pTFTouchPlayer->AwardAchievement( ACHIEVEMENT_TF_MVM_PICKUP_MONEY_ABOUT_TO_EXPIRE );
			}
		}

		CReliableBroadcastRecipientFilter filter;
		EmitSound( filter, entindex(), TF_CURRENCYPACK_PICKUP_SOUND );
		
		if ( !m_bDistributed )
		{
			TFGameRules()->DistributeCurrencyAmount( m_nAmount, pTFTouchPlayer );
			CTF_GameStats.Event_PlayerCollectedCurrency( pTFTouchPlayer, m_nAmount );
		}

		if ( ( !pTFTouchPlayer->IsPlayerClass( TF_CLASS_SPY ) ) ||
			 ( !pTFTouchPlayer->m_Shared.IsStealthed() && !pTFTouchPlayer->m_Shared.InCond( TF_COND_STEALTHED_BLINK ) && !pTFTouchPlayer->m_Shared.InCond( TF_COND_DISGUISED ) ) )
		{
			pTFTouchPlayer->SpeakConceptIfAllowed( MP_CONCEPT_MVM_MONEY_PICKUP );
		}

		pTFTouchPlayer->SetLastObjectiveTime( gpGlobals->curtime );
		
		m_bTouched = true;
	}

	return m_bTouched;
}


//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
const char *CCurrencyPackCustom::GetDefaultPowerupModel( void )
{ 
	// Custom packs should always be set to a value by hand
	Assert( m_nAmount > 0 );

	// Try to pick a model that's appropriate to our drop amount (which is in our multiplier)
	if ( m_nAmount >= 25 )
		return "models/items/currencypack_large.mdl"; 
	if ( m_nAmount >= 10 )
		return "models/items/currencypack_medium.mdl"; 
	return "models/items/currencypack_small.mdl";
}

bool CCurrencyPackBonus::ValidTouch( CBasePlayer* pPlayer )
{
	if ( ( GetTeamNumber() > LAST_SHARED_TEAM ) && ( pPlayer->GetTeamNumber() != GetTeamNumber() ) )
		return false;

	CTFPlayer* pTFPlayer = ToTFPlayer( pPlayer );
	if ( !pTFPlayer )
		return false;

	// No invis spies
	if ( pTFPlayer->m_Shared.InCond( TF_COND_STEALTHED ) || pTFPlayer->m_Shared.GetPercentInvisible() > 0.25f )
		return false;

	// No disguised spies
	if ( pTFPlayer->m_Shared.InCond( TF_COND_DISGUISED ) || pTFPlayer->m_Shared.InCond( TF_COND_DISGUISING ) )
		return false;

	// No bonk'd scouts
	if ( pTFPlayer->m_Shared.InCond( TF_COND_PHASE ) || pTFPlayer->m_Shared.InCond( TF_COND_PASSTIME_INTERCEPTION ) )
		return false;

	// No teleporting players
	if ( pTFPlayer->m_Shared.InCond( TF_COND_SELECTED_TO_TELEPORT ) )
		return false;

	// No invulns
	if ( pTFPlayer->m_Shared.IsInvulnerable() && !TFGameRules()->IsInMadDashMode() )
		return false;

	return BaseClass::ValidTouch( pPlayer );
}

bool CCurrencyPackBonus::MyTouch( CBasePlayer* pPlayer )
{
	if ( ValidTouch( pPlayer ) && gpGlobals->curtime >= m_flCanPickupTime )
	{
		CTFPlayer* pTFPlayer = ToTFPlayer( pPlayer );
		if (!pTFPlayer)
			return true;

		// Play a particle colored the color of the player that picked it up
		Vector vecOrigin = GetAbsOrigin() + Vector(0, 0, 5);
		CPVSFilter pvsfilter( vecOrigin );
		const char* pszParticleName = pPlayer->GetTeamNumber() == TF_TEAM_RED ? TF_BONUSPACK_RED_PICKUP : TF_BONUSPACK_BLUE_PICKUP;
		TE_TFParticleEffect( pvsfilter, 0.f, pszParticleName, vecOrigin, vec3_angle );

		if ( CTFRobotDestructionLogic::GetRobotDestructionLogic() )
		{
			CTFRobotDestructionLogic::GetRobotDestructionLogic()->ScorePoints( GetTeamNumber()
				, tf_bonuspack_score.GetInt()
				, SCORE_CORES_COLLECTED
				, ToTFPlayer( pPlayer ) );
		}

		int iBoostMax = pTFPlayer->m_Shared.GetMaxBuffedHealth();
		// Cap it to the max we'll boost a player's health
		int nHealthToAdd = clamp( 5, 0, iBoostMax - pTFPlayer->GetHealth() );
		// Give health
		pPlayer->TakeHealth( nHealthToAdd, DMG_GENERIC | DMG_IGNORE_MAXHEALTH );

		for ( int i = 0; i < TF_AMMO_COUNT; i++ )
		{
			pPlayer->GiveAmmo( 5, i );
		}

		pPlayer->SetLastObjectiveTime( gpGlobals->curtime );

		return true;
	}

	return false;
}

void CCurrencyPackBonus::BlinkThink()
{
	float flTimeToKill = m_flKillTime - gpGlobals->curtime;
	float flNextBlink = RemapValClamped(flTimeToKill, TF_BONUSPACK_BLINK_TIME, 0.f, 0.5f, 0.1f);

	SetContextThink( &CCurrencyPackBonus::BlinkThink, gpGlobals->curtime + flNextBlink, TF_BONUSPACK_BLINK_CONTEXT );

	SetRenderMode( kRenderTransAlpha );

	++m_nBlinkCount;
	if ( m_nBlinkCount % 2 == 0 )
	{
		SetRenderColorA( 25 );
	}
	else
	{
		SetRenderColorA( 255 );
	}
}

void CCurrencyPackBonus::PostSpawn()
{
	const char* pszParticleName = GetTeamNumber() == TF_TEAM_RED ? "powercore_alert_blue" : "powercore_alert_red";
	DispatchParticleEffect( pszParticleName, PATTACH_POINT_FOLLOW, this, "particle_spawn" );

	SetModel( GetPowerupModel() );
	CollisionProp()->UseTriggerBounds( true, 64 );
	m_flCanPickupTime = gpGlobals->curtime + TF_BONUSPACK_PICKUP_TIME;
	m_nBlinkCount = 0;
	m_flKillTime = gpGlobals->curtime + TF_BONUSPACK_REMOVE_TIME + TF_BONUSPACK_BLINK_TIME;
	SetContextThink( &CCurrencyPackBonus::BlinkThink, gpGlobals->curtime + TF_BONUSPACK_REMOVE_TIME, TF_BONUSPACK_BLINK_CONTEXT );
	SetContextThink( &CCurrencyPackBonus::SUB_Remove, m_flKillTime, "RemoveThink" );
}
