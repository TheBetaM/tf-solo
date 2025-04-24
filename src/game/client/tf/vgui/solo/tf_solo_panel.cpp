#include "cbase.h"
#include "tf_solo_node_panel.h"
#include <vgui/IInput.h>
#include "tf_solo_region_panel.h"
#include "clientmode_tf.h"
#include <vgui_controls/AnimationController.h>
#include "item_model_panel.h"
#include "tf_solo_node_view_panel.h"
#include "tf_vgui_video.h"
#include "tf_matchmaking_dashboard.h"
#include "tf_hud_mainmenuoverride.h"
#include "vguicenterprint.h"
#include "tf_solo_panel.h"
#include "tf_playermodelpanel.h"
#include "vscript_client.h"
#include "vscript_utils.h"
#include "softline.h"

class CSoloTooltip : public CTFTextToolTip
{
public:
	CSoloTooltip(vgui::Panel* parent) : CTFTextToolTip(parent) {}
	// Force the panel to reposition itself every frame.  If the tooltip is coming
	// from an image panel it won't do this, but for the quest panel this is what we want
	virtual void PerformLayout() { CTFTextToolTip::PerformLayout(); _isDirty = true; }
};

DECLARE_BUILD_FACTORY(CSoloPanel);
//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
CSoloPanel* g_pSoloPanel = NULL;

CSoloPanel* GetSoloPanel()
{
	if (g_pSoloPanel == NULL)
	{
		CHudMainMenuOverride* pMMOverride = (CHudMainMenuOverride*)(gViewPortInterface->FindPanelByName(PANEL_MAINMENUOVERRIDE));
		g_pSoloPanel = new CSoloPanel(pMMOverride, "Solo");
		g_pSoloPanel->MakeReadyForUse();
	}

	return g_pSoloPanel;
}

CSoloPanel::CSoloPanel(Panel* pParent, const char* pszPanelName)
	: BaseClass(pParent, pszPanelName)
	, m_mapRegions(DefLessFunc(uint32))
	, m_bMapLoaded(false)
{
	// So we can paint the radio needle *on top* of our children
	SetPostChildPaintEnabled(true);

	if (g_pVGuiLocalize)
	{
		g_pVGuiLocalize->AddFile("resource/tf_quests_%language%.txt");
	}

	Assert(g_pSoloPanel == NULL);
	g_pSoloPanel = this;

	// Item tooltip
	m_pMouseOverItemPanel = vgui::SETUP_PANEL(new CItemModelPanel(this, "mouseoveritempanel"));
	m_pMouseOverTooltip = new CItemModelPanelToolTip(this);
	m_pMouseOverTooltip->SetupPanels(this, m_pMouseOverItemPanel);

	// Text tooltip
	m_pToolTip = new CSoloTooltip(this);
	m_pToolTipEmbeddedPanel = new vgui::EditablePanel(this, "TooltipPanel");
	m_pToolTipEmbeddedPanel->SetKeyBoardInputEnabled(false);
	m_pToolTipEmbeddedPanel->SetMouseInputEnabled(false);
	m_pToolTip->SetEmbeddedPanel(m_pToolTipEmbeddedPanel);
	m_pToolTip->SetTooltipDelay(0);

	m_pMainContainer = new EditablePanel(this, "MainContainer");

	m_pMapAreaPanel = new EditablePanel(m_pMainContainer, "MapAreaPanel");

	m_pPathsPanel = new CSoloPathsPanel(m_pMainContainer, "PathsPanel");

	// Quest objective tooltip
	m_pQuestObjectiveTooltip = new CSoloObjectiveTooltip(m_pMapAreaPanel, "ObjectiveTooltip");
	m_pQuestObjectivePanel = new CSoloObjectivePanel(m_pMapAreaPanel, "QuestObjective");
	m_pQuestObjectiveTooltip->SetObjectivePanel(m_pQuestObjectivePanel);
	// Node view
	m_pQuestNodeViewPanel = new CSoloNodeViewPanel(m_pMapAreaPanel, "SelectedNodeInfoPanel");
	m_pQuestNodeViewPanel->SetItemModelPanelTooltip(m_pMouseOverTooltip);
	m_pQuestNodeViewPanel->SetTextTooltip(m_pToolTip);
	m_pQuestNodeViewPanel->SetObjectiveTooltip(m_pQuestObjectiveTooltip);

	ListenForGameEvent("gameui_hidden");

	// TODO: Tutorial check here
	m_eScreenDisplay = SCREEN_INVALID;
	ChangeScreenDisplay(SCREEN_STORE); // This needs to be after all the panel pointers are setup

	if (!g_pScriptVM->Has("SoloPanel"))
	{
		g_pScriptVM->RegisterInstance(this, "SoloPanel");
	}
}

CSoloPanel::~CSoloPanel()
{
	Assert(g_pSoloPanel == this);
	g_pSoloPanel = NULL;
}

void CSoloPanel::ApplySchemeSettings(IScheme* pScheme)
{
	BaseClass::ApplySchemeSettings(pScheme);

	LoadControlSettings("Resource/UI/solo/SoloPanel.res");
}

void CSoloPanel::ApplySettings(KeyValues* inResourceData)
{
	BaseClass::ApplySettings(inResourceData);
}

void CSoloPanel::OnCommand(const char* pCommand)
{
	if (ScriptHookEnabled("solopanel_command"))
	{
		IScriptVM* pVM = g_pScriptVM;
		ScriptVariant_t varTable;
		pVM->CreateTable(varTable);
		pVM->SetValue(varTable, "command", pCommand);
		pVM->SetValue(varTable, "early_out", false);
		if (RunScriptHook("solopanel_command", varTable))
		{
			if (pVM->Get<bool>(varTable, "early_out"))
				return;
		}
	}

	if (FStrEq("close", pCommand))
	{
		SetVisible(false);
		return;
	}
	else if (FStrEq("anim_close", pCommand))
	{
		SetVisible(false);
		return;
	}

	BaseClass::OnCommand(pCommand);
}

void CSoloPanel::ChangeScreenDisplay(EScreenDisplay eScreen)
{
	if (eScreen == m_eScreenDisplay)
		return;
	m_eScreenDisplay = eScreen;
	InvalidateLayout();
}

void CSoloPanel::SetVisible(bool bVisible)
{
	if (IsVisible() == bVisible)
		return;

	UpdateControls(bVisible);

	BaseClass::SetVisible(bVisible);

	if (bVisible)
	{
		if (!g_pScriptVM->Has("SoloPanel"))
		{
			g_pScriptVM->RegisterInstance(this, "SoloPanel");
			if (m_pPathsPanel)
			{
				m_pPathsPanel->ResetVisuals();
			}
		}
		m_pQuestNodeViewPanel->SetVisible(false);
		RunScriptHook("solopanel_open", NULL);
	}
	else
	{
		RunScriptHook("solopanel_closed", NULL);
		ChangeScreenDisplay(SCREEN_STORE);
	}
}

void CSoloPanel::FireGameEvent(IGameEvent* event)
{
	if (FStrEq(event->GetName(), "gameui_hidden"))
	{
		// When the gameui hides, we need to hide so we're not still open if the gameui re-opens
		SetVisible(false);
	}
}

void CSoloPanel::OnPlaySoundEntry(KeyValues* pParams)
{
	PlaySoundEntry(pParams->GetString("sound"));
}

void CSoloPanel::UpdateControls(bool bIgnoreInvalidLayout)
{
	if (!bIgnoreInvalidLayout && IsLayoutInvalid())
		return;

	m_bMapLoaded = true;

	InvalidateLayout();
}

void CSoloPanel::GoToCurrentQuest()
{
	MakeReadyForUse();
}

// ----------------------------------------------------------------------------

void CSoloPanel::ForceOpen()
{
	if (engine->IsInGame())
	{
		engine->ClientCmd_Unrestricted("gameui_activate");
	}
	GetSoloPanel()->SetVisible(true);
	GetSoloPanel()->GoToCurrentQuest();
}
void CSoloPanel::ForceClose()
{
	if (GetSoloPanel()->IsVisible())
	{
		if (engine->IsInGame())
		{
			engine->ClientCmd_Unrestricted("gameui_hide");
		}
		GetSoloPanel()->SetVisible(false);
	}
}
void CSoloPanel::ForceUpdateControls()
{
	UpdateControls();
}
void CSoloPanel::HideMainTooltip()
{
	m_pToolTip->HideTooltip();
}
void CSoloPanel::PrepareForLevelLoad()
{
	g_pCVar->RevertFlaggedConVars(FCVAR_REPLICATED);
	g_pCVar->RevertFlaggedConVars(FCVAR_CHEAT);

	ConVarRef tf_gamemode_solo("tf_gamemode_solo");
	tf_gamemode_solo.SetValue(1);
}

void CSoloPanel::RunAnimationScript(const char* pszScript, bool bCanBeCancelled)
{
	g_pClientMode->GetViewportAnimationController()->RunScript(pszScript, this, bCanBeCancelled);
}

void CSoloPanel::SetActiveCirclePos(int PosX, int PosY)
{
	if (m_pPathsPanel)
	{
		m_pPathsPanel->m_bDrawActiveCircle = true;
		m_pPathsPanel->m_ActiveCirclePosX = PosX;
		m_pPathsPanel->m_ActiveCirclePosY = PosY;
	}
}

void CSoloPanel::SetDrawActiveCircle(bool mVal)
{
	if (m_pPathsPanel)
	{
		m_pPathsPanel->m_bDrawActiveCircle = mVal;
	}
}

void CSoloPanel::SetDrawGrid(bool mVal)
{
	if (m_pPathsPanel)
	{
		m_pPathsPanel->m_bDrawGrid = mVal;
	}
}

void CSoloPanel::SetGridScale(float mVal)
{
	if (m_pPathsPanel)
	{
		m_pPathsPanel->m_flZoomScale = mVal;
	}
}

int CSoloPanel::GetScreenWidth()
{
	return ScreenWidth();
}
int CSoloPanel::GetScreenHeight()
{
	return ScreenWidth();
}

void CSoloPanel::ClearNodePaths() 
{
	if (m_pPathsPanel)
	{
		m_pPathsPanel->ClearScriptPaths();
	}
}
int CSoloPanel::AddNodePath(int startX, int startY, int endX, int endY, bool dashed, bool active, bool arrows)
{
	if (m_pPathsPanel)
	{
		return m_pPathsPanel->AddScriptPath(startX, startY, endX, endY, dashed, active, arrows);
	}
	return -1;
}

BEGIN_SCRIPTDESC_ROOT(CSoloPanel, SCRIPT_SINGLETON "Used to access the main solo interface")

DEFINE_SCRIPTFUNC(ForceOpen, "")
DEFINE_SCRIPTFUNC(ForceClose, "")
DEFINE_SCRIPTFUNC(ForceUpdateControls, "")
DEFINE_SCRIPTFUNC(CreatePanel, "")
DEFINE_SCRIPTFUNC(CreatePanelRoot, "")
DEFINE_SCRIPTFUNC(DeleteSubPanel, "")
DEFINE_SCRIPTFUNC(ClearAllScriptPanels, "")
DEFINE_SCRIPTFUNC(RunAnimationScript, "")
DEFINE_SCRIPTFUNC(HideMainTooltip, "")
DEFINE_SCRIPTFUNC(PrepareForLevelLoad, "")
DEFINE_SCRIPTFUNC(FindPanelRoot, "")
DEFINE_SCRIPTFUNC(FindPanel, "")
DEFINE_SCRIPTFUNC(AddActionSignalTargetForPanel, "")
DEFINE_SCRIPTFUNC(SetActiveCirclePos, "")
DEFINE_SCRIPTFUNC(SetActiveCirclePanelPos, "")
DEFINE_SCRIPTFUNC(SetDrawActiveCircle, "")
DEFINE_SCRIPTFUNC(SetDrawGrid, "")
DEFINE_SCRIPTFUNC(GetScreenWidth, "")
DEFINE_SCRIPTFUNC(GetScreenHeight, "")
DEFINE_SCRIPTFUNC(ClearNodePaths, "")
DEFINE_SCRIPTFUNC(AddNodePath, "")
DEFINE_SCRIPTFUNC(ApplyPanelSettings, "")

END_SCRIPTDESC();

BEGIN_SCRIPTDESC_ROOT(Panel, "Used to access a generic panel")

DEFINE_SCRIPTFUNC(SetName, "")
DEFINE_SCRIPTFUNC(GetName, "")
DEFINE_SCRIPTFUNC(GetClassName, "")
DEFINE_SCRIPTFUNC(MakeReadyForUse, "")
DEFINE_SCRIPTFUNC(SetPos, "")

DEFINE_SCRIPTFUNC(GetXPos, "")
DEFINE_SCRIPTFUNC(GetYPos, "")
DEFINE_SCRIPTFUNC(SetSize, "")

DEFINE_SCRIPTFUNC(SetBounds, "")

DEFINE_SCRIPTFUNC(GetWide, "")
DEFINE_SCRIPTFUNC(SetWide, "")
DEFINE_SCRIPTFUNC(GetTall, "")
DEFINE_SCRIPTFUNC(SetTall, "")
DEFINE_SCRIPTFUNC(SetMinimumSize, "")

DEFINE_SCRIPTFUNC(IsBuildModeEditable, "")
DEFINE_SCRIPTFUNC(SetBuildModeEditable, "")
DEFINE_SCRIPTFUNC(IsBuildModeDeletable, "")
DEFINE_SCRIPTFUNC(SetBuildModeDeletable, "")
DEFINE_SCRIPTFUNC(IsBuildModeActive, "")
DEFINE_SCRIPTFUNC(SetZPos, "")
DEFINE_SCRIPTFUNC(GetZPos, "")
DEFINE_SCRIPTFUNC(SetAlpha, "")
DEFINE_SCRIPTFUNC(GetAlpha, "")
DEFINE_SCRIPTFUNC(SetVisible, "")
DEFINE_SCRIPTFUNC(IsVisible, "")

DEFINE_SCRIPTFUNC(IsWithin, "")

DEFINE_SCRIPTFUNC(GetChildCount, "")
DEFINE_SCRIPTFUNC(FindChildIndexByName, "")

DEFINE_SCRIPTFUNC(SetAutoDelete, "")
DEFINE_SCRIPTFUNC(IsAutoDeleteSet, "")
DEFINE_SCRIPTFUNC(DeletePanel, "")

DEFINE_SCRIPTFUNC(InvalidateLayout, "")


END_SCRIPTDESC();

BEGIN_SCRIPTDESC(EditablePanel, Panel, "")
DEFINE_SCRIPTFUNC(SetControlEnabled, "")
DEFINE_SCRIPTFUNC(SetControlVisible, "")
DEFINE_SCRIPTFUNC_NAMED(SetDialogVariableConst, "SetDialogVariable", "")
DEFINE_SCRIPTFUNC(SetDialogVariableInt, "")
DEFINE_SCRIPTFUNC(SetDialogVariableFloat, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(CExScrollingEditablePanel, EditablePanel, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(ScrollBar, Panel, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(CExLabel, Label, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(CExImageButton, Button, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(ImagePanel, Panel, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(CTFImagePanel, EditablePanel, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(CBaseModelPanel, EditablePanel, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(CItemModelPanel, EditablePanel, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(CTFPlayerModelPanel, EditablePanel, "")
DEFINE_SCRIPTFUNC(SetToPlayerClass, "")
DEFINE_SCRIPTFUNC(HoldItemInSlot, "")
DEFINE_SCRIPTFUNC(HoldItem, "")
DEFINE_SCRIPTFUNC(ClearCarriedItems, "")
DEFINE_SCRIPTFUNC(PlayVCD, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(CTFVideoPanel, EditablePanel, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(CExRichText, EditablePanel, "")
DEFINE_SCRIPTFUNC_NAMED(SetTextConst, "SetText", "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(CRichTextWithScrollbarBorders, CExRichText, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(CEconItemDetailsRichText, CRichTextWithScrollbarBorders, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(Label, Panel, "")
DEFINE_SCRIPTFUNC_NAMED(SetTextConst, "SetText", "")
DEFINE_SCRIPTFUNC(SizeToContents, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(Button, Label, "")
DEFINE_SCRIPTFUNC_NAMED(SetCommandConst, "SetCommand", "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(Frame, EditablePanel, "")
END_SCRIPTDESC();
BEGIN_SCRIPTDESC(CSoloNodePanel, EditablePanel, "")
DEFINE_SCRIPTFUNC(UpdateStateVisuals, "")
END_SCRIPTDESC();

void CSoloPanel::ClearAllScriptPanels()
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

void CSoloPanel::DeleteSubPanel(const char* hPanel)
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

HSCRIPT CSoloPanel::CreatePanel(HSCRIPT hTable, const char* hParentTarget)
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

HSCRIPT CSoloPanel::CreatePanelRoot(HSCRIPT hTable)
{
	return CreatePanelInternal(hTable, NULL);
}

HSCRIPT PanelToScriptHandle(Panel* pPanel)
{
	// This is lame... but it works.
	if (dynamic_cast<CSoloNodePanel*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<CSoloNodePanel*>(pPanel));
	if (dynamic_cast<CExScrollingEditablePanel*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<CExScrollingEditablePanel*>(pPanel));
	if (dynamic_cast<ScrollBar*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<ScrollBar*>(pPanel));
	if (dynamic_cast<CExImageButton*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<CExImageButton*>(pPanel));
	if (dynamic_cast<CTFImagePanel*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<CTFImagePanel*>(pPanel));
	if (dynamic_cast<CItemModelPanel*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<CItemModelPanel*>(pPanel));
	if (dynamic_cast<CTFPlayerModelPanel*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<CTFPlayerModelPanel*>(pPanel));
	if (dynamic_cast<CBaseModelPanel*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<CBaseModelPanel*>(pPanel));
	if (dynamic_cast<CTFVideoPanel*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<CTFVideoPanel*>(pPanel));
	if (dynamic_cast<CEconItemDetailsRichText*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<CEconItemDetailsRichText*>(pPanel));
	if (dynamic_cast<CRichTextWithScrollbarBorders*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<CRichTextWithScrollbarBorders*>(pPanel));
	if (dynamic_cast<CExRichText*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<CExRichText*>(pPanel));
	if (dynamic_cast<CExLabel*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<CExLabel*>(pPanel));
	if (dynamic_cast<Button*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<Button*>(pPanel));
	if (dynamic_cast<Label*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<Label*>(pPanel));
	if (dynamic_cast<Frame*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<Frame*>(pPanel));
	if (dynamic_cast<EditablePanel*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<EditablePanel*>(pPanel));
	if (dynamic_cast<ImagePanel*>(pPanel) != NULL) return g_pScriptVM->RegisterInstance(dynamic_cast<ImagePanel*>(pPanel));
	
	return g_pScriptVM->RegisterInstance(pPanel);
}
HSCRIPT CSoloPanel::FindPanelRoot(const char* hTarget)
{
	Panel* pPanel = FindChildByName(hTarget, true);
	if (pPanel)
	{
		return PanelToScriptHandle(pPanel);
	}
	return NULL;
}
HSCRIPT CSoloPanel::FindPanel(HSCRIPT hPanelRootHandle, const char* hTarget)
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
void CSoloPanel::AddActionSignalTargetForPanel(HSCRIPT hPanel)
{
	auto hPanelRoot = (Panel*)g_pScriptVM->GetInstanceValue(hPanel, GetScriptDescForClass(Panel));
	if (hPanelRoot)
	{
		hPanelRoot->AddActionSignalTarget(this);
	}
}
void CSoloPanel::SetActiveCirclePanelPos(HSCRIPT hPanel)
{
	auto hPanelRoot = (Panel*)g_pScriptVM->GetInstanceValue(hPanel, GetScriptDescForClass(Panel));
	if (hPanelRoot)
	{
		if (m_pPathsPanel)
		{
			m_pPathsPanel->m_bDrawActiveCircle = true;
			m_pPathsPanel->m_ActiveCirclePosX = hPanelRoot->GetXPos();
			m_pPathsPanel->m_ActiveCirclePosY = hPanelRoot->GetYPos();
		}
	}

}

void CSoloPanel::ApplyPanelSettings(HSCRIPT hPanelHandle, HSCRIPT hTable)
{
	auto hPanel = (Panel*)g_pScriptVM->GetInstanceValue(hPanelHandle, GetScriptDescForClass(Panel));
	if (!hPanel) return;
	KeyValues* hKV = ScriptTableToKeyValues(g_pScriptVM, "PanelSettings", hTable);
	hPanel->ApplySettings(hKV);
}

HSCRIPT CSoloPanel::CreatePanelInternal(HSCRIPT hTable, Panel* hParentTarget)
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
	else if (FStrEq(pszPanelType, "CSoloNodePanel"))
	{
		CSoloNodePanel* pBasePanel = new CSoloNodePanel(hParent, "QuestMapNode");
		pPanel = pBasePanel;
		pEditPanel = pBasePanel;
		pDesc = GetScriptDescForClass(CSoloNodePanel);
		pBasePanel->MakeReadyForUse();
		pBasePanel->AddActionSignalTarget(this);
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

CON_COMMAND(tfsolo_show_menu, "Show the solo menu")
{
	if (GetSoloPanel()->IsVisible())
	{
		if (engine->IsInGame())
		{
			engine->ClientCmd_Unrestricted("gameui_hide");
		}
		GetSoloPanel()->SetVisible(false);
	}
	else
	{
		if (engine->IsInGame())
		{
			engine->ClientCmd_Unrestricted("gameui_activate");
		}
		GetSoloPanel()->SetVisible(true);
		GetSoloPanel()->GoToCurrentQuest();
	}
}
CON_COMMAND(tfsolo_reset_menu, "Reset the solo menu")
{
	GetSoloPanel()->SetVisible(false);
	GetSoloPanel()->ClearAllScriptPanels();
}