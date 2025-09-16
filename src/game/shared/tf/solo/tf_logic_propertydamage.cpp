#include "cbase.h"
#include "tf_logic_propertydamage.h"

#ifdef GAME_DLL
#include "tf_player.h"
#include "entity_capture_flag.h"
#include "tf_obj_dispenser.h"
#include "tf_gamerules.h"
#include "solo/propertydamage_prop.h"
#else
#include "c_tf_player.h"
#endif // GAME_DLL
				   
#ifdef GAME_DLL
BEGIN_DATADESC( CTFSOLOPropertyDamageLogic )
DEFINE_KEYFIELD( m_iGamemodeType, FIELD_INTEGER, "gamemode_type" ),
DEFINE_KEYFIELD( m_flMaxPointsFraction, FIELD_FLOAT, "max_points_fraction" ),
DEFINE_KEYFIELD( m_iFixedMaxPoints, FIELD_INTEGER, "fixed_max_points" ),
DEFINE_OUTPUT( m_onPropCapturedTeam1, "OnPropCapturedTeam1" ),
DEFINE_OUTPUT( m_onPropCapturedTeam2, "OnPropCapturedTeam2" ),
DEFINE_OUTPUT( m_onPropLostTeam1, "OnPropLostTeam1" ),
DEFINE_OUTPUT( m_onPropLostTeam2, "OnPropLostTeam2" ),
DEFINE_INPUTFUNC( FIELD_VOID, "UpdateMaxPoints", InputUpdateMaxPoints ),
DEFINE_INPUTFUNC( FIELD_INTEGER, "SetFixedMaxPoints", InputSetFixedMaxPoints ),
DEFINE_INPUTFUNC( FIELD_VOID, "LoseRedPoints", InputLoseRedPoints ),
DEFINE_INPUTFUNC( FIELD_VOID, "LoseBluePoints", InputLoseBluePoints ),
END_DATADESC()
#endif

LINK_ENTITY_TO_CLASS( tf_logic_propertydamage, CTFSOLOPropertyDamageLogic );
IMPLEMENT_NETWORKCLASS_ALIASED( TFSOLOPropertyDamageLogic, DT_TFSOLOPropertyDamageLogic )

BEGIN_NETWORK_TABLE( CTFSOLOPropertyDamageLogic, DT_TFSOLOPropertyDamageLogic )
END_NETWORK_TABLE()


//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
CTFSOLOPropertyDamageLogic::CTFSOLOPropertyDamageLogic()
{
#if GAME_DLL
	m_iFixedMaxPoints = 0;
	m_flMaxPointsFraction = 0.75f;
	m_iGamemodeType = 0;
	m_bFlipTeams = false;
#endif
}


//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
CTFSOLOPropertyDamageLogic* CTFSOLOPropertyDamageLogic::GetPropertyDamageLogic()
{
	return assert_cast< CTFSOLOPropertyDamageLogic* >( CTFRobotDestructionLogic::GetRobotDestructionLogic() );
}

#ifdef GAME_DLL
void CTFSOLOPropertyDamageLogic::EvaluatePlayerCount()
{
	if ( !IsMaxScoreUpdatingAllowed() )
		return;

	CalculatePropCount();
}

void CTFSOLOPropertyDamageLogic::CalculatePropCount()
{
	int propCount = 0;
	int propRedCount = 0;
	int propBlueCount = 0;
	propCount += ITFSOLOPropertyDamageProp::AutoList().Count();
	propCount += ITFSOLOPropertyDamagePhysicsProp::AutoList().Count();
	propCount += ITFSOLOPropertyDamageBrush::AutoList().Count();
	propCount += ITFSOLOPropertyDamageNextBot::AutoList().Count();
	for ( int i = 0; i < ITFSOLOPropertyDamageProp::AutoList().Count(); ++i )
	{
		CTFSOLOPropertyDamageProp* pObj = static_cast<CTFSOLOPropertyDamageProp*>( ITFSOLOPropertyDamageProp::AutoList()[i] );
		if ( pObj->GetTeamNumber() == TF_TEAM_RED )
		{
			propRedCount++;
		}
		else if ( pObj->GetTeamNumber() == TF_TEAM_BLUE )
		{
			propBlueCount++;
		}
	}
	for ( int i = 0; i < ITFSOLOPropertyDamagePhysicsProp::AutoList().Count(); ++i )
	{
		CTFSOLOPropertyDamagePhysicsProp* pObj = static_cast<CTFSOLOPropertyDamagePhysicsProp*>( ITFSOLOPropertyDamagePhysicsProp::AutoList()[i] );
		if ( pObj->GetTeamNumber() == TF_TEAM_RED )
		{
			propRedCount++;
		}
		else if ( pObj->GetTeamNumber() == TF_TEAM_BLUE )
		{
			propBlueCount++;
		}
	}
	for ( int i = 0; i < ITFSOLOPropertyDamageBrush::AutoList().Count(); ++i )
	{
		CTFSOLOPropertyDamageBrush* pObj = static_cast<CTFSOLOPropertyDamageBrush*>( ITFSOLOPropertyDamageBrush::AutoList()[i] );
		if ( pObj->GetTeamNumber() == TF_TEAM_RED )
		{
			propRedCount++;
		}
		else if ( pObj->GetTeamNumber() == TF_TEAM_BLUE )
		{
			propBlueCount++;
		}
	}
	for ( int i = 0; i < ITFSOLOPropertyDamageNextBot::AutoList().Count(); ++i )
	{
		CTFSOLOPropertyDamageNextBot* pObj = static_cast<CTFSOLOPropertyDamageNextBot*>( ITFSOLOPropertyDamageNextBot::AutoList()[i] );
		if ( pObj->GetTeamNumber() == TF_TEAM_RED )
		{
			propRedCount++;
		}
		else if ( pObj->GetTeamNumber() == TF_TEAM_BLUE )
		{
			propBlueCount++;
		}
	}

	if ( m_iFixedMaxPoints != 0 )
	{
		m_nMaxPoints = m_iFixedMaxPoints;
	}
	else
	{
		m_nMaxPoints = Floor2Int( propCount * m_flMaxPointsFraction );
	}
	m_nBlueTargetPoints.Set( propBlueCount );
	m_nBlueScore.Set( propBlueCount );
	m_nRedTargetPoints.Set( propRedCount );
	m_nRedScore.Set( propRedCount );
}

void CTFSOLOPropertyDamageLogic::InputLoseRedPoints( inputdata_t& inputdata )
{
	ScorePoints( TF_TEAM_RED, -1, SCORE_REACTOR_STEAL, NULL );
}

void CTFSOLOPropertyDamageLogic::InputLoseBluePoints( inputdata_t& inputdata )
{
	ScorePoints( TF_TEAM_BLUE, -1, SCORE_REACTOR_STEAL, NULL );
}

void CTFSOLOPropertyDamageLogic::InputSetFixedMaxPoints( inputdata_t& inputdata )
{
	m_iFixedMaxPoints = inputdata.value.Int();
	if ( m_iFixedMaxPoints != 0 )
	{
		m_nMaxPoints = m_iFixedMaxPoints;
	}
	else
	{
		CalculatePropCount();
	}
}

void CTFSOLOPropertyDamageLogic::InputUpdateMaxPoints( inputdata_t& inputdata )
{
	CalculatePropCount();
}
#endif
