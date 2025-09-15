#ifndef TFSOLO_LOGIC_PROPERTY_DAMAGE_H
#define TFSOLO_LOGIC_PROPERTY_DAMAGE_H
#pragma once

#include "cbase.h"
#include "tf_logic_player_destruction.h"

#ifdef CLIENT_DLL
	#define CTFSOLOPropertyDamageLogic C_TFSOLOPropertyDamageLogic
#endif

//-----------------------------------------------------------------------------
class CTFSOLOPropertyDamageLogic : public CTFPlayerDestructionLogic
{
public:
#ifdef GAME_DLL
	DECLARE_DATADESC();
#endif // GAME_DLL
	DECLARE_CLASS( CTFSOLOPropertyDamageLogic, CTFPlayerDestructionLogic )
	DECLARE_NETWORKCLASS();

	virtual EType GetType() const { return TYPE_PROPERTY_DAMAGE; }

	CTFSOLOPropertyDamageLogic();
	static CTFSOLOPropertyDamageLogic* GetPropertyDamageLogic();

#ifdef GAME_DLL
	virtual void EvaluatePlayerCount() OVERRIDE;
	void CalculatePropCount();

private:
	void InputLoseRedPoints( inputdata_t& inputdata );
	void InputLoseBluePoints( inputdata_t& inputdata );
	void InputSetFixedMaxPoints( inputdata_t& inputdata );
	void InputUpdateMaxPoints( inputdata_t& inputdata );

	float m_flMaxPointsFraction;
	int m_iFixedMaxPoints;

	COutputEvent m_onPropCapturedTeam1;
	COutputEvent m_onPropCapturedTeam2;
	COutputEvent m_onPropLostTeam1;
	COutputEvent m_onPropLostTeam2;
#endif
};

#endif// TFSOLO_LOGIC_PROPERTY_DAMAGE_H
