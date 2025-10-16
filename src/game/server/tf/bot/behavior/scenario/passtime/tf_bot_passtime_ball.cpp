#include "cbase.h"

#include "tf_player_shared.h"
#include "bot/tf_bot.h"
#include "bot/behavior/scenario/passtime/tf_bot_passtime_ball.h"
#include "bot/behavior/tf_bot_taunt.h"
#include "bot/behavior/nav_entities/tf_bot_nav_ent_move_to.h"
#include "bot/behavior/nav_entities/tf_bot_nav_ent_wait.h"
#include "func_passtime_goal.h"

//---------------------------------------------------------------------------------------------
ActionResult< CTFBot >	CTFBotDeliverBall::OnStart( CTFBot* me, Action< CTFBot >* priorAction )
{
	m_flTotalTravelDistance = -1.0f;

	m_path.SetMinLookAheadDistance( me->GetDesiredPathLookAheadRange() );

	me->SetAttribute( CTFBot::SUPPRESS_FIRE );

	return Continue();
}

//---------------------------------------------------------------------------------------------
ActionResult< CTFBot > CTFBotDeliverBall::Update( CTFBot* me, float interval )
{
	if ( !me->m_Shared.HasPasstimeBall() )
	{
		return Done( "No ball" );
	}

	// deliver the ball
	if ( m_repathTimer.IsElapsed() )
	{
		CFuncPasstimeGoal* zone = NULL;
		const auto& list = CFuncPasstimeGoal::GetAutoList();
		for ( int i = 0; i < list.Count(); ++i )
		{
			CFuncPasstimeGoal* azone = list[i];
			if ( !azone->IsDisabled() && ( azone->GetTeamNumber() != GetEnemyTeam( me->GetTeamNumber() ) ) )
			{
				// this will only look for grounded goals for now
				CTFBotPathCost cost( me, DEFAULT_ROUTE );
				if ( m_path.Compute( me, azone->WorldSpaceCenter(), cost, 0.0f ) )
				{
					zone = azone;
					break;
				}
			}
		}

		if ( !zone )
		{
			return Done( "No ball capture zone exists!" );
		}

		CTFBotPathCost cost( me, FASTEST_ROUTE );
		m_path.Compute( me, zone->WorldSpaceCenter(), cost );

		float flOldTravelDistance = m_flTotalTravelDistance;

		m_flTotalTravelDistance = NavAreaTravelDistance( me->GetLastKnownArea(), TheNavMesh->GetNavArea( zone->WorldSpaceCenter() ), cost );

		m_repathTimer.Start( RandomFloat( 1.0f, 2.0f ) );
	}

	m_path.Update( me );

	return Continue();
}


//---------------------------------------------------------------------------------------------
void CTFBotDeliverBall::OnEnd( CTFBot* me, Action< CTFBot >* nextAction )
{
	me->ClearAttribute( CTFBot::SUPPRESS_FIRE );
}


//---------------------------------------------------------------------------------------------
QueryResultType CTFBotDeliverBall::ShouldAttack( const INextBot* me, const CKnownEntity* them ) const
{
	return ANSWER_NO;
}


//---------------------------------------------------------------------------------------------
// are we in a hurry?
QueryResultType CTFBotDeliverBall::ShouldHurry( const INextBot* me ) const
{
	return ANSWER_YES;
}


//---------------------------------------------------------------------------------------------
// is it time to retreat?
QueryResultType	CTFBotDeliverBall::ShouldRetreat( const INextBot* me ) const
{
	return ANSWER_NO;
}


//---------------------------------------------------------------------------------------------
EventDesiredResult< CTFBot > CTFBotDeliverBall::OnContact( CTFBot* me, CBaseEntity* other, CGameTrace* resul)
{
	return TryContinue();
}

