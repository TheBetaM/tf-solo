#ifndef TF_BOT_FETCH_BALL_H
#define TF_BOT_FETCH_BALL_H

#include "Path/NextBotPathFollow.h"


//-----------------------------------------------------------------------------
class CTFBotFetchBall : public Action< CTFBot >
{
public:
#define TEMPORARY_BALL_FETCH true
	CTFBotFetchBall( bool isTemporary = false );
	virtual ~CTFBotFetchBall() { }

	virtual ActionResult< CTFBot >	OnStart( CTFBot* me, Action< CTFBot >* priorAction );
	virtual ActionResult< CTFBot >	Update( CTFBot* me, float interval );

	virtual QueryResultType ShouldHurry( const INextBot* me ) const;
	virtual QueryResultType	ShouldRetreat( const INextBot* me ) const;

	virtual const char* GetName( void ) const { return "FetchBall"; };

private:
	bool m_isTemporary;
	PathFollower m_path;
	CountdownTimer m_repathTimer;
};


#endif // TF_BOT_FETCH_BALL_H
