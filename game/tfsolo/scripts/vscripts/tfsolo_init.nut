printl("[TFSOLO] Init")
::TFSOLO <- 1

local TFSOLO_EventTag = UniqueString()
getroottable()[TFSOLO_EventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
	
	OnGameEvent_player_spawn = function(params)
	{
	}
	
	OnGameEvent_post_inventory_application = function(params)
	{
	}

	OnGameEvent_player_team = function(params)
	{
	}

	OnGameEvent_player_death = function(params)
	{
	}
}
__CollectGameEventCallbacks(TFSOLO_EventTag)

::SoloTestArmoryFlag <- function()
{
	SendGlobalGameEvent("solo_armory_flag", {
		flag = "ArmoryTest",
		count = 5,
		setflag = true,
	})
}
::SoloTestCampaignFlag <- function()
{
	SendGlobalGameEvent("solo_campaign_flag", {
		campaign = "campaigntest",
		flag = "CampaignFlagTest",
		count = 5,
		setflag = true,
	})
}
::SoloTestBotPresetFlag <- function()
{
	SendGlobalGameEvent("solo_botpreset_flag", {
		preset = "testpreset",
		flag = "BotPresetFlagTest",
		count = 5,
		setflag = true,
	})
}
::SoloTestGenericFlag <- function()
{
	SendGlobalGameEvent("solo_generic_flag", {
		flag = "GenericTestFlag",
		count = 5,
		setflag = true,
	})
}
::SoloTestSave <- function()
{
	Entities.FindByClassname(null,"tf_gamerules").AcceptInput("SoloSaveData","",null,null)
}