#include "cbase.h"

#ifdef GAME_DLL
#include "tf_ammo_pack.h"
#include "tf_player.h"
#endif // GAME_DLL
#include "particle_parse.h"
#include "tf_gamerules.h"
#include "propertydamage_prop.h"
#include "solo/tf_logic_propertydamage.h"

#include "tier0/memdbgon.h"

#define PDA_PROP_AFTERBURN_INTERVAL	1.0f

IMPLEMENT_NETWORKCLASS_ALIASED(TFSOLOPropertyDamageProp, DT_TFSOLOPropertyDamageProp)
IMPLEMENT_NETWORKCLASS_ALIASED(TFSOLOPropertyDamagePhysicsProp, DT_TFSOLOPropertyDamagePhysicsProp)
IMPLEMENT_NETWORKCLASS_ALIASED(TFSOLOPropertyDamageBrush, DT_TFSOLOPropertyDamageBrush)
IMPLEMENT_NETWORKCLASS_ALIASED(TFSOLOPropertyDamageNextBot, DT_TFSOLOPropertyDamageNextBot)

BEGIN_NETWORK_TABLE(CTFSOLOPropertyDamageProp, DT_TFSOLOPropertyDamageProp)
#ifdef GAME_DLL
SendPropFloat(SENDINFO(m_flCurrentDamage)),
SendPropFloat(SENDINFO(m_flLastMaxDamage)),
SendPropBool(SENDINFO(m_bIsOnFire)),
#else
RecvPropFloat(RECVINFO(m_flCurrentDamage)),
RecvPropFloat(RECVINFO(m_flLastMaxDamage)),
RecvPropBool(RECVINFO(m_bIsOnFire)),
#endif
END_NETWORK_TABLE()

BEGIN_NETWORK_TABLE(CTFSOLOPropertyDamagePhysicsProp, DT_TFSOLOPropertyDamagePhysicsProp)
#ifdef GAME_DLL
SendPropFloat(SENDINFO(m_flCurrentDamage)),
SendPropFloat(SENDINFO(m_flLastMaxDamage)),
SendPropBool(SENDINFO(m_bIsOnFire)),
#else
RecvPropFloat(RECVINFO(m_flCurrentDamage)),
RecvPropFloat(RECVINFO(m_flLastMaxDamage)),
RecvPropBool(RECVINFO(m_bIsOnFire)),
#endif
END_NETWORK_TABLE()

BEGIN_NETWORK_TABLE(CTFSOLOPropertyDamageBrush, DT_TFSOLOPropertyDamageBrush)
#ifdef GAME_DLL
SendPropFloat(SENDINFO(m_flCurrentDamage)),
SendPropFloat(SENDINFO(m_flLastMaxDamage)),
SendPropBool(SENDINFO(m_bIsOnFire)),
#else
RecvPropFloat(RECVINFO(m_flCurrentDamage)),
RecvPropFloat(RECVINFO(m_flLastMaxDamage)),
RecvPropBool(RECVINFO(m_bIsOnFire)),
#endif
END_NETWORK_TABLE()

BEGIN_NETWORK_TABLE(CTFSOLOPropertyDamageNextBot, DT_TFSOLOPropertyDamageNextBot)
#ifdef GAME_DLL
SendPropFloat(SENDINFO(m_flCurrentDamage)),
SendPropFloat(SENDINFO(m_flLastMaxDamage)),
SendPropBool(SENDINFO(m_bIsOnFire)),
#else
RecvPropFloat(RECVINFO(m_flCurrentDamage)),
RecvPropFloat(RECVINFO(m_flLastMaxDamage)),
RecvPropBool(RECVINFO(m_bIsOnFire)),
#endif
END_NETWORK_TABLE()

LINK_ENTITY_TO_CLASS( tf_propertydamage_prop, CTFSOLOPropertyDamageProp );
LINK_ENTITY_TO_CLASS( tf_propertydamage_prop_physics, CTFSOLOPropertyDamagePhysicsProp );
LINK_ENTITY_TO_CLASS( func_propertydamage_brush, CTFSOLOPropertyDamageBrush );
LINK_ENTITY_TO_CLASS( tf_propertydamage_nextbot, CTFSOLOPropertyDamageNextBot );

IMPLEMENT_AUTO_LIST( ITFSOLOPropertyDamageProp );
IMPLEMENT_AUTO_LIST( ITFSOLOPropertyDamagePhysicsProp );
IMPLEMENT_AUTO_LIST( ITFSOLOPropertyDamageBrush );
IMPLEMENT_AUTO_LIST( ITFSOLOPropertyDamageNextBot );

BEGIN_DATADESC( CTFSOLOPropertyDamageProp )
DEFINE_KEYFIELD( m_flFixedDamageAmount, FIELD_FLOAT, "fixed_damage_amount" ),
DEFINE_KEYFIELD( m_flLastMaxDamage, FIELD_FLOAT, "starting_damage_amount" ),
DEFINE_KEYFIELD( m_flMaxDamageIncrement, FIELD_FLOAT, "max_damage_increment" ),
DEFINE_KEYFIELD( m_flMaxDamageMult, FIELD_FLOAT, "max_damage_mult" ),
DEFINE_KEYFIELD( m_iCaptureAction, FIELD_INTEGER, "capture_action" ),
DEFINE_KEYFIELD( m_bIsDamageable, FIELD_BOOLEAN, "is_damageable" ),
DEFINE_KEYFIELD( m_bIsSappable, FIELD_BOOLEAN, "is_sappable" ),
DEFINE_KEYFIELD( m_bIsRepairable, FIELD_BOOLEAN, "is_repairable" ),
DEFINE_KEYFIELD( m_bIsIgnitable, FIELD_BOOLEAN, "is_ignitable" ),
#ifdef GAME_DLL
DEFINE_OUTPUT( m_onPropDamaged, "OnPropDamaged" ),
DEFINE_OUTPUT( m_onPropCaptured, "OnPropCaptured" ),
DEFINE_OUTPUT( m_onPropCapturedTeam1, "OnPropCapturedTeam1" ),
DEFINE_OUTPUT( m_onPropCapturedTeam2, "OnPropCapturedTeam2" ),
DEFINE_INPUTFUNC( FIELD_VOID, "RoundActivate", InputRoundActivate ),
DEFINE_INPUTFUNC( FIELD_FLOAT, "SetDamageAmount", InputSetDamageAmount ),
DEFINE_INPUTFUNC( FIELD_BOOLEAN, "SetDamageable", InputSetDamageable ),
DEFINE_INPUTFUNC( FIELD_BOOLEAN, "SetSappable", InputSetSappable ),
DEFINE_INPUTFUNC( FIELD_BOOLEAN, "SetRepairable", InputSetRepairable ),
#endif
END_DATADESC()

BEGIN_DATADESC( CTFSOLOPropertyDamagePhysicsProp )
DEFINE_KEYFIELD( m_flFixedDamageAmount, FIELD_FLOAT, "fixed_damage_amount" ),
DEFINE_KEYFIELD( m_flLastMaxDamage, FIELD_FLOAT, "starting_damage_amount" ),
DEFINE_KEYFIELD( m_flMaxDamageIncrement, FIELD_FLOAT, "max_damage_increment" ),
DEFINE_KEYFIELD( m_flMaxDamageMult, FIELD_FLOAT, "max_damage_mult" ),
DEFINE_KEYFIELD( m_iCaptureAction, FIELD_INTEGER, "capture_action" ),
DEFINE_KEYFIELD( m_bIsDamageable, FIELD_BOOLEAN, "is_damageable" ),
DEFINE_KEYFIELD( m_bIsSappable, FIELD_BOOLEAN, "is_sappable" ),
DEFINE_KEYFIELD( m_bIsRepairable, FIELD_BOOLEAN, "is_repairable" ),
DEFINE_KEYFIELD( m_bIsIgnitable, FIELD_BOOLEAN, "is_ignitable" ),
#ifdef GAME_DLL
DEFINE_OUTPUT( m_onPropDamaged, "OnPropDamaged" ),
DEFINE_OUTPUT( m_onPropCaptured, "OnPropCaptured" ),
DEFINE_OUTPUT( m_onPropCapturedTeam1, "OnPropCapturedTeam1" ),
DEFINE_OUTPUT( m_onPropCapturedTeam2, "OnPropCapturedTeam2" ),
DEFINE_INPUTFUNC( FIELD_VOID, "RoundActivate", InputRoundActivate ),
DEFINE_INPUTFUNC( FIELD_FLOAT, "SetDamageAmount", InputSetDamageAmount ),
DEFINE_INPUTFUNC( FIELD_BOOLEAN, "SetDamageable", InputSetDamageable ),
DEFINE_INPUTFUNC( FIELD_BOOLEAN, "SetSappable", InputSetSappable ),
DEFINE_INPUTFUNC( FIELD_BOOLEAN, "SetRepairable", InputSetRepairable ),
#endif
END_DATADESC()

BEGIN_DATADESC( CTFSOLOPropertyDamageBrush )
DEFINE_KEYFIELD( m_flFixedDamageAmount, FIELD_FLOAT, "fixed_damage_amount" ),
DEFINE_KEYFIELD( m_flLastMaxDamage, FIELD_FLOAT, "starting_damage_amount" ),
DEFINE_KEYFIELD( m_flMaxDamageIncrement, FIELD_FLOAT, "max_damage_increment" ),
DEFINE_KEYFIELD( m_flMaxDamageMult, FIELD_FLOAT, "max_damage_mult" ),
DEFINE_KEYFIELD( m_iCaptureAction, FIELD_INTEGER, "capture_action" ),
DEFINE_KEYFIELD( m_bIsDamageable, FIELD_BOOLEAN, "is_damageable" ),
DEFINE_KEYFIELD( m_bIsSappable, FIELD_BOOLEAN, "is_sappable" ),
DEFINE_KEYFIELD( m_bIsRepairable, FIELD_BOOLEAN, "is_repairable" ),
DEFINE_KEYFIELD( m_bIsIgnitable, FIELD_BOOLEAN, "is_ignitable" ),
#ifdef GAME_DLL
DEFINE_OUTPUT( m_onPropDamaged, "OnPropDamaged" ),
DEFINE_OUTPUT( m_onPropCaptured, "OnPropCaptured" ),
DEFINE_OUTPUT( m_onPropCapturedTeam1, "OnPropCapturedTeam1" ),
DEFINE_OUTPUT( m_onPropCapturedTeam2, "OnPropCapturedTeam2" ),
DEFINE_INPUTFUNC( FIELD_VOID, "RoundActivate", InputRoundActivate ),
DEFINE_INPUTFUNC( FIELD_FLOAT, "SetDamageAmount", InputSetDamageAmount ),
DEFINE_INPUTFUNC( FIELD_BOOLEAN, "SetDamageable", InputSetDamageable ),
DEFINE_INPUTFUNC( FIELD_BOOLEAN, "SetSappable", InputSetSappable ),
DEFINE_INPUTFUNC( FIELD_BOOLEAN, "SetRepairable", InputSetRepairable ),
#endif
END_DATADESC()

BEGIN_DATADESC( CTFSOLOPropertyDamageNextBot )
DEFINE_KEYFIELD( m_bMovementCollide, FIELD_BOOLEAN, "movement_collide" ),

DEFINE_KEYFIELD( m_flFixedDamageAmount, FIELD_FLOAT, "fixed_damage_amount" ),
DEFINE_KEYFIELD( m_flLastMaxDamage, FIELD_FLOAT, "starting_damage_amount" ),
DEFINE_KEYFIELD( m_flMaxDamageIncrement, FIELD_FLOAT, "max_damage_increment" ),
DEFINE_KEYFIELD( m_flMaxDamageMult, FIELD_FLOAT, "max_damage_mult" ),
DEFINE_KEYFIELD( m_iCaptureAction, FIELD_INTEGER, "capture_action" ),
DEFINE_KEYFIELD( m_bIsDamageable, FIELD_BOOLEAN, "is_damageable" ),
DEFINE_KEYFIELD( m_bIsSappable, FIELD_BOOLEAN, "is_sappable" ),
DEFINE_KEYFIELD( m_bIsRepairable, FIELD_BOOLEAN, "is_repairable" ),
DEFINE_KEYFIELD( m_bIsIgnitable, FIELD_BOOLEAN, "is_ignitable" ),
#ifdef GAME_DLL
DEFINE_OUTPUT( m_onPropDamaged, "OnPropDamaged" ),
DEFINE_OUTPUT( m_onPropCaptured, "OnPropCaptured" ),
DEFINE_OUTPUT( m_onPropCapturedTeam1, "OnPropCapturedTeam1" ),
DEFINE_OUTPUT( m_onPropCapturedTeam2, "OnPropCapturedTeam2" ),
DEFINE_INPUTFUNC( FIELD_VOID, "RoundActivate", InputRoundActivate ),
DEFINE_INPUTFUNC( FIELD_FLOAT, "SetDamageAmount", InputSetDamageAmount ),
DEFINE_INPUTFUNC( FIELD_BOOLEAN, "SetDamageable", InputSetDamageable ),
DEFINE_INPUTFUNC( FIELD_BOOLEAN, "SetSappable", InputSetSappable ),
DEFINE_INPUTFUNC( FIELD_BOOLEAN, "SetRepairable", InputSetRepairable ),
#endif
END_DATADESC()

#ifdef GAME_DLL
bool ITFSOLOPropertyDamagePropAll::PropTookDamage( const CTakeDamageInfo& info, int TeamNum, CBaseEntity* pEnt )
{
	CTFPlayer* pTFPlayer = ToTFPlayer( info.GetAttacker() );
	if ( pTFPlayer && pTFPlayer->GetTeamNumber() != TeamNum )
	{
		DispatchParticleEffect( "merasmus_blood", info.GetDamagePosition(), vec3_angle );

		bool isMaxDamage = false;
		if ( m_flFixedDamageAmount > 0.0f )
		{
			SetDamage( MIN( GetDamage() + info.GetDamage(), m_flFixedDamageAmount ) );
			if ( GetDamage() >= m_flFixedDamageAmount )
			{
				SetDamage( 0.0f );
				isMaxDamage = true;
			}
		}
		else
		{
			SetDamage( GetDamage() + info.GetDamage() );
			if ( GetDamage() >= GetMaxDamage() )
			{
				SetMaxDamage( ( GetDamage() + m_flMaxDamageIncrement ) * m_flMaxDamageMult );
				SetDamage( 0.0f );
				isMaxDamage = true;
			}
		}

		if ( !isMaxDamage )
		{
			if ( info.GetDamageCustom() == TF_DMG_CUSTOM_BURNING || info.GetDamageCustom() == TF_DMG_CUSTOM_FLYINGBURN ||
				info.GetDamageCustom() == TF_DMG_CUSTOM_PLASMA_CHARGED || info.GetDamageCustom() == TF_DMG_CUSTOM_BURNING_ARROW ||
				info.GetDamageCustom() == TF_DMG_CUSTOM_FLARE_EXPLOSION || info.GetDamageCustom() == TF_DMG_CUSTOM_FLARE_PELLET ||
				info.GetDamageCustom() == TF_DMG_CUSTOM_BURNING_FLARE || ( info.GetDamageType() & DMG_IGNITE ) )
			{
				m_hBurnAttacker = pTFPlayer;
				m_hBurnWeapon = (CTFWeaponBase*)info.GetWeapon();
				IgniteOnFire();
			}
		}

		IGameEvent* event = gameeventmanager->CreateEvent( "npc_hurt" );
		if ( event )
		{
			event->SetInt( "entindex", pEnt->entindex() );
			if ( isMaxDamage )
			{
				event->SetInt( "health", 0 );
			}
			else
			{
				event->SetInt( "health", 99999 );
			}
			event->SetInt( "damageamount", info.GetDamage() );
			event->SetBool( "crit", ( ( info.GetDamageType() & DMG_CRITICAL ) || isMaxDamage ) ? true : false );
			event->SetInt( "attacker_player", pTFPlayer->GetUserID() );
			if ( pTFPlayer->GetActiveTFWeapon() )
			{
				event->SetInt( "weaponid", pTFPlayer->GetActiveTFWeapon()->GetWeaponID() );
			}
			else
			{
				event->SetInt( "weaponid", 0 );
			}
			gameeventmanager->FireEvent( event );
		}

		return isMaxDamage;
	}
	return false;
}

bool ITFSOLOPropertyDamagePropAll::OnWrenchHit( CTFPlayer* pPlayer, CTFWrench* pWrench, Vector hitLoc, CBaseEntity* pEnt )
{
	// todo: deal damage to sappers

	if ( !IsRepairable() || GetDamage() <= 0.0f )
	{
		return false;
	}

	float flAmount = pWrench->GetRepairAmount();
	float flRepairToMetalRatio = 1.0f; // 3.0f
	float flRepairAmountMax = flAmount * 1.0f;
	int iRepairAmount = MIN( RoundFloatToInt( flRepairAmountMax ), GetDamage() );
	int iRepairCost = ceil( (float)( iRepairAmount ) / flRepairToMetalRatio );
	if ( iRepairCost > pPlayer->GetBuildResources() )
	{
		iRepairCost = pPlayer->GetBuildResources();
	}
	if ( iRepairCost <= 0 )
	{
		return false;
	}

	iRepairAmount = iRepairCost * flRepairToMetalRatio;
	SetDamage( MAX( 0, GetDamage() - iRepairAmount ) );
	pPlayer->RemoveBuildResources( iRepairCost );

	IGameEvent* pEvent = gameeventmanager->CreateEvent( "building_healed" );
	if ( pEvent )
	{
		pEvent->SetInt( "priority", 1 );
		pEvent->SetInt( "building", pEnt->entindex() );
		pEvent->SetInt( "healer", pPlayer->entindex() );
		pEvent->SetInt( "amount", iRepairAmount );
		gameeventmanager->FireEvent( pEvent );
	}
	return true;
}

void ITFSOLOPropertyDamagePropAll::AfterCapture( int oldTeam, CBaseEntity* pEnt, CTFPlayer* pTFPlayer )
{
	pEnt->FireNamedOutput( "OnPropCaptured", variant_t(), pEnt, pTFPlayer );
	if ( pTFPlayer->GetTeamNumber() == TF_TEAM_RED )
	{
		pEnt->FireNamedOutput( "OnPropCapturedTeam1", variant_t(), pEnt, pTFPlayer );
	}
	else if ( pTFPlayer->GetTeamNumber() == TF_TEAM_BLUE )
	{
		pEnt->FireNamedOutput( "OnPropCapturedTeam2", variant_t(), pEnt, pTFPlayer );
	}
	if ( CTFSOLOPropertyDamageLogic::GetPropertyDamageLogic() )
	{
		auto pda_logic = CTFSOLOPropertyDamageLogic::GetPropertyDamageLogic();
		const char* pda_output = "OnPropCapturedTeam1";
		const char* pda_output2 = "OnPropLostTeam2";
		if ( pTFPlayer->GetTeamNumber() == TF_TEAM_BLUE )
		{
			pda_output = "OnPropCapturedTeam2";
			pda_output2 = "OnPropLostTeam1";
		}
		pda_logic->FireNamedOutput( pda_output, variant_t(), pEnt, pTFPlayer );
		if ( ( oldTeam == TF_TEAM_RED && pTFPlayer->GetTeamNumber() == TF_TEAM_BLUE ) ||
			( oldTeam == TF_TEAM_BLUE && pTFPlayer->GetTeamNumber() == TF_TEAM_RED ) )
		{
			pda_logic->FireNamedOutput( pda_output2, variant_t(), pEnt, pTFPlayer );
		}
	}
}
#endif

CTFSOLOPropertyDamageProp::CTFSOLOPropertyDamageProp()
{
	m_flCurrentDamage = 0.0f;
	m_flLastMaxDamage = 0.0f;
	m_flFixedDamageAmount = 0.0f;
	m_iCaptureAction = 0;
	m_flMaxDamageIncrement = 1.0f;
	m_flMaxDamageMult = 1.0f;
	m_bIsDamageable = true;
	m_bIsSappable = true;
	m_bIsRepairable = true;
	m_bIsIgnitable = true;
	m_flOnFireTime = 0.0f;
#ifdef GAME_DLL
	m_hBurnAttacker = NULL;
	m_hBurnWeapon = NULL;
#endif
#ifdef CLIENT_DLL
	m_pBurningEffect = NULL;
#endif
}

#ifdef CLIENT_DLL
void CTFSOLOPropertyDamageProp::Spawn()
{
	BaseClass::Spawn();
	SetNextClientThink( CLIENT_THINK_ALWAYS );
}

void CTFSOLOPropertyDamageProp::ClientThink()
{
	BaseClass::ClientThink();
	if ( m_bIsOnFire && !m_pBurningEffect )
	{
		const char* pEffectName = ( GetTeamNumber() == TF_TEAM_RED ) ? "burningplayer_red" : "burningplayer_blue";
		m_pBurningEffect = ParticleProp()->Create( pEffectName, PATTACH_ABSORIGIN_FOLLOW );
	}
	else if ( !m_bIsOnFire && m_pBurningEffect )
	{
		ParticleProp()->StopEmission( m_pBurningEffect );
		m_pBurningEffect = NULL;
	}
}
#endif

#ifdef GAME_DLL
void CTFSOLOPropertyDamageProp::Spawn()
{
	Precache();
	SetModel( STRING( GetModelName() ) );
	BaseClass::Spawn();
	SetMoveType( MOVETYPE_NONE );
	SetSolid( SOLID_VPHYSICS );
	m_takedamage = DAMAGE_YES;
	m_lifeState = LIFE_ALIVE;
	RemoveFlag( FL_STATICPROP );
	SetMaxHealth( 99999 );
	SetHealth( 99999 );
	if ( m_iCaptureAction == 1 )
	{
		if ( GetTeamNumber() == TF_TEAM_RED )
		{
			SetRenderColor(189, 59, 59);
		}
		else if ( GetTeamNumber() == TF_TEAM_BLUE )
		{
			SetRenderColor(125, 168, 196);
		}
	}
	else if ( m_iCaptureAction == 2 )
	{
		SetSkin( GetTeamNumber() );
	}
	AddFlag( FL_GRENADE );
	m_hBurnAttacker = NULL;
	m_hBurnWeapon = NULL;
}

void CTFSOLOPropertyDamageProp::InputRoundActivate( inputdata_t& inputdata )
{
	if ( m_iCaptureAction == 1 )
	{
		if ( GetTeamNumber() == TF_TEAM_RED )
		{
			SetRenderColor(189, 59, 59);
		}
		else if ( GetTeamNumber() == TF_TEAM_BLUE )
		{
			SetRenderColor(125, 168, 196);
		}
	}
	else if ( m_iCaptureAction == 2 )
	{
		SetSkin( GetTeamNumber() );
	}
}

void CTFSOLOPropertyDamageProp::InputSetDamageAmount( inputdata_t& inputdata )
{
	m_flCurrentDamage = inputdata.value.Float();
}

void CTFSOLOPropertyDamageProp::InputSetDamageable( inputdata_t& inputdata )
{
	m_bIsDamageable = inputdata.value.Bool();
}

void CTFSOLOPropertyDamageProp::InputSetSappable( inputdata_t& inputdata )
{
	m_bIsSappable = inputdata.value.Bool();
}

void CTFSOLOPropertyDamageProp::InputSetRepairable( inputdata_t& inputdata )
{
	m_bIsRepairable = inputdata.value.Bool();
}

void CTFSOLOPropertyDamageProp::Event_Killed( const CTakeDamageInfo &info )
{
	BaseClass::Event_Killed( info );
}


int CTFSOLOPropertyDamageProp::OnTakeDamage( const CTakeDamageInfo &info )
{
	CTFPlayer* pTFPlayer = ToTFPlayer( info.GetAttacker() );
	if ( pTFPlayer && pTFPlayer->GetTeamNumber() != GetTeamNumber() )
	{
		FireNamedOutput( "OnPropDamaged", variant_t(), this, pTFPlayer );
	}
	if ( IsDamageable() && PropTookDamage( info, GetTeamNumber(), this ) )
	{
		if ( pTFPlayer )
		{
			int oldTeam = GetTeamNumber();
			ChangeTeam( pTFPlayer->GetTeamNumber() );
			if ( m_iCaptureAction == 1 )
			{
				if ( pTFPlayer->GetTeamNumber() == TF_TEAM_RED )
				{
					SetRenderColor(189, 59, 59);
				}
				else if ( pTFPlayer->GetTeamNumber() == TF_TEAM_BLUE )
				{
					SetRenderColor(125, 168, 196);
				}
				else
				{
					SetRenderColor(255, 255, 255);
				}
			}
			else if ( m_iCaptureAction == 2 )
			{
				SetSkin( pTFPlayer->GetTeamNumber() );
			}
			m_flOnFireTime = 0.0f;
			m_bIsOnFire = false;

			AfterCapture( oldTeam, this, pTFPlayer );
		}
	}

	CTakeDamageInfo newinfo = info;
	newinfo.SetDamage( 0.0f );
	return BaseClass::OnTakeDamage( newinfo );
}


void CTFSOLOPropertyDamageProp::Touch( CBaseEntity *pOther )
{
	BaseClass::Touch( pOther );

	if ( pOther && pOther->IsPlayer() )
	{
		CTFPlayer *pPlayer = ToTFPlayer( pOther );
		
	}
}

bool CTFSOLOPropertyDamageProp::OverridePropdata()
{
	return true;
}

void CTFSOLOPropertyDamageProp::Deflected( CBaseEntity* pDeflectedBy, Vector& vecDir )
{
	if ( m_bIsOnFire && pDeflectedBy->GetTeamNumber() == GetTeamNumber() )
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
		EmitSound( "TFPlayer.FlameOut" );
	}
}

void CTFSOLOPropertyDamageProp::IgniteOnFire()
{
	if ( !m_bIsIgnitable )
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
		return;
	}

	if ( m_bIsOnFire )
	{
		if ( m_flOnFireTime < 10.0f )
		{
			m_flOnFireTime += 2.0f;
			if ( m_flOnFireTime > 10.0f )
			{
				m_flOnFireTime = 10.0f;
			}
		}
	}
	else
	{
		m_bIsOnFire = true;
		m_flOnFireTime = 5.0f;
		EmitSound( "Player.OnFire" );
		SetContextThink( &CTFSOLOPropertyDamageProp::OnFireThink, gpGlobals->curtime + PDA_PROP_AFTERBURN_INTERVAL, "OnFireThink" );
	}
}

void CTFSOLOPropertyDamageProp::OnFireThink()
{
	if ( !m_bIsOnFire || !m_bIsIgnitable )
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
		return;
	}

	float flBurnDamage = TF_BURNING_DMG;
	int team = GetTeamNumber();
	
	CTakeDamageInfo info( m_hBurnAttacker, m_hBurnAttacker, m_hBurnWeapon, flBurnDamage, DMG_BURN | DMG_PREVENT_PHYSICS_FORCE, TF_DMG_CUSTOM_TRIGGER_HURT );
	TakeDamage( info );

	m_flOnFireTime -= PDA_PROP_AFTERBURN_INTERVAL;

	if ( team == GetTeamNumber() && m_flOnFireTime > 0.0f )
	{
		SetContextThink( &CTFSOLOPropertyDamageProp::OnFireThink, gpGlobals->curtime + PDA_PROP_AFTERBURN_INTERVAL, "OnFireThink" );
	}
	else
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
	}
}

CTFSOLOPropertyDamageProp* CTFSOLOPropertyDamageProp::Create( const Vector& vPosition, const QAngle& qAngles )
{
	CTFSOLOPropertyDamageProp *pPropertyDamageProp = static_cast<CTFSOLOPropertyDamageProp*>( CBaseEntity::Create( "tf_propertydamage_prop", vPosition, qAngles, NULL ) );

	return pPropertyDamageProp;
}


#endif
//=========================================================================//

CTFSOLOPropertyDamagePhysicsProp::CTFSOLOPropertyDamagePhysicsProp()
{
	m_flCurrentDamage = 0.0f;
	m_flLastMaxDamage = 0.0f;
	m_flFixedDamageAmount = 0.0f;
	m_iCaptureAction = 0;
	m_flMaxDamageIncrement = 1.0f;
	m_flMaxDamageMult = 1.0f;
	m_bIsDamageable = true;
	m_bIsSappable = true;
	m_bIsRepairable = true;
	m_bIsIgnitable = true;
	m_flOnFireTime = 0.0f;
#ifdef GAME_DLL
	m_hBurnAttacker = NULL;
	m_hBurnWeapon = NULL;
#endif
#ifdef CLIENT_DLL
	m_pBurningEffect = NULL;
#endif
}

#ifdef CLIENT_DLL
void CTFSOLOPropertyDamagePhysicsProp::Spawn()
{
	BaseClass::Spawn();
	SetNextClientThink( CLIENT_THINK_ALWAYS );
}

void CTFSOLOPropertyDamagePhysicsProp::ClientThink()
{
	BaseClass::ClientThink();
	if ( m_bIsOnFire && !m_pBurningEffect )
	{
		const char* pEffectName = ( GetTeamNumber() == TF_TEAM_RED ) ? "burningplayer_red" : "burningplayer_blue";
		m_pBurningEffect = ParticleProp()->Create( pEffectName, PATTACH_ABSORIGIN_FOLLOW );
	}
	else if ( !m_bIsOnFire && m_pBurningEffect )
	{
		ParticleProp()->StopEmission( m_pBurningEffect );
		m_pBurningEffect = NULL;
	}
}
#endif

#ifdef GAME_DLL
void CTFSOLOPropertyDamagePhysicsProp::Spawn()
{
	Precache();
	SetModel( STRING( GetModelName() ) );
	BaseClass::Spawn();
	SetMoveType( MOVETYPE_VPHYSICS );
	SetSolid( SOLID_VPHYSICS );
	m_takedamage = DAMAGE_YES;
	m_lifeState = LIFE_ALIVE;
	RemoveFlag( FL_STATICPROP );
	SetMaxHealth( 99999 );
	SetHealth( 99999 );
	if ( m_iCaptureAction == 1 )
	{
		if ( GetTeamNumber() == TF_TEAM_RED )
		{
			SetRenderColor(189, 59, 59);
		}
		else if ( GetTeamNumber() == TF_TEAM_BLUE )
		{
			SetRenderColor(125, 168, 196);
		}
	}
	else if ( m_iCaptureAction == 2 )
	{
		SetSkin( GetTeamNumber() );
	}
	AddFlag( FL_GRENADE );
	m_hBurnAttacker = NULL;
	m_hBurnWeapon = NULL;
}

void CTFSOLOPropertyDamagePhysicsProp::InputRoundActivate( inputdata_t& inputdata )
{
	if ( m_iCaptureAction == 1 )
	{
		if ( GetTeamNumber() == TF_TEAM_RED )
		{
			SetRenderColor(189, 59, 59);
		}
		else if ( GetTeamNumber() == TF_TEAM_BLUE )
		{
			SetRenderColor(125, 168, 196);
		}
	}
	else if ( m_iCaptureAction == 2 )
	{
		SetSkin( GetTeamNumber() );
	}
}

void CTFSOLOPropertyDamagePhysicsProp::InputSetDamageAmount( inputdata_t& inputdata )
{
	m_flCurrentDamage = inputdata.value.Float();
}

void CTFSOLOPropertyDamagePhysicsProp::InputSetDamageable( inputdata_t& inputdata )
{
	m_bIsDamageable = inputdata.value.Bool();
}

void CTFSOLOPropertyDamagePhysicsProp::InputSetSappable( inputdata_t& inputdata )
{
	m_bIsSappable = inputdata.value.Bool();
}

void CTFSOLOPropertyDamagePhysicsProp::InputSetRepairable( inputdata_t& inputdata )
{
	m_bIsRepairable = inputdata.value.Bool();
}

void CTFSOLOPropertyDamagePhysicsProp::Event_Killed( const CTakeDamageInfo& info )
{
	BaseClass::Event_Killed( info );
}


int CTFSOLOPropertyDamagePhysicsProp::OnTakeDamage( const CTakeDamageInfo& info )
{
	CTFPlayer* pTFPlayer = ToTFPlayer( info.GetAttacker() );
	if ( pTFPlayer && pTFPlayer->GetTeamNumber() != GetTeamNumber() )
	{
		FireNamedOutput( "OnPropDamaged", variant_t(), this, pTFPlayer );
	}
	if ( IsDamageable() && PropTookDamage( info, GetTeamNumber(), this ) )
	{
		if ( pTFPlayer )
		{
			int oldTeam = GetTeamNumber();
			ChangeTeam( pTFPlayer->GetTeamNumber() );
			if ( m_iCaptureAction == 1 )
			{
				if ( pTFPlayer->GetTeamNumber() == TF_TEAM_RED )
				{
					SetRenderColor(189, 59, 59);
				}
				else if ( pTFPlayer->GetTeamNumber() == TF_TEAM_BLUE )
				{
					SetRenderColor(125, 168, 196);
				}
				else
				{
					SetRenderColor(255, 255, 255);
				}
			}
			else if ( m_iCaptureAction == 2 )
			{
				SetSkin( pTFPlayer->GetTeamNumber() );
			}
			m_flOnFireTime = 0.0f;
			m_bIsOnFire = false;

			AfterCapture( oldTeam, this, pTFPlayer );
		}
	}

	CTakeDamageInfo newinfo = info;
	newinfo.SetDamage( 0.0f );
	return BaseClass::OnTakeDamage( newinfo );
}


void CTFSOLOPropertyDamagePhysicsProp::Touch( CBaseEntity* pOther )
{
	BaseClass::Touch( pOther );

	if ( pOther && pOther->IsPlayer() )
	{
		CTFPlayer* pPlayer = ToTFPlayer( pOther );

	}
}

bool CTFSOLOPropertyDamagePhysicsProp::OverridePropdata()
{
	return true;
}

void CTFSOLOPropertyDamagePhysicsProp::Deflected( CBaseEntity* pDeflectedBy, Vector& vecDir )
{
	if ( m_bIsOnFire && pDeflectedBy->GetTeamNumber() == GetTeamNumber() )
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
		EmitSound( "TFPlayer.FlameOut" );
	}
}

void CTFSOLOPropertyDamagePhysicsProp::IgniteOnFire()
{
	if ( !m_bIsIgnitable )
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
		return;
	}

	if ( m_bIsOnFire )
	{
		if ( m_flOnFireTime < 10.0f )
		{
			m_flOnFireTime += 2.0f;
			if ( m_flOnFireTime > 10.0f )
			{
				m_flOnFireTime = 10.0f;
			}
		}
	}
	else
	{
		m_bIsOnFire = true;
		m_flOnFireTime = 5.0f;
		EmitSound( "Player.OnFire" );
		SetContextThink( &CTFSOLOPropertyDamagePhysicsProp::OnFireThink, gpGlobals->curtime + PDA_PROP_AFTERBURN_INTERVAL, "OnFireThink" );
	}
}

void CTFSOLOPropertyDamagePhysicsProp::OnFireThink()
{
	if ( !m_bIsOnFire || !m_bIsIgnitable )
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
		return;
	}

	float flBurnDamage = TF_BURNING_DMG;
	int team = GetTeamNumber();
	
	CTakeDamageInfo info( m_hBurnAttacker, m_hBurnAttacker, m_hBurnWeapon, flBurnDamage, DMG_BURN | DMG_PREVENT_PHYSICS_FORCE, TF_DMG_CUSTOM_TRIGGER_HURT );
	TakeDamage( info );

	m_flOnFireTime -= PDA_PROP_AFTERBURN_INTERVAL;

	if ( team == GetTeamNumber() && m_flOnFireTime > 0.0f )
	{
		SetContextThink( &CTFSOLOPropertyDamagePhysicsProp::OnFireThink, gpGlobals->curtime + PDA_PROP_AFTERBURN_INTERVAL, "OnFireThink" );
	}
	else
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
	}
}


CTFSOLOPropertyDamagePhysicsProp* CTFSOLOPropertyDamagePhysicsProp::Create(const Vector& vPosition, const QAngle& qAngles)
{
	CTFSOLOPropertyDamagePhysicsProp *pPropertyDamagePhysicsProp = static_cast<CTFSOLOPropertyDamagePhysicsProp *>( CBaseEntity::Create( "tf_propertydamage_prop_physics", vPosition, qAngles, NULL ) );

	return pPropertyDamagePhysicsProp;
}

#endif
//=========================================================================//

CTFSOLOPropertyDamageBrush::CTFSOLOPropertyDamageBrush()
{
	m_flCurrentDamage = 0.0f;
	m_flLastMaxDamage = 0.0f;
	m_flFixedDamageAmount = 0.0f;
	m_iCaptureAction = 0;
	m_flMaxDamageIncrement = 1.0f;
	m_flMaxDamageMult = 1.0f;
	m_bIsDamageable = true;
	m_bIsSappable = true;
	m_bIsRepairable = true;
	m_bIsIgnitable = true;
	m_flOnFireTime = 0.0f;
#ifdef GAME_DLL
	m_hBurnAttacker = NULL;
	m_hBurnWeapon = NULL;
#endif
#ifdef CLIENT_DLL
	m_pBurningEffect = NULL;
#endif
}

#ifdef CLIENT_DLL
void CTFSOLOPropertyDamageBrush::Spawn()
{
	BaseClass::Spawn();
	SetNextClientThink( CLIENT_THINK_ALWAYS );
}

void CTFSOLOPropertyDamageBrush::ClientThink()
{
	BaseClass::ClientThink();
	if ( m_bIsOnFire && !m_pBurningEffect )
	{
		const char* pEffectName = ( GetTeamNumber() == TF_TEAM_RED ) ? "burningplayer_red" : "burningplayer_blue";
		m_pBurningEffect = ParticleProp()->Create( pEffectName, PATTACH_ABSORIGIN_FOLLOW );
	}
	else if ( !m_bIsOnFire && m_pBurningEffect )
	{
		ParticleProp()->StopEmission( m_pBurningEffect );
		m_pBurningEffect = NULL;
	}
}
#endif

#ifdef GAME_DLL
void CTFSOLOPropertyDamageBrush::Spawn()
{
	Precache();
	SetModel( STRING( GetModelName() ) );
	AddEFlags( EFL_USE_PARTITION_WHEN_NOT_SOLID );
	CreateVPhysics();
	SetMoveType( MOVETYPE_NONE );
	SetSolid( SOLID_BSP );
	m_takedamage = DAMAGE_YES;
	m_lifeState = LIFE_ALIVE;
	SetMaxHealth( 99999 );
	SetHealth( 99999 );
	if ( m_iCaptureAction == 1 )
	{
		if ( GetTeamNumber() == TF_TEAM_RED )
		{
			SetRenderColor(189, 59, 59);
		}
		else if ( GetTeamNumber() == TF_TEAM_BLUE )
		{
			SetRenderColor(125, 168, 196);
		}
	}
	AddFlag( FL_GRENADE );
	m_hBurnAttacker = NULL;
	m_hBurnWeapon = NULL;
}

void CTFSOLOPropertyDamageBrush::InputRoundActivate( inputdata_t& inputdata )
{
	if ( m_iCaptureAction == 1 )
	{
		if ( GetTeamNumber() == TF_TEAM_RED )
		{
			SetRenderColor(189, 59, 59);
		}
		else if ( GetTeamNumber() == TF_TEAM_BLUE )
		{
			SetRenderColor(125, 168, 196);
		}
	}
}

void CTFSOLOPropertyDamageBrush::InputSetDamageAmount( inputdata_t& inputdata )
{
	m_flCurrentDamage = inputdata.value.Float();
}

void CTFSOLOPropertyDamageBrush::InputSetDamageable( inputdata_t& inputdata )
{
	m_bIsDamageable = inputdata.value.Bool();
}

void CTFSOLOPropertyDamageBrush::InputSetSappable( inputdata_t& inputdata )
{
	m_bIsSappable = inputdata.value.Bool();
}

void CTFSOLOPropertyDamageBrush::InputSetRepairable( inputdata_t& inputdata )
{
	m_bIsRepairable = inputdata.value.Bool();
}

int CTFSOLOPropertyDamageBrush::OnTakeDamage( const CTakeDamageInfo& info )
{
	CTFPlayer* pTFPlayer = ToTFPlayer( info.GetAttacker() );
	if ( pTFPlayer && pTFPlayer->GetTeamNumber() != GetTeamNumber() )
	{
		FireNamedOutput( "OnPropDamaged", variant_t(), this, pTFPlayer );
	}
	if ( IsDamageable() && PropTookDamage( info, GetTeamNumber(), this ) )
	{
		if ( pTFPlayer )
		{
			int oldTeam = GetTeamNumber();
			ChangeTeam( pTFPlayer->GetTeamNumber() );
			if ( m_iCaptureAction == 1 )
			{
				if ( pTFPlayer->GetTeamNumber() == TF_TEAM_RED )
				{
					SetRenderColor(189, 59, 59);
				}
				else if ( pTFPlayer->GetTeamNumber() == TF_TEAM_BLUE )
				{
					SetRenderColor(125, 168, 196);
				}
				else
				{
					SetRenderColor(255, 255, 255);
				}
			}
			m_flOnFireTime = 0.0f;
			m_bIsOnFire = false;

			AfterCapture( oldTeam, this, pTFPlayer );
		}
	}

	CTakeDamageInfo newinfo = info;
	newinfo.SetDamage( 0.0f );
	return BaseClass::OnTakeDamage( newinfo );
}

void CTFSOLOPropertyDamageBrush::Deflected( CBaseEntity* pDeflectedBy, Vector& vecDir )
{
	if ( m_bIsOnFire && pDeflectedBy->GetTeamNumber() == GetTeamNumber() )
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
		EmitSound( "TFPlayer.FlameOut" );
	}
}

void CTFSOLOPropertyDamageBrush::IgniteOnFire()
{
	if ( !m_bIsIgnitable )
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
		return;
	}

	if ( m_bIsOnFire )
	{
		if ( m_flOnFireTime < 10.0f )
		{
			m_flOnFireTime += 2.0f;
			if ( m_flOnFireTime > 10.0f )
			{
				m_flOnFireTime = 10.0f;
			}
		}
	}
	else
	{
		m_bIsOnFire = true;
		m_flOnFireTime = 5.0f;
		EmitSound( "Player.OnFire" );
		SetContextThink( &CTFSOLOPropertyDamageBrush::OnFireThink, gpGlobals->curtime + PDA_PROP_AFTERBURN_INTERVAL, "OnFireThink" );
	}
}

void CTFSOLOPropertyDamageBrush::OnFireThink()
{
	if ( !m_bIsOnFire || !m_bIsIgnitable )
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
		return;
	}

	float flBurnDamage = TF_BURNING_DMG;
	int team = GetTeamNumber();
	
	CTakeDamageInfo info( m_hBurnAttacker, m_hBurnAttacker, m_hBurnWeapon, flBurnDamage, DMG_BURN | DMG_PREVENT_PHYSICS_FORCE, TF_DMG_CUSTOM_TRIGGER_HURT );
	TakeDamage( info );

	m_flOnFireTime -= PDA_PROP_AFTERBURN_INTERVAL;

	if ( team == GetTeamNumber() && m_flOnFireTime > 0.0f )
	{
		SetContextThink( &CTFSOLOPropertyDamageBrush::OnFireThink, gpGlobals->curtime + PDA_PROP_AFTERBURN_INTERVAL, "OnFireThink" );
	}
	else
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
	}
}

#endif
//=========================================================================//

CTFSOLOPropertyDamageNextBot::CTFSOLOPropertyDamageNextBot()
{
	m_flCurrentDamage = 0.0f;
	m_flLastMaxDamage = 0.0f;
	m_flFixedDamageAmount = 0.0f;
	m_iCaptureAction = 0;
	m_flMaxDamageIncrement = 1.0f;
	m_flMaxDamageMult = 1.0f;
	m_bIsDamageable = true;
	m_bIsSappable = true;
	m_bIsRepairable = true;
	m_bMovementCollide = false;
	m_bIsIgnitable = true;
	m_flOnFireTime = 0.0f;
#ifdef GAME_DLL
	m_hBurnAttacker = NULL;
	m_hBurnWeapon = NULL;
#endif
#ifdef CLIENT_DLL
	m_pBurningEffect = NULL;
#endif
}

#ifdef CLIENT_DLL
void CTFSOLOPropertyDamageNextBot::Spawn()
{
	BaseClass::Spawn();
	SetNextClientThink( CLIENT_THINK_ALWAYS );
}

void CTFSOLOPropertyDamageNextBot::ClientThink()
{
	BaseClass::ClientThink();
	if ( m_bIsOnFire && !m_pBurningEffect )
	{
		const char* pEffectName = ( GetTeamNumber() == TF_TEAM_RED ) ? "burningplayer_red" : "burningplayer_blue";
		m_pBurningEffect = ParticleProp()->Create( pEffectName, PATTACH_ABSORIGIN_FOLLOW );
	}
	else if ( !m_bIsOnFire && m_pBurningEffect )
	{
		ParticleProp()->StopEmission( m_pBurningEffect );
		m_pBurningEffect = NULL;
	}
}
#endif

#ifdef GAME_DLL
void CTFSOLOPropertyDamageNextBot::Spawn()
{
	BaseClass::Spawn();
	m_takedamage = DAMAGE_YES;
	m_lifeState = LIFE_ALIVE;
	SetMaxHealth( 99999 );
	SetHealth( 99999 );
	if ( m_iCaptureAction == 1 )
	{
		if ( GetTeamNumber() == TF_TEAM_RED )
		{
			SetRenderColor(189, 59, 59);
		}
		else if ( GetTeamNumber() == TF_TEAM_BLUE )
		{
			SetRenderColor(125, 168, 196);
		}
	}
	else if ( m_iCaptureAction == 2 )
	{
		SetSkin( GetTeamNumber() );
	}
	AddFlag( FL_GRENADE );
	m_hBurnAttacker = NULL;
	m_hBurnWeapon = NULL;
}

void CTFSOLOPropertyDamageNextBot::InputRoundActivate( inputdata_t& inputdata )
{
	if ( m_iCaptureAction == 1 )
	{
		if ( GetTeamNumber() == TF_TEAM_RED )
		{
			SetRenderColor(189, 59, 59);
		}
		else if ( GetTeamNumber() == TF_TEAM_BLUE )
		{
			SetRenderColor(125, 168, 196);
		}
	}
	else if ( m_iCaptureAction == 2 )
	{
		SetSkin( GetTeamNumber() );
	}
}

void CTFSOLOPropertyDamageNextBot::InputSetDamageAmount( inputdata_t& inputdata )
{
	m_flCurrentDamage = inputdata.value.Float();
}

void CTFSOLOPropertyDamageNextBot::InputSetDamageable( inputdata_t& inputdata )
{
	m_bIsDamageable = inputdata.value.Bool();
}

void CTFSOLOPropertyDamageNextBot::InputSetSappable( inputdata_t& inputdata )
{
	m_bIsSappable = inputdata.value.Bool();
}

void CTFSOLOPropertyDamageNextBot::InputSetRepairable( inputdata_t& inputdata )
{
	m_bIsRepairable = inputdata.value.Bool();
}

int CTFSOLOPropertyDamageNextBot::OnTakeDamage( const CTakeDamageInfo& info )
{
	CTFPlayer* pTFPlayer = ToTFPlayer( info.GetAttacker() );
	if ( pTFPlayer && pTFPlayer->GetTeamNumber() != GetTeamNumber() )
	{
		FireNamedOutput( "OnPropDamaged", variant_t(), this, pTFPlayer );
	}
	if ( IsDamageable() && PropTookDamage( info, GetTeamNumber(), this ) )
	{
		if ( pTFPlayer )
		{
			int oldTeam = GetTeamNumber();
			ChangeTeam( pTFPlayer->GetTeamNumber() );
			if ( m_iCaptureAction == 1 )
			{
				if ( pTFPlayer->GetTeamNumber() == TF_TEAM_RED )
				{
					SetRenderColor(189, 59, 59);
				}
				else if ( pTFPlayer->GetTeamNumber() == TF_TEAM_BLUE )
				{
					SetRenderColor(125, 168, 196);
				}
				else
				{
					SetRenderColor(255, 255, 255);
				}
			}
			else if ( m_iCaptureAction == 2 )
			{
				SetSkin( pTFPlayer->GetTeamNumber() );
			}
			m_flOnFireTime = 0.0f;
			m_bIsOnFire = false;

			AfterCapture( oldTeam, this, pTFPlayer );
		}
	}

	CTakeDamageInfo newinfo = info;
	newinfo.SetDamage( 0.0f );
	return BaseClass::OnTakeDamage( newinfo );
}

void CTFSOLOPropertyDamageNextBot::Deflected( CBaseEntity* pDeflectedBy, Vector& vecDir )
{
	if ( m_bIsOnFire && pDeflectedBy->GetTeamNumber() == GetTeamNumber() )
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
		EmitSound( "TFPlayer.FlameOut" );
	}
}

void CTFSOLOPropertyDamageNextBot::IgniteOnFire()
{
	if ( !m_bIsIgnitable )
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
		return;
	}

	if ( m_bIsOnFire )
	{
		if ( m_flOnFireTime < 10.0f )
		{
			m_flOnFireTime += 2.0f;
			if ( m_flOnFireTime > 10.0f )
			{
				m_flOnFireTime = 10.0f;
			}
		}
	}
	else
	{
		m_bIsOnFire = true;
		m_flOnFireTime = 5.0f;
		EmitSound( "Player.OnFire" );
		SetContextThink( &CTFSOLOPropertyDamageNextBot::OnFireThink, gpGlobals->curtime + PDA_PROP_AFTERBURN_INTERVAL, "OnFireThink" );
	}
}

void CTFSOLOPropertyDamageNextBot::OnFireThink()
{
	if ( !m_bIsOnFire || !m_bIsIgnitable )
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
		return;
	}

	float flBurnDamage = TF_BURNING_DMG;
	int team = GetTeamNumber();
	
	CTakeDamageInfo info( m_hBurnAttacker, m_hBurnAttacker, m_hBurnWeapon, flBurnDamage, DMG_BURN | DMG_PREVENT_PHYSICS_FORCE, TF_DMG_CUSTOM_TRIGGER_HURT );
	TakeDamage( info );

	m_flOnFireTime -= PDA_PROP_AFTERBURN_INTERVAL;

	if ( team == GetTeamNumber() && m_flOnFireTime > 0.0f )
	{
		SetContextThink( &CTFSOLOPropertyDamageNextBot::OnFireThink, gpGlobals->curtime + PDA_PROP_AFTERBURN_INTERVAL, "OnFireThink" );
	}
	else
	{
		m_flOnFireTime = 0.0f;
		m_bIsOnFire = false;
	}
}

int CTFSOLOPropertyDamageNextBot::OnTakeDamage_Alive( const CTakeDamageInfo& info )
{
	CTakeDamageInfo newinfo = info;
	newinfo.SetDamage( 0.0f );
	return BaseClass::BaseClass::OnTakeDamage_Alive( newinfo );
}

bool CTFSOLOPropertyDamageNextBot::ShouldCollide( int collisionGroup, int contentsMask ) const
{
	if ( collisionGroup == COLLISION_GROUP_PLAYER_MOVEMENT && !m_bMovementCollide )
	{
		return false;
	}

	return BaseClass::ShouldCollide( collisionGroup, contentsMask );
}

#endif
