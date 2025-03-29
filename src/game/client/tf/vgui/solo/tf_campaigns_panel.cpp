//========= Copyright Valve Corporation, All rights reserved. ============//
//
// Purpose:
//
//=============================================================================//

#include "cbase.h"
#include "tf_campaigns_panel.h"
#include "tf_item_inventory.h"

#include "vgui_controls/ProgressBar.h"
#include "vgui_controls/AnimationController.h"
#include "vgui_controls/cvartogglecheckbutton.h"
#include "vgui_controls/ComboBox.h"

#include "tf_gc_client.h"
#include "tf_partyclient.h"

#include "clientmode_tf.h"

#include "tf_matchmaking_shared.h"
#include "tf_matchmaking_dashboard.h"

#define TFSOLO_CAMPAIGNS_CONFIG "cfg/solo/campaigns.txt"



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

	virtual void ApplySchemeSettings(IScheme* pScheme) OVERRIDE
	{
		BaseClass::ApplySchemeSettings(pScheme);

		LoadControlSettings("resource/ui/MatchMakingCampaignsPanelSingle.res");

		const char* cName = "";
		const char* cDesc;
		CUtlString cProgress;
		const char* cMap = "";
		bool cShowProgress = false;
		const char* cProgressKey = "";
		const char* cBGArt = "";
		if (m_Config)
		{
			cName = m_Config->GetString("Name");
			cDesc = m_Config->GetString("Desc");
			cMap = m_Config->GetString("Map");
			cShowProgress = m_Config->GetBool("ShowProgress");
			cProgressKey = m_Config->GetString("ProgressKey");
			cBGArt = m_Config->GetString("BGArt");
			if (cShowProgress)
			{
				auto saveKV = TFInventoryManager()->GetSaveData();
				int progVal = 0;
				auto campaignsKV = saveKV->FindKey("Campaigns", true);
				auto campKV = campaignsKV->FindKey(m_Config->GetName(), true);
				if (campKV->GetInt(cProgressKey) != 0)
				{
					progVal = campKV->GetInt(cProgressKey);
				}
				cProgress.Append(CFmtStr("%d", progVal));
				cProgress.Append("%");
			}
		}

		EditablePanel* pTopContainer = FindControl< EditablePanel >("TopContainer", true);
		if (pTopContainer)
		{
			// Set our dialog variables
			auto tCheck = g_pVGuiLocalize->FindIndex(cName);
			if (tCheck == INVALID_STRING_INDEX)
			{
				pTopContainer->SetDialogVariable("title_token", cName);
			}
			else
			{
				pTopContainer->SetDialogVariable("title_token", cName);
				//pTopContainer->SetDialogVariable("title_token", g_pVGuiLocalize->Find(cName));
			}
			tCheck = g_pVGuiLocalize->FindIndex(cDesc);
			if (tCheck == INVALID_STRING_INDEX)
			{
				pTopContainer->SetDialogVariable("desc_token", cDesc);
			}
			else
			{
				pTopContainer->SetDialogVariable("desc_token", cDesc);
				//pTopContainer->SetDialogVariable("desc_token", g_pVGuiLocalize->Find(cDesc));
			}
			pTopContainer->SetDialogVariable("prog_token", cProgress);
		}

		ImagePanel* pImagePanel = FindControl< ImagePanel >("BGImage", true);
		if (pImagePanel && cBGArt != "")
		{
			pImagePanel->SetImage(cBGArt);
		}

		EditablePanel* pMapsContainer = FindControl< EditablePanel >("MapsContainer", true);

		if (pMapsContainer)
		{
			int nYPos = 16;

			pMapsContainer->SetTall(nYPos + 10);
			pMapsContainer->SetAutoResize(PIN_BOTTOMRIGHT, Panel::AUTORESIZE_NO, 0, 0, 0, 0);

			// We want to be able to expand to this height
			m_nExpandedHeight = nYPos + m_nCollapsedHeight;
		}

		// Snag the button for later
		pToggleButton = FindControl< CExImageButton >("PlayButton", true);
	}

	virtual void OnToggleCollapse(bool bIsExpanded) OVERRIDE
	{
		if (bIsExpanded)
		{
			PostActionSignal(new KeyValues("CategoryExpanded", "category", m_eCategory));
		}

		BaseClass::OnToggleCollapse(bIsExpanded);
	}

	virtual void OnCommand(const char* command) OVERRIDE
	{
		if (FStrEq(command, "playcampaign"))
		{
			if (!m_Config)
			{
				return;
			}
			const char* cMap = m_Config->GetString("Map");

			// reset server enforced cvars
			g_pCVar->RevertFlaggedConVars(FCVAR_REPLICATED);
			g_pCVar->RevertFlaggedConVars(FCVAR_CHEAT);

			//ConVarRef sv_use_steam_netorwking("sv_use_steam_netorwking");
			//sv_use_steam_netorwking.SetValue(0);

			// create the command to execute
			CFmtStr1024 fmtMapCommand(
				"disconnect\nwait\nwait\nmaxplayers 32\n\nprogress_enable\nmap %s\n", cMap
			);
			engine->ClientCmd_Unrestricted(fmtMapCommand.Access());
			GetDashboardPanel().GetTypedPanel< CMatchMakingDashboardSidePanel >(k_eCampaigns)->SetVisible(false);
			GetMMDashboard()->OnCommand("dimmer_hide");

			return;
		}

		BaseClass::OnCommand(command);
	}

	virtual void PerformLayout() OVERRIDE
	{
		BaseClass::PerformLayout();

		SetControlVisible("EntryToggleButtonCollapsed", !BIsExpanded(), true);
		SetControlVisible("EntryToggleButtonExpanded", BIsExpanded(), true);
	}

	void SetCheckButtonState(uint32 nMapDefIndex, bool bSelected, bool bClickable)
	{

	}

private:
	const char* m_eCategory;
	CExImageButton* pToggleButton;
	Panel* m_pSignalHandler;
	KeyValues* m_Config;
};



Panel* GetDashboardCampaignsPanel()
{
	// Force to 12v12.  It's got the most players
	CTFCampaignsPanel* pPanel = new CTFCampaignsPanel(NULL, "CampaignsPanel", k_eTFMatchGroup_Casual_12v12);
	pPanel->AddActionSignalTarget(GetMMDashboard());
	return pPanel;
}

REGISTER_FUNC_FOR_DASHBOARD_PANEL_TYPE(GetDashboardCampaignsPanel, k_eCampaigns);


CTFCampaignsPanel::CTFCampaignsPanel(Panel* pPanel, const char* pszName, ETFMatchGroup eMatchGroup)
	: CMatchMakingDashboardSidePanel(pPanel, pszName, "resource/ui/MatchMakingCampaignsPanel.res", k_eSideLeft),
	m_eMatchGroup(eMatchGroup)
{
	SetProportional(true);

	m_pInviteModeComboBox = new ComboBox(this, "InviteModeComboBox", 3, false);
	m_pInviteModeComboBox->AddItem("#TF_MM_InviteMode_Open", new KeyValues(NULL, "mode", CTFPartyClient::k_ePartyJoinRequestMode_OpenToFriends));
	m_pInviteModeComboBox->AddItem("#TF_MM_InviteMode_Invite", new KeyValues(NULL, "mode", CTFPartyClient::k_ePartyJoinRequestMode_FriendsCanRequestToJoin));
	m_pInviteModeComboBox->AddItem("#TF_MM_InviteMode_Closed", new KeyValues(NULL, "mode", CTFPartyClient::k_ePartyJoinRequestMode_ClosedToFriends));
	m_pInviteModeComboBox->SilentActivateItemByRow(GTFPartyClient()->GetPartyJoinRequestMode());
	m_pInviteModeComboBox->SetEditable(false);

	ListenForGameEvent("ping_updated");
	ListenForGameEvent("mmstats_updated");
	ListenForGameEvent("party_pref_changed");
}


CTFCampaignsPanel::~CTFCampaignsPanel()
{
	CleanupCampaignsPanels();
	//if (m_CampaignsConfig)
	//{
	//	m_CampaignsConfig->deleteThis();
	//	m_CampaignsConfig = NULL;
	//}
}


//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFCampaignsPanel::ApplySchemeSettings(IScheme* pScheme)
{
	m_mapCategoryPanels.Purge();

	BaseClass::ApplySchemeSettings(pScheme);

	m_pIgnoreInvitesCheckBox = FindControl< CvarToggleCheckButton<UIConVarRef> >("IgnorePartyInvites", true);

	RegenerateCampaignsPanels();
}

//-----------------------------------------------------------------------------
void CTFCampaignsPanel::RegenerateCampaignsPanels()
{
	CleanupCampaignsPanels();

	//if (m_CampaignsConfig)
	//{
		//m_CampaignsConfig->deleteThis();
		//m_CampaignsConfig = NULL;
	//}

	m_CampaignsConfig = new KeyValues("campaigns");
	if (!m_CampaignsConfig->LoadFromFile(g_pFullFileSystem, TFSOLO_CAMPAIGNS_CONFIG, "GAME"))
	{
		Msg("Unable to parse campaigns.txt into keyvalues.\n");
		return;
	}

	CScrollableList* pScrollableList = FindControl< CScrollableList >("DataCenterList", true);

	// Category items.
	FOR_EACH_SUBKEY(m_CampaignsConfig, camKey)
	{
		if (V_strcmp(camKey->GetName(), "version"))
		{
			CTFCampaignsPanelSingle* pListEntry = NULL;
			pListEntry = new CTFCampaignsPanelSingle(pScrollableList, "CampaignSinglePanel", camKey->GetName(), this, camKey);
			pListEntry->AddActionSignalTarget(this);
			pListEntry->MakeReadyForUse();
			pScrollableList->AddPanel(pListEntry, 5);
			pListEntry->InvalidateLayout();
		}
	}

	InvalidateLayout();
}


//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFCampaignsPanel::PerformLayout()
{
	BaseClass::PerformLayout();

	FOR_EACH_VEC(m_vecDataCenterPingPanels, i)
	{
		const PingPanelInfo& info = m_vecDataCenterPingPanels[i];
		int iTall = info.m_pPanel->GetTall();
		int iYGap = i > 0 ? m_iDataCenterYSpace : 0;
		int iXPos = info.m_pPanel->GetXPos();
		info.m_pPanel->SetPos(iXPos, m_iDataCenterY + iYGap + i * iTall);

		// Update bars with latest health data
		ProgressBar* pProgress = info.m_pPanel->FindControl< ProgressBar >("HealthProgressBar", true);
		if (pProgress)
		{
			auto healthData = GTFGCClientSystem()->GetHealthBracketForRatio(info.m_flPopulationRatio);

			pProgress->MakeReadyForUse();
			pProgress->SetProgress(healthData.m_flRatio);
			pProgress->SetFgColor(healthData.m_colorBar);
		}
	}

	UpdateCurrentCampaigns();
}


//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFCampaignsPanel::OnCommand(const char* command)
{
	if (FStrEq(command, "close"))
	{
		MarkForDeletion();
		return;
	}

	BaseClass::OnCommand(command);
}

//-----------------------------------------------------------------------------
void CTFCampaignsPanel::OnThink()
{
	BaseClass::OnThink();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFCampaignsPanel::FireGameEvent(IGameEvent* event)
{
	const char* pszEventName = event->GetName();
	if (FStrEq(pszEventName, "ping_updated") || FStrEq(pszEventName, "mmstats_updated"))
	{
		
	}
}


//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFCampaignsPanel::CleanupCampaignsPanels()
{
	FOR_EACH_VEC(m_vecDataCenterPingPanels, i)
	{
		m_vecDataCenterPingPanels[i].m_pPanel->MarkForDeletion();
	}

	m_vecDataCenterPingPanels.Purge();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFCampaignsPanel::OnTextChanged(vgui::Panel* panel)
{
	if (panel == m_pInviteModeComboBox)
	{
		using EPartyJoinRequestMode = CTFPartyClient::EPartyJoinRequestMode;
		EPartyJoinRequestMode eMode = (EPartyJoinRequestMode)m_pInviteModeComboBox->GetActiveItemUserData()->GetInt("mode");
		GTFPartyClient()->SetPartyJoinRequestMode(eMode);
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFCampaignsPanel::OnCheckButtonChecked(vgui::Panel* panel)
{
	if (m_pIgnoreInvitesCheckBox == panel)
		m_pIgnoreInvitesCheckBox->ApplyChanges();
	if (m_pSteamNetworkingCheckBox == panel)
		m_pSteamNetworkingCheckBox->ApplyChanges();
}


//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFCampaignsPanel::OnSliderMoved()
{

}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFCampaignsPanel::UpdateCurrentCampaigns()
{
	
}