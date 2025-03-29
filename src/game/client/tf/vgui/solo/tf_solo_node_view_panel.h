#include "vgui_controls/EditablePanel.h"
#include "tf_controls.h"

using namespace vgui;

class CItemModelPanelToolTip;
//class CQuestProgressTrackerPanel;
class CItemModelPanel;
class CSoloNodePanel;
class CSoloNodeViewSubPanel;

class CSoloObjectivePanel : public EditablePanel
{
	DECLARE_CLASS_SIMPLE(CSoloObjectivePanel, EditablePanel);
public:
	CSoloObjectivePanel(Panel* pParent, const char* pszPanelname);

	virtual void PerformLayout() OVERRIDE;

	//void SetQuestData(const CQuest* pQuest, const CQuestDefinition* pQuestDef);

private:

	//CQuestProgressTrackerPanel* m_pItemTrackerPanel;
};

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
class CSoloObjectiveTooltip : public vgui::BaseTooltip
{
	DECLARE_CLASS_SIMPLE(CSoloObjectiveTooltip, vgui::BaseTooltip);
public:
	CSoloObjectiveTooltip(vgui::Panel* parent, const char* text = NULL);

	void SetText(const char* text) { return; }
	const char* GetText() { return NULL; }

	virtual void PerformLayout();
	virtual void ShowTooltip(vgui::Panel* currentPanel);
	virtual void HideTooltip();

	void SetObjectivePanel(CSoloObjectivePanel* pObjectivePanel) { m_pObjectivePanel = pObjectivePanel; }

private:

	CSoloObjectivePanel* m_pObjectivePanel;	// This is the tooltip panel we make visible. Must be a CQuestObjectivePanel.
	vgui::DHANDLE<CSoloNodeViewSubPanel> m_hCurrentPanel;
};


class CSoloNodeViewSubPanel : public CExpandablePanel
	, public CGameEventListener
{
	DECLARE_CLASS_SIMPLE(CSoloNodeViewSubPanel, CExpandablePanel);
public:
	CSoloNodeViewSubPanel(Panel* pParent,
		const char* pszPanelName);

	virtual void ApplySchemeSettings(IScheme* pScheme) OVERRIDE;
	virtual void PerformLayout() OVERRIDE;
	virtual void OnSizeChanged(int nWide, int nTall) OVERRIDE;
	virtual void OnCommand(const char* command) OVERRIDE;

	virtual void FireGameEvent(IGameEvent* event) OVERRIDE;

	//const CQuestDefinition* GetQuestDefindex() const { return m_pQuestDef; }
	//void SetQuestData(const CQuest* pQuest, const CQuestDefinition* pQuestDef, bool bShowObjectives);
	//void SetNodeData(const CSOQuestMapNode& msgNodeData);
	void SetTextTooltip(CTFTextToolTip* pTextTooltip) { m_pToolTip = pTextTooltip; }
	void SetObjectiveTooltip(CSoloObjectiveTooltip* pObjectiveTooltip) { m_pObjectiveTooltip = pObjectiveTooltip; }

	virtual void OnCursorEntered();
	virtual void OnCursorExited();

	void OnConfirmSelectQuest();

	MESSAGE_FUNC(OnShowTurnInSuccess, "ShowTurnInSuccess");

private:
	void HideSelectQuestInfo();
	void BeginTurnInAnimation();

	EditablePanel* m_pAcceptTooltipHack;
	CExButton* m_pActivateButton;
	CTFTextToolTip* m_pToolTip;
	ImagePanel* m_pBGImage;
	ImagePanel* m_pInfo;

	// Turn in
	EditablePanel* m_pTurnInContainer;

	bool m_bTurningIn = false;
	bool m_bShowObjectives = false;
	//CSOQuestMapNode m_msgNodeData;
	//const CQuest* m_pQuest;
	//const CQuestDefinition* m_pQuestDef;
	CSoloObjectivePanel* m_pObjectivePanel;
	CSoloObjectiveTooltip* m_pObjectiveTooltip;
};


//-----------------------------------------------------------------------------
// Purpose: The view of a quest node with inspected
//-----------------------------------------------------------------------------
class CSoloNodeViewPanel: public CExpandablePanel
	, public CGameEventListener
{
public:
	DECLARE_CLASS_SIMPLE(CSoloNodeViewPanel, CExpandablePanel);
	CSoloNodeViewPanel(Panel* pParent, const char* pszPanelname);

	virtual void ApplySchemeSettings(IScheme* pScheme) OVERRIDE;
	virtual void PerformLayout() OVERRIDE;
	virtual void OnCommand(const char* pCommand) OVERRIDE;
	virtual void OnThink() OVERRIDE;
	virtual void Paint() OVERRIDE;
	virtual void SetVisible(bool bVisible) OVERRIDE;

	virtual void FireGameEvent(IGameEvent* event) OVERRIDE;

	void SetItemModelPanelTooltip(CItemModelPanelToolTip* pItemTooltip) { m_pItemToolTip = pItemTooltip; }
	void SetTextTooltip(CTFTextToolTip* pTooltip);
	void SetObjectiveTooltip(CSoloObjectiveTooltip* pObjectiveTooltip);
	//void SetData(const CSOQuestMapNode& msgNodeData);
	//const CSOQuestMapNode GetData() const { return m_msgNodeData; }

	void UpdateQuestViewPanelForNode(CSoloNodePanel* pNodePanel);

	//virtual void SOCreated(const CSteamID& steamIDOwner, const GCSDK::CSharedObject* pObject, GCSDK::ESOCacheEvent eEvent) OVERRIDE;
	//virtual void SOUpdated(const CSteamID& steamIDOwner, const GCSDK::CSharedObject* pObject, GCSDK::ESOCacheEvent eEvent) OVERRIDE;
	//virtual void SODestroyed(const CSteamID& steamIDOwner, const GCSDK::CSharedObject* pObject, GCSDK::ESOCacheEvent eEvent) OVERRIDE;

	MESSAGE_FUNC_PARAMS(QuestClicked, "QuestClicked", pParams);
	MESSAGE_FUNC(TurnInComplete, "TurnInComplete");
private:

	void UpdatePosition();
	void UpdateQuestSubPanels();
	void UpdateHeights();

	//
	// Animation things
	//
	void SelectedQuestArrived();

	//CSOQuestMapNode m_msgPreTurnInSoData;
	//CSOQuestMapNode m_msgNodeData;

	Panel* m_pNodeStateBorder;
	Label* m_pTitleLabel;
	EditablePanel* m_pContentContainer;
	EditablePanel* m_pRewardsContainer;
	CUtlVector< CSoloNodeViewSubPanel*	> m_vecQuestSubPanels;
	CItemModelPanelToolTip* m_pItemToolTip;
	CItemModelPanel* m_pRewardItemPanel;
	CTFTextToolTip* m_pToolTip;
	ImagePanel* m_pContractsInfo;
	ImagePanel* m_pRewardsInfo;
	bool m_bQuestCreated;
	bool m_bHasItemsToShow = false;
	bool m_bTurningIn = false;

	int m_nNodePanelX;
	int m_nNodePanelY;
	int m_nNodePanelWide;
	int m_nNodePanelTall;

};
