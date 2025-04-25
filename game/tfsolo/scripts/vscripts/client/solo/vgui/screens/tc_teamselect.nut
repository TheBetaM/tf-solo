TFSOLO.Screens.TC_TeamSelect <- class extends TFSOLO.Screen
{
	Name = "TC_TeamSelect"
	constructor() { }
	
	function OnEnter()
	{
		local kv = {
			ControlName =	"CExImageButton",
			fieldName =		"TeamRedButton",
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
			labeltext		="Territorial Control"
			font			="QuestLargeText"
			textAlignment	="center"
			dulltext		="0"
			brighttext	="0"
			proportionaltoparent ="1"
			paintbackground		="0"
		}
		SoloPanel.CreatePanelRoot(kv3)
		
		local savekv = Solo.GetSaveData()
		local solokv = savekv.GetKey("Solo", true)
		local tckv = solokv.GetKey("tc", true)
		local MapPoolFull = TFSOLO.ValidMaps.slice()
		local MapCount = 0
		local MapCount_RED = 0
		local MapCount_BLU = 0
		local MapCount_NONE = 0
		
		for (local i = 0; i < MapPoolFull.len() - 1; i++)
		{
			local MapKey = TFSOLO.GetMapEntry(MapPoolFull[i])
			local TagsKey = MapKey.GetKey("tags", true)
			if (TagsKey.FindKey("theme_hallow") != null)
			{
			}
			else if (TagsKey.FindKey("theme_xmas") != null)
			{
			}
			else if (TagsKey.FindKey("theme_invasion") != null)
			{
			}
			else if (TagsKey.FindKey("theme_bread") != null)
			{
			}
			else if (TagsKey.FindKey("mvm") != null)
			{
			}
			else if (TagsKey.FindKey("vsh") != null)
			{
			}
			else if (TagsKey.GetInt("stages") > 1)
			{
			}
			else
			{
				MapCount++
				if (tckv.FindKey(MapPoolFull[i]) != null)
				{
					local mapkv = tckv.FindKey(MapPoolFull[i])
					local mapteam = mapkv.GetInt("team")
					if (mapteam == 2)
					{
						MapCount_RED++
					}
					else if (mapteam == 3)
					{
						MapCount_BLU++
					}
					else
					{
						MapCount_NONE++
					}
				}
				else
				{
					MapCount_NONE++
				}
			}
		}
		
		local ControlRED = MapCount_RED//(MapCount_RED / MapCount) * 100
		local ControlBLU = MapCount_BLU//(MapCount_BLU / MapCount) * 100
		local ControlNONE = MapCount_NONE//(MapCount_NONE / MapCount) * 100
		
		local kv4 = {
			ControlName	="Label"
			fieldName		="Title"
			xpos			="cs-0.5+150"
			ypos			="cs-0.5+25"
			wide			="300"
			tall			="14"
			autoResize	="0"
			pinCorner		="0"
			visible		="1"
			enabled		="1"
			tabPosition	="0"
			labeltext		="RED CONTROL: " + ControlRED// + "%"
			font			="QuestLargeText"
			textAlignment	="center"
			dulltext		="0"
			brighttext	="0"
			proportionaltoparent ="1"
			paintbackground		="0"
			fgcolor_override = "HUDRedTeam"
		}
		SoloPanel.CreatePanelRoot(kv4)
		
		local kv5 = {
			ControlName	="Label"
			fieldName		="Title"
			xpos			="cs-0.5-150"
			ypos			="cs-0.5+25"
			wide			="300"
			tall			="14"
			autoResize	="0"
			pinCorner		="0"
			visible		="1"
			enabled		="1"
			tabPosition	="0"
			labeltext		="BLU CONTROL: " + ControlBLU// + "%"
			font			="QuestLargeText"
			textAlignment	="center"
			dulltext		="0"
			brighttext	="0"
			proportionaltoparent ="1"
			paintbackground		="0"
			fgcolor_override = "HUDBlueTeam"
		}
		SoloPanel.CreatePanelRoot(kv5)
		
		local kv6 = {
			ControlName	="Label"
			fieldName		="Title"
			xpos			="cs-0.5"
			ypos			="cs-0.5-25"
			wide			="300"
			tall			="14"
			autoResize	="0"
			pinCorner		="0"
			visible		="1"
			enabled		="1"
			tabPosition	="0"
			labeltext		="UNCLAIMED: " + ControlNONE// + "%"
			font			="QuestLargeText"
			textAlignment	="center"
			dulltext		="0"
			brighttext	="0"
			proportionaltoparent ="1"
			paintbackground		="0"
			fgcolor_override = "QuestMap_ActiveOrange"
		}
		SoloPanel.CreatePanelRoot(kv6)
		
	}
}

TFSOLO.TC_TeamSelectEventTag <- UniqueString()
getroottable()[TFSOLO.TC_TeamSelectEventTag] <- {
	OnScriptHook_solopanel_command = function(params)
	{
		if (TFSOLO.Screens.Active != TFSOLO.Screens.TC_TeamSelect) return;
		if (params.command == "teamselect_blue")
		{
			TFSOLO.PlayerData.TeamSelected = 1
			TFSOLO.PlayTransitionScreenEffects()
			TFSOLO.WorldMaps.TC_BLU.Enter()
		}
		else if (params.command == "teamselect_red")
		{
			TFSOLO.PlayerData.TeamSelected = 0
			TFSOLO.PlayTransitionScreenEffects()
			TFSOLO.WorldMaps.TC_RED.Enter()
		}
	}
}
TFSOLO.TC_TeamSelectEventTable <- getroottable()[TFSOLO.TC_TeamSelectEventTag]
__CollectGameEventCallbacks(TFSOLO.TC_TeamSelectEventTable)