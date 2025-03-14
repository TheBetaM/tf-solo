//========== Copyright (c) 2008, Valve Corporation, All rights reserved. ========
//
// Purpose:
//
//=============================================================================

#include "cbase.h"
#include "vscript_client.h"
#include "icommandline.h"
#include "tier1/utlbuffer.h"
#include "tier1/fmtstr.h"
#include "filesystem.h"
#include "characterset.h"
#include "isaverestore.h"
#include "gamerules.h"
//#include "vscript_client_nut.h"
//#include "gameui/gameui_interface.h"
#include "vscript_utils.h"
#include "in_buttons.h"
#include "vgui/ISurface.h"


#ifdef PANORAMA_ENABLE
#include "panorama/panorama.h"
#include "panorama/uijsregistration.h"
#endif

#include "usermessages.h"
#include "hud_macros.h"

#if defined( PORTAL2_PUZZLEMAKER )
#include "matchmaking/imatchframework.h"
#endif // PORTAL2_PUZZLEMAKER

#ifdef TF_CLIENT_DLL
#include "c_tf_player.h"
#include "character_info_panel.h"
#include "ienginevgui.h"
#endif // TF_CLIENT_DLL


extern IScriptManager *scriptmanager;
extern ScriptClassDesc_t * GetScriptDesc( CBaseEntity * );
CVScriptGameSystem g_VScriptGameSystem;

// #define VMPROFILE 1

#ifdef VMPROFILE

#define VMPROF_START double debugStartTime = Plat_FloatTime();
#define VMPROF_SHOW( funcname, funcdesc  ) DevMsg("***VSCRIPT PROFILE***: %s %s: %6.4f milliseconds\n", (##funcname), (##funcdesc), (Plat_FloatTime() - debugStartTime)*1000.0 );

#else // !VMPROFILE

#define VMPROF_START
#define VMPROF_SHOW

#endif // VMPROFILE

//-----------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------

#ifdef PANORAMA_ENABLE

DECLARE_PANORAMA_EVENT2( VScriptTrigger, const char *, const char * );
DEFINE_PANORAMA_EVENT( VScriptTrigger );

class CScriptPanorama
{
public:

	void DispatchEvent( const char *pszEventName, const char *pszMessage )
	{
		panorama::DispatchEvent( VScriptTrigger(), nullptr, pszEventName, pszMessage );
	}


private:
} g_ScriptPanorama;

BEGIN_SCRIPTDESC_ROOT_NAMED( CScriptPanorama, "CPanorama", SCRIPT_SINGLETON "Panorama VScript Interface" )
	DEFINE_SCRIPTFUNC( DispatchEvent, "Trigger a panorama event" )
END_SCRIPTDESC();

#endif

//-----------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------
static float Time()
{
	return gpGlobals->curtime;
}

static float MaxClients()
{
	return gpGlobals->maxClients;
}

static float FrameTime()
{
	return gpGlobals->frametime;
}

static const char *GetMapName()
{
	return engine->GetLevelName();
}

static const char *DoUniqueString( const char *pszBase )
{
	static char szBuf[512];
	g_pScriptVM->GenerateUniqueKey( pszBase, szBuf, ARRAYSIZE(szBuf) );
	return szBuf;
}

bool DoIncludeScript( const char *pszScript, HSCRIPT hScope )
{
	if ( !VScriptRunScript( pszScript, hScope, true ) )
	{
		g_pScriptVM->RaiseException( CFmtStr( "Failed to include script \"%s\"", ( pszScript ) ? pszScript : "unknown" ) );
		return false;
	}
	return true;
}

#if defined( PORTAL2_PUZZLEMAKER )
void RequestMapRating( void )
{
	g_pMatchFramework->GetEventsSubscription()->BroadcastEvent( new KeyValues( "OnRequestMapRating" ) );		
}

//
//  Hack solution for the moment
//

void OpenVoteDialog( void )
{
	RequestMapRating();
}

ConCommand cm_open_vote_dialog( "cm_open_vote_dialog", OpenVoteDialog, "Opens the map voting dialog for testing purposes" );
#endif // PORTAL2_PUZZLEMAKER

int GetDeveloperLevel()
{
	return developer.GetInt();
}

CVScriptGameEventListener g_VScriptGameEventListener;

void CVScriptGameEventListener::Init()
{
	m_RunGameEventCallbacksFunc = INVALID_HSCRIPT;
	m_CollectGameEventCallbacksFunc = INVALID_HSCRIPT;
	m_ScriptHookCallbacksFunc = INVALID_HSCRIPT;
}
void CVScriptGameEventListener::FireGameEvent(IGameEvent* event)
{
	// Pass all keyvales as a table of parameters
	HSCRIPT paramsTable = ScriptTableFromKeyValues(g_pScriptVM, event->GetDataKeys());
	RunGameEventCallbacks(event->GetName(), paramsTable);
}

void CVScriptGameEventListener::ListenForScriptHook(const char* szName)
{
	m_ScriptHooks.AddString(szName);
}

void CVScriptGameEventListener::ClearAllScriptHooks()
{
	m_ScriptHooks.RemoveAll();
}

bool CVScriptGameEventListener::HasScriptHook(const char* szName)
{
	if (!szName || !*szName)
		return false;

	return m_ScriptHooks.Find(szName).IsValid();
}

bool CVScriptGameEventListener::FireScriptHook(const char* pszHookName, HSCRIPT params)
{
	if (!HasScriptHook(pszHookName))
		return false;

	RunScriptHookCallbacks(pszHookName, params);
	return true;
}

// Calls a squirrel func (see vscript_server.nut) to call each
// registered script function associated with this game event.
void CVScriptGameEventListener::RunGameEventCallbacks(const char* szName, HSCRIPT params)
{
	Assert(szName);
	if (!szName)
		return;

	if (m_RunGameEventCallbacksFunc == INVALID_HSCRIPT)
		m_RunGameEventCallbacksFunc = g_pScriptVM->LookupFunction("__RunGameEventCallbacks");

	if (m_RunGameEventCallbacksFunc)
	{
		g_pScriptVM->Call(m_RunGameEventCallbacksFunc, NULL, true, NULL, szName, params);
	}
}

void CVScriptGameEventListener::RunScriptHookCallbacks(const char* szName, HSCRIPT params)
{
	Assert(szName);
	if (!szName)
		return;

	if (m_ScriptHookCallbacksFunc == INVALID_HSCRIPT)
		m_ScriptHookCallbacksFunc = g_pScriptVM->LookupFunction("__RunScriptHookCallbacks");

	if (m_ScriptHookCallbacksFunc)
	{
		g_pScriptVM->Call(m_ScriptHookCallbacksFunc, NULL, true, NULL, szName, params);
	}
}

void CVScriptGameEventListener::CollectGameEventCallbacksInScope(HSCRIPT scope)
{
	if (m_CollectGameEventCallbacksFunc == INVALID_HSCRIPT)
		m_CollectGameEventCallbacksFunc = g_pScriptVM->LookupFunction("__CollectGameEventCallbacks");

	if (m_CollectGameEventCallbacksFunc)
	{
		g_pScriptVM->Call(m_CollectGameEventCallbacksFunc, NULL, true, NULL, scope);
	}
}

void RegisterScriptGameEventListener(const char* pszEventName)
{
	if (!pszEventName || !*pszEventName)
	{
		Log_Warning(LOG_VScript, "No event name specified\n");
		return;
	}

	g_VScriptGameEventListener.ListenForGameEvent(pszEventName);
}

void RegisterScriptHookListener(const char* pszEventName)
{
	if (!pszEventName || !*pszEventName)
	{
		Log_Warning(LOG_VScript, "No event name specified\n");
		return;
	}

	g_VScriptGameEventListener.ListenForScriptHook(pszEventName);
}

void CollectGameEventCallbacksInScope(HSCRIPT scope)
{
	g_VScriptGameEventListener.CollectGameEventCallbacksInScope(scope);
}

void ClearScriptGameEventListeners(void)
{
	g_VScriptGameEventListener.StopListeningForAllEvents();
	g_VScriptGameEventListener.ClearAllScriptHooks();
}

bool ScriptHooksEnabled()
{
	return g_pScriptVM;
}

bool ScriptHookEnabled(const char* pszName)
{
	if (!ScriptHooksEnabled())
		return false;

	if (!pszName || !*pszName)
	{
		Log_Warning(LOG_VScript, "No event name specified\n");
		return false;
	}

	return g_VScriptGameEventListener.HasScriptHook(pszName);
}

bool RunScriptHook(const char* pszHookName, HSCRIPT params)
{
	if (!pszHookName || !*pszHookName)
	{
		Log_Warning(LOG_VScript, "No event name specified\n");
		return false;
	}

	return g_VScriptGameEventListener.FireScriptHook(pszHookName, params);
}

// ----------------------------------------------------------------------------
// KeyValues access - CBaseEntity::ScriptGetKeyFromModel returns root KeyValues
// ----------------------------------------------------------------------------

BEGIN_SCRIPTDESC_ROOT(CScriptKeyValues, "Wrapper class over KeyValues instance")
DEFINE_SCRIPT_CONSTRUCTOR()
DEFINE_SCRIPTFUNC_NAMED(ScriptFindKey, "FindKey", "Given a KeyValues object and a key name, find a KeyValues object associated with the key name");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetKey, "GetKey", "Given a KeyValues object and a key name, find a KeyValues object associated with the key name (optional bool to create it)");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetFirstSubKey, "GetFirstSubKey", "Given a KeyValues object, return the first sub key object");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetNextKey, "GetNextKey", "Given a KeyValues object, return the next key object in a sub key group");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetKeyValueInt, "GetKeyInt", "Given a KeyValues object and a key name, return associated integer value");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetKeyValueFloat, "GetKeyFloat", "Given a KeyValues object and a key name, return associated float value");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetKeyValueBool, "GetKeyBool", "Given a KeyValues object and a key name, return associated bool value");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetKeyValueString, "GetKeyString", "Given a KeyValues object and a key name, return associated string value");
DEFINE_SCRIPTFUNC_NAMED(ScriptIsKeyValueEmpty, "IsKeyEmpty", "Given a KeyValues object and a key name, return true if key name has no value");
DEFINE_SCRIPTFUNC_NAMED(ScriptReleaseKeyValues, "ReleaseKeyValues", "Given a root KeyValues object, release its contents");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetKeyValueName, "GetKeyName", "Given a KeyValues object, return key name");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetKeyValueName, "GetName", "Given a KeyValues object, return key name");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetKeyValueInt, "GetInt", "Given a KeyValues object and a key name, return associated integer value");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetKeyValueFloat, "GetFloat", "Given a KeyValues object and a key name, return associated float value");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetKeyValueBool, "GetBool", "Given a KeyValues object and a key name, return associated bool value");
DEFINE_SCRIPTFUNC_NAMED(ScriptGetKeyValueString, "GetString", "Given a KeyValues object and a key name, return associated string value");
DEFINE_SCRIPTFUNC_NAMED(ScriptSetKeyValueInt, "SetInt", "Given a KeyValues object and a key name, set associated integer value");
DEFINE_SCRIPTFUNC_NAMED(ScriptSetKeyValueFloat, "SetFloat", "Given a KeyValues object and a key name, set associated float value");
DEFINE_SCRIPTFUNC_NAMED(ScriptSetKeyValueBool, "SetBool", "Given a KeyValues object and a key name, set associated bool value");
DEFINE_SCRIPTFUNC_NAMED(ScriptSetKeyValueString, "SetString", "Given a KeyValues object and a key name, set associated string value");
DEFINE_SCRIPTFUNC_NAMED(ScriptSetKeyValueInt, "SetKeyInt", "Given a KeyValues object and a key name, set associated integer value");
DEFINE_SCRIPTFUNC_NAMED(ScriptSetKeyValueFloat, "SetKeyFloat", "Given a KeyValues object and a key name, set associated float value");
DEFINE_SCRIPTFUNC_NAMED(ScriptSetKeyValueBool, "SetKeyBool", "Given a KeyValues object and a key name, set associated bool value");
DEFINE_SCRIPTFUNC_NAMED(ScriptSetKeyValueString, "SetKeyString", "Given a KeyValues object and a key name, set associated string value");
DEFINE_SCRIPTFUNC_NAMED(ScriptSetKeyValueName, "SetName", "Given a KeyValues object and a key name, set associated key name");
DEFINE_SCRIPTFUNC_NAMED(ScriptSetKeyValueName, "SetKeyName", "Given a KeyValues object and a key name, set associated key name");
DEFINE_SCRIPTFUNC_NAMED(ScriptRemoveSubKey, "RemoveSubKey", "Given a KeyValues object and a key name, remove sub key");
END_SCRIPTDESC();

HSCRIPT CScriptKeyValues::ScriptFindKey(const char* pszName)
{
	KeyValues* pKeyValues = m_pKeyValues->FindKey(pszName);
	if (pKeyValues == NULL)
		return NULL;

	CScriptKeyValues* pScriptKey = new CScriptKeyValues(pKeyValues);

	// UNDONE: who calls ReleaseInstance on this??
	HSCRIPT hScriptInstance = g_pScriptVM->RegisterInstance(pScriptKey);
	return hScriptInstance;
}

HSCRIPT CScriptKeyValues::ScriptGetKey(const char* pszName, bool bCreate)
{
	KeyValues* pKeyValues = m_pKeyValues->FindKey(pszName, bCreate);
	if (pKeyValues == NULL)
		return NULL;

	CScriptKeyValues* pScriptKey = new CScriptKeyValues(pKeyValues);

	// UNDONE: who calls ReleaseInstance on this??
	HSCRIPT hScriptInstance = g_pScriptVM->RegisterInstance(pScriptKey);
	return hScriptInstance;
}

HSCRIPT CScriptKeyValues::ScriptGetFirstSubKey(void)
{
	KeyValues* pKeyValues = m_pKeyValues->GetFirstSubKey();
	if (pKeyValues == NULL)
		return NULL;

	CScriptKeyValues* pScriptKey = new CScriptKeyValues(pKeyValues);

	// UNDONE: who calls ReleaseInstance on this??
	HSCRIPT hScriptInstance = g_pScriptVM->RegisterInstance(pScriptKey);
	return hScriptInstance;
}

HSCRIPT CScriptKeyValues::ScriptGetNextKey(void)
{
	KeyValues* pKeyValues = m_pKeyValues->GetNextKey();
	if (pKeyValues == NULL)
		return NULL;

	CScriptKeyValues* pScriptKey = new CScriptKeyValues(pKeyValues);

	// UNDONE: who calls ReleaseInstance on this??
	HSCRIPT hScriptInstance = g_pScriptVM->RegisterInstance(pScriptKey);
	return hScriptInstance;
}

int CScriptKeyValues::ScriptGetKeyValueInt(const char* pszName)
{
	int i = m_pKeyValues->GetInt(pszName);
	return i;
}

float CScriptKeyValues::ScriptGetKeyValueFloat(const char* pszName)
{
	float f = m_pKeyValues->GetFloat(pszName);
	return f;
}

const char* CScriptKeyValues::ScriptGetKeyValueString(const char* pszName)
{
	const char* psz = m_pKeyValues->GetString(pszName);
	return psz;
}

bool CScriptKeyValues::ScriptIsKeyValueEmpty(const char* pszName)
{
	bool b = m_pKeyValues->IsEmpty(pszName);
	return b;
}

bool CScriptKeyValues::ScriptGetKeyValueBool(const char* pszName)
{
	bool b = m_pKeyValues->GetBool(pszName);
	return b;
}

void CScriptKeyValues::ScriptReleaseKeyValues()
{
	m_pKeyValues->deleteThis();
	m_pKeyValues = NULL;
}

void CScriptKeyValues::ScriptRemoveSubKey(const char* pszName)
{
	auto key = m_pKeyValues->FindKey(pszName);
	if (key)
	{
		m_pKeyValues->RemoveSubKey(key);
		key->deleteThis();
	}
}

const char* CScriptKeyValues::ScriptGetKeyValueName(const char* pszName)
{
	const char* psz = m_pKeyValues->GetName();
	return psz;
}

void CScriptKeyValues::ScriptSetKeyValueName(const char* pszName, const char* i)
{
	m_pKeyValues->SetName(i);
}

void CScriptKeyValues::ScriptSetKeyValueInt(const char* pszName, int i)
{
	m_pKeyValues->SetInt(pszName, i);
}

void CScriptKeyValues::ScriptSetKeyValueFloat(const char* pszName, float i)
{
	m_pKeyValues->SetFloat(pszName, i);
}

void CScriptKeyValues::ScriptSetKeyValueString(const char* pszName, const char* i)
{
	m_pKeyValues->SetString(pszName, i);
}

void CScriptKeyValues::ScriptSetKeyValueBool(const char* pszName, bool i)
{
	m_pKeyValues->SetBool(pszName, i);
}


// constructors
CScriptKeyValues::CScriptKeyValues(KeyValues* pKeyValues)
{
	m_pKeyValues = pKeyValues;
}

// destructor
CScriptKeyValues::~CScriptKeyValues()
{
	//if (m_pKeyValues)
	//{
	//	m_pKeyValues->deleteThis();
	//}
	m_pKeyValues = NULL;
}

// Fires a game event from a script file to any listening script hooks.
// NOTE: this only goes from script, to script. No C code game event listeners
// will be notified.
bool ScriptFireGameEvent(const char* szName, HSCRIPT params)
{
	if (!szName || !*szName)
		return false;

	g_VScriptGameEventListener.RunGameEventCallbacks(szName, params);
	return true;
}

bool ScriptFireScriptHook(const char* szName, HSCRIPT params)
{
	if (!szName || !*szName)
		return false;

	return g_VScriptGameEventListener.FireScriptHook(szName, params);
}

bool ScriptSendGlobalGameEvent(const char* szName, HSCRIPT params)
{
	if (!szName || !*szName)
		return false;

	IGameEvent* event = gameeventmanager->CreateEvent(szName);
	if (!event)
		return false;

	// Josh: This wasn't as bad as I thought it would be!
	{
		int nIter = 0;
		int nEntries = g_pScriptVM->GetNumTableEntries(params);
		for (int i = 0; i < nEntries; i++)
		{
			ScriptVariant_t vKey, vValue;
			nIter = g_pScriptVM->GetKeyValue(params, nIter, &vKey, &vValue);

			if (vKey.GetType() != FIELD_CSTRING)
			{
				Log_Msg(LOG_VScript, "VSCRIPT: ScriptSendRealGameEvent: Key must be a FIELD_CSTRING");
				continue;
			}
			const char* pszKeyName = (const char*)vKey;
			switch (vValue.GetType())
			{
			case FIELD_BOOLEAN: event->SetBool(pszKeyName, (bool)vValue);         break;
			case FIELD_FLOAT:   event->SetFloat(pszKeyName, (float)vValue);        break;
			case FIELD_INTEGER: event->SetInt(pszKeyName, (int)vValue);          break;
			case FIELD_CSTRING: event->SetString(pszKeyName, (const char*)vValue); break;
			case FIELD_UINT64:  event->SetUint64(pszKeyName, (uint64)vValue);       break;
			default:
			{
				Log_Msg(LOG_VScript, "VSCRIPT: ScriptSendRealGameEvent: Don't understand FIELD_TYPE of value for key %s.", pszKeyName);
				break;
			}
			}
		}
	}

	gameeventmanager->FireEvent(event);

	return true;
}

const Vector& RotatePosition(const Vector rotateOrigin, const QAngle rotateAngles, const Vector position)
{
	VMatrix rotationMatrix;
	static Vector vecRotated;
	rotationMatrix.SetupMatrixOrgAngles(rotateOrigin, rotateAngles);
	vecRotated = rotationMatrix.ApplyRotation(position);
	return vecRotated;
}

QAngle RotateOrientation(QAngle posAngles, QAngle entAngles)
{
	matrix3x4_t posMat;
	AngleMatrix(posAngles, posMat);

	matrix3x4_t entMat;
	AngleMatrix(entAngles, entMat);

	matrix3x4_t outMat;
	ConcatTransforms(posMat, entMat, outMat);

	QAngle outAngles;
	MatrixAngles(outMat, outAngles);
	return outAngles;
}

// Users have requested the ability to write to subdirectories of /scriptdata/, so some extra
// validation will be needed to prevent writing to any locations outside the scriptdata directory
template <size_t maxLenInChars>
static bool CreateAndValidateFileLocation(char(&pDest)[maxLenInChars], const char* pFileName)
{
	// establish the scriptdata directory
	char szFullSCRIPTDATAPath[MAX_PATH];
	V_MakeAbsolutePath(szFullSCRIPTDATAPath, sizeof(szFullSCRIPTDATAPath), "scriptdata");

	// Get the filepath, clean it up, and make it a subdir of /scriptdata/
	char szPath[MAX_PATH];
	char szFullFilePath[MAX_PATH];
	char szFixedPathName[MAX_PATH];
	V_FixupPathName(szFixedPathName, sizeof(szFixedPathName), pFileName);
	V_snprintf(szPath, sizeof(szPath), "scriptdata%c%s", CORRECT_PATH_SEPARATOR, szFixedPathName);
	V_MakeAbsolutePath(szFullFilePath, sizeof(szFullFilePath), szPath);

	// Get the relative path, if possible
	char szRelativePath[MAX_PATH];
	bool bSuccess = V_MakeRelativePath(szFullFilePath, szFullSCRIPTDATAPath, szRelativePath, sizeof(szRelativePath));

	// Don't allow users to move outside the scriptdata folder
	if (!bSuccess || V_stristr(szRelativePath, ".."))
	{
		Warning("Invalid file location: %s\n", szFullFilePath);
		return false;
	}

	// Now build the final path
	char szDirHierarchy[MAX_PATH];
	V_ExtractFilePath(szPath, szDirHierarchy, sizeof(szDirHierarchy));
	g_pFullFileSystem->CreateDirHierarchy(szDirHierarchy, "DEFAULT_WRITE_PATH");
	V_snprintf(pDest, maxLenInChars, "scriptdata%c%s", CORRECT_PATH_SEPARATOR, szRelativePath);
	return true;
}

static bool Script_StringToFile(const char* pszFileName, const char* pszTmp)
{
	if (!pszFileName || !*pszFileName)
	{
		Log_Warning(LOG_VScript, "Script_StringToFile: NULL/empty file name\n");
		return false;
	}

	if (V_strstr(pszFileName, ".."))
	{
		Log_Warning(LOG_VScript, "StringToFile() file name cannot contain '..'\n");
		return false;
	}

	char szFilePath[MAX_PATH];
	if (!CreateAndValidateFileLocation(szFilePath, pszFileName))
		return false;

	FileHandle_t hFile = g_pFullFileSystem->Open(szFilePath, "wt", "DEFAULT_WRITE_PATH");  // is this failing and not allowing a rewrite?
	if (hFile == FILESYSTEM_INVALID_HANDLE)
	{
		Warning("Couldn't open %s (as %p) to write out the table\n", szFilePath, pszFileName);
		return false;
	}
	//	int rval = 
	g_pFullFileSystem->Write(pszTmp, V_strlen(pszTmp) + 1, hFile);
	//	DevMsg("Think we wrote to %s rval is %d and size is %d\n", pszFileName, rval, V_strlen(pszTmp)+1 );
	g_pFullFileSystem->Close(hFile);
	return true;
}

#define FILE_TO_STRING_BUF_SIZE 65534
static char fileReadBuf[FILE_TO_STRING_BUF_SIZE + 1];
static const char* Script_FileToString(const char* pszFileName)
{
	if (!pszFileName || !*pszFileName)
	{
		Log_Warning(LOG_VScript, "Script_FileToString: NULL/empty file name\n");
		return NULL;
	}

	if (V_strstr(pszFileName, ".."))
	{
		Log_Warning(LOG_VScript, "FileToString() file name cannot contain '..'\n");
		return NULL;
	}

	char szFilePath[MAX_PATH];
	if (!CreateAndValidateFileLocation(szFilePath, pszFileName))
		return NULL;

	FileHandle_t hFile = g_pFullFileSystem->Open(szFilePath, "r", "DEFAULT_WRITE_PATH");
	if (hFile == FILESYSTEM_INVALID_HANDLE)
		return NULL;

	g_pFullFileSystem->Seek(hFile, 0, FILESYSTEM_SEEK_TAIL);
	uint iFLen = g_pFullFileSystem->Tell(hFile);
	if (iFLen > FILE_TO_STRING_BUF_SIZE)
	{
		Warning("File %s (from %s) is len %d too long for a ScriptFileRead\n", szFilePath, pszFileName, iFLen);
		return NULL;
	}
	g_pFullFileSystem->Seek(hFile, 0, FILESYSTEM_SEEK_HEAD);
	uint rval = g_pFullFileSystem->Read(fileReadBuf, iFLen, hFile);
	fileReadBuf[rval] = 0;  // null terminate the thing we just read!
	g_pFullFileSystem->Close(hFile);
	//	DevMsg("Think we loaded, rval was %d and iflen was %d for file %s\n", rval, iFLen, pszFileName );
	return fileReadBuf;
}

static HSCRIPT Script_FileToKeyValues(const char* pszFileName)
{
	if (!pszFileName || !*pszFileName)
	{
		Log_Warning(LOG_VScript, "Script_FileToKeyValues: NULL/empty file name\n");
		return NULL;
	}

	KeyValues* pKeyValues = new KeyValues("scriptkv");
	if (pKeyValues->LoadFromFile(g_pFullFileSystem, pszFileName, "GAME"))
	{
		CScriptKeyValues* pScriptKey = new CScriptKeyValues(pKeyValues);
		HSCRIPT hScriptInstance = g_pScriptVM->RegisterInstance(pScriptKey);
		return hScriptInstance;
	}
	return NULL;
}

static int Script_GetFrameCount(void)
{
	return gpGlobals->framecount;
}

bool Script_IsInGame()
{
	return engine->IsInGame();
}

static void Script_GetLocalTime(HSCRIPT hTable)
{
	if (!hTable)
		return;

	tm timeValue;
	VCRHook_LocalTime(&timeValue); 	// Calls time and gives you localtime's result.
	const tm* pLocalTime = &timeValue;

	g_pScriptVM->SetValue(hTable, "second", pLocalTime->tm_sec);
	g_pScriptVM->SetValue(hTable, "minute", pLocalTime->tm_min);
	g_pScriptVM->SetValue(hTable, "hour", pLocalTime->tm_hour);
	g_pScriptVM->SetValue(hTable, "day", pLocalTime->tm_mday);
	g_pScriptVM->SetValue(hTable, "month", (pLocalTime->tm_mon + 1));
	g_pScriptVM->SetValue(hTable, "year", (pLocalTime->tm_year + 1900));
	g_pScriptVM->SetValue(hTable, "dayofweek", pLocalTime->tm_wday);
	g_pScriptVM->SetValue(hTable, "dayofyear", pLocalTime->tm_yday);
	g_pScriptVM->SetValue(hTable, "daylightsavings", pLocalTime->tm_isdst);

}

bool Script_FileExists(const char* file, const char* pathID = "GAME")
{
	return g_pFullFileSystem->FileExists(file, pathID);
}

void Script_VGUI_PlaySound(const char* file)
{
	vgui::surface()->PlaySound(file);
}

bool Script_IsServer()
{
	return false;
}
bool Script_IsClient()
{
	return true;
}

static void SendToConsole(const char* pszCommand)
{
	if (!pszCommand)
		return;

	engine->ClientCmd_Unrestricted(pszCommand);
}

static void SendToServerConsole(const char* pszCommand)
{
	if (!pszCommand)
		return;

	engine->ServerCmd(pszCommand);
}

#ifdef TF_CLIENT_DLL
// ----------------------------------------------------------------------------
// Solo access
// ----------------------------------------------------------------------------
class CSoloAccess
{
public:
	CSoloAccess() { };
	~CSoloAccess() { };

	void WriteSaveData()
	{
		TFInventoryManager()->WriteSaveData();
	}
	HSCRIPT GetSaveData(void)
	{
		KeyValues* pKeyValues = TFInventoryManager()->GetSaveData();
		if (pKeyValues == NULL)
			return NULL;

		CScriptKeyValues* pScriptKey = new CScriptKeyValues(pKeyValues);
		HSCRIPT hScriptInstance = g_pScriptVM->RegisterInstance(pScriptKey);
		return hScriptInstance;
	}
	void UnlockItem(const char* name)
	{
		auto def = GetItemSchema()->GetItemDefinitionByName(name);
		if (def)
		{
			TFInventoryManager()->AddSoloItem(def->GetDefinitionIndex());
		}
	}
	void UnlockItemID(int id)
	{
		auto def = GetItemSchema()->GetItemDefinition(id);
		if (def)
		{
			TFInventoryManager()->AddSoloItem(id);
		}
	}
	void EconMenuClose()
	{
		EconUI()->CloseEconUI();
	}
	void EconMenuOpenArmory()
	{
		EconUI()->OpenEconUI(ECONUI_ARMORY);
	}
	void EconMenuOpenBestiary()
	{
		EconUI()->OpenEconUI(ECONUI_CRAFTING);
	}
	void EconNotifyPop(const char* text, float lifetime = 5.0f, bool localize = false)
	{
		KeyValuesAD keyValues("notify");
		keyValues->SetColor("custom_color", Color(255, 255, 255, 255));
		CEconNotification* pNotification = new CEconNotification();
		if (localize)
		{
			pNotification->SetText(text);
		}
		else
		{
			wchar_t wConvert[1024];
			V_UTF8ToUnicode(text, wConvert, ARRAYSIZE(wConvert));
			keyValues->SetWString("message", wConvert);
			pNotification->SetText("#Notification_System_Message");
		}
		pNotification->SetLifetime(lifetime);
		pNotification->SetSoundFilename("vo/null.mp3");
		pNotification->SetKeyValues(keyValues);
		NotificationQueue_Add(pNotification);
	}
	bool ItemDefExists(const char* name)
	{
		return GetItemSchema()->GetItemDefinitionByName(name) != NULL;
	}
	bool ItemDefIDExists(int id)
	{
		return GetItemSchema()->GetItemDefinition(id) != NULL;
	}
	const char* ItemDefName(int id)
	{
		if (GetItemSchema()->GetItemDefinition(id) != NULL)
		{
			return GetItemSchema()->GetItemDefinition(id)->GetDefinitionName();
		}
		return NULL;
	}
	HSCRIPT ItemSchemaGetKV()
	{
		return Script_FileToKeyValues("scripts/items/items_custom.txt");
	}
	void ItemSchemaReload(HSCRIPT kv)
	{
		g_VScriptGameSystem.m_bLockSchema = true;
		auto kvs = (CScriptKeyValues*)g_pScriptVM->GetInstanceValue(kv, GetScriptDescForClass(CScriptKeyValues));
		GetItemSchema()->BInitFromKV(kvs->m_pKeyValues);
		g_VScriptGameSystem.m_bLockSchema = false;
	}
};

CSoloAccess g_SoloAccess;

BEGIN_SCRIPTDESC_ROOT_NAMED(CSoloAccess, "CSolo", SCRIPT_SINGLETON "Solo access")

	DEFINE_SCRIPTFUNC(WriteSaveData, "Save solo data.")
	DEFINE_SCRIPTFUNC(GetSaveData, "Get a KeyValues handle of the solo save data.")

	DEFINE_SCRIPTFUNC(ItemSchemaGetKV, "")
	DEFINE_SCRIPTFUNC(ItemSchemaReload, "")
	DEFINE_SCRIPTFUNC(ItemDefExists, "")
	DEFINE_SCRIPTFUNC(ItemDefIDExists, "")
	DEFINE_SCRIPTFUNC(ItemDefName, "")

	DEFINE_SCRIPTFUNC(UnlockItem, "Unlock an item by schema name.")
	DEFINE_SCRIPTFUNC(UnlockItemID, "Unlock an item by schema ID.")

	DEFINE_SCRIPTFUNC(EconMenuClose, "")
	DEFINE_SCRIPTFUNC(EconMenuOpenArmory, "")
	DEFINE_SCRIPTFUNC(EconMenuOpenBestiary, "")
	DEFINE_SCRIPTFUNC(EconNotifyPop, "")

END_SCRIPTDESC();
#endif // TF_CLIENT_DLL

bool VScriptClientInit()
{
	VMPROF_START

	if( scriptmanager != NULL )
	{
		ScriptLanguage_t scriptLanguage = SL_DEFAULT;

		char const *pszScriptLanguage;
		if ( CommandLine()->CheckParm( "-scriptlang", &pszScriptLanguage ) )
		{
			if( !Q_stricmp(pszScriptLanguage, "gamemonkey") )
			{
				scriptLanguage = SL_GAMEMONKEY;
			}
			else if( !Q_stricmp(pszScriptLanguage, "squirrel") )
			{
				scriptLanguage = SL_SQUIRREL;
			}
			else if( !Q_stricmp(pszScriptLanguage, "python") )
			{
				scriptLanguage = SL_PYTHON;
			}
			else
			{
				DevWarning("-scriptlang does not recognize a language named '%s'. virtual machine did NOT start.\n", pszScriptLanguage );
				scriptLanguage = SL_NONE;
			}

		}
		if( scriptLanguage != SL_NONE )
		{
			if ( g_pScriptVM == NULL )
				g_pScriptVM = scriptmanager->CreateVM( scriptLanguage );

			if( g_pScriptVM )
			{
				Log_Msg( LOG_VScript, "VSCRIPT: Started VScript virtual machine using script language '%s'\n", g_pScriptVM->GetLanguageName() );
				ScriptRegisterFunction( g_pScriptVM, GetMapName, "Get the name of the map.");
				ScriptRegisterFunction( g_pScriptVM, Time, "Get the current server time" );
				ScriptRegisterFunction( g_pScriptVM, DoIncludeScript, "Execute a script (internal)" );
				ScriptRegisterFunction( g_pScriptVM, GetDeveloperLevel, "Gets the level of 'develoer'" );

				ScriptRegisterFunction(g_pScriptVM, SendToConsole, "Send a string to the client console as a command");
				ScriptRegisterFunction(g_pScriptVM, SendToServerConsole, "Send a string that gets executed on the server as a ClientCommand.");
				ScriptRegisterFunctionNamed(g_pScriptVM, SendToServerConsole, "SendToConsoleServer", "Copy of SendToServerConsole with another name for compat.");
				//ScriptRegisterFunction(g_pScriptVM, DoEntFire, SCRIPT_ALIAS("EntFire", "Generate and entity i/o event"));
				ScriptRegisterFunction(g_pScriptVM, DoUniqueString, SCRIPT_ALIAS("UniqueString", "Generate a string guaranteed to be unique across the life of the script VM, with an optional root string. Useful for adding data to tables when not sure what keys are already in use in that table."));
				ScriptRegisterFunction(g_pScriptVM, RegisterScriptGameEventListener, "Register as a listener for a game event from script.");
				ScriptRegisterFunction(g_pScriptVM, RegisterScriptHookListener, "Register as a listener for a script hook from script.");
				//ScriptRegisterFunction(g_pScriptVM, EntIndexToHScript, "Turn an entity index integer to an HScript representing that entity's script instance.");
				//ScriptRegisterFunction(g_pScriptVM, PlayerInstanceFromIndex, "Get a script instance of a player by index.");
				ScriptRegisterFunctionNamed(g_pScriptVM, ScriptFireGameEvent, "FireGameEvent", "Fire a game event to a listening callback function in script. Parameters are passed in a squirrel table.");
				ScriptRegisterFunctionNamed(g_pScriptVM, ScriptFireScriptHook, "FireScriptHook", "Fire a script hoook to a listening callback function in script. Parameters are passed in a squirrel table.");
				ScriptRegisterFunctionNamed(g_pScriptVM, ScriptSendGlobalGameEvent, "SendGlobalGameEvent", "Sends a real game event to everything. Parameters are passed in a squirrel table.");
				ScriptRegisterFunction(g_pScriptVM, ScriptHooksEnabled, "Returns whether script hooks are currently enabled.");

				ScriptRegisterFunction(g_pScriptVM, RotatePosition, "Rotate a Vector around a point.");
				ScriptRegisterFunction(g_pScriptVM, RotateOrientation, "Rotate a QAngle by another QAngle.");

				ScriptRegisterFunctionNamed(g_pScriptVM, Script_StringToFile, "StringToFile", "Store a string to a file for later reading");
				ScriptRegisterFunctionNamed(g_pScriptVM, Script_FileToString, "FileToString", "Reads a string from a file to send to script");
				ScriptRegisterFunctionNamed(g_pScriptVM, Script_FileToKeyValues, "FileToKeyValues", "Reads KeyValues from a file to send to script");

				ScriptRegisterFunctionNamed(g_pScriptVM, Script_GetFrameCount, "GetFrameCount", "Returns the engines current frame count");
				ScriptRegisterFunction(g_pScriptVM, FrameTime, "Get the time spent on the server in the last frame");
				ScriptRegisterFunction(g_pScriptVM, MaxClients, "Get the current number of max clients set by the maxplayers command.");
				ScriptRegisterFunctionNamed(g_pScriptVM, Script_GetLocalTime, "LocalTime", "Fills out a table with the local time (second, minute, hour, day, month, year, dayofweek, dayofyear, daylightsavings)");
				ScriptRegisterFunctionNamed(g_pScriptVM, Script_IsInGame, "IsInGame", "Returns true if client is in a server.");
				ScriptRegisterFunctionNamed(g_pScriptVM, Script_IsServer, "IsServer", "Returns true if script is running on the server.");
				ScriptRegisterFunctionNamed(g_pScriptVM, Script_IsClient, "IsClient", "Returns true if script is running on the client.");

				ScriptRegisterFunctionNamed(g_pScriptVM, Script_FileExists, "FileExists", "Returns true if file exists in file system.");
				ScriptRegisterFunctionNamed(g_pScriptVM, Script_VGUI_PlaySound, "VGUI_PlaySound", "");

#if defined( PORTAL2_PUZZLEMAKER )
				ScriptRegisterFunction( g_pScriptVM, RequestMapRating, "Pops up the map rating dialog for user input" );
#endif // PORTAL2_PUZZLEMAKER
				
				g_pScriptVM->RegisterAllClasses();

				if ( GameRules() )
				{
					GameRules()->RegisterScriptFunctions();
				}

#ifdef TF_CLIENT_DLL
				g_pScriptVM->RegisterInstance(&g_SoloAccess, "Solo");
#endif // TF_CLIENT_DLL

#ifdef PANORAMA_ENABLE
				g_pScriptVM->RegisterInstance( &g_ScriptPanorama, "Panorama" );
#endif

				ScriptVariant_t	vConstantsTable;
				g_pScriptVM->CreateTable(vConstantsTable);
#define DECLARE_SCRIPT_CONST_TABLE( x ) ScriptVariant_t	vConstantsTable_##x; g_pScriptVM->CreateTable( vConstantsTable_##x );
#define DECLARE_SCRIPT_CONST_NAMED( type, name, x ) g_pScriptVM->SetValue( (HSCRIPT)vConstantsTable_##type, name, x );
#define DECLARE_SCRIPT_CONST( type, x ) DECLARE_SCRIPT_CONST_NAMED( type, #x, x )
#define REGISTER_SCRIPT_CONST_TABLE( x ) g_pScriptVM->SetValue( (HSCRIPT) vConstantsTable, #x, vConstantsTable_##x );
#ifdef TF_CLIENT_DLL
				/*
				DECLARE_SCRIPT_CONST_TABLE(EScriptRecipientFilter)
				DECLARE_SCRIPT_CONST(EScriptRecipientFilter, RECIPIENT_FILTER_DEFAULT)
				DECLARE_SCRIPT_CONST(EScriptRecipientFilter, RECIPIENT_FILTER_PAS_ATTENUATION)
				DECLARE_SCRIPT_CONST(EScriptRecipientFilter, RECIPIENT_FILTER_PAS)
				DECLARE_SCRIPT_CONST(EScriptRecipientFilter, RECIPIENT_FILTER_PVS)
				DECLARE_SCRIPT_CONST(EScriptRecipientFilter, RECIPIENT_FILTER_SINGLE_PLAYER)
				DECLARE_SCRIPT_CONST(EScriptRecipientFilter, RECIPIENT_FILTER_GLOBAL)
				DECLARE_SCRIPT_CONST(EScriptRecipientFilter, RECIPIENT_FILTER_TEAM)
				REGISTER_SCRIPT_CONST_TABLE(EScriptRecipientFilter)
				*/
					DECLARE_SCRIPT_CONST_TABLE(ETFCond)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_INVALID)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_AIMING)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_ZOOMED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_DISGUISING)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_DISGUISED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_STEALTHED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_INVULNERABLE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_TELEPORTED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_TAUNTING)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_INVULNERABLE_WEARINGOFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_STEALTHED_BLINK)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_SELECTED_TO_TELEPORT)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_CRITBOOSTED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_TMPDAMAGEBONUS)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_FEIGN_DEATH)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_PHASE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_STUNNED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_OFFENSEBUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_SHIELD_CHARGE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_DEMO_BUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_ENERGY_BUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RADIUSHEAL)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HEALTH_BUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_BURNING)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HEALTH_OVERHEALED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_URINE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_BLEEDING)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_DEFENSEBUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MAD_MILK)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MEGAHEAL)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_REGENONDAMAGEBUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MARKEDFORDEATH)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_NOHEALINGDAMAGEBUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_SPEED_BOOST)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_CRITBOOSTED_PUMPKIN)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_CRITBOOSTED_USER_BUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_CRITBOOSTED_DEMO_CHARGE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_SODAPOPPER_HYPE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_CRITBOOSTED_FIRST_BLOOD)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_CRITBOOSTED_BONUS_TIME)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_CRITBOOSTED_CTF_CAPTURE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_CRITBOOSTED_ON_KILL)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_CANNOT_SWITCH_FROM_MELEE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_DEFENSEBUFF_NO_CRIT_BLOCK)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_REPROGRAMMED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_CRITBOOSTED_RAGE_BUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_DEFENSEBUFF_HIGH)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_SNIPERCHARGE_RAGE_BUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_DISGUISE_WEARINGOFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MARKEDFORDEATH_SILENT)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_DISGUISED_AS_DISPENSER)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_SAPPED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_INVULNERABLE_USER_BUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HALLOWEEN_BOMB_HEAD)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HALLOWEEN_THRILLER)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RADIUSHEAL_ON_DAMAGE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_CRITBOOSTED_CARD_EFFECT)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_INVULNERABLE_CARD_EFFECT)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MEDIGUN_UBER_BULLET_RESIST)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MEDIGUN_UBER_BLAST_RESIST)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MEDIGUN_UBER_FIRE_RESIST)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MEDIGUN_SMALL_BULLET_RESIST)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MEDIGUN_SMALL_BLAST_RESIST)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MEDIGUN_SMALL_FIRE_RESIST)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_STEALTHED_USER_BUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MEDIGUN_DEBUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_STEALTHED_USER_BUFF_FADING)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_BULLET_IMMUNE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_BLAST_IMMUNE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_FIRE_IMMUNE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_PREVENT_DEATH)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MVM_BOT_STUN_RADIOWAVE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HALLOWEEN_SPEED_BOOST)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HALLOWEEN_QUICK_HEAL)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HALLOWEEN_GIANT)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HALLOWEEN_TINY)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HALLOWEEN_IN_HELL)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HALLOWEEN_GHOST_MODE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MINICRITBOOSTED_ON_KILL)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_OBSCURED_SMOKE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_PARACHUTE_ACTIVE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_BLASTJUMPING)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HALLOWEEN_KART)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HALLOWEEN_KART_DASH)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_BALLOON_HEAD)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_MELEE_ONLY)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_SWIMMING_CURSE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_FREEZE_INPUT)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HALLOWEEN_KART_CAGE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_DONOTUSE_0)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_STRENGTH)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_HASTE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_REGEN)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_RESIST)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_VAMPIRE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_REFLECT)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_PRECISION)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_AGILITY)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_GRAPPLINGHOOK)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_GRAPPLINGHOOK_SAFEFALL)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_GRAPPLINGHOOK_LATCHED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_GRAPPLINGHOOK_BLEEDING)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_AFTERBURN_IMMUNE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_KNOCKOUT)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_IMBALANCE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_CRITBOOSTED_RUNE_TEMP)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_PASSTIME_INTERCEPTION)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_SWIMMING_NO_EFFECTS)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_PURGATORY)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_KING)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_PLAGUE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_RUNE_SUPERNOVA)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_PLAGUE)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_KING_BUFFED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_TEAM_GLOWS)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_KNOCKED_INTO_AIR)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_COMPETITIVE_WINNER)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_COMPETITIVE_LOSER)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HEALING_DEBUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_PASSTIME_PENALTY_DEBUFF)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_GRAPPLED_TO_PLAYER)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_GRAPPLED_BY_PLAYER)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_PARACHUTE_DEPLOYED)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_GAS)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_BURNING_PYRO)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_ROCKETPACK)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_LOST_FOOTING)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_AIR_CURRENT)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_HALLOWEEN_HELL_HEAL)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_POWERUPMODE_DOMINANT)
				DECLARE_SCRIPT_CONST(ETFCond, TF_COND_IMMUNE_TO_PUSHBACK)
				REGISTER_SCRIPT_CONST_TABLE(ETFCond)
				/*
					DECLARE_SCRIPT_CONST_TABLE(ECritType)
				DECLARE_SCRIPT_CONST_NAMED(ECritType, "CRIT_NONE", CTakeDamageInfo::CRIT_NONE)
				DECLARE_SCRIPT_CONST_NAMED(ECritType, "CRIT_MINI", CTakeDamageInfo::CRIT_MINI)
				DECLARE_SCRIPT_CONST_NAMED(ECritType, "CRIT_FULL", CTakeDamageInfo::CRIT_FULL)
				REGISTER_SCRIPT_CONST_TABLE(ECritType)

					DECLARE_SCRIPT_CONST_TABLE(FTFBotAttributeType)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "REMOVE_ON_DEATH", CTFBot::AttributeType::REMOVE_ON_DEATH)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "AGGRESSIVE", CTFBot::AttributeType::AGGRESSIVE)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "IS_NPC", CTFBot::AttributeType::IS_NPC)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "SUPPRESS_FIRE", CTFBot::AttributeType::SUPPRESS_FIRE)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "DISABLE_DODGE", CTFBot::AttributeType::DISABLE_DODGE)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "BECOME_SPECTATOR_ON_DEATH", CTFBot::AttributeType::BECOME_SPECTATOR_ON_DEATH)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "QUOTA_MANANGED", CTFBot::AttributeType::QUOTA_MANANGED)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "RETAIN_BUILDINGS", CTFBot::AttributeType::RETAIN_BUILDINGS)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "SPAWN_WITH_FULL_CHARGE", CTFBot::AttributeType::SPAWN_WITH_FULL_CHARGE)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "ALWAYS_CRIT", CTFBot::AttributeType::ALWAYS_CRIT)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "IGNORE_ENEMIES", CTFBot::AttributeType::IGNORE_ENEMIES)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "HOLD_FIRE_UNTIL_FULL_RELOAD", CTFBot::AttributeType::HOLD_FIRE_UNTIL_FULL_RELOAD)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "PRIORITIZE_DEFENSE", CTFBot::AttributeType::PRIORITIZE_DEFENSE)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "ALWAYS_FIRE_WEAPON", CTFBot::AttributeType::ALWAYS_FIRE_WEAPON)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "TELEPORT_TO_HINT", CTFBot::AttributeType::TELEPORT_TO_HINT)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "MINIBOSS", CTFBot::AttributeType::MINIBOSS)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "USE_BOSS_HEALTH_BAR", CTFBot::AttributeType::USE_BOSS_HEALTH_BAR)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "IGNORE_FLAG", CTFBot::AttributeType::IGNORE_FLAG)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "AUTO_JUMP", CTFBot::AttributeType::AUTO_JUMP)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "AIR_CHARGE_ONLY", CTFBot::AttributeType::AIR_CHARGE_ONLY)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "PREFER_VACCINATOR_BULLETS", CTFBot::AttributeType::PREFER_VACCINATOR_BULLETS)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "PREFER_VACCINATOR_BLAST", CTFBot::AttributeType::PREFER_VACCINATOR_BLAST)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "PREFER_VACCINATOR_FIRE", CTFBot::AttributeType::PREFER_VACCINATOR_FIRE)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "BULLET_IMMUNE", CTFBot::AttributeType::BULLET_IMMUNE)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "BLAST_IMMUNE", CTFBot::AttributeType::BLAST_IMMUNE)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "FIRE_IMMUNE", CTFBot::AttributeType::FIRE_IMMUNE)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "PARACHUTE", CTFBot::AttributeType::PARACHUTE)
				DECLARE_SCRIPT_CONST_NAMED(FTFBotAttributeType, "PROJECTILE_SHIELD", CTFBot::AttributeType::PROJECTILE_SHIELD)
				REGISTER_SCRIPT_CONST_TABLE(FTFBotAttributeType)

					DECLARE_SCRIPT_CONST_TABLE(ETFBotDifficultyType)
				DECLARE_SCRIPT_CONST_NAMED(ETFBotDifficultyType, "UNDEFINED", CTFBot::DifficultyType::UNDEFINED)
				DECLARE_SCRIPT_CONST_NAMED(ETFBotDifficultyType, "EASY", CTFBot::DifficultyType::EASY)
				DECLARE_SCRIPT_CONST_NAMED(ETFBotDifficultyType, "NORMAL", CTFBot::DifficultyType::NORMAL)
				DECLARE_SCRIPT_CONST_NAMED(ETFBotDifficultyType, "HARD", CTFBot::DifficultyType::HARD)
				DECLARE_SCRIPT_CONST_NAMED(ETFBotDifficultyType, "EXPERT", CTFBot::DifficultyType::EXPERT)
				DECLARE_SCRIPT_CONST_NAMED(ETFBotDifficultyType, "NUM_DIFFICULTY_LEVELS", CTFBot::DifficultyType::NUM_DIFFICULTY_LEVELS)
				REGISTER_SCRIPT_CONST_TABLE(ETFBotDifficultyType)

					DECLARE_SCRIPT_CONST_TABLE(ENavDirType)
				DECLARE_SCRIPT_CONST(ENavDirType, NORTH)
				DECLARE_SCRIPT_CONST(ENavDirType, EAST)
				DECLARE_SCRIPT_CONST(ENavDirType, SOUTH)
				DECLARE_SCRIPT_CONST(ENavDirType, WEST)
				DECLARE_SCRIPT_CONST(ENavDirType, NUM_DIRECTIONS)
				REGISTER_SCRIPT_CONST_TABLE(ENavDirType)

					DECLARE_SCRIPT_CONST_TABLE(ENavTraverseType)
				DECLARE_SCRIPT_CONST(ENavTraverseType, GO_NORTH)
				DECLARE_SCRIPT_CONST(ENavTraverseType, GO_EAST)
				DECLARE_SCRIPT_CONST(ENavTraverseType, GO_SOUTH)
				DECLARE_SCRIPT_CONST(ENavTraverseType, GO_WEST) // life is peaceful there
					DECLARE_SCRIPT_CONST(ENavTraverseType, GO_LADDER_UP)
				DECLARE_SCRIPT_CONST(ENavTraverseType, GO_LADDER_DOWN)
				DECLARE_SCRIPT_CONST(ENavTraverseType, GO_JUMP)
				DECLARE_SCRIPT_CONST(ENavTraverseType, GO_ELEVATOR_UP)
				DECLARE_SCRIPT_CONST(ENavTraverseType, GO_ELEVATOR_DOWN)
				DECLARE_SCRIPT_CONST(ENavTraverseType, NUM_TRAVERSE_TYPES)
				REGISTER_SCRIPT_CONST_TABLE(ENavTraverseType)

					DECLARE_SCRIPT_CONST_TABLE(ENavCornerType)
				DECLARE_SCRIPT_CONST(ENavCornerType, NORTH_WEST)
				DECLARE_SCRIPT_CONST(ENavCornerType, NORTH_EAST)
				DECLARE_SCRIPT_CONST(ENavCornerType, SOUTH_EAST)
				DECLARE_SCRIPT_CONST(ENavCornerType, SOUTH_WEST)
				DECLARE_SCRIPT_CONST(ENavCornerType, NUM_CORNERS)
				REGISTER_SCRIPT_CONST_TABLE(ENavCornerType)

					DECLARE_SCRIPT_CONST_TABLE(ENavRelativeDirType)
				DECLARE_SCRIPT_CONST(ENavRelativeDirType, FORWARD)
				DECLARE_SCRIPT_CONST(ENavRelativeDirType, RIGHT)
				DECLARE_SCRIPT_CONST(ENavRelativeDirType, BACKWARD)
				DECLARE_SCRIPT_CONST(ENavRelativeDirType, LEFT)
				DECLARE_SCRIPT_CONST(ENavRelativeDirType, UP)
				DECLARE_SCRIPT_CONST(ENavRelativeDirType, DOWN)
				DECLARE_SCRIPT_CONST(ENavRelativeDirType, NUM_RELATIVE_DIRECTIONS)
				REGISTER_SCRIPT_CONST_TABLE(ENavRelativeDirType)

					DECLARE_SCRIPT_CONST_TABLE(FNavAttributeType)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_INVALID)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_CROUCH)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_JUMP)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_PRECISE)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_NO_JUMP)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_STOP)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_RUN)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_WALK)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_AVOID)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_TRANSIENT)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_DONT_HIDE)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_STAND)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_NO_HOSTAGES)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_STAIRS)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_NO_MERGE)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_OBSTACLE_TOP)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_CLIFF)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_FIRST_CUSTOM)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_LAST_CUSTOM)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_FUNC_COST)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_HAS_ELEVATOR)
				DECLARE_SCRIPT_CONST(FNavAttributeType, NAV_MESH_NAV_BLOCKER)
				REGISTER_SCRIPT_CONST_TABLE(FNavAttributeType)
				*/
					DECLARE_SCRIPT_CONST_TABLE(FButtons)
				DECLARE_SCRIPT_CONST(FButtons, IN_ATTACK)
				DECLARE_SCRIPT_CONST(FButtons, IN_JUMP)
				DECLARE_SCRIPT_CONST(FButtons, IN_DUCK)
				DECLARE_SCRIPT_CONST(FButtons, IN_FORWARD)
				DECLARE_SCRIPT_CONST(FButtons, IN_BACK)
				DECLARE_SCRIPT_CONST(FButtons, IN_USE)
				DECLARE_SCRIPT_CONST(FButtons, IN_CANCEL)
				DECLARE_SCRIPT_CONST(FButtons, IN_LEFT)
				DECLARE_SCRIPT_CONST(FButtons, IN_RIGHT)
				DECLARE_SCRIPT_CONST(FButtons, IN_MOVELEFT)
				DECLARE_SCRIPT_CONST(FButtons, IN_MOVERIGHT)
				DECLARE_SCRIPT_CONST(FButtons, IN_ATTACK2)
				DECLARE_SCRIPT_CONST(FButtons, IN_RUN)
				DECLARE_SCRIPT_CONST(FButtons, IN_RELOAD)
				DECLARE_SCRIPT_CONST(FButtons, IN_ALT1)
				DECLARE_SCRIPT_CONST(FButtons, IN_ALT2)
				DECLARE_SCRIPT_CONST(FButtons, IN_SCORE)
				DECLARE_SCRIPT_CONST(FButtons, IN_SPEED)
				DECLARE_SCRIPT_CONST(FButtons, IN_WALK)
				DECLARE_SCRIPT_CONST(FButtons, IN_ZOOM)
				DECLARE_SCRIPT_CONST(FButtons, IN_WEAPON1)
				DECLARE_SCRIPT_CONST(FButtons, IN_WEAPON2)
				DECLARE_SCRIPT_CONST(FButtons, IN_BULLRUSH)
				DECLARE_SCRIPT_CONST(FButtons, IN_GRENADE1)
				DECLARE_SCRIPT_CONST(FButtons, IN_GRENADE2)
				DECLARE_SCRIPT_CONST(FButtons, IN_ATTACK3)
				REGISTER_SCRIPT_CONST_TABLE(FButtons)
				
					DECLARE_SCRIPT_CONST_TABLE(FHideHUD)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_WEAPONSELECTION)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_FLASHLIGHT)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_ALL)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_HEALTH)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_PLAYERDEAD)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_NEEDSUIT)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_MISCSTATUS)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_CHAT)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_CROSSHAIR)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_VEHICLE_CROSSHAIR)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_INVEHICLE)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_BONUS_PROGRESS)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_BUILDING_STATUS)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_CLOAK_AND_FEIGN)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_PIPES_AND_CHARGE)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_METAL)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_TARGET_ID)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_MATCH_STATUS)
				DECLARE_SCRIPT_CONST(FHideHUD, HIDEHUD_BITCOUNT)
				REGISTER_SCRIPT_CONST_TABLE(FHideHUD)

					DECLARE_SCRIPT_CONST_TABLE(FTaunts)
				DECLARE_SCRIPT_CONST(FTaunts, TAUNT_BASE_WEAPON)
				DECLARE_SCRIPT_CONST(FTaunts, TAUNT_MISC_ITEM)
				DECLARE_SCRIPT_CONST(FTaunts, TAUNT_SHOW_ITEM)
				DECLARE_SCRIPT_CONST(FTaunts, TAUNT_LONG)
				DECLARE_SCRIPT_CONST(FTaunts, TAUNT_SPECIAL)
				REGISTER_SCRIPT_CONST_TABLE(FTaunts)

					DECLARE_SCRIPT_CONST_TABLE(EHitGroup)
				DECLARE_SCRIPT_CONST(EHitGroup, HITGROUP_GENERIC)
				DECLARE_SCRIPT_CONST(EHitGroup, HITGROUP_HEAD)
				DECLARE_SCRIPT_CONST(EHitGroup, HITGROUP_CHEST)
				DECLARE_SCRIPT_CONST(EHitGroup, HITGROUP_STOMACH)
				DECLARE_SCRIPT_CONST(EHitGroup, HITGROUP_LEFTARM)
				DECLARE_SCRIPT_CONST(EHitGroup, HITGROUP_RIGHTARM)
				DECLARE_SCRIPT_CONST(EHitGroup, HITGROUP_LEFTLEG)
				DECLARE_SCRIPT_CONST(EHitGroup, HITGROUP_RIGHTLEG)
				DECLARE_SCRIPT_CONST(EHitGroup, HITGROUP_GEAR)
				REGISTER_SCRIPT_CONST_TABLE(EHitGroup)

					DECLARE_SCRIPT_CONST_TABLE(FDmgType)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_GENERIC)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_CRUSH)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_CLUB)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_BULLET)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_SLASH)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_BURN)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_VEHICLE)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_FALL)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_BLAST)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_CLUB)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_SHOCK)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_SONIC)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_ENERGYBEAM)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_PREVENT_PHYSICS_FORCE)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_NEVERGIB)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_ALWAYSGIB)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_DROWN)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_PARALYZE)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_NERVEGAS)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_POISON)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_RADIATION)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_DROWNRECOVER)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_ACID)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_SLOWBURN)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_REMOVENORAGDOLL)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_PHYSGUN)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_PLASMA)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_AIRBOAT)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_DISSOLVE)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_BLAST_SURFACE)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_DIRECT)
				DECLARE_SCRIPT_CONST(FDmgType, DMG_BUCKSHOT)
				REGISTER_SCRIPT_CONST_TABLE(FDmgType)

					DECLARE_SCRIPT_CONST_TABLE(ESpectatorMode)
				DECLARE_SCRIPT_CONST(ESpectatorMode, OBS_MODE_NONE)
				DECLARE_SCRIPT_CONST(ESpectatorMode, OBS_MODE_DEATHCAM)
				DECLARE_SCRIPT_CONST(ESpectatorMode, OBS_MODE_FREEZECAM)
				DECLARE_SCRIPT_CONST(ESpectatorMode, OBS_MODE_FIXED)
				DECLARE_SCRIPT_CONST(ESpectatorMode, OBS_MODE_IN_EYE)
				DECLARE_SCRIPT_CONST(ESpectatorMode, OBS_MODE_CHASE)
				DECLARE_SCRIPT_CONST(ESpectatorMode, OBS_MODE_POI)
				DECLARE_SCRIPT_CONST(ESpectatorMode, OBS_MODE_ROAMING)
				DECLARE_SCRIPT_CONST(ESpectatorMode, NUM_OBSERVER_MODES)
				REGISTER_SCRIPT_CONST_TABLE(ESpectatorMode)

					DECLARE_SCRIPT_CONST_TABLE(FEntityEFlags)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_KILLME)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_DORMANT)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_NOCLIP_ACTIVE)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_SETTING_UP_BONES)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_KEEP_ON_RECREATE_ENTITIES)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_HAS_PLAYER_CHILD)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_DIRTY_SHADOWUPDATE)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_NOTIFY)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_FORCE_CHECK_TRANSMIT)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_BOT_FROZEN)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_SERVER_ONLY)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_NO_AUTO_EDICT_ATTACH)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_DIRTY_ABSTRANSFORM)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_DIRTY_ABSVELOCITY)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_DIRTY_ABSANGVELOCITY)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_DIRTY_SURROUNDING_COLLISION_BOUNDS)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_DIRTY_SPATIAL_PARTITION)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_FORCE_ALLOW_MOVEPARENT)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_IN_SKYBOX)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_USE_PARTITION_WHEN_NOT_SOLID)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_TOUCHING_FLUID)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_IS_BEING_LIFTED_BY_BARNACLE)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_NO_ROTORWASH_PUSH)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_NO_THINK_FUNCTION)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_NO_GAME_PHYSICS_SIMULATION)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_CHECK_UNTOUCH)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_DONTBLOCKLOS)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_DONTWALKON)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_NO_DISSOLVE)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_NO_MEGAPHYSCANNON_RAGDOLL)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_NO_WATER_VELOCITY_CHANGE)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_NO_PHYSCANNON_INTERACTION)
				DECLARE_SCRIPT_CONST(FEntityEFlags, EFL_NO_DAMAGE_FORCES)
				REGISTER_SCRIPT_CONST_TABLE(FEntityEFlags)

					DECLARE_SCRIPT_CONST_TABLE(FSolid)
				DECLARE_SCRIPT_CONST(FSolid, FSOLID_CUSTOMRAYTEST)
				DECLARE_SCRIPT_CONST(FSolid, FSOLID_CUSTOMBOXTEST)
				DECLARE_SCRIPT_CONST(FSolid, FSOLID_NOT_SOLID)
				DECLARE_SCRIPT_CONST(FSolid, FSOLID_TRIGGER)
				DECLARE_SCRIPT_CONST(FSolid, FSOLID_NOT_STANDABLE)
				DECLARE_SCRIPT_CONST(FSolid, FSOLID_VOLUME_CONTENTS)
				DECLARE_SCRIPT_CONST(FSolid, FSOLID_FORCE_WORLD_ALIGNED)
				DECLARE_SCRIPT_CONST(FSolid, FSOLID_USE_TRIGGER_BOUNDS)
				DECLARE_SCRIPT_CONST(FSolid, FSOLID_ROOT_PARENT_ALIGNED)
				DECLARE_SCRIPT_CONST(FSolid, FSOLID_TRIGGER_TOUCH_DEBRIS)
				DECLARE_SCRIPT_CONST(FSolid, FSOLID_MAX_BITS)
				REGISTER_SCRIPT_CONST_TABLE(FSolid)

					DECLARE_SCRIPT_CONST_TABLE(ERenderMode)
				DECLARE_SCRIPT_CONST(ERenderMode, kRenderNormal)
				DECLARE_SCRIPT_CONST(ERenderMode, kRenderTransColor)
				DECLARE_SCRIPT_CONST(ERenderMode, kRenderTransTexture)
				DECLARE_SCRIPT_CONST(ERenderMode, kRenderGlow)
				DECLARE_SCRIPT_CONST(ERenderMode, kRenderTransAlpha)
				DECLARE_SCRIPT_CONST(ERenderMode, kRenderTransAdd)
				DECLARE_SCRIPT_CONST(ERenderMode, kRenderEnvironmental)
				DECLARE_SCRIPT_CONST(ERenderMode, kRenderTransAddFrameBlend)
				DECLARE_SCRIPT_CONST(ERenderMode, kRenderTransAlphaAdd)
				DECLARE_SCRIPT_CONST(ERenderMode, kRenderWorldGlow)
				DECLARE_SCRIPT_CONST(ERenderMode, kRenderNone)
				DECLARE_SCRIPT_CONST(ERenderMode, kRenderModeCount)
				REGISTER_SCRIPT_CONST_TABLE(ERenderMode)

					DECLARE_SCRIPT_CONST_TABLE(ERenderFx)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxNone)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxPulseSlow)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxPulseFast)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxPulseSlowWide)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxPulseFastWide)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxFadeSlow)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxFadeFast)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxSolidSlow)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxSolidFast)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxStrobeSlow)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxStrobeFast)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxStrobeFaster)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxFlickerSlow)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxFlickerFast)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxNoDissipation)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxDistort)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxHologram)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxExplode)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxGlowShell)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxClampMinScale)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxEnvRain)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxEnvSnow)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxSpotlight)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxRagdoll)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxPulseFastWider)
				DECLARE_SCRIPT_CONST(ERenderFx, kRenderFxMax)
				REGISTER_SCRIPT_CONST_TABLE(ERenderFx)

					DECLARE_SCRIPT_CONST_TABLE(ECollisionGroup)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_NONE)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_DEBRIS)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_DEBRIS_TRIGGER)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_INTERACTIVE_DEBRIS)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_INTERACTIVE)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_PLAYER)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_BREAKABLE_GLASS)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_VEHICLE)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_PLAYER_MOVEMENT)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_NPC)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_IN_VEHICLE)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_WEAPON)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_VEHICLE_CLIP)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_PROJECTILE)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_DOOR_BLOCKER)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_PASSABLE_DOOR)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_DISSOLVING)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_PUSHAWAY)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_NPC_ACTOR)
				DECLARE_SCRIPT_CONST(ECollisionGroup, COLLISION_GROUP_NPC_SCRIPTED)
				DECLARE_SCRIPT_CONST(ECollisionGroup, LAST_SHARED_COLLISION_GROUP)
				REGISTER_SCRIPT_CONST_TABLE(ECollisionGroup)

					DECLARE_SCRIPT_CONST_TABLE(FPlayer)
				DECLARE_SCRIPT_CONST(FPlayer, FL_ONGROUND)
				DECLARE_SCRIPT_CONST(FPlayer, FL_DUCKING)
				DECLARE_SCRIPT_CONST(FPlayer, FL_ANIMDUCKING)
				DECLARE_SCRIPT_CONST(FPlayer, FL_WATERJUMP)
				DECLARE_SCRIPT_CONST(FPlayer, FL_ONTRAIN)
				DECLARE_SCRIPT_CONST(FPlayer, FL_INRAIN)
				DECLARE_SCRIPT_CONST(FPlayer, FL_FROZEN)
				DECLARE_SCRIPT_CONST(FPlayer, FL_ATCONTROLS)
				DECLARE_SCRIPT_CONST(FPlayer, FL_CLIENT)
				DECLARE_SCRIPT_CONST(FPlayer, FL_FAKECLIENT)
				DECLARE_SCRIPT_CONST(FPlayer, FL_INWATER)
				DECLARE_SCRIPT_CONST(FPlayer, FL_FLY)
				DECLARE_SCRIPT_CONST(FPlayer, FL_SWIM)
				DECLARE_SCRIPT_CONST(FPlayer, FL_CONVEYOR)
				DECLARE_SCRIPT_CONST(FPlayer, FL_NPC)
				DECLARE_SCRIPT_CONST(FPlayer, FL_GODMODE)
				DECLARE_SCRIPT_CONST(FPlayer, FL_NOTARGET)
				DECLARE_SCRIPT_CONST(FPlayer, FL_AIMTARGET)
				DECLARE_SCRIPT_CONST(FPlayer, FL_PARTIALGROUND)
				DECLARE_SCRIPT_CONST(FPlayer, FL_STATICPROP)
				DECLARE_SCRIPT_CONST(FPlayer, FL_GRAPHED)
				DECLARE_SCRIPT_CONST(FPlayer, FL_GRENADE)
				DECLARE_SCRIPT_CONST(FPlayer, FL_STEPMOVEMENT)
				DECLARE_SCRIPT_CONST(FPlayer, FL_DONTTOUCH)
				DECLARE_SCRIPT_CONST(FPlayer, FL_BASEVELOCITY)
				DECLARE_SCRIPT_CONST(FPlayer, FL_WORLDBRUSH)
				DECLARE_SCRIPT_CONST(FPlayer, FL_OBJECT)
				DECLARE_SCRIPT_CONST(FPlayer, FL_KILLME)
				DECLARE_SCRIPT_CONST(FPlayer, FL_ONFIRE)
				DECLARE_SCRIPT_CONST(FPlayer, FL_DISSOLVING)
				DECLARE_SCRIPT_CONST(FPlayer, FL_TRANSRAGDOLL)
				DECLARE_SCRIPT_CONST(FPlayer, FL_UNBLOCKABLE_BY_PLAYER)
				DECLARE_SCRIPT_CONST(FPlayer, PLAYER_FLAG_BITS)
				REGISTER_SCRIPT_CONST_TABLE(FPlayer)

					DECLARE_SCRIPT_CONST_TABLE(FEntityEffects)
				DECLARE_SCRIPT_CONST(FEntityEffects, EF_BONEMERGE)
				DECLARE_SCRIPT_CONST(FEntityEffects, EF_BRIGHTLIGHT)
				DECLARE_SCRIPT_CONST(FEntityEffects, EF_DIMLIGHT)
				DECLARE_SCRIPT_CONST(FEntityEffects, EF_NOINTERP)
				DECLARE_SCRIPT_CONST(FEntityEffects, EF_NOSHADOW)
				DECLARE_SCRIPT_CONST(FEntityEffects, EF_NODRAW)
				DECLARE_SCRIPT_CONST(FEntityEffects, EF_NORECEIVESHADOW)
				DECLARE_SCRIPT_CONST(FEntityEffects, EF_BONEMERGE_FASTCULL)
				DECLARE_SCRIPT_CONST(FEntityEffects, EF_ITEM_BLINK)
				DECLARE_SCRIPT_CONST(FEntityEffects, EF_PARENT_ANIMATES)
				DECLARE_SCRIPT_CONST(FEntityEffects, EF_MAX_BITS)
				REGISTER_SCRIPT_CONST_TABLE(FEntityEffects)

					DECLARE_SCRIPT_CONST_TABLE(ESolidType)
				DECLARE_SCRIPT_CONST(ESolidType, SOLID_NONE)
				DECLARE_SCRIPT_CONST(ESolidType, SOLID_BSP)
				DECLARE_SCRIPT_CONST(ESolidType, SOLID_BBOX)
				DECLARE_SCRIPT_CONST(ESolidType, SOLID_OBB)
				DECLARE_SCRIPT_CONST(ESolidType, SOLID_OBB_YAW)
				DECLARE_SCRIPT_CONST(ESolidType, SOLID_CUSTOM)
				DECLARE_SCRIPT_CONST(ESolidType, SOLID_VPHYSICS)
				DECLARE_SCRIPT_CONST(ESolidType, SOLID_LAST)
				REGISTER_SCRIPT_CONST_TABLE(ESolidType)

					DECLARE_SCRIPT_CONST_TABLE(FContents)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_EMPTY)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_SOLID)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_WINDOW)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_AUX)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_GRATE)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_SLIME)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_WATER)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_BLOCKLOS)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_OPAQUE)
				DECLARE_SCRIPT_CONST(FContents, LAST_VISIBLE_CONTENTS)
				DECLARE_SCRIPT_CONST(FContents, ALL_VISIBLE_CONTENTS)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_TESTFOGVOLUME)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_UNUSED)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_UNUSED6)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_TEAM1)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_TEAM2)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_IGNORE_NODRAW_OPAQUE)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_MOVEABLE)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_AREAPORTAL)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_PLAYERCLIP)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_MONSTERCLIP)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_CURRENT_0)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_CURRENT_90)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_CURRENT_180)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_CURRENT_270)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_CURRENT_UP)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_CURRENT_DOWN)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_ORIGIN)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_MONSTER)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_DEBRIS)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_DETAIL)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_TRANSLUCENT)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_LADDER)
				DECLARE_SCRIPT_CONST(FContents, CONTENTS_HITBOX)
				REGISTER_SCRIPT_CONST_TABLE(FContents)

					DECLARE_SCRIPT_CONST_TABLE(FSurf)
				DECLARE_SCRIPT_CONST(FSurf, SURF_LIGHT)
				DECLARE_SCRIPT_CONST(FSurf, SURF_SKY2D)
				DECLARE_SCRIPT_CONST(FSurf, SURF_SKY)
				DECLARE_SCRIPT_CONST(FSurf, SURF_WARP)
				DECLARE_SCRIPT_CONST(FSurf, SURF_TRANS)
				DECLARE_SCRIPT_CONST(FSurf, SURF_NOPORTAL)
				DECLARE_SCRIPT_CONST(FSurf, SURF_TRIGGER)
				DECLARE_SCRIPT_CONST(FSurf, SURF_NODRAW)
				DECLARE_SCRIPT_CONST(FSurf, SURF_HINT)
				DECLARE_SCRIPT_CONST(FSurf, SURF_SKIP)
				DECLARE_SCRIPT_CONST(FSurf, SURF_NOLIGHT)
				DECLARE_SCRIPT_CONST(FSurf, SURF_BUMPLIGHT)
				DECLARE_SCRIPT_CONST(FSurf, SURF_NOSHADOWS)
				DECLARE_SCRIPT_CONST(FSurf, SURF_NODECALS)
				DECLARE_SCRIPT_CONST(FSurf, SURF_NOCHOP)
				DECLARE_SCRIPT_CONST(FSurf, SURF_HITBOX)
				REGISTER_SCRIPT_CONST_TABLE(FSurf)

					// MoveType_t
					DECLARE_SCRIPT_CONST_TABLE(EMoveType)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_NONE)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_ISOMETRIC)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_WALK)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_STEP)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_FLY)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_FLYGRAVITY)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_VPHYSICS)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_PUSH)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_NOCLIP)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_LADDER)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_OBSERVER)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_CUSTOM)
				DECLARE_SCRIPT_CONST(EMoveType, MOVETYPE_LAST)
				REGISTER_SCRIPT_CONST_TABLE(EMoveType)

					DECLARE_SCRIPT_CONST_TABLE(EMoveCollide)
				DECLARE_SCRIPT_CONST(EMoveCollide, MOVECOLLIDE_DEFAULT)
				DECLARE_SCRIPT_CONST(EMoveCollide, MOVECOLLIDE_FLY_BOUNCE)
				DECLARE_SCRIPT_CONST(EMoveCollide, MOVECOLLIDE_FLY_CUSTOM)
				DECLARE_SCRIPT_CONST(EMoveCollide, MOVECOLLIDE_FLY_SLIDE)
				DECLARE_SCRIPT_CONST(EMoveCollide, MOVECOLLIDE_COUNT)
				DECLARE_SCRIPT_CONST(EMoveCollide, MOVECOLLIDE_MAX_BITS)
				REGISTER_SCRIPT_CONST_TABLE(EMoveCollide)

					// Unnamed enum
					DECLARE_SCRIPT_CONST_TABLE(ETFTeam)
				DECLARE_SCRIPT_CONST(ETFTeam, TEAM_ANY)
				DECLARE_SCRIPT_CONST(ETFTeam, TEAM_INVALID)
				DECLARE_SCRIPT_CONST(ETFTeam, TEAM_UNASSIGNED)
				DECLARE_SCRIPT_CONST(ETFTeam, TEAM_SPECTATOR)
				DECLARE_SCRIPT_CONST(ETFTeam, TEAM_SPECTATOR)
				DECLARE_SCRIPT_CONST(ETFTeam, TF_TEAM_RED)
				DECLARE_SCRIPT_CONST(ETFTeam, TF_TEAM_BLUE)
				DECLARE_SCRIPT_CONST(ETFTeam, TF_TEAM_COUNT)
				DECLARE_SCRIPT_CONST(ETFTeam, TF_TEAM_PVE_INVADERS)
				DECLARE_SCRIPT_CONST(ETFTeam, TF_TEAM_PVE_DEFENDERS)
				DECLARE_SCRIPT_CONST(ETFTeam, TF_TEAM_PVE_INVADERS_GIANTS)
				REGISTER_SCRIPT_CONST_TABLE(ETFTeam)

					// ETFDmgCustom
					DECLARE_SCRIPT_CONST_TABLE(ETFDmgCustom)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_NONE)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_HEADSHOT)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_BACKSTAB)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_BURNING)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_WRENCH_FIX)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_MINIGUN)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SUICIDE)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_HADOUKEN)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_BURNING_FLARE)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_HIGH_NOON)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_GRAND_SLAM)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_PENETRATE_MY_TEAM)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_PENETRATE_ALL_PLAYERS)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_FENCING)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_PENETRATE_NONBURNING_TEAMMATE)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_ARROW_STAB)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TELEFRAG)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_BURNING_ARROW)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_FLYINGBURN)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_PUMPKIN_BOMB)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_DECAPITATION)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_GRENADE)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_BASEBALL)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_CHARGE_IMPACT)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_BARBARIAN_SWING)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_AIR_STICKY_BURST)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_DEFENSIVE_STICKY)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_PICKAXE)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_ROCKET_DIRECTHIT)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_UBERSLICE)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_PLAYER_SENTRY)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_STANDARD_STICKY)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SHOTGUN_REVENGE_CRIT)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_ENGINEER_GUITAR_SMASH)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_BLEEDING)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_GOLD_WRENCH)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_CARRIED_BUILDING)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_COMBO_PUNCH)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_ENGINEER_ARM_KILL)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_FISH_KILL)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TRIGGER_HURT)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_DECAPITATION_BOSS)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_STICKBOMB_EXPLOSION)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_AEGIS_ROUND)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_FLARE_EXPLOSION)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_BOOTS_STOMP)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_PLASMA)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_PLASMA_CHARGED)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_PLASMA_GIB)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_PRACTICE_STICKY)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_EYEBALL_ROCKET)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_HEADSHOT_DECAPITATION)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_ARMAGEDDON)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_FLARE_PELLET)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_CLEAVER)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_CLEAVER_CRIT)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SAPPER_RECORDER_DEATH)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_MERASMUS_PLAYER_BOMB)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_MERASMUS_GRENADE)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_MERASMUS_ZAP)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_MERASMUS_DECAPITATION)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_CANNONBALL_PUSH)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_ALLCLASS_GUITAR_RIFF)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_THROWABLE)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_THROWABLE_KILL)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SPELL_TELEPORT)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SPELL_SKELETON)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SPELL_MIRV)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SPELL_METEOR)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SPELL_LIGHTNING)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SPELL_FIREBALL)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SPELL_MONOCULUS)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SPELL_BLASTJUMP)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SPELL_BATS)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SPELL_TINY)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_KART)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_GIANT_HAMMER)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_RUNE_REFLECT)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_DRAGONS_FURY_IGNITE)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_DRAGONS_FURY_BONUS_BURNING)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_SLAP_KILL)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_CROC)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_TAUNTATK_GASBLAST)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_AXTINGUISHER_BOOSTED)
				DECLARE_SCRIPT_CONST(ETFDmgCustom, TF_DMG_CUSTOM_END)
				REGISTER_SCRIPT_CONST_TABLE(ETFDmgCustom)

					// ETFClass
					DECLARE_SCRIPT_CONST_TABLE(ETFClass)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_UNDEFINED)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_SCOUT)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_SNIPER)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_SOLDIER)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_DEMOMAN)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_MEDIC)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_HEAVYWEAPONS)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_PYRO)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_SPY)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_ENGINEER)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_CIVILIAN)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_COUNT_ALL)
				DECLARE_SCRIPT_CONST(ETFClass, TF_CLASS_RANDOM)
				REGISTER_SCRIPT_CONST_TABLE(ETFClass)

					/* gamerules_roundstate_t
					DECLARE_SCRIPT_CONST_TABLE(ERoundState)
				DECLARE_SCRIPT_CONST(ERoundState, GR_STATE_INIT)
				DECLARE_SCRIPT_CONST(ERoundState, GR_STATE_PREGAME)
				DECLARE_SCRIPT_CONST(ERoundState, GR_STATE_STARTGAME)
				DECLARE_SCRIPT_CONST(ERoundState, GR_STATE_PREROUND)
				DECLARE_SCRIPT_CONST(ERoundState, GR_STATE_RND_RUNNING)
				DECLARE_SCRIPT_CONST(ERoundState, GR_STATE_TEAM_WIN)
				DECLARE_SCRIPT_CONST(ERoundState, GR_STATE_RESTART)
				DECLARE_SCRIPT_CONST(ERoundState, GR_STATE_STALEMATE)
				DECLARE_SCRIPT_CONST(ERoundState, GR_STATE_GAME_OVER)
				DECLARE_SCRIPT_CONST(ERoundState, GR_NUM_ROUND_STATES)
				REGISTER_SCRIPT_CONST_TABLE(ERoundState)
				
					// Unnamed enum
					DECLARE_SCRIPT_CONST_TABLE(EStopwatchState)
				DECLARE_SCRIPT_CONST(EStopwatchState, STOPWATCH_CAPTURE_TIME_NOT_SET)
				DECLARE_SCRIPT_CONST(EStopwatchState, STOPWATCH_RUNNING)
				DECLARE_SCRIPT_CONST(EStopwatchState, STOPWATCH_OVERTIME)
				REGISTER_SCRIPT_CONST_TABLE(EStopwatchState)
				*/
					// EHoliday
					DECLARE_SCRIPT_CONST_TABLE(EHoliday)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_None)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_TFBirthday)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_Halloween)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_Christmas)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_CommunityUpdate)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_EOTL)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_Valentines)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_MeetThePyro)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_FullMoon)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_HalloweenOrFullMoon)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_HalloweenOrFullMoonOrValentines)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_AprilFools)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_Soldier)
				DECLARE_SCRIPT_CONST(EHoliday, kHoliday_Summer)
				DECLARE_SCRIPT_CONST(EHoliday, kHolidayCount)
				REGISTER_SCRIPT_CONST_TABLE(EHoliday)

					/* TFNavAttributeType
					DECLARE_SCRIPT_CONST_TABLE(FTFNavAttributeType)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_INVALID)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_BLOCKED)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_SPAWN_ROOM_RED)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_SPAWN_ROOM_BLUE)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_SPAWN_ROOM_EXIT)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_HAS_AMMO)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_HAS_HEALTH)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_CONTROL_POINT)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_BLUE_SENTRY_DANGER)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_RED_SENTRY_DANGER)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_BLUE_SETUP_GATE)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_RED_SETUP_GATE)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_BLOCKED_AFTER_POINT_CAPTURE)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_BLOCKED_UNTIL_POINT_CAPTURE)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_BLUE_ONE_WAY_DOOR)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_RED_ONE_WAY_DOOR)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_WITH_SECOND_POINT)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_WITH_THIRD_POINT)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_WITH_FOURTH_POINT)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_WITH_FIFTH_POINT)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_SNIPER_SPOT)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_SENTRY_SPOT)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_ESCAPE_ROUTE)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_ESCAPE_ROUTE_VISIBLE)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_NO_SPAWNING)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_RESCUE_CLOSET)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_BOMB_CAN_DROP_HERE)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_DOOR_NEVER_BLOCKS)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_DOOR_ALWAYS_BLOCKS)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_UNBLOCKABLE)
				DECLARE_SCRIPT_CONST(FTFNavAttributeType, TF_NAV_PERSISTENT_ATTRIBUTES)
				REGISTER_SCRIPT_CONST_TABLE(FTFNavAttributeType)
				*/
					DECLARE_SCRIPT_CONST_TABLE(EHudNotify)
				DECLARE_SCRIPT_CONST(EHudNotify, HUD_PRINTNOTIFY)
				DECLARE_SCRIPT_CONST(EHudNotify, HUD_PRINTCONSOLE)
				DECLARE_SCRIPT_CONST(EHudNotify, HUD_PRINTTALK)
				DECLARE_SCRIPT_CONST(EHudNotify, HUD_PRINTCENTER)
				REGISTER_SCRIPT_CONST_TABLE(EHudNotify)

					//DECLARE_SCRIPT_CONST_TABLE(EBotType)
				//DECLARE_SCRIPT_CONST(EBotType, TF_BOT_TYPE)
				//REGISTER_SCRIPT_CONST_TABLE(EBotType)

					DECLARE_SCRIPT_CONST_TABLE(Math)
				DECLARE_SCRIPT_CONST_NAMED(Math, "Epsilon", FLT_EPSILON)
				DECLARE_SCRIPT_CONST_NAMED(Math, "Zero", 0.0f)
				DECLARE_SCRIPT_CONST_NAMED(Math, "One", 1.0f)
				DECLARE_SCRIPT_CONST_NAMED(Math, "E", 2.718281828f)
				DECLARE_SCRIPT_CONST_NAMED(Math, "Pi", 3.141592654f)
				DECLARE_SCRIPT_CONST_NAMED(Math, "Tau", 6.283185307f)
				DECLARE_SCRIPT_CONST_NAMED(Math, "Sqrt2", 1.414213562f)
				DECLARE_SCRIPT_CONST_NAMED(Math, "Sqrt3", 1.732050808f)
				DECLARE_SCRIPT_CONST_NAMED(Math, "GoldenRatio", 1.618033989f)
				REGISTER_SCRIPT_CONST_TABLE(Math)

					DECLARE_SCRIPT_CONST_TABLE(Server)
				DECLARE_SCRIPT_CONST(Server, MAX_EDICTS)
				DECLARE_SCRIPT_CONST(Server, MAX_PLAYERS)
				//DECLARE_SCRIPT_CONST(Server, DIST_EPSILON)
				DECLARE_SCRIPT_CONST_NAMED(Server, "ConstantNamingConvention", "Constants are named as follows: F -> flags, E -> enums, (nothing) -> random values/constants")
				REGISTER_SCRIPT_CONST_TABLE(Server)
#endif
					g_pScriptVM->SetValue("Constants", vConstantsTable);

				if ( scriptLanguage == SL_SQUIRREL )
				{
					//g_pScriptVM->Run( g_Script_vscript_client );
				}
				g_VScriptGameEventListener.Init();

				VScriptRunScript( "gamespawn", false );

				VMPROF_SHOW( pszScriptLanguage, "virtual machine startup" );

				return true;
			}
			else
			{
				DevWarning("VM Did not start!\n");
			}
		}
	}
	else
	{
		Log_Msg( LOG_VScript, "\nVSCRIPT: Scripting is disabled.\n" );
	}
	g_pScriptVM = NULL;
	return false;
}

void VScriptClientTerm()
{
	if( g_pScriptVM != NULL )
	{
		if( g_pScriptVM )
		{
			scriptmanager->DestroyVM( g_pScriptVM );
			g_pScriptVM = NULL;
		}
	}
}

bool IsEntityCreationAllowedInScripts( void )
{
	return g_VScriptGameSystem.m_bAllowEntityCreationInScripts;
}

//
// Slart: These were Portal 2 only, now they're not
//
/*
bool __MsgFunc_SetMixLayerTriggerFactor(const CCSUsrMsg_SetMixLayerTriggerFactor &msg)
{
	int iLayerID = engine->GetMixLayerIndex(msg.layer().c_str());
	if (iLayerID < 0)
	{
		Warning("Invalid mix layer passed to SetMixLayerTriggerFactor: '%s'\n", msg.layer().c_str());
		return true;
	}
	int iGroupID = engine->GetMixGroupIndex(msg.group().c_str());
	if (iGroupID < 0)
	{
		Warning("Invalid mix group passed to SetMixLayerTriggerFactor: '%s'\n", msg.group().c_str());
		return true;
	}

	engine->SetMixLayerTriggerFactor(iLayerID, iGroupID, msg.factor());
	return true;
}

class CSetMixLayerTriggerHelper : public CAutoGameSystem 
{
	virtual bool Init()
	{
		for( int i = 0; i < MAX_SPLITSCREEN_PLAYERS; ++i )
		{
			ACTIVE_SPLITSCREEN_PLAYER_GUARD( i );
			HOOK_MESSAGE( SetMixLayerTriggerFactor );
		}
		return true;
	}

	CUserMessageBinder m_UMCMsgSetMixLayerTriggerFactor;
};

static CSetMixLayerTriggerHelper g_SetMixLayerTriggerHelper;
*/
#ifdef PANORAMA_ENABLE

bool __MsgFunc_PanoramaDispatchEvent( const CCSUsrMsg_PanoramaDispatchEvent &msg )
{
	g_ScriptPanorama.DispatchEvent( msg.event().c_str(), msg.message().c_str() );
	return true;
}

class CVScriptPanoramaHelper : public CAutoGameSystem 
{
	virtual bool Init()
	{
		for( int i = 0; i < MAX_SPLITSCREEN_PLAYERS; ++i )
		{
			ACTIVE_SPLITSCREEN_PLAYER_GUARD( i );
			HOOK_MESSAGE( PanoramaDispatchEvent );
		}
		return true;
	}

	CUserMessageBinder m_UMCMsgPanoramaDispatchEvent;
};

static CVScriptPanoramaHelper g_VScriptPanoramaHelper;

#endif

bool CVScriptGameSystem::Init()
{
	m_bAllowEntityCreationInScripts = false;
	m_bLockSchema = true;
	VScriptClientInit();
	m_bLockSchema = false;
	return true;
}

void CVScriptGameSystem::Reload()
{
	m_bAllowEntityCreationInScripts = false;
	VScriptClientTerm();
	VScriptClientInit();
}
