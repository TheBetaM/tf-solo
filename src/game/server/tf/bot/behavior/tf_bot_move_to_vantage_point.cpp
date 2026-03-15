//========= Copyright Valve Corporation, All rights reserved. ============//
// tf_bot_move_to_vantage_point.h
// Move to a position where at least one enemy is visible
// Michael Booth, November 2009

#include "cbase.h"
#include "tf_player.h"
#include "bot/tf_bot.h"
#include "bot/behavior/tf_bot_move_to_vantage_point.h"
#include "tf/solo/ChoreoSystem.h"

#include "nav_mesh.h"

extern ConVar tf_bot_path_lookahead_range;


//---------------------------------------------------------------------------------------------
CTFBotMoveToVantagePoint::CTFBotMoveToVantagePoint( float maxTravelDistance )
{
	m_maxTravelDistance = maxTravelDistance;
	m_isEscaping = false;
	m_isEscapingZone = false;
	m_bHasEscaped = false;
}

//---------------------------------------------------------------------------------------------
CTFBotMoveToVantagePoint::CTFBotMoveToVantagePoint( float maxTravelDistance, bool escape, bool zone )
{
	m_maxTravelDistance = maxTravelDistance;
	m_isEscaping = true;
	m_bHasEscaped = false;
	m_isEscapingZone = zone;
}


//---------------------------------------------------------------------------------------------
ActionResult< CTFBot >	CTFBotMoveToVantagePoint::OnStart( CTFBot *me, Action< CTFBot > *priorAction )
{
	m_path.SetMinLookAheadDistance( me->GetDesiredPathLookAheadRange() );

	if ( me->HasMission( CTFBot::MISSION_CHOREO ) )
	{
		m_vantageArea = dynamic_cast<CTFNavArea *>( TheTFNavMesh()->GetNearestNavArea( g_ChoreoSystem.GetStartOrigin( me->entindex() ), true, 10000.0f, false, true, TEAM_ANY ) );
	}
	else if ( !m_isEscaping )
	{
		m_vantageArea = me->FindVantagePoint( m_maxTravelDistance );
	}
	else
	{
		m_vantageArea = me->FindUnderworldExitPoint( m_maxTravelDistance );
	}
	if ( !m_vantageArea )
	{
		if ( me->HasMission( CTFBot::MISSION_CHOREO ) )
		{
			me->SetMission( CTFBot::NO_MISSION, false );
		}
		return Done( "No vantage point found" );
	}

	m_path.Invalidate();
	m_repathTimer.Invalidate();

	return Continue();
}


//---------------------------------------------------------------------------------------------
ActionResult< CTFBot >	CTFBotMoveToVantagePoint::Update( CTFBot *me, float interval )
{
	if ( me->HasMission( CTFBot::MISSION_CHOREO ) )
	{
		if ( !m_path.IsValid() && m_repathTimer.IsElapsed() )
		{
			m_repathTimer.Start( 1.0f );

			CTFBotPathCost cost( me, FASTEST_ROUTE );
			if ( !m_path.Compute( me, g_ChoreoSystem.GetStartOrigin( me->entindex() ), cost ) )
			{
				me->SetMission( CTFBot::NO_MISSION, false );
				me->SetAbsOrigin( g_ChoreoSystem.GetStartOrigin( me->entindex() ) );
				me->SnapEyeAngles( g_ChoreoSystem.GetStartAngles( me->entindex() ) );
				g_ChoreoSystem.Resume( me->entindex() );
				return Done( "No path to choreo start exists" );
			}
		}

		m_path.Update( me );

		return Continue();
	}

	if ( !m_isEscaping )
	{
		const CKnownEntity *threat = me->GetVisionInterface()->GetPrimaryKnownThreat();
		if ( threat && threat->IsVisibleInFOVNow() )
		{
			return Done( "Enemy is visible" );
		}
	}

	if ( !m_path.IsValid() && m_repathTimer.IsElapsed() )
	{
		m_repathTimer.Start( 1.0f );

		CTFBotPathCost cost( me, FASTEST_ROUTE );
		if ( !m_path.Compute( me, m_vantageArea->GetCenter(), cost ) )
		{
			return Done( "No path to vantage point exists" );
		}
	}

	if ( m_isEscaping && !m_isEscapingZone && !me->m_Shared.InCond( TF_COND_PURGATORY ) && !me->m_Shared.InCond( TF_COND_HALLOWEEN_IN_HELL )
		&& V_stricmp( me->GetScriptOverlayMaterial(), "effects/map_afterlife_soul_overlay" ) && !me->HasTag( "InPurg" ) )
	{
		return Done( "I've escaped" );
	}

	if ( m_bHasEscaped && m_isEscapingZone )
	{
		return Done( "I've escaped" );
	}

	// move along path to vantage point
	m_path.Update( me );

	return Continue();
}


//---------------------------------------------------------------------------------------------
EventDesiredResult< CTFBot > CTFBotMoveToVantagePoint::OnStuck( CTFBot *me )
{
	if ( !m_isEscaping )
	{
		m_path.Invalidate();
	}
	return TryContinue();
}


//---------------------------------------------------------------------------------------------
EventDesiredResult< CTFBot > CTFBotMoveToVantagePoint::OnMoveToSuccess( CTFBot *me, const Path *path )
{
	if ( me->HasMission( CTFBot::MISSION_CHOREO ) )
	{
		me->SetMission( CTFBot::NO_MISSION, false );
		me->SetAbsOrigin( g_ChoreoSystem.GetStartOrigin( me->entindex() ) );
		me->SnapEyeAngles( g_ChoreoSystem.GetStartAngles( me->entindex() ) );
		g_ChoreoSystem.Resume( me->entindex() );
	}
	return TryDone( RESULT_CRITICAL, "Vantage point reached" );
}


//---------------------------------------------------------------------------------------------
EventDesiredResult< CTFBot > CTFBotMoveToVantagePoint::OnMoveToFailure( CTFBot *me, const Path *path, MoveToFailureType reason )
{
	m_path.Invalidate();
	return TryContinue();
}


EventDesiredResult< CTFBot > CTFBotMoveToVantagePoint::OnNavAreaChanged( CTFBot* me, CNavArea* newArea, CNavArea* oldArea )
{
	if ( me->HasMission( CTFBot::MISSION_CHOREO ) )
	{
		return TryContinue();
	}
	if ( m_isEscapingZone && newArea && !newArea->HasAttributes( NAV_MESH_NO_HOSTAGES ) )
	{
		m_bHasEscaped = true;
	}
	if ( m_isEscaping && !m_isEscapingZone && newArea && newArea->HasAttributes( NAV_MESH_NO_HOSTAGES ) )
	{
		m_isEscapingZone = true;
		m_vantageArea = me->FindUnderworldExitPoint( newArea, m_maxTravelDistance );
		m_path.Invalidate();
		m_repathTimer.Invalidate();
	}

	return TryContinue();
}

