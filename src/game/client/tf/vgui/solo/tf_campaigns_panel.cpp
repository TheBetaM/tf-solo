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

void CTFCampaignsPanelSingle::ApplySchemeSettings(IScheme* pScheme)
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

void CTFCampaignsPanelSingle::OnToggleCollapse(bool bIsExpanded)
{
	if (bIsExpanded)
	{
		PostActionSignal(new KeyValues("CategoryExpanded", "category", m_eCategory));
	}

	BaseClass::OnToggleCollapse(bIsExpanded);
}

void CTFCampaignsPanelSingle::OnCommand(const char* command)
{
	if (FStrEq(command, "playcampaign"))
	{
		if (!m_Config)
		{
			return;
		}
		const char* cMap = m_Config->GetString("Map");
		const char* cLoadingImage = m_Config->GetString("LoadingImage");

		// reset server enforced cvars
		g_pCVar->RevertFlaggedConVars(FCVAR_REPLICATED);
		g_pCVar->RevertFlaggedConVars(FCVAR_CHEAT);

		ConVarRef tf_gamemode_campaign("tf_gamemode_campaign");
		tf_gamemode_campaign.SetValue(1);
		engine->ClientCmd_Unrestricted("nav_generate_auto 1\n");
		engine->ClientCmd_Unrestricted("nav_generate_auto_view_distance 2500\n");
		engine->ClientCmd_Unrestricted("cl_loadingimage_force 1\n");
		ConVarRef cl_loadingimage_override("cl_loadingimage_override");
		if ( cLoadingImage && cLoadingImage[0] )
		{
			cl_loadingimage_override.SetValue( cLoadingImage );
		}
		else
		{
			int screenWide, screenTall;
			surface()->GetScreenSize(screenWide, screenTall);
			float aspectRatio = (float)screenWide / (float)screenTall;
			bool bIsWidescreen = aspectRatio >= 1.5999f;
			if ( bIsWidescreen )
			{
				cl_loadingimage_override.SetValue( "../console/title_team_tough_break_widescreen" );
			}
			else
			{
				cl_loadingimage_override.SetValue( "../console/title_team_tough_break" );
			}
		}

		// create the command to execute
		CFmtStr1024 fmtMapCommand(
			"disconnect\nwait\nwait\nmaxplayers 33\n\nprogress_enable\nmap %s\n", cMap
		);
		engine->ClientCmd_Unrestricted(fmtMapCommand.Access());
		GetDashboardPanel().GetTypedPanel< CMatchMakingDashboardSidePanel >(k_eCampaigns)->SetVisible(false);
		GetMMDashboard()->OnCommand("dimmer_hide");

		return;
	}

	BaseClass::OnCommand(command);
}

void CTFCampaignsPanelSingle::PerformLayout()
{
	BaseClass::PerformLayout();

	SetControlVisible("EntryToggleButtonCollapsed", !BIsExpanded(), true);
	SetControlVisible("EntryToggleButtonExpanded", BIsExpanded(), true);
}

void CTFCampaignsPanelSingle::SetCheckButtonState(uint32 nMapDefIndex, bool bSelected, bool bClickable)
{

}

void CTFCampaignsPanelSingle::UpdateProgress()
{
	if (m_Config)
	{
		CUtlString cProgress;
		bool cShowProgress = false;
		const char* cProgressKey = "";
		cShowProgress = m_Config->GetBool("ShowProgress");
		cProgressKey = m_Config->GetString("ProgressKey");
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

			EditablePanel* pTopContainer = FindControl< EditablePanel >("TopContainer", true);
			if (pTopContainer)
			{
				pTopContainer->SetDialogVariable("prog_token", cProgress);
			}
		}
	}
}


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
		CTFCampaignsPanelSingle* pListEntry = NULL;
		pListEntry = new CTFCampaignsPanelSingle(pScrollableList, "CampaignSinglePanel", camKey->GetName(), this, camKey);
		pListEntry->AddActionSignalTarget(this);
		pListEntry->MakeReadyForUse();
		pScrollableList->AddPanel(pListEntry, 5);
		pListEntry->InvalidateLayout();
		m_vecCampaignPanels.AddToTail(pListEntry);
	}

	InvalidateLayout();
}


//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CTFCampaignsPanel::PerformLayout()
{
	BaseClass::PerformLayout();

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
	FOR_EACH_VEC(m_vecCampaignPanels, i)
	{
		m_vecCampaignPanels[i]->MarkForDeletion();
	}

	m_vecCampaignPanels.Purge();
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
	FOR_EACH_VEC(m_vecCampaignPanels, i)
	{
		auto pPanel = m_vecCampaignPanels[i];
		pPanel->UpdateProgress();
	}
}