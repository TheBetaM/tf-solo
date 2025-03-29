TFSOLO.Screens.TeamSelect <- class extends TFSOLO.Screen
{
	Name = "TeamSelect"
	constructor() { }
	
	function OnEnter()
	{
		local kv = {
			ControlName =	"CExImageButton",
			fieldName =		"TeamRedButton",
			xpos =			"cs-0.5-150",
			ypos =			"cs-0.5",
			zpos =			"10",
			wide =			"110",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"RED",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"teamselect_red",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		kv["default"] <- "1"
		SoloPanel.CreatePanelRoot(kv)
		
		local kv2 = {
			ControlName =	"CExImageButton",
			fieldName =		"TeamBlueButton",
			xpos =			"cs-0.5+150",
			ypos =			"cs-0.5",
			zpos =			"10",
			wide =			"110",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"BLU",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"teamselect_blue",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		kv2["default"] <- "0"
		SoloPanel.CreatePanelRoot(kv2)
		
		local kv3 = {
			ControlName	="Label"
			fieldName		="Title"
			xpos			="cs-0.5"
			ypos			="50"
			wide			="300"
			tall			="14"
			autoResize	="0"
			pinCorner		="0"
			visible		="1"
			enabled		="1"
			tabPosition	="0"
			labeltext		="Select Your Team"
			font			="QuestLargeText"
			textAlignment	="center"
			dulltext		="0"
			brighttext	="0"
			proportionaltoparent ="1"
			paintbackground		="0"
		}
		kv3["default"] <- "0"
		SoloPanel.CreatePanelRoot(kv3)
	}
}

TFSOLO.TeamSelectEventTag <- UniqueString()
getroottable()[TFSOLO.TeamSelectEventTag] <- {
	OnScriptHook_solopanel_command = function(params)
	{
		if (TFSOLO.Screens.Active != TFSOLO.Screens.TeamSelect) return;
		if (params.command == "teamselect_blue")
		{
			TFSOLO.PlayerData.TeamSelected = 1
			TFSOLO.PlayTransitionScreenEffects()
			TFSOLO.WorldMaps.Test.Enter()
		}
		else if (params.command == "teamselect_red")
		{
			TFSOLO.PlayerData.TeamSelected = 0
			TFSOLO.PlayTransitionScreenEffects()
			TFSOLO.WorldMaps.Test.Enter()
		}
	}
}
TFSOLO.TeamSelectEventTable <- getroottable()[TFSOLO.TeamSelectEventTag]
__CollectGameEventCallbacks(TFSOLO.TeamSelectEventTable)