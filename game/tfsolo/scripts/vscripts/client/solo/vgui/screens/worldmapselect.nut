TFSOLO.Screens.WorldMapSelect <- class extends TFSOLO.Screen
{
	Name = "WorldMapSelect"
	constructor() { }
	
	function OnEnter()
	{
		local kv_listpanel = {
			ControlName=		"CPanelListPanel"
			fieldName=		"PanelListPanel"
			xpos=		"0"
			ypos=		"0"
			wide=		"f0"
			tall=		"f60"
			autoResize=		"0"
			pinCorner=		"0"
			visible=		"1"
			enabled=		"1"
			tabPosition=		"0"
			bgcolor_override=	"0 0 0 0"
		}
		//local listPanel = SoloPanel.CreatePanelRoot(kv_listpanel)
	
		local kv_button2 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton2",
			xpos =			"cs-0.5-100",
			ypos =			"cs-0.5-150",
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
		local button_mtt = SoloPanel.CreatePanelRoot(kv_button2)
		
		local kv_button3 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton3",
			xpos =			"cs-0.5+100",
			ypos =			"cs-0.5-150",
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
		local button_war1 = SoloPanel.CreatePanelRoot(kv_button3)
		SoloPanel.SetTooltip(button_war1, "The Demoman versus The Soldier")
		
		local kv_button4 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton4",
			xpos =			"cs-0.5-100",
			ypos =			"cs-0.5-120",
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
		local button_invasion = SoloPanel.CreatePanelRoot(kv_button4)
		
		local kv_button5 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton5",
			xpos =			"cs-0.5+100",
			ypos =			"cs-0.5-120",
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
		local button_bread = SoloPanel.CreatePanelRoot(kv_button5)
		
		local kv_button_hallow = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton5",
			xpos =			"cs-0.5-100",
			ypos =			"cs-0.5-90",
			zpos =			"10",
			wide =			"150",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"Scream Fortress",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_hallow",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		local button_hallow = SoloPanel.CreatePanelRoot(kv_button_hallow)
		
		local kv_button_xmas = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton5",
			xpos =			"cs-0.5+100",
			ypos =			"cs-0.5-90",
			zpos =			"10",
			wide =			"150",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"Smissmas",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_xmas",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		local button_xmas = SoloPanel.CreatePanelRoot(kv_button_xmas)
		
		local kv_button_mvm = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton5",
			xpos =			"cs-0.5-100",
			ypos =			"cs-0.5-60",
			zpos =			"10",
			wide =			"150",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"Mann vs. Machine",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_mvm",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		local button_mvm = SoloPanel.CreatePanelRoot(kv_button_mvm)
		
		local kv_button_comp = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton5",
			xpos =			"cs-0.5+100",
			ypos =			"cs-0.5-60",
			zpos =			"10",
			wide =			"150",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"Meet Your Match",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_comp",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		local button_comp = SoloPanel.CreatePanelRoot(kv_button_comp)
		
		
		
		local kv_button1 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton1",
			xpos =			"cs-0.5-110",
			ypos =			"cs-0.5+150",
			zpos =			"10",
			wide =			"200",
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
		local button_TC = SoloPanel.CreatePanelRoot(kv_button1)
		SoloPanel.SetTooltip(button_TC, "The never-ending battle for control.")
		
		local kv_button6 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton6",
			xpos =			"cs-0.5+110",
			ypos =			"cs-0.5+150",
			zpos =			"10",
			wide =			"200",
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
		local button_tc_hallow = SoloPanel.CreatePanelRoot(kv_button6)
		SoloPanel.SetTooltip(button_tc_hallow, "The never-ending scream for help.")
		
		local kv_button7 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton7",
			xpos =			"cs-0.5-110",
			ypos =			"cs-0.5+180",
			zpos =			"10",
			wide =			"200",
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
		local button_tc_xmas = SoloPanel.CreatePanelRoot(kv_button7)
		SoloPanel.SetTooltip(button_tc_xmas, "The never-ending gift that keeps on giving.")
		
		local kv_button8 = {
			ControlName =	"CExImageButton",
			fieldName =		"MapButton7",
			xpos =			"cs-0.5+110",
			ypos =			"cs-0.5+180",
			zpos =			"10",
			wide =			"200",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"Terabyte Control",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_tc_mvm",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		local button_tc_mvm = SoloPanel.CreatePanelRoot(kv_button8)
		SoloPanel.SetTooltip(button_tc_mvm, "The never-ending robot siege.")
		
		button_war1.SetEnabled(false)
		SoloPanel.SetTooltip(button_war1, "Coming soon!")
		button_invasion.SetEnabled(false)
		SoloPanel.SetTooltip(button_invasion, "Coming soon!")
		button_bread.SetEnabled(false)
		SoloPanel.SetTooltip(button_bread, "Coming soon!")
		button_hallow.SetEnabled(false)
		SoloPanel.SetTooltip(button_hallow, "Coming soon!")
		button_xmas.SetEnabled(false)
		SoloPanel.SetTooltip(button_xmas, "Coming soon!")
		button_comp.SetEnabled(false)
		SoloPanel.SetTooltip(button_comp, "Coming soon!")
		button_mvm.SetEnabled(false)
		SoloPanel.SetTooltip(button_mvm, "Coming soon!")
		button_tc_mvm.SetEnabled(false)
		SoloPanel.SetTooltip(button_tc_mvm, "Coming soon!")
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
			TFSOLO.WorldMaps.WarDemoSoldier.Enter()
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
		else if (params.command == "map_comp")
		{
			TFSOLO.PlayTransitionScreenEffects()
			//TFSOLO.WorldMaps.Bread.Enter()
		}
		else if (params.command == "map_mvm")
		{
			TFSOLO.PlayTransitionScreenEffects()
			//TFSOLO.WorldMaps.Bread.Enter()
		}
		else if (params.command == "map_hallow")
		{
			TFSOLO.PlayTransitionScreenEffects()
			//TFSOLO.WorldMaps.Bread.Enter()
		}
		else if (params.command == "map_xmas")
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
		else if (params.command == "map_tc_mvm")
		{
			TFSOLO.PlayTransitionScreenEffects()
			TFSOLO.Screens.TC_MVM_TeamSelect.Enter()
		}
	}
}
TFSOLO.WorldMapSelectEventTable <- getroottable()[TFSOLO.WorldMapSelectEventTag]
__CollectGameEventCallbacks(TFSOLO.WorldMapSelectEventTable)