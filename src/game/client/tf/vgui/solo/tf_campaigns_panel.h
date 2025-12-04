#ifndef TF_CAMPAIGNS_PANEL_H
#define TF_CAMPAIGNS_PANEL_H
#ifdef _WIN32
#pragma once
#endif

#include <vgui_controls/EditablePanel.h>
#include "tf_matchmaking_dashboard_side_panel.h"
#include <../common/GameUI/cvarslider.h>

using namespace vgui;

class CTFCampaignsPanelSingle : public CExpandablePanel
{
	DECLARE_CLASS_SIMPLE(CTFCampaignsPanelSingle, CExpandablePanel);

public:
	CTFCampaignsPanelSingle(Panel* parent, const char* panelName, const char* eCategory, Panel* pSignalHandler, KeyValues* config)
		: BaseClass(parent, panelName)
		, m_eCategory(eCategory)
		, pToggleButton(NULL)
		, m_pSignalHandler(pSignalHandler)
		, m_Config(config)
	{}

	~CTFCampaignsPanelSingle()
	{
	}

	virtual void ApplySchemeSettings(IScheme* pScheme) OVERRIDE;
	virtual void OnToggleCollapse(bool bIsExpanded) OVERRIDE;
	virtual void OnCommand(const char* command) OVERRIDE;
	virtual void PerformLayout() OVERRIDE;
	void SetCheckButtonState(uint32 nMapDefIndex, bool bSelected, bool bClickable);
	void UpdateProgress();

private:
	const char* m_eCategory;
	CExImageButton* pToggleButton;
	Panel* m_pSignalHandler;
	KeyValues* m_Config;
};


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

	CvarToggleCheckButton<UIConVarRef>* m_pIgnoreInvitesCheckBox = NULL;
	CvarToggleCheckButton<UIConVarRef>* m_pSteamNetworkingCheckBox = NULL;

	KeyValues* m_CampaignsConfig;
	CUtlMap< int, Panel* > m_mapCategoryPanels;

	CUtlVector< CTFCampaignsPanelSingle* > m_vecCampaignPanels;

	ETFMatchGroup m_eMatchGroup;
};

#endif // TF_CAMPAIGNS_PANEL_H
