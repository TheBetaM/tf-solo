#include "cbase.h"

#include "bot/tf_bot.h"
#include "bot/behavior/scenario/passtime/tf_bot_passtime_roam.h"
#include "bot/behavior/scenario/passtime/tf_bot_passtime_ball.h"
#include "tf_passtime_ball.h"
#include "bot/behavior/tf_bot_seek_and_destroy.h"


//---------------------------------------------------------------------------------------------
CTFBotFetchBall::CTFBotFetchBall( bool isTemporary )
{
	m_isTemporary = isTemporary;
}


//---------------------------------------------------------------------------------------------
ActionResult< CTFBot >	CTFBotFetchBall::OnStart( CTFBot* me, Action< CTFBot >* priorAction )
{
	m_path.SetMinLookAheadDistance( me->GetDesiredPathLookAheadRange() );

	return Continue();
}


//---------------------------------------------------------------------------------------------
ActionResult< CTFBot > CTFBotFetchBall::Update( CTFBot* me, float interval )
{
	CPasstimeBall* ball = me->GetBallToFetch();

	if ( !ball )
	{
		return Done( "No ball" );
	}
	if ( me->m_Shared.HasPasstimeBall() )
	{
		return Done( "I got the ball" );
	}

	const CKnownEntity* threat = me->GetVisionInterface()->GetPrimaryKnownThreat();
	if ( threat )
	{
		me->EquipBestWeaponForThreat( threat );
	}

	CTFPlayer* carrier = ToTFPlayer( ball->GetCarrier() );
	if ( carrier )
	{
		//if ( m_isTemporary )
		//{
		//	return Done( "Someone else picked up the ball" );
		//}

		// NOTE: if I've picked up the ball, the ScenarioMonitor will handle it
		return SuspendFor( new CTFBotSeekAndDestroy( RandomFloat( 5.0f, 10.0f ) ), "Someone has the ball - attacking the enemy defenders" );
	}

	// go pick up the ball
	if ( m_repathTimer.IsElapsed() )
	{
		CTFBotPathCost cost( me, DEFAULT_ROUTE );
		if ( m_path.Compute( me, ball->WorldSpaceCenter(), cost, 0.0f ) == false )
		{
			if ( ball->GetBallState() == 1 )
			{
				// flag is unreachable - attack for awhile and hope someone else can dislodge it
				return SuspendFor( new CTFBotSeekAndDestroy( RandomFloat( 5.0f, 10.0f ) ), "Ball unreachable - Attacking" );
			}
		}

		m_repathTimer.Start( RandomFloat( 1.0f, 2.0f ) );
	}

	m_path.Update( me );

	return Continue();
}


//---------------------------------------------------------------------------------------------
// are we in a hurry?
QueryResultType CTFBotFetchBall::ShouldHurry( const INextBot* me ) const
{
	return ANSWER_YES;
}


//---------------------------------------------------------------------------------------------
// is it time to retreat?
QueryResultType	CTFBotFetchBall::ShouldRetreat( const INextBot* me ) const
{
	return ANSWER_UNDEFINED;
}
