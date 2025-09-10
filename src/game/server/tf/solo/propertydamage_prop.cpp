#include "cbase.h"

#include "tf_ammo_pack.h"
#include "particle_parse.h"
#include "tf_player.h"
#include "tf_gamerules.h"

#include "propertydamage_prop.h"
#include "solo/tf_logic_propertydamage.h"

LINK_ENTITY_TO_CLASS( tf_propertydamage_prop, CTFSOLOPropertyDamageProp );
LINK_ENTITY_TO_CLASS( tf_propertydamage_prop_physics, CTFSOLOPropertyDamagePhysicsProp );
LINK_ENTITY_TO_CLASS( func_propertydamage_brush, CTFSOLOPropertyDamageBrush );

IMPLEMENT_AUTO_LIST( ITFSOLOPropertyDamageProp );
IMPLEMENT_AUTO_LIST( ITFSOLOPropertyDamagePhysicsProp );
IMPLEMENT_AUTO_LIST( ITFSOLOPropertyDamageBrush );

BEGIN_DATADESC( CTFSOLOPropertyDamageProp )
DEFINE_KEYFIELD( m_flFixedDamageAmount, FIELD_FLOAT, "fixed_damage_amount" ),
DEFINE_KEYFIELD( m_flLastMaxDamage, FIELD_FLOAT, "starting_damage_amount" ),
DEFINE_KEYFIELD( m_iCaptureAction, FIELD_INTEGER, "capture_action" ),
DEFINE_OUTPUT( m_onPropDamaged, "OnPropDamaged" ),
DEFINE_INPUTFUNC( FIELD_VOID, "RoundActivate", InputRoundActivate ),
END_DATADESC()

BEGIN_DATADESC( CTFSOLOPropertyDamagePhysicsProp )
DEFINE_KEYFIELD( m_flFixedDamageAmount, FIELD_FLOAT, "fixed_damage_amount" ),
DEFINE_KEYFIELD( m_flLastMaxDamage, FIELD_FLOAT, "starting_damage_amount" ),
DEFINE_KEYFIELD( m_iCaptureAction, FIELD_INTEGER, "capture_action" ),
DEFINE_OUTPUT( m_onPropDamaged, "OnPropDamaged" ),
DEFINE_INPUTFUNC( FIELD_VOID, "RoundActivate", InputRoundActivate ),
END_DATADESC()

BEGIN_DATADESC( CTFSOLOPropertyDamageBrush )
DEFINE_KEYFIELD( m_flFixedDamageAmount, FIELD_FLOAT, "fixed_damage_amount" ),
DEFINE_KEYFIELD( m_flLastMaxDamage, FIELD_FLOAT, "starting_damage_amount" ),
DEFINE_KEYFIELD( m_iCaptureAction, FIELD_INTEGER, "capture_action" ),
DEFINE_OUTPUT( m_onPropDamaged, "OnPropDamaged" ),
DEFINE_INPUTFUNC( FIELD_VOID, "RoundActivate", InputRoundActivate ),
END_DATADESC()

bool TFSOLO_PropertyDamagePropTookDamage( const CTakeDamageInfo& info, int TeamNum, int entindex,
	float& currentDmg, float& lastDmg, float fixedDmg )
{
	CTFPlayer *pTFPlayer = ToTFPlayer( info.GetAttacker() );
	if ( pTFPlayer && pTFPlayer->GetTeamNumber() != TeamNum )
	{
		DispatchParticleEffect( "merasmus_blood", info.GetDamagePosition(), vec3_angle );

		bool isMaxDamage = false;
		if ( fixedDmg > 0.0f )
		{
			currentDmg = MIN( currentDmg + info.GetDamage(), fixedDmg );
			if ( currentDmg >= fixedDmg )
			{
				currentDmg = 0.0f;
				isMaxDamage = true;
			}
		}
		else
		{
			currentDmg = currentDmg + info.GetDamage();
			if ( currentDmg >= lastDmg )
			{
				lastDmg = currentDmg + 1.0f;
				currentDmg = 0.0f;
				isMaxDamage = true;
			}
		}

		IGameEvent* event = gameeventmanager->CreateEvent( "npc_hurt" );
		if ( event )
		{
			event->SetInt( "entindex", entindex );
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

CTFSOLOPropertyDamageProp::CTFSOLOPropertyDamageProp()
{
	m_flCurrentDamage = 0.0f;
	m_flLastMaxDamage = 0.0f;
	m_flFixedDamageAmount = 0.0f;
	m_iCaptureAction = 0;
}


void CTFSOLOPropertyDamageProp::Spawn()
{
	Precache();
	SetModel( STRING( GetModelName() ) );
	BaseClass::Spawn();
	SetMoveType( MOVETYPE_NONE );
	SetSolid( SOLID_VPHYSICS );
	m_takedamage = DAMAGE_YES;
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
	if ( TFSOLO_PropertyDamagePropTookDamage( info, GetTeamNumber(), entindex(), m_flCurrentDamage, m_flLastMaxDamage, m_flFixedDamageAmount ) )
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
			FireNamedOutput( "OnPropCaptured", variant_t(), this, pTFPlayer );
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
				pda_logic->FireNamedOutput( pda_output, variant_t(), this, pTFPlayer );
				if ( ( oldTeam == TF_TEAM_RED && pTFPlayer->GetTeamNumber() == TF_TEAM_BLUE ) ||
					( oldTeam == TF_TEAM_BLUE && pTFPlayer->GetTeamNumber() == TF_TEAM_RED ) )
				{
					pda_logic->FireNamedOutput( pda_output2, variant_t(), this, pTFPlayer );
				}
			}
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


CTFSOLOPropertyDamageProp* CTFSOLOPropertyDamageProp::Create( const Vector& vPosition, const QAngle& qAngles )
{
	CTFSOLOPropertyDamageProp *pPropertyDamageProp = static_cast<CTFSOLOPropertyDamageProp*>( CBaseEntity::Create( "tf_propertydamage_prop", vPosition, qAngles, NULL ) );

	return pPropertyDamageProp;
}

//=========================================================================//

CTFSOLOPropertyDamagePhysicsProp::CTFSOLOPropertyDamagePhysicsProp()
{
	m_flCurrentDamage = 0.0f;
	m_flLastMaxDamage = 0.0f;
	m_flFixedDamageAmount = 0.0f;
	m_iCaptureAction = 0;
}


void CTFSOLOPropertyDamagePhysicsProp::Spawn()
{
	Precache();
	SetModel( STRING( GetModelName() ) );
	BaseClass::Spawn();
	SetMoveType( MOVETYPE_VPHYSICS );
	SetSolid( SOLID_VPHYSICS );
	m_takedamage = DAMAGE_YES;
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
	if ( TFSOLO_PropertyDamagePropTookDamage( info, GetTeamNumber(), entindex(), m_flCurrentDamage, m_flLastMaxDamage, m_flFixedDamageAmount ) )
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
			FireNamedOutput( "OnPropCaptured", variant_t(), this, pTFPlayer );
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
				pda_logic->FireNamedOutput( pda_output, variant_t(), this, pTFPlayer );
				if ( ( oldTeam == TF_TEAM_RED && pTFPlayer->GetTeamNumber() == TF_TEAM_BLUE ) ||
					( oldTeam == TF_TEAM_BLUE && pTFPlayer->GetTeamNumber() == TF_TEAM_RED ) )
				{
					pda_logic->FireNamedOutput( pda_output2, variant_t(), this, pTFPlayer );
				}
			}
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


CTFSOLOPropertyDamagePhysicsProp* CTFSOLOPropertyDamagePhysicsProp::Create(const Vector& vPosition, const QAngle& qAngles)
{
	CTFSOLOPropertyDamagePhysicsProp *pPropertyDamagePhysicsProp = static_cast<CTFSOLOPropertyDamagePhysicsProp *>( CBaseEntity::Create( "tf_propertydamage_prop_physics", vPosition, qAngles, NULL ) );

	return pPropertyDamagePhysicsProp;
}

//=========================================================================//

CTFSOLOPropertyDamageBrush::CTFSOLOPropertyDamageBrush()
{
	m_flCurrentDamage = 0.0f;
	m_flLastMaxDamage = 0.0f;
	m_flFixedDamageAmount = 0.0f;
	m_iCaptureAction = 0;
}


void CTFSOLOPropertyDamageBrush::Spawn()
{
	Precache();
	SetModel( STRING( GetModelName() ) );
	AddEFlags( EFL_USE_PARTITION_WHEN_NOT_SOLID );
	CreateVPhysics();
	SetMoveType( MOVETYPE_NONE );
	SetSolid( SOLID_BSP );
	m_takedamage = DAMAGE_YES;
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

int CTFSOLOPropertyDamageBrush::OnTakeDamage( const CTakeDamageInfo& info )
{
	CTFPlayer* pTFPlayer = ToTFPlayer( info.GetAttacker() );
	if ( pTFPlayer && pTFPlayer->GetTeamNumber() != GetTeamNumber() )
	{
		FireNamedOutput( "OnPropDamaged", variant_t(), this, pTFPlayer );
	}
	if ( TFSOLO_PropertyDamagePropTookDamage( info, GetTeamNumber(), entindex(), m_flCurrentDamage, m_flLastMaxDamage, m_flFixedDamageAmount ) )
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
			FireNamedOutput( "OnPropCaptured", variant_t(), this, pTFPlayer );
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
				pda_logic->FireNamedOutput( pda_output, variant_t(), this, pTFPlayer );
				if ( ( oldTeam == TF_TEAM_RED && pTFPlayer->GetTeamNumber() == TF_TEAM_BLUE ) ||
					( oldTeam == TF_TEAM_BLUE && pTFPlayer->GetTeamNumber() == TF_TEAM_RED ) )
				{
					pda_logic->FireNamedOutput( pda_output2, variant_t(), this, pTFPlayer );
				}
			}
		}
	}

	CTakeDamageInfo newinfo = info;
	newinfo.SetDamage( 0.0f );
	return BaseClass::OnTakeDamage( newinfo );
}

