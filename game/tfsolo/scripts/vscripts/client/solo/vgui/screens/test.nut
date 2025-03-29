TFSOLO.Screens.Test <- class extends TFSOLO.Screen
{
	Name = "TestScreen"
	
	constructor()
    {
		
    }
	
	function OnEnter()
	{
		local kv = {
			ControlName =	"CExImageButton",
			fieldName =		"TestScreenButtonTest",
			xpos =			"cs-0.5",
			ypos =			"cs-0.5",
			zpos =			"10",
			wide =			"110",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"TEST",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"but_the_test",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		kv["default"] <- "1"
		local panel = SoloPanel.CreatePanelRoot(kv)
	}
	function OnExit()
	{
		
	}
}

TFSOLO.VguiTestEventTag <- UniqueString()
getroottable()[TFSOLO.VguiTestEventTag] <- {
	OnScriptHook_solopanel_command = function(params)
	{
		if (TFSOLO.Screens.Active != TFSOLO.Screens.Test) return;
		if (params.command == "but_the_test")
		{
			TFSOLO.PlayTransitionScreenEffects()
			//TFSOLO.Screens.TeamSelect.Enter()
			//TFSOLO.Cutscenes.Test.Enter()
			TFSOLO.WorldMaps.Test.Enter()
		}
	}
}
TFSOLO.VguiTestEventTable <- getroottable()[TFSOLO.VguiTestEventTag]
__CollectGameEventCallbacks(TFSOLO.VguiTestEventTable)
