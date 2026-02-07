#ifndef TFSOLO_PROPERTY_DAMAGE_PROP_H
#define TFSOLO_PROPERTY_DAMAGE_PROP_H

#ifdef GAME_DLL
#include "props.h"
#include "modelentities.h"
#include "tf/player_vs_environment/tf_base_boss.h"
#endif
#include "tf_weapon_wrench.h"

#ifdef CLIENT_DLL
#include "c_props.h"
#include "c_physicsprop.h"
#include "tf/player_vs_environment/c_tf_base_boss.h"
#define CTFSOLOPropertyDamageProp C_TFSOLOPropertyDamageProp
#define CTFSOLOPropertyDamagePhysicsProp C_TFSOLOPropertyDamagePhysicsProp
#define CTFSOLOPropertyDamageBrush C_TFSOLOPropertyDamageBrush
#define CTFSOLOPropertyDamageNextBot C_TFSOLOPropertyDamageNextBot
#define CPhysicsProp C_PhysicsProp
#define CTFBaseBoss C_TFBaseBoss
#endif

abstract_class ITFSOLOPropertyDamagePropAll
{
public:
	bool			IsDamageable( void ) { return m_bIsDamageable; }
	bool			IsSappable( void ) { return m_bIsSappable; }
	bool			IsRepairable( void ) { return m_bIsRepairable; }
#ifdef GAME_DLL
	virtual void	SetDamage(float flDmg) = 0;
	virtual void	SetMaxDamage(float flDmg) = 0;
	virtual float	GetDamage() = 0;
	virtual float	GetMaxDamage() = 0;
	bool			PropTookDamage( const CTakeDamageInfo& info, int TeamNum, CBaseEntity* pEnt );
	bool			OnWrenchHit( CTFPlayer* pPlayer, CTFWrench* pWrench, Vector hitLoc, CBaseEntity* pEnt );
	void			AfterCapture( int oldteam, CBaseEntity* pEnt, CTFPlayer* pTFPlayer );
#endif

	float m_flFixedDamageAmount;
	float m_flMaxDamageIncrement;
	float m_flMaxDamageMult;
	int m_iCaptureAction;

	bool m_bIsDamageable;
	bool m_bIsSappable;
	bool m_bIsRepairable;

#ifdef GAME_DLL
	COutputEvent m_onPropDamaged;
	COutputEvent m_onPropCaptured;
	COutputEvent m_onPropCapturedTeam1;
	COutputEvent m_onPropCapturedTeam2;
#endif // GAME_DLL
};

DECLARE_AUTO_LIST( ITFSOLOPropertyDamageProp );

class CTFSOLOPropertyDamageProp : public CDynamicProp, public ITFSOLOPropertyDamageProp, public ITFSOLOPropertyDamagePropAll
{
	DECLARE_NETWORKCLASS();
	DECLARE_CLASS( CTFSOLOPropertyDamageProp, CDynamicProp );

public:
	CTFSOLOPropertyDamageProp();
	~CTFSOLOPropertyDamageProp() {}

	CNetworkVar( float, m_flCurrentDamage );
	CNetworkVar( float, m_flLastMaxDamage );

#ifdef GAME_DLL
	virtual void	Spawn( void );
	virtual void	Event_Killed( const CTakeDamageInfo &info );
	virtual int		OnTakeDamage( const CTakeDamageInfo &info );
	virtual void	Touch( CBaseEntity *pOther );
	virtual bool	IsProjectileCollisionTarget( void ) const OVERRIDE { return true; }
	virtual bool	OverridePropdata( void ) OVERRIDE;
	virtual bool	IsAlive( void ) OVERRIDE { return true; }
	virtual void	SetDamage( float flDmg ) { m_flCurrentDamage = flDmg; }
	virtual void	SetMaxDamage( float flDmg ) { m_flLastMaxDamage = flDmg; }
	virtual float	GetDamage() { return m_flCurrentDamage; }
	virtual float	GetMaxDamage() { return m_flLastMaxDamage; }

	void InputRoundActivate(inputdata_t& inputdata);
	void InputSetDamageAmount(inputdata_t& inputdata);
	void InputSetDamageable(inputdata_t& inputdata);
	void InputSetSappable(inputdata_t& inputdata);
	void InputSetRepairable(inputdata_t& inputdata);

	static CTFSOLOPropertyDamageProp* Create( const Vector& vPosition, const QAngle& qAngles );
#endif

#ifdef CLIENT_DLL
	virtual bool	IsVisibleToTargetID( void ) const { return true; }
	virtual bool	IsHealthBarVisible( void ) const { return true; }
#endif // CLIENT_DLL
	
private:
	DECLARE_DATADESC();
};

DECLARE_AUTO_LIST( ITFSOLOPropertyDamagePhysicsProp );

class CTFSOLOPropertyDamagePhysicsProp : public CPhysicsProp, public ITFSOLOPropertyDamagePhysicsProp, public ITFSOLOPropertyDamagePropAll
{
	DECLARE_NETWORKCLASS();
	DECLARE_CLASS( CTFSOLOPropertyDamagePhysicsProp, CPhysicsProp );

public:
	CTFSOLOPropertyDamagePhysicsProp();
	~CTFSOLOPropertyDamagePhysicsProp() {}

	CNetworkVar( float, m_flCurrentDamage );
	CNetworkVar( float, m_flLastMaxDamage );

#ifdef GAME_DLL
	virtual void	Spawn( void );
	virtual void	Event_Killed( const CTakeDamageInfo& info );
	virtual int		OnTakeDamage( const CTakeDamageInfo& info );
	virtual void	Touch( CBaseEntity* pOther );
	virtual bool	IsProjectileCollisionTarget( void ) const OVERRIDE { return true; }
	virtual bool	OverridePropdata( void ) OVERRIDE;
	virtual bool	IsAlive( void ) OVERRIDE { return true; }
	virtual void	SetDamage( float flDmg ) { m_flCurrentDamage = flDmg; }
	virtual void	SetMaxDamage( float flDmg ) { m_flLastMaxDamage = flDmg; }
	virtual float	GetDamage() { return m_flCurrentDamage; }
	virtual float	GetMaxDamage() { return m_flLastMaxDamage; }

	void InputRoundActivate( inputdata_t& inputdata );
	void InputSetDamageAmount( inputdata_t& inputdata );
	void InputSetDamageable( inputdata_t& inputdata );
	void InputSetSappable( inputdata_t& inputdata );
	void InputSetRepairable( inputdata_t& inputdata );

	static CTFSOLOPropertyDamagePhysicsProp* Create( const Vector& vPosition, const QAngle& qAngles );
#endif

#ifdef CLIENT_DLL
	virtual bool	IsVisibleToTargetID( void ) const { return true; }
	virtual bool	IsHealthBarVisible( void ) const { return true; }
#endif // CLIENT_DLL

private:
	DECLARE_DATADESC();
};

DECLARE_AUTO_LIST( ITFSOLOPropertyDamageBrush );

#ifdef GAME_DLL
class CTFSOLOPropertyDamageBrush : public CFuncBrush, public ITFSOLOPropertyDamageBrush, public ITFSOLOPropertyDamagePropAll
#else
class CTFSOLOPropertyDamageBrush : public C_BaseEntity, public ITFSOLOPropertyDamageBrush, public ITFSOLOPropertyDamagePropAll
#endif
{
	DECLARE_NETWORKCLASS();
#ifdef GAME_DLL
	DECLARE_CLASS( CTFSOLOPropertyDamageBrush, CFuncBrush );
#else
	DECLARE_CLASS( CTFSOLOPropertyDamageBrush, C_BaseEntity );
#endif
public:

	CTFSOLOPropertyDamageBrush();

	CNetworkVar( float, m_flCurrentDamage );
	CNetworkVar( float, m_flLastMaxDamage );

#ifdef GAME_DLL
	virtual void Spawn( void );
	virtual int OnTakeDamage(const CTakeDamageInfo& info);

	virtual int		UpdateTransmitState( void ) { return SetTransmitState( FL_EDICT_ALWAYS ); }
	virtual int		ShouldTransmit( const CCheckTransmitInfo* pInfo ) { return FL_EDICT_ALWAYS; }
	virtual bool	ShouldCollide( int collisionGroup, int contentsMask ) const { return true; }
	virtual bool	IsProjectileCollisionTarget( void ) const OVERRIDE { return true; }
	virtual bool	IsAlive( void ) OVERRIDE { return true; }
	virtual void	SetDamage( float flDmg ) { m_flCurrentDamage = flDmg; }
	virtual void	SetMaxDamage( float flDmg ) { m_flLastMaxDamage = flDmg; }
	virtual float	GetDamage() { return m_flCurrentDamage; }
	virtual float	GetMaxDamage() { return m_flLastMaxDamage; }

	void InputRoundActivate( inputdata_t& inputdata );
	void InputSetDamageAmount( inputdata_t& inputdata );
	void InputSetDamageable( inputdata_t& inputdata );
	void InputSetSappable( inputdata_t& inputdata );
	void InputSetRepairable( inputdata_t& inputdata );
#endif

#ifdef CLIENT_DLL
	virtual bool	IsVisibleToTargetID( void ) const { return true; }
	virtual bool	IsHealthBarVisible( void ) const { return true; }
#endif // CLIENT_DLL

private:
	DECLARE_DATADESC();
};

DECLARE_AUTO_LIST( ITFSOLOPropertyDamageNextBot );

class CTFSOLOPropertyDamageNextBot : public CTFBaseBoss, public ITFSOLOPropertyDamageNextBot, public ITFSOLOPropertyDamagePropAll
{
	DECLARE_NETWORKCLASS();
	DECLARE_CLASS( CTFSOLOPropertyDamageNextBot, CTFBaseBoss );
public:

	CTFSOLOPropertyDamageNextBot();

	CNetworkVar( float, m_flCurrentDamage );
	CNetworkVar( float, m_flLastMaxDamage );

#ifdef GAME_DLL
	virtual void Spawn( void );
	virtual int OnTakeDamage( const CTakeDamageInfo& info ) OVERRIDE;
	virtual int OnTakeDamage_Alive( const CTakeDamageInfo& info ) OVERRIDE;
	virtual bool ShouldCollide( int collisionGroup, int contentsMask ) const OVERRIDE;

	virtual bool	IsProjectileCollisionTarget( void ) const OVERRIDE { return true; }
	virtual bool	IsAlive( void ) OVERRIDE { return true; }
	virtual void	SetDamage( float flDmg ) { m_flCurrentDamage = flDmg; }
	virtual void	SetMaxDamage( float flDmg ) { m_flLastMaxDamage = flDmg; }
	virtual float	GetDamage() { return m_flCurrentDamage; }
	virtual float	GetMaxDamage() { return m_flLastMaxDamage; }

	void InputRoundActivate( inputdata_t& inputdata );
	void InputSetDamageAmount( inputdata_t& inputdata );
	void InputSetDamageable( inputdata_t& inputdata );
	void InputSetSappable( inputdata_t& inputdata );
	void InputSetRepairable( inputdata_t& inputdata );
#endif

#ifdef CLIENT_DLL
	virtual bool	IsVisibleToTargetID( void ) const { return true; }
	virtual bool	IsHealthBarVisible( void ) const { return true; }
#endif // CLIENT_DLL

	bool m_bMovementCollide;

private:
	DECLARE_DATADESC();
};

#endif // TFSOLO_PROPERTY_DAMAGE_PROP_H
