#ifndef TFSOLO_PROPERTY_DAMAGE_PROP_H
#define TFSOLO_PROPERTY_DAMAGE_PROP_H

#include "props.h"
#include "modelentities.h"

DECLARE_AUTO_LIST( ITFSOLOPropertyDamageProp );

class CTFSOLOPropertyDamageProp : public CDynamicProp, public ITFSOLOPropertyDamageProp
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

	void InputRoundActivate( inputdata_t& inputdata );

	static CTFSOLOPropertyDamageProp* Create( const Vector& vPosition, const QAngle& qAngles );

	float m_flCurrentDamage;
	float m_flLastMaxDamage;
	float m_flFixedDamageAmount;
	int m_iCaptureAction;
private:
	DECLARE_DATADESC();

	COutputEvent m_onPropDamaged;
	COutputEvent m_onPropCaptured;
};

DECLARE_AUTO_LIST( ITFSOLOPropertyDamagePhysicsProp );

class CTFSOLOPropertyDamagePhysicsProp : public CPhysicsProp, public ITFSOLOPropertyDamagePhysicsProp
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

	void InputRoundActivate( inputdata_t& inputdata );

	static CTFSOLOPropertyDamagePhysicsProp* Create( const Vector& vPosition, const QAngle& qAngles );

	float m_flCurrentDamage;
	float m_flLastMaxDamage;
	float m_flFixedDamageAmount;
	int m_iCaptureAction;
private:
	DECLARE_DATADESC();

	COutputEvent m_onPropDamaged;
	COutputEvent m_onPropCaptured;
};

DECLARE_AUTO_LIST( ITFSOLOPropertyDamageBrush );

class CTFSOLOPropertyDamageBrush : public CFuncBrush, public ITFSOLOPropertyDamageBrush
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

	void InputRoundActivate( inputdata_t& inputdata );

	float m_flCurrentDamage;
	float m_flLastMaxDamage;
	float m_flFixedDamageAmount;
	int m_iCaptureAction;
private:
	DECLARE_DATADESC();

	COutputEvent m_onPropDamaged;
	COutputEvent m_onPropCaptured;
};

#endif // TFSOLO_PROPERTY_DAMAGE_PROP_H
