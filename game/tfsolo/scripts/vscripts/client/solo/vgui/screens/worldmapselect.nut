TFSOLO.Screens.WorldMapSelect <- class extends TFSOLO.Screen
{
	Name = "WorldMapSelect"
	constructor() { }
	
	function OnEnter()
	{
		local kv_button1 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton1",
			xpos =			"cs-0.5",
			ypos =			"cs-0.5-100",//"cs-0.5-150",
			zpos =			"10",
			wide =			"300",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"Territory Control",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_tc",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		kv_button1["default"] <- "1"
		SoloPanel.CreatePanelRoot(kv_button1)
		
		local kv_button2 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton2",
			xpos =			"cs-0.5",
			ypos =			"cs-0.5-150",//"cs-0.5-100",
			zpos =			"10",
			wide =			"150",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"Meet The Team",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_mtt",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		SoloPanel.CreatePanelRoot(kv_button2)
		
		local kv_button3 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton3",
			xpos =			"cs-0.5",
			ypos =			"cs-0.5-50",
			zpos =			"10",
			wide =			"150",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"WAR!",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_war",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		//SoloPanel.CreatePanelRoot(kv_button3)
		
		local kv_button4 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton4",
			xpos =			"cs-0.5",
			ypos =			"cs-0.5",
			zpos =			"10",
			wide =			"150",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"Invasion",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_invasion",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		//SoloPanel.CreatePanelRoot(kv_button4)
		
		local kv_button5 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton5",
			xpos =			"cs-0.5",
			ypos =			"cs-0.5+50",
			zpos =			"10",
			wide =			"150",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"Expiration Date",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_bread",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		//SoloPanel.CreatePanelRoot(kv_button5)
		
		local kv_button6 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton6",
			xpos =			"cs-0.5",
			ypos =			"cs-0.5+100",
			zpos =			"10",
			wide =			"300",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"Terrifying Control",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_tc_hallow",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		SoloPanel.CreatePanelRoot(kv_button6)
		
		local kv_button7 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton7",
			xpos =			"cs-0.5",
			ypos =			"cs-0.5+150",
			zpos =			"10",
			wide =			"300",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"Smissmas Control",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_tc_xmas",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		SoloPanel.CreatePanelRoot(kv_button7)
		
		
		local kv_text1 = {
			ControlName		="Label"
			fieldName		="DescLabel1"
			xpos			="cs-0.5"
			ypos			="cs-0.5-80"//"cs-0.5-130"
			wide			="500"
			tall			="20"
			autoResize		="0"
			pinCorner		="0"
			visible			="1"
			enabled			="1"
			tabPosition		="0"
			labeltext		="The never-ending battle for control."
			font			="QuestLargeText"
			textAlignment	="center"
			dulltext		="0"
			brighttext		="0"
			proportionaltoparent ="1"
			paintbackground		 ="0"
		}
		SoloPanel.CreatePanelRoot(kv_text1)
		
		local kv_text2 = {
			ControlName		="Label"
			fieldName		="DescLabel2"
			xpos			="cs-0.5"
			ypos			="cs-0.5+120"
			wide			="500"
			tall			="20"
			autoResize		="0"
			pinCorner		="0"
			visible			="1"
			enabled			="1"
			tabPosition		="0"
			labeltext		="The never-ending scream for help."
			font			="QuestLargeText"
			textAlignment	="center"
			dulltext		="0"
			brighttext		="0"
			proportionaltoparent ="1"
			paintbackground		 ="0"
		}
		SoloPanel.CreatePanelRoot(kv_text2)
		
		local kv_text3 = {
			ControlName		="Label"
			fieldName		="DescLabel3"
			xpos			="cs-0.5"
			ypos			="cs-0.5+170"
			wide			="500"
			tall			="20"
			autoResize		="0"
			pinCorner		="0"
			visible			="1"
			enabled			="1"
			tabPosition		="0"
			labeltext		="The never-ending gift that keeps on giving."
			font			="QuestLargeText"
			textAlignment	="center"
			dulltext		="0"
			brighttext		="0"
			proportionaltoparent ="1"
			paintbackground		 ="0"
		}
		SoloPanel.CreatePanelRoot(kv_text3)
		
		local kv_text4 = {
			ControlName		="Label"
			fieldName		="DescLabel4"
			xpos			="cs-0.5"
			ypos			="cs-0.5-30"
			wide			="500"
			tall			="20"
			autoResize		="0"
			pinCorner		="0"
			visible			="1"
			enabled			="1"
			tabPosition		="0"
			labeltext		="The Demoman versus The Soldier"
			font			="QuestLargeText"
			textAlignment	="center"
			dulltext		="0"
			brighttext		="0"
			proportionaltoparent ="1"
			paintbackground		 ="0"
		}
		//SoloPanel.CreatePanelRoot(kv_text4)
		
	}
}

TFSOLO.WorldMapSelectEventTag <- UniqueString()
getroottable()[TFSOLO.WorldMapSelectEventTag] <- {
	OnScriptHook_solopanel_command = function(params)
	{
		if (TFSOLO.Screens.Active != TFSOLO.Screens.WorldMapSelect) return;
		if (params.command == "map_tc")
		{
			TFSOLO.PlayTransitionScreenEffects()
			TFSOLO.Screens.TC_TeamSelect.Enter()
		}
		else if (params.command == "map_mtt")
		{
			TFSOLO.PlayTransitionScreenEffects()
			TFSOLO.WorldMaps.MTT.Enter()
		}
		else if (params.command == "map_war")
		{
			TFSOLO.PlayTransitionScreenEffects()
			//TFSOLO.WorldMaps.War.Enter()
		}
		else if (params.command == "map_invasion")
		{
			TFSOLO.PlayTransitionScreenEffects()
			//TFSOLO.WorldMaps.Invasion.Enter()
		}
		else if (params.command == "map_bread")
		{
			TFSOLO.PlayTransitionScreenEffects()
			//TFSOLO.WorldMaps.Bread.Enter()
		}
		else if (params.command == "map_tc_hallow")
		{
			TFSOLO.PlayTransitionScreenEffects()
			TFSOLO.Screens.TC_Hallow_TeamSelect.Enter()
		}
		else if (params.command == "map_tc_xmas")
		{
			TFSOLO.PlayTransitionScreenEffects()
			TFSOLO.Screens.TC_Xmas_TeamSelect.Enter()
		}
	}
}
TFSOLO.WorldMapSelectEventTable <- getroottable()[TFSOLO.WorldMapSelectEventTag]
__CollectGameEventCallbacks(TFSOLO.WorldMapSelectEventTable)