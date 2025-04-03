#include "cbase.h"
#include <vgui_controls/AnimationController.h>
#include "tf_hud_freezepanel.h"
#include "clientmode_shared.h"
#include "tf_hud_solo_objectives.h"
#include "vscript_client.h"
#include "tf_gamerules.h"
#include "tf_playermodelpanel.h"
#include "tf_vgui_video.h"
#include "tf_solo_panel.h"
#include "tf_hud_match_status.h"

using namespace vgui;

CTFHUDSoloObjectives::CTFHUDSoloObjectives( Panel *parent, const char *name )
	: EditablePanel( parent, name )
{
	ResetResFile();
	ReinitializeEverything();

	//vgui::ivgui()->AddTickSignal( GetVPanel(), 16 );

	ListenForGameEvent( "server_spawn" );
	ListenForGameEvent( "solohud_file_changed" );
	ListenForGameEvent( "solohud_int" );
	ListenForGameEvent( "solohud_float" );
	ListenForGameEvent( "solohud_string" );
	ListenForGameEvent( "solohud_event" );

	if ( g_pScriptVM )
	{
		g_pScriptVM->RegisterInstance( this, "SoloHUD" );
	}
}

CTFHUDSoloObjectives::~CTFHUDSoloObjectives()
{
}

bool CTFHUDSoloObjectives::IsVisible( void )
{
	if( IsTakingAFreezecamScreenshot() )
		return false;

	bool bShouldDraw = ( !gHUD.IsHidden( HIDEHUD_TARGET_ID ) );
	if ( !bShouldDraw )
		return false;

	return BaseClass::IsVisible();
}


void CTFHUDSoloObjectives::ApplySettings( KeyValues *inResourceData )
{
	BaseClass::ApplySettings( inResourceData );
}

void CTFHUDSoloObjectives::ReinitializeEverything()
{
	ClearAllScriptPanels();

	while (vgui::ipanel()->GetChildCount(GetVPanel()))
	{
		VPANEL child = vgui::ipanel()->GetChild(GetVPanel(), 0);
		vgui::ipanel()->DeletePanel(child);
	}
}

void CTFHUDSoloObjectives::ApplySchemeSettings( IScheme *pScheme )
{
	ReinitializeEverything();

	BaseClass::ApplySchemeSettings( pScheme );

	LoadControlSettings( m_pszResFile );
}

void CTFHUDSoloObjectives::PerformLayout()
{
	BaseClass::PerformLayout();
}

void CTFHUDSoloObjectives::Reset()
{
	
}

void CTFHUDSoloObjectives::Think()
{
	RunScriptHook("solohud_think", NULL);
}

void CTFHUDSoloObjectives::PaintBackground()
{
	BaseClass::PaintBackground();
}

void CTFHUDSoloObjectives::Paint()
{
	BaseClass::Paint();
}

void CTFHUDSoloObjectives::FireGameEvent( IGameEvent * pEvent )
{
	const char *pszName = pEvent->GetName();

	if ( FStrEq( pszName, "solohud_file_changed" ) )
	{
		const char* pszPath = pEvent->GetString("path");
		SetResFile( pszPath );
		RunScriptHook("solohud_file_changed", NULL);
	}
	else if ( FStrEq( pszName, "server_spawn" ) )
	{
		if ( g_pScriptVM )
		{
			g_pScriptVM->RegisterInstance( this, "SoloHUD" );
		}
		ReinitializeEverything();
		ResetResFile();
		RunScriptHook( "solohud_init", NULL );
	}
}

void CTFHUDSoloObjectives::SetResFile(const char* file)
{
	if (file[0] == '\0')
	{
		ResetResFile();
	}
	else
	{
		m_pszResFile = file;
	}
	InvalidateLayout(true, true);
}

void CTFHUDSoloObjectives::ResetResFile()
{
	m_pszResFile = "Resource/UI/solo/HudSoloBase.res";
	InvalidateLayout(true, true);
}

void CTFHUDSoloObjectives::SyncResFile()
{
	if ( TFGameRules() )
	{
		const char* pszRulesResFile = TFGameRules()->GetSoloObjectivesResFile();
		if (pszRulesResFile && pszRulesResFile[0])
		{
			SetResFile( pszRulesResFile );
		}
	}
}

void CTFHUDSoloObjectives::RunAnimationScript(const char* pszScript, bool bCanBeCancelled)
{
	g_pClientMode->GetViewportAnimationController()->RunScript(pszScript, this, bCanBeCancelled);
}

int CTFHUDSoloObjectives::GetScreenWidth()
{
	return ScreenWidth();
}
int CTFHUDSoloObjectives::GetScreenHeight()
{
	return ScreenWidth();
}

BEGIN_SCRIPTDESC(CTFHUDSoloObjectives, EditablePanel, SCRIPT_SINGLETON "Used to access the ingame objectives HUD")

DEFINE_SCRIPTFUNC(Reset, "")
DEFINE_SCRIPTFUNC(GetResFile, "")
DEFINE_SCRIPTFUNC(SetResFile, "")
DEFINE_SCRIPTFUNC(ResetResFile, "")
DEFINE_SCRIPTFUNC(SyncResFile, "")
DEFINE_SCRIPTFUNC(CreatePanel, "")
DEFINE_SCRIPTFUNC(CreatePanelRoot, "")
DEFINE_SCRIPTFUNC(DeleteSubPanel, "")
DEFINE_SCRIPTFUNC(ClearAllScriptPanels, "")
DEFINE_SCRIPTFUNC(RunAnimationScript, "")
DEFINE_SCRIPTFUNC(FindPanelRoot, "")
DEFINE_SCRIPTFUNC(FindPanel, "")
DEFINE_SCRIPTFUNC(AddActionSignalTargetForPanel, "")
DEFINE_SCRIPTFUNC(ReinitializeEverything, "")
DEFINE_SCRIPTFUNC(GetMatchStatusPanel, "")
DEFINE_SCRIPTFUNC(GetKothTimersPanel, "")

END_SCRIPTDESC();

void CTFHUDSoloObjectives::ClearAllScriptPanels()
{
	FOR_EACH_VEC(m_scriptPanels, pIter)
	{
		ScriptPanelData item = m_scriptPanels[pIter];
		g_pScriptVM->RemoveInstance(item.m_Handle);
		if (!item.m_RootChild)
		{
			item.m_Panel->SetAutoDelete(true);
		}
	}
	FOR_EACH_VEC(m_scriptPanels, pIter)
	{
		ScriptPanelData item = m_scriptPanels[pIter];
		if (item.m_RootChild)
		{
			item.m_Panel->DeletePanel();
		}
	}
	m_scriptPanels.Purge();
}

void CTFHUDSoloObjectives::DeleteSubPanel(const char* hPanel)
{
	FOR_EACH_VEC(m_scriptPanels, pIter)
	{
		ScriptPanelData item = m_scriptPanels[pIter];
		if (FStrEq(item.m_Panel->GetName(), hPanel))
		{
			g_pScriptVM->RemoveInstance(item.m_Handle);
			item.m_Panel->DeletePanel();
			return;
		}
	}
}

HSCRIPT CTFHUDSoloObjectives::CreatePanel(HSCRIPT hTable, const char* hParentTarget)
{
	FOR_EACH_VEC(m_scriptPanels, pIter)
	{
		ScriptPanelData item = m_scriptPanels[pIter];
		if (FStrEq(item.m_Panel->GetName(), hParentTarget))
		{
			return CreatePanelInternal(hTable, item.m_Panel);
		}
	}
	return NULL;
}

HSCRIPT CTFHUDSoloObjectives::CreatePanelRoot(HSCRIPT hTable)
{
	return CreatePanelInternal(hTable, NULL);
}

HSCRIPT CTFHUDSoloObjectives::FindPanelRoot(const char* hTarget)
{
	Panel* pPanel = FindChildByName(hTarget, true);
	if (pPanel)
	{
		return PanelToScriptHandle(pPanel);
	}
	return NULL;
}
HSCRIPT CTFHUDSoloObjectives::FindPanel(HSCRIPT hPanelRootHandle, const char* hTarget)
{
	auto hPanelRoot = (Panel*)g_pScriptVM->GetInstanceValue(hPanelRootHandle, GetScriptDescForClass(Panel));
	if (hPanelRoot)
	{
		Panel* pPanel = hPanelRoot->FindChildByName(hTarget, true);
		if (pPanel)
		{
			return PanelToScriptHandle(pPanel);
		}
	}
	return NULL;
}
void CTFHUDSoloObjectives::AddActionSignalTargetForPanel(HSCRIPT hPanel)
{
	auto hPanelRoot = (Panel*)g_pScriptVM->GetInstanceValue(hPanel, GetScriptDescForClass(Panel));
	if (hPanelRoot)
	{
		hPanelRoot->AddActionSignalTarget(this);
	}
}

HSCRIPT CTFHUDSoloObjectives::CreatePanelInternal(HSCRIPT hTable, Panel* hParentTarget)
{
	KeyValues* hKV = ScriptTableToKeyValues(g_pScriptVM, "PanelSettings", hTable);
	const char* pszPanelType = hKV->GetString("ControlName", "Panel");
	if (!pszPanelType)
	{
		return NULL;
	}
	Panel* hParent = this;
	if (hParentTarget)
	{
		hParent = hParentTarget;
	}

	Panel* pPanel;
	EditablePanel* pEditPanel = NULL;
	ScriptClassDesc_t* pDesc = GetScriptDescForClass(Panel);
	const char* pszControlName = hKV->GetString("fieldName", "NoName");
	if (FStrEq(pszPanelType, "EditablePanel"))
	{
		EditablePanel* pBasePanel = new EditablePanel(hParent, pszControlName);
		pPanel = pBasePanel;
		pEditPanel = pBasePanel;
		pDesc = GetScriptDescForClass(EditablePanel);
	}
	else if (FStrEq(pszPanelType, "Panel"))
	{
		Panel* pBasePanel = new Panel(hParent, pszControlName);
		pPanel = pBasePanel;
	}
	else if (FStrEq(pszPanelType, "CExScrollingEditablePanel"))
	{
		CExScrollingEditablePanel* pBasePanel = new CExScrollingEditablePanel(hParent, pszControlName);
		pPanel = pBasePanel;
		pEditPanel = pBasePanel;
		pDesc = GetScriptDescForClass(CExScrollingEditablePanel);
	}
	else if (FStrEq(pszPanelType, "ScrollBar"))
	{
		int isVertical = hKV->GetInt("isVertical");
		ScrollBar* pBasePanel = new ScrollBar(hParent, pszControlName, isVertical != 0);
		pPanel = pBasePanel;
		pDesc = GetScriptDescForClass(ScrollBar);
	}
	else if (FStrEq(pszPanelType, "CExLabel"))
	{
		CExLabel* pBasePanel = new CExLabel(hParent, pszControlName, (const char*)NULL);
		pPanel = pBasePanel;
		pDesc = GetScriptDescForClass(CExLabel);
	}
	else if (FStrEq(pszPanelType, "CExImageButton"))
	{
		CExImageButton* pBasePanel = new CExImageButton(hParent, pszControlName, (const char*)NULL, this);
		pPanel = pBasePanel;
		pDesc = GetScriptDescForClass(CExImageButton);
	}
	else if (FStrEq(pszPanelType, "ImagePanel"))
	{
		ImagePanel* pBasePanel = new ImagePanel(hParent, pszControlName);
		pPanel = pBasePanel;
		pDesc = GetScriptDescForClass(ImagePanel);
	}
	else if (FStrEq(pszPanelType, "CTFImagePanel"))
	{
		CTFImagePanel* pBasePanel = new CTFImagePanel(hParent, pszControlName);
		pPanel = pBasePanel;
		pDesc = GetScriptDescForClass(CTFImagePanel);
	}
	else if (FStrEq(pszPanelType, "CBaseModelPanel"))
	{
		CBaseModelPanel* pBasePanel = new CBaseModelPanel(hParent, pszControlName);
		pPanel = pBasePanel;
		pEditPanel = pBasePanel;
		pDesc = GetScriptDescForClass(CBaseModelPanel);
	}
	else if (FStrEq(pszPanelType, "CItemModelPanel"))
	{
		CItemModelPanel* pBasePanel = new CItemModelPanel(hParent, pszControlName);
		pPanel = pBasePanel;
		pEditPanel = pBasePanel;
		pDesc = GetScriptDescForClass(CItemModelPanel);
	}
	else if (FStrEq(pszPanelType, "CTFPlayerModelPanel"))
	{
		CTFPlayerModelPanel* pBasePanel = new CTFPlayerModelPanel(hParent, pszControlName);
		pPanel = pBasePanel;
		pEditPanel = pBasePanel;
		pDesc = GetScriptDescForClass(CTFPlayerModelPanel);
	}
	else if (FStrEq(pszPanelType, "VideoPanel"))
	{
		CTFVideoPanel* pBasePanel = new CTFVideoPanel(hParent, pszControlName);
		pPanel = pBasePanel;
		pEditPanel = pBasePanel;
		pDesc = GetScriptDescForClass(CTFVideoPanel);
	}
	else if (FStrEq(pszPanelType, "CExRichText"))
	{
		CExRichText* pBasePanel = new CExRichText(hParent, pszControlName);
		pPanel = pBasePanel;
		pEditPanel = pBasePanel;
		pDesc = GetScriptDescForClass(CExRichText);
	}
	else if (FStrEq(pszPanelType, "CRichTextWithScrollbarBorders"))
	{
		CRichTextWithScrollbarBorders* pBasePanel = new CRichTextWithScrollbarBorders(hParent, pszControlName);
		pPanel = pBasePanel;
		pEditPanel = pBasePanel;
		pDesc = GetScriptDescForClass(CRichTextWithScrollbarBorders);
	}
	else if (FStrEq(pszPanelType, "Label"))
	{
		Label* pBasePanel = new Label(hParent, pszControlName, (const char*)NULL);
		pPanel = pBasePanel;
		pDesc = GetScriptDescForClass(Label);
	}
	else if (FStrEq(pszPanelType, "CEconItemDetailsRichText"))
	{
		CEconItemDetailsRichText* pBasePanel = new CEconItemDetailsRichText(hParent, pszControlName);
		pPanel = pBasePanel;
		pEditPanel = pBasePanel;
		pDesc = GetScriptDescForClass(CEconItemDetailsRichText);
	}
	else if (FStrEq(pszPanelType, "Button"))
	{
		Button* pBasePanel = new Button(hParent, pszControlName, (const char*)NULL, this);
		pPanel = pBasePanel;
		pDesc = GetScriptDescForClass(Button);
	}
	else if (FStrEq(pszPanelType, "Frame"))
	{
		Frame* pBasePanel = new Frame(hParent, pszControlName);
		pPanel = pBasePanel;
		pDesc = GetScriptDescForClass(Frame);
	}
	else
	{
		// Panel not found!
		Assert(false);
	}

	if (hKV->FindKey("ControlSettings") != NULL && pEditPanel)
	{
		pEditPanel->MakeReadyForUse();
		pEditPanel->LoadControlSettings(hKV->GetString("ControlSettings"));
	}
	pPanel->ApplySettings(hKV);

	char szName[1024];
	g_pScriptVM->GenerateUniqueKey((pszControlName != NULL_STRING) ? STRING(pszControlName) : pszPanelType, szName, 1024);
	string_t m_iszScriptId = AllocPooledString(szName);

	HSCRIPT m_hScriptInstance = g_pScriptVM->RegisterInstance(pDesc, pPanel);
	g_pScriptVM->SetInstanceUniqeId(m_hScriptInstance, STRING(m_iszScriptId));

	ScriptPanelData PanelData;
	PanelData.m_Handle = m_hScriptInstance;
	PanelData.m_Panel = pPanel;
	PanelData.m_RootChild = true;
	if (hParent != this)
	{
		PanelData.m_RootChild = false;
	}

	m_scriptPanels.AddToTail(PanelData);

	return m_hScriptInstance;
}

HSCRIPT CTFHUDSoloObjectives::GetMatchStatusPanel()
{
	CTFHudMatchStatus* pStatus = GET_HUDELEMENT(CTFHudMatchStatus);
	return PanelToScriptHandle(pStatus);
}

HSCRIPT CTFHUDSoloObjectives::GetKothTimersPanel()
{
	CTFHudKothTimeStatus* pKothHUD = GET_HUDELEMENT(CTFHudKothTimeStatus);
	return PanelToScriptHandle(pKothHUD);
}
