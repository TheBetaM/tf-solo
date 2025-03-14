//========== Copyright © 2008, Valve Corporation, All rights reserved. ========
//
// Purpose:
//
//=============================================================================

#ifndef VSCRIPT_SERVER_H
#define VSCRIPT_SERVER_H

#include "vscript/ivscript.h"
#include "vscript_shared.h"

#if defined( _WIN32 )
#pragma once
#endif

extern IScriptVM * g_pScriptVM;

// Only allow scripts to create entities during map initialization
bool IsEntityCreationAllowedInScripts( void );

class CVScriptGameEventListener : public CGameEventListener
{
public:
	virtual void FireGameEvent(IGameEvent* event);
	bool FireScriptHook(const char* pszHookName, HSCRIPT params);

	void RunGameEventCallbacks(const char* szName, HSCRIPT params);
	void RunScriptHookCallbacks(const char* szName, HSCRIPT params);

	void Init();
	void CollectGameEventCallbacksInScope(HSCRIPT scope);

	void ListenForScriptHook(const char* szName);
	bool HasScriptHook(const char* szName);
	void ClearAllScriptHooks();

private:

	CUtlSymbolTable m_ScriptHooks;

	HSCRIPT m_RunGameEventCallbacksFunc;
	HSCRIPT m_CollectGameEventCallbacksFunc;
	HSCRIPT m_ScriptHookCallbacksFunc;
};

extern CVScriptGameEventListener g_VScriptGameEventListener;

bool ScriptHooksEnabled(void);
bool ScriptHookEnabled(const char* pszName);
bool RunScriptHook(const char* pszHookName, HSCRIPT params);

// ----------------------------------------------------------------------------
// KeyValues access
// ----------------------------------------------------------------------------
class CScriptKeyValues
{
public:
	CScriptKeyValues(KeyValues* pKeyValues = NULL);
	~CScriptKeyValues();

	HSCRIPT ScriptFindKey(const char* pszName);
	HSCRIPT ScriptGetKey(const char* pszName, bool bCreate);
	HSCRIPT ScriptGetFirstSubKey(void);
	HSCRIPT ScriptGetNextKey(void);
	int ScriptGetKeyValueInt(const char* pszName);
	float ScriptGetKeyValueFloat(const char* pszName);
	const char* ScriptGetKeyValueString(const char* pszName);
	bool ScriptIsKeyValueEmpty(const char* pszName);
	bool ScriptGetKeyValueBool(const char* pszName);
	void ScriptReleaseKeyValues();
	const char* ScriptGetKeyValueName(const char* pszName);
	void ScriptSetKeyValueInt(const char* pszName, int i);
	void ScriptSetKeyValueFloat(const char* pszName, float i);
	void ScriptSetKeyValueString(const char* pszName, const char* i);
	void ScriptSetKeyValueBool(const char* pszName, bool i);
	void ScriptSetKeyValueName(const char* pszName, const char* i);
	void ScriptRemoveSubKey(const char* pszName);

	KeyValues* m_pKeyValues;	// actual KeyValue entity
};

class CVScriptGameSystem : public CAutoGameSystemPerFrame
{
public:
	// Inherited from IAutoServerSystem
	virtual bool Init(void);

	virtual void LevelInitPreEntity(void)
	{
		m_bAllowEntityCreationInScripts = true;
	}

	virtual void LevelInitPostEntity(void)
	{
		m_bAllowEntityCreationInScripts = false;
	}

	virtual void LevelShutdownPostEntity(void)
	{
		//VScriptClientTerm();
		m_bAllowEntityCreationInScripts = false;
	}

	virtual void FrameUpdatePostEntityThink()
	{
		if (g_pScriptVM)
			g_pScriptVM->Frame(gpGlobals->frametime);
	}

	virtual void Run(const char* code)
	{
		g_pScriptVM->Run(code);
	}

	virtual void Reload();

	bool m_bAllowEntityCreationInScripts;
	bool m_bLockSchema;
};

#endif // VSCRIPT_SERVER_H
