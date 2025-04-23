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
::SoloTestHudText <- function()
{
	SendGlobalGameEvent("solohud_string", {
		key = "objective1",
		value = "This is a test objective 0/100"
	})
}
::SoloTestHudText2 <- function()
{
	SendGlobalGameEvent("solohud_string", {
		key = "objective1",
		value = "This is a test objective 5/100"
	})
}

//SetSoloObjectivesResFile("Resource/UI/solo/mission_basic.res")