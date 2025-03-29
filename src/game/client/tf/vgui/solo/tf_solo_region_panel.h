#include "vgui_controls/EditablePanel.h"
#include "tf_controls.h"

using namespace vgui;

class CSoloNodePanel;
class CSoloObjectiveTextPanel;
class CExScrollingEditablePanel;
class CSoloProgressTrackerPanel;
class CItemModelPanel;
class CItemModelPanelToolTip;
class CSoloNodeViewPanel;

namespace vgui
{
	class Slider;
}

class CSoloCircleDrawingHelper
{
public:
	struct SoloCircleAnimData_t
	{
		double flStartTime;
		double flEndTime;
		float flX;
		float flY;
		float flStartRadius;
		float flEndRadius;
		Color colorStart;
		Color colorEnd;
		bool bFilled;
	};


	void PaintCircles();

	void AddCircle(const SoloCircleAnimData_t animData) {
		m_vecCircles.AddToTail(animData);
	}
	void ClearAllCircles() {
		m_vecCircles.Purge();
	}

private:
	CUtlVector< SoloCircleAnimData_t > m_vecCircles;
};

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
class CSoloPathsPanel : public Panel
{
public:
	DECLARE_CLASS_SIMPLE(CSoloPathsPanel, Panel);
	CSoloPathsPanel(Panel* pParent, const char* pszPanelname);

	virtual void Paint() OVERRIDE;

	void AddNode(CSoloNodePanel* pNodePanel);
	void RemoveNode(uint32 nDefindex);

	void AddRegion(EditablePanel* pRegionPanel, uint32 nDefIndex);
	void RemoveRegion(uint32 nDefIndex);
	void SetActiveRegion(EditablePanel* pRegionPanel) { m_pActiveRegionLinkPanel = pRegionPanel; }
	void ResetVisuals();
	void ClearScriptPaths();
	int AddScriptPath(int startX, int startY, int endX, int endY, bool dashed, bool active, bool arrows);

	CSoloCircleDrawingHelper& GetCircleDrawer() { return m_circleDrawer; }

	float m_flZoomScale;
	bool m_bDrawActiveCircle;
	int m_ActiveCirclePosX;
	int m_ActiveCirclePosY;
	bool m_bDrawGrid;

private:

	enum eSoloPathTypes
	{
		SoloPathType_Normal = 0,
		SoloPathType_Dashed,
	};

	struct ScriptPathData
	{
		int StartX;
		int StartY;
		int EndX;
		int EndY;
		bool DrawDashed;
		bool IsActive;
		bool DrawArrows;
	};

	CUtlVector< ScriptPathData > m_scriptPaths;
	CSoloCircleDrawingHelper m_circleDrawer;
	CUtlMap< uint32, EditablePanel* > m_mapRegionLinkPanels;
	EditablePanel* m_pActiveRegionLinkPanel = nullptr;
	CUtlMap< uint32, CSoloNodePanel* > m_mapQuestNodes;
	int m_nWhiteTexture;

};

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
class CSoloRegionPanel : public EditablePanel
	, public CGameEventListener
{
	DECLARE_CLASS_SIMPLE(CSoloRegionPanel, EditablePanel);
public:
	CSoloRegionPanel(Panel* pParent, const char* pszPanelName, CSoloNodeViewPanel* pNodeViewPanel);
	~CSoloRegionPanel();

	virtual void ApplySchemeSettings(IScheme* pScheme) OVERRIDE;
	virtual void OnCommand(const char* pCommand) OVERRIDE;

	virtual void OnTick() OVERRIDE;

	virtual void FireGameEvent(IGameEvent* event) OVERRIDE;

	MESSAGE_FUNC_PARAMS(NodeSelected, "NodeSelected", pParams);
	MESSAGE_FUNC_PARAMS(NodeCursorEntered, "NodeCursorEntered", pParams);
	MESSAGE_FUNC(NodeViewClosed, "NodeViewClosed");

	MESSAGE_FUNC(CloseNodeView, "CloseNodeView");
	MESSAGE_FUNC_PARAMS(CreateActivationCircle, "CreateActivationCircle", pParams);
	MESSAGE_FUNC_PARAMS(CreateCircle, "CreateCircle", pParams);

	virtual void OnMousePressed(MouseCode code);
	virtual void OnMouseDoublePressed(MouseCode code);

	const EditablePanel* GetRegionLinkPanel(uint32 nDefIndex) const;
	const CSoloNodePanel* GetNodePanel(uint32 nDefIndex) const;
	const CDraggableScrollingPanel* GetZoomPanel() const { return m_pZoomPanel; }

	void StartZoomTo(float flX, float flY, bool bZoomingIn);
	void StartZoomAway(float flX, float flY, bool bZoomingIn);
	bool BIsZooming() const;
	void UpdateControls();
private:

	void SOChangeEvent();
	void CreateClickCircle();

	CDraggableScrollingPanel* m_pZoomPanel;
	CSoloPathsPanel* m_pPathsPanel;
	CSoloNodeViewPanel* m_pQuestMapNodeView;
	CUtlMap< uint32, EditablePanel* > m_mapRegionLinkPanels;
	CUtlMap< uint32, CSoloNodePanel* >	m_mapNodePanels;
	ImagePanel* m_pBGImage;
	Panel* m_pDimmer = NULL;
	float m_flLastClickTime;
	float m_flClickScale;

	CPanelAnimationVar(float, m_flZoomScale, "zoom_scale", "1.1");
	CPanelAnimationVar(float, m_flZoomX, "zoom_x", "0.5");
	CPanelAnimationVar(float, m_flZoomY, "zoom_y", "0.5");
	float m_flZoomStartTime;
	float m_flZoomTime;
	bool m_bTurningIn = false;
};

