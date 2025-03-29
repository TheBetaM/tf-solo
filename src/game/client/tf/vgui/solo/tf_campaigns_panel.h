#ifndef TF_CAMPAIGNS_PANEL_H
#define TF_CAMPAIGNS_PANEL_H
#ifdef _WIN32
#pragma once
#endif

#include <vgui_controls/EditablePanel.h>
#include "tf_matchmaking_dashboard_side_panel.h"
#include <../common/GameUI/cvarslider.h>

using namespace vgui;

class CTFCampaignsPanel : public CMatchMakingDashboardSidePanel, public CGameEventListener
{
	DECLARE_CLASS_SIMPLE(CTFCampaignsPanel, CMatchMakingDashboardSidePanel)
public:
	CTFCampaignsPanel(Panel* pPanel, const char* pszName, ETFMatchGroup eMatchGroup);
	~CTFCampaignsPanel();

	virtual void ApplySchemeSettings(IScheme* pScheme) OVERRIDE;
	virtual void PerformLayout() OVERRIDE;
	virtual void OnCommand(const char* command) OVERRIDE;
	virtual void OnThink() OVERRIDE;

	virtual void FireGameEvent(IGameEvent* event) OVERRIDE;

private:
	void CleanupCampaignsPanels();
	void RegenerateCampaignsPanels();
	void UpdateCurrentCampaigns();

	MESSAGE_FUNC_PTR(OnTextChanged, "TextChanged", panel);
	MESSAGE_FUNC_PTR(OnCheckButtonChecked, "CheckButtonChecked", panel);
	MESSAGE_FUNC(OnSliderMoved, "SliderMoved");

	CPanelAnimationVarAliasType(int, m_iDataCenterY, "datacenter_y", "0", "proportional_int");
	CPanelAnimationVarAliasType(int, m_iDataCenterYSpace, "datacenter_y_space", "0", "proportional_int");

	ComboBox* m_pInviteModeComboBox = NULL;
	CvarToggleCheckButton<UIConVarRef>* m_pIgnoreInvitesCheckBox = NULL;
	CvarToggleCheckButton<UIConVarRef>* m_pSteamNetworkingCheckBox = NULL;

	KeyValues* m_CampaignsConfig;
	CUtlMap< int, Panel* > m_mapCategoryPanels;

	struct PingPanelInfo
	{
		EditablePanel* m_pPanel;
		float m_flPopulationRatio;
		int m_nPing;
	};
	CUtlVector< PingPanelInfo > m_vecDataCenterPingPanels;

	ETFMatchGroup m_eMatchGroup;
};

#endif // TF_CAMPAIGNS_PANEL_H
