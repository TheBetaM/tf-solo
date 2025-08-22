TFSOLO.Screens.MapSelect <- class extends TFSOLO.Screen
{
	Name = "MapSelect"
	NodePanels = []
	constructor() {}
	
	function GenerateBackButton()
	{
		local kvBack = {
			ControlName =	"CExImageButton",
			fieldName =		"MapScreenButtonBack",
			xpos =			"cs-0.5-150",
			ypos =			"cs-0.5-150",
			zpos =			"16",
			wide =			"110",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"BACK",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"map_back",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		kvBack["default"] <- "1"
		SoloPanel.CreatePanelRoot(kvBack)
	}
	function GenerateNodes()
	{
		NodePanels.clear()
		foreach (i,node in TFSOLO.WorldMaps.Active.Nodes)
		{
			local kvNode = {
				ControlName		="CSoloNodePanel"
				xpos			=node.PosX
				ypos			=node.PosY
				iconName		=node.Icon
				nodeText		=node.Name
				nodeID			=i
				tooltipText		=node.Tooltip
				isLocked		=node.StateLocked
				hasCredits		=node.StateCreditsType
				hasStarCount	=node.StateStarCount
				hasItem			=node.StateHasItem
				completionState	=node.StateCompletionState
				completionSegments =node.StateCompletionSegments
				nodeTeam 		=node.StateTeam
			}
			local NodePanel = SoloPanel.CreatePanelRoot(kvNode)
			NodePanels.push(NodePanel)
			node.Panel = NodePanel
			node.ID = i
			node.WorldMap = TFSOLO.WorldMaps.Active
		}
	}
	function GenerateMapVisuals()
	{
		local kvTitle = {
			ControlName		="Label"
			fieldName		="Title"
			xpos			="cs-0.5"
			ypos			="50"
			wide			="300"
			tall			="20"
			autoResize		="0"
			pinCorner		="0"
			visible			="1"
			enabled			="1"
			tabPosition		="0"
			labeltext		=TFSOLO.WorldMaps.Active.Name
			font			="QuestLargeText"
			textAlignment	="center"
			dulltext		="0"
			brighttext		="0"
			proportionaltoparent ="1"
			paintbackground		="0"
		}
		kvTitle["default"] <- "0"
		SoloPanel.CreatePanelRoot(kvTitle)
	}
	
	function OnEnter()
	{
		if (TFSOLO.WorldMaps.Active == null)
		{
			printl("[TFSOLO] No world map active to show on the screen!")
			TFSOLO.Screens.TeamSelect.Enter()
			return
		}
		
		GenerateBackButton()
		GenerateNodes()
		GenerateMapVisuals()
		
	}
}

TFSOLO.VguiMapSelectEventTag <- UniqueString()
getroottable()[TFSOLO.VguiMapSelectEventTag] <- {
	OnScriptHook_solopanel_command = function(params)
	{
		if (TFSOLO.Screens.Active != TFSOLO.Screens.MapSelect) return;
		if (params.command == "map_back")
		{
			TFSOLO.WorldMaps.Active.OnBackButton()
		}
	}
	
	OnScriptHook_node_selected = function(params)
	{
		if (TFSOLO.Screens.Active != TFSOLO.Screens.MapSelect) return;
		TFSOLO.WorldMaps.Active.NodeSelect(params.nodeID)
	}
}
TFSOLO.VguiMapSelectEventTable <- getroottable()[TFSOLO.VguiMapSelectEventTag]
__CollectGameEventCallbacks(TFSOLO.VguiMapSelectEventTable)
