#include "vgui_controls/EditablePanel.h"
#include "tf_controls.h"
#include "vscript_client.h"
#include "vscript_utils.h"

using namespace vgui;

class CItemModelPanel;
class CItemModelPanelToolTip;
class CSoloNodeViewPanel;
class CSoloRegionPanel;
class CTFVideoPanel;
class CExButton;
class CSoloObjectiveTooltip;
class CSoloObjectivePanel;
class CSoloPathsPanel;

namespace vgui
{
	class Slider;
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
class CSoloPanel : public EditablePanel
	, public CGameEventListener
{
	DECLARE_CLASS_SIMPLE(CSoloPanel, EditablePanel);
public:
	CSoloPanel(Panel* pParent, const char* pszPanelName);
	~CSoloPanel();

	virtual void ApplySchemeSettings(IScheme* pScheme) OVERRIDE;
	virtual void ApplySettings(KeyValues* inResourceData) OVERRIDE;
	virtual void OnCommand(const char* pCommand) OVERRIDE;
	virtual void SetVisible(bool bVisible) OVERRIDE;
	virtual void FireGameEvent(IGameEvent* event) OVERRIDE;

	MESSAGE_FUNC_PARAMS(OnPlaySoundEntry, "PlaySoundEntry", pParams);

	CTFTextToolTip* GetTextTooltip() const { return m_pToolTip; }

	void GoToCurrentQuest();
	void ClearAllScriptPanels();
	void ForceOpen();
	void ForceClose();
	void ForceUpdateControls();
	void HideMainTooltip();
	void PrepareForLevelLoad();
	void RunAnimationScript(const char* pszScript, bool bCanBeCancelled);
	void SetActiveCirclePos(int PosX, int PosY);
	void SetDrawActiveCircle(bool check);
	void SetDrawGrid(bool check);
	void SetGridScale(float flScale);
	int GetScreenWidth();
	int GetScreenHeight();
	void ClearNodePaths();
	int AddNodePath(int startX, int startY, int endX, int endY, bool dashed, bool active, bool arrows);
	virtual HSCRIPT CreatePanel(HSCRIPT hTable, const char* hParent);
	virtual HSCRIPT CreatePanelRoot(HSCRIPT hTable);
	void ApplyPanelSettings(HSCRIPT hPanelHandle, HSCRIPT hTable);
	void SetTooltip(HSCRIPT hPanelHandle, const char* tip);
	virtual HSCRIPT CreatePanelInternal(HSCRIPT hTable, Panel* hParent);
	virtual HSCRIPT FindPanelRoot(const char* hPanel);
	virtual HSCRIPT FindPanel(HSCRIPT hPanelRoot, const char* hPanel);
	virtual void AddActionSignalTargetForPanel(HSCRIPT hPanel);
	virtual void SetActiveCirclePanelPos(HSCRIPT pPanel);
	virtual void DeleteSubPanel(const char* hPanel);

	void UpdateControls(bool bIgnoreInvalidLayout = false);

	enum EScreenDisplay
	{
		SCREEN_INVALID,
		SCREEN_MAP,
		SCREEN_STORE,
	};
	void ChangeScreenDisplay(EScreenDisplay eScreen);

	struct ScriptPanelData
	{
		HSCRIPT m_Handle;
		Panel* m_Panel;
		bool m_RootChild;
	};

private:
	
	CSoloObjectiveTooltip* m_pQuestObjectiveTooltip;
	CSoloObjectivePanel* m_pQuestObjectivePanel;
	CSoloNodeViewPanel* m_pQuestNodeViewPanel;
	CItemModelPanel* m_pMouseOverItemPanel;
	CItemModelPanelToolTip* m_pMouseOverTooltip; // The map needs to own this so things will be sorted correctly
	CTFTextToolTip* m_pToolTip;
	CSoloPathsPanel* m_pPathsPanel;
	vgui::EditablePanel* m_pMainContainer;
	vgui::EditablePanel* m_pToolTipEmbeddedPanel;
	vgui::EditablePanel* m_pMapAreaPanel;
	
	CUtlMap< uint32, CSoloRegionPanel* > m_mapRegions;
	CUtlVector< ScriptPanelData > m_scriptPanels;

	bool m_bTurnInSuccess = false;
	bool m_bAwaitingItemConfirm = false;
	bool m_bMapLoaded;
	EScreenDisplay m_eScreenDisplay;

};

CSoloPanel* GetSoloPanel();

HSCRIPT PanelToScriptHandle(Panel* pPanel);
