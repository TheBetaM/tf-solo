#include "vgui_controls/EditablePanel.h"
#include "tf_controls.h"

using namespace vgui;

extern const float node_medium_radius;
extern const float node_large_radius;

void DrawAmbientActiveCirlceSolo(float flXPos, float flYPos, const Color& color);

//-----------------------------------------------------------------------------
// Purpose: A node on the solo map
//-----------------------------------------------------------------------------
class CSoloNodePanel : public vgui::EditablePanel
{
public:

	enum EMapState
	{
		NEUTRAL,
		MOUSE_OVER,
		SELECTED,
	};

	DECLARE_CLASS_SIMPLE(CSoloNodePanel, vgui::EditablePanel);
	CSoloNodePanel(Panel* pParent, const char* pszPanelName);
	~CSoloNodePanel();

	virtual void ApplySchemeSettings(IScheme* pScheme) OVERRIDE;
	virtual void ApplySettings(KeyValues* inResourceData) OVERRIDE;
	virtual void OnCommand(const char* pCommand) OVERRIDE;
	virtual void PerformLayout() OVERRIDE;
	virtual void OnThink() OVERRIDE;
	virtual void Paint() OVERRIDE;
	virtual void OnCursorEntered() OVERRIDE;
	virtual void OnCursorExited() OVERRIDE;
	virtual void OnMousePressed(MouseCode code) OVERRIDE;
	virtual void OnMouseDoublePressed(MouseCode code) OVERRIDE;

	void UpdateStateVisuals();

	EMapState GetState() const { return m_eMapState; }
	void EnterMapState(EMapState eMapState);
	bool BRequirementsMet() const { return m_bRequirementsMet; }

	void DrawNode(float flXPos,
		float flYPos,
		bool bPurchased,
		const Color& colorActive,
		const Color& colorBonus,
		const Color& colorInactive,
		const Color& colorRed,
		const Color& colorBlue,
		float flScale) const;
private:
	static uint32 m_nDraggingID;

	EMapState m_eMapState;
	float m_flMapStateEnterTime;
	CExButton* m_pSelectButton;
	Label* m_pNameLabel;
	ImagePanel* m_pStarCostImage;
	bool m_bOverSelected;
	
	bool m_bBaselineSet = false;

	int m_nStartWide;
	int m_nStartTall;

	bool m_bRequirementsMet;
	int m_nCreditsType;
	const char* m_pszNodeText;
	int m_nStarCount;
	bool m_bHasItem;
	bool m_bIsLocked;
	const char* m_pszIconName;
	int m_nCompletionState;
	int m_nCompletionSegments = 1;
	bool m_bIsIngame;
	int m_nNodeID;
	const char* m_pszTooltipText;
	int m_nTeam;
};

//-----------------------------------------------------------------------------
// Purpose: Tooltip to hold the tooltip panel
//-----------------------------------------------------------------------------
class CSoloNodeTooltip : public vgui::BaseTooltip, public vgui::EditablePanel
{
	DECLARE_CLASS_SIMPLE(CSoloNodeTooltip, vgui::EditablePanel);
public:
	CSoloNodeTooltip(vgui::Panel* pParent);

	virtual void ShowTooltip(Panel* pCurrentPanel) OVERRIDE;
	virtual void HideTooltip() OVERRIDE;
	virtual void PerformLayout() OVERRIDE;

	virtual void PositionWindow(Panel* pTipPanel) OVERRIDE;
	virtual void ApplySchemeSettings(IScheme* pScheme) OVERRIDE;

private:

	CSoloNodePanel* m_pFocusedNode;
};
