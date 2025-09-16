#ifndef TFSOLO_PROPERTY_DAMAGE_PROP_H
#define TFSOLO_PROPERTY_DAMAGE_PROP_H

#include "props.h"
#include "modelentities.h"
#include "tf_weapon_wrench.h"
#include "tf/player_vs_environment/tf_base_boss.h"

abstract_class ITFSOLOPropertyDamagePropAll
{
public:
	bool			IsDamageable( void ) { return m_bIsDamageable; }
	bool			IsSappable( void ) { return m_bIsSappable; }
	bool			IsRepairable( void ) { return m_bIsRepairable; }
	bool			PropTookDamage( const CTakeDamageInfo& info, int TeamNum, int entindex );
	bool			OnWrenchHit( CTFPlayer* pPlayer, CTFWrench* pWrench, Vector hitLoc, CBaseEntity* pEnt );
	void			AfterCapture( int oldteam, CBaseEntity* pEnt, CTFPlayer* pTFPlayer );

	float m_flCurrentDamage;
	float m_flLastMaxDamage;
	float m_flFixedDamageAmount;
	float m_flMaxDamageIncrement;
	float m_flMaxDamageMult;
	int m_iCaptureAction;
	bool m_bIsDamageable;
	bool m_bIsSappable;
	bool m_bIsRepairable;

	COutputEvent m_onPropDamaged;
	COutputEvent m_onPropCaptured;
	COutputEvent m_onPropCapturedTeam1;
	COutputEvent m_onPropCapturedTeam2;
};

DECLARE_AUTO_LIST( ITFSOLOPropertyDamageProp );

class CTFSOLOPropertyDamageProp : public CDynamicProp, public ITFSOLOPropertyDamageProp, public ITFSOLOPropertyDamagePropAll
{
	DECLARE_CLASS( CTFSOLOPropertyDamageProp, CDynamicProp );

public:
	CTFSOLOPropertyDamageProp();
	~CTFSOLOPropertyDamageProp() {}

	virtual void	Spawn( void );
	virtual void	Event_Killed( const CTakeDamageInfo &info );
	virtual int		OnTakeDamage( const CTakeDamageInfo &info );
	virtual void	Touch( CBaseEntity *pOther );
	virtual bool	IsProjectileCollisionTarget( void ) const OVERRIDE { return true; }
	virtual bool	OverridePropdata( void ) OVERRIDE;
	virtual bool	IsAlive( void ) OVERRIDE { return true; }

	void InputRoundActivate(inputdata_t& inputdata);
	void InputSetDamageAmount(inputdata_t& inputdata);
	void InputSetDamageable(inputdata_t& inputdata);
	void InputSetSappable(inputdata_t& inputdata);
	void InputSetRepairable(inputdata_t& inputdata);

	static CTFSOLOPropertyDamageProp* Create( const Vector& vPosition, const QAngle& qAngles );
	
private:
	DECLARE_DATADESC();
};

DECLARE_AUTO_LIST( ITFSOLOPropertyDamagePhysicsProp );

class CTFSOLOPropertyDamagePhysicsProp : public CPhysicsProp, public ITFSOLOPropertyDamagePhysicsProp, public ITFSOLOPropertyDamagePropAll
{
	DECLARE_CLASS( CTFSOLOPropertyDamagePhysicsProp, CPhysicsProp );

public:
	CTFSOLOPropertyDamagePhysicsProp();
	~CTFSOLOPropertyDamagePhysicsProp() {}

	virtual void	Spawn( void );
	virtual void	Event_Killed( const CTakeDamageInfo& info );
	virtual int		OnTakeDamage( const CTakeDamageInfo& info );
	virtual void	Touch( CBaseEntity* pOther );
	virtual bool	IsProjectileCollisionTarget( void ) const OVERRIDE { return true; }
	virtual bool	OverridePropdata( void ) OVERRIDE;
	virtual bool	IsAlive( void ) OVERRIDE { return true; }

	void InputRoundActivate( inputdata_t& inputdata );
	void InputSetDamageAmount( inputdata_t& inputdata );
	void InputSetDamageable( inputdata_t& inputdata );
	void InputSetSappable( inputdata_t& inputdata );
	void InputSetRepairable( inputdata_t& inputdata );

	static CTFSOLOPropertyDamagePhysicsProp* Create( const Vector& vPosition, const QAngle& qAngles );

private:
	DECLARE_DATADESC();
};

DECLARE_AUTO_LIST( ITFSOLOPropertyDamageBrush );

class CTFSOLOPropertyDamageBrush : public CFuncBrush, public ITFSOLOPropertyDamageBrush, public ITFSOLOPropertyDamagePropAll
{
	DECLARE_CLASS( CTFSOLOPropertyDamageBrush, CFuncBrush );
public:

	CTFSOLOPropertyDamageBrush();

	virtual void Spawn( void );
	virtual int OnTakeDamage(const CTakeDamageInfo& info);

	virtual int		UpdateTransmitState( void ) { return SetTransmitState( FL_EDICT_ALWAYS ); }
	virtual int		ShouldTransmit( const CCheckTransmitInfo* pInfo ) { return FL_EDICT_ALWAYS; }
	virtual bool	ShouldCollide( int collisionGroup, int contentsMask ) const { return true; }
	virtual bool	IsProjectileCollisionTarget( void ) const OVERRIDE { return true; }
	virtual bool	IsAlive( void ) OVERRIDE { return true; }

	void InputRoundActivate( inputdata_t& inputdata );
	void InputSetDamageAmount( inputdata_t& inputdata );
	void InputSetDamageable( inputdata_t& inputdata );
	void InputSetSappable( inputdata_t& inputdata );
	void InputSetRepairable( inputdata_t& inputdata );

private:
	DECLARE_DATADESC();
};

DECLARE_AUTO_LIST( ITFSOLOPropertyDamageNextBot );

class CTFSOLOPropertyDamageNextBot : public CTFBaseBoss, public ITFSOLOPropertyDamageNextBot, public ITFSOLOPropertyDamagePropAll
{
	DECLARE_CLASS( CTFSOLOPropertyDamageNextBot, CTFBaseBoss );
public:

	CTFSOLOPropertyDamageNextBot();

	virtual void Spawn( void );
	virtual int OnTakeDamage( const CTakeDamageInfo& info ) OVERRIDE;
	virtual int OnTakeDamage_Alive( const CTakeDamageInfo& info ) OVERRIDE;
	virtual bool ShouldCollide( int collisionGroup, int contentsMask ) const OVERRIDE;

	virtual bool	IsProjectileCollisionTarget( void ) const OVERRIDE { return true; }
	virtual bool	IsAlive( void ) OVERRIDE { return true; }

	void InputRoundActivate( inputdata_t& inputdata );
	void InputSetDamageAmount( inputdata_t& inputdata );
	void InputSetDamageable( inputdata_t& inputdata );
	void InputSetSappable( inputdata_t& inputdata );
	void InputSetRepairable( inputdata_t& inputdata );

	bool m_bMovementCollide;

private:
	DECLARE_DATADESC();
};

#endif // TFSOLO_PROPERTY_DAMAGE_PROP_H
