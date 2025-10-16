#ifndef TF_BOT_DELIVER_BALL_H
#define TF_BOT_DELIVER_BALL_H

#include "Path/NextBotPathFollow.h"


//-----------------------------------------------------------------------------
class CTFBotDeliverBall : public Action< CTFBot >
{
public:
	virtual ActionResult< CTFBot >	OnStart( CTFBot* me, Action< CTFBot >* priorAction );
	virtual ActionResult< CTFBot >	Update( CTFBot* me, float interval );
	virtual void					OnEnd( CTFBot* me, Action< CTFBot >* nextAction );

	virtual QueryResultType ShouldAttack( const INextBot* me, const CKnownEntity* them ) const;
	virtual QueryResultType ShouldHurry( const INextBot* me ) const;
	virtual QueryResultType	ShouldRetreat( const INextBot* me ) const;

	virtual EventDesiredResult< CTFBot > OnContact( CTFBot* me, CBaseEntity* other, CGameTrace* result = NULL );

	virtual const char* GetName( void ) const { return "DeliverBall"; };

private:
	PathFollower m_path;
	CountdownTimer m_repathTimer;
	float m_flTotalTravelDistance;
};


#endif // TF_BOT_DELIVER_BALL_H
