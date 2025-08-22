TFSOLO.WorldMaps.TestClass <- class extends TFSOLO.WorldMap
{
	Name = "Test World Map"
	constructor() { 
		Nodes = []
		SelectedNode = null
		
		local Node1 = TFSOLO.WorldMapNode("Dustbowl","",null)
		local Node2 = TFSOLO.WorldMapNode("Viaduct","",TFSOLO.Cutscenes.Test)
		local Node3 = TFSOLO.WorldMapNode("Upward","",null)
		
		Node1.PosX = "cs-0.5-150"
		Node1.Icon = "cyoa/cyoa_icon_spy"
		Node1.Settings.PlayerClass <- "spy"
		Node1.Settings.Map <- "cp_dustbowl"
		
		Node2.Icon = "cyoa/cyoa_icon_scout"
		Node2.Settings.PlayerClass <- "scout"
		Node2.Settings.Map <- "koth_viaduct"
		Node2.Tooltip = "This one starts a cutscene."
		
		Node3.Icon = "cyoa/cyoa_icon_soldier"
		Node3.PosX = "cs-0.5+150"
		Node3.Settings.PlayerClass <- "soldier"
		Node3.Settings.Map <- "pl_upward"
		
		Nodes.push(Node1)
		Nodes.push(Node2)
		Nodes.push(Node3)
	}
	
	function OnEnter()
	{
		local kvRegionLink = {
			ControlName		="EditablePanel"
			fieldName		="Link"
			xpos			="cs-0.5-50"
			ypos			="cs-0.5+100"
			ControlSettings ="Resource/UI/quests/cyoa/QuestMapRegionLink.res"
		}
		local LinkPanel = SoloPanel.CreatePanelRoot(kvRegionLink)
		LinkPanel.SetDialogVariable("link_region_name", "Test Region Link")
		LinkPanel.SetDialogVariable("completed", "Completed: None so far")
		LinkPanel.SetDialogVariable("available", "Available: Also none")
		LinkPanel.SetControlVisible("ActiveLabel", false, true)
		local LinkButton = SoloPanel.FindPanel(LinkPanel, "LinkRegionNameButton")
		SoloPanel.AddActionSignalTargetForPanel(LinkButton)
		LinkButton.SetCommand("close")
		local nTall = LinkButton.GetTall()
		LinkButton.SizeToContents()
		LinkButton.SetTall(nTall)
		
		SoloPanel.SetDrawGrid(true)
		local PosX = Nodes[1].Panel.GetXPos()
		local PosY = Nodes[1].Panel.GetYPos()
		local SizeX = Nodes[1].Panel.GetWide()
		local SizeY = Nodes[1].Panel.GetTall()
		PosX += SizeX / 2.0
		PosY += (SizeY / 2.0) - 46
		SoloPanel.SetActiveCirclePos(PosX, PosY)
		
		local PosX1 = Nodes[0].Panel.GetXPos()
		local PosY1 = Nodes[0].Panel.GetYPos()
		local SizeX1 = Nodes[0].Panel.GetWide()
		local SizeY1 = Nodes[0].Panel.GetTall()
		local PosX2 = Nodes[1].Panel.GetXPos()
		local PosY2 = Nodes[1].Panel.GetYPos()
		local SizeX2 = Nodes[1].Panel.GetWide()
		local SizeY2 = Nodes[1].Panel.GetTall()
		local PosX3 = Nodes[2].Panel.GetXPos()
		local PosY3 = Nodes[2].Panel.GetYPos()
		local SizeX3 = Nodes[2].Panel.GetWide()
		local SizeY3 = Nodes[2].Panel.GetTall()
		PosX1 += SizeX1 / 2.0
		PosY1 += (SizeY1 / 2.0) - 46
		PosX2 += SizeX2 / 2.0
		PosY2 += (SizeY2 / 2.0) - 46
		PosX3 += SizeX3 / 2.0
		PosY3 += (SizeY3 / 2.0) - 46
		SoloPanel.AddNodePath(PosX2, PosY2, PosX1, PosY1, false, true, true)
		SoloPanel.AddNodePath(PosX2, PosY2, PosX3, PosY3, true, false, true)
		SoloPanel.AddNodePath(PosX2, PosY2, PosX2 - 160, PosY2 + 160, false, true, false)
	}
	
	function OnNodeSelect(id)
	{
		Nodes[id].Select()
	}
	
	function OnBackButton()
	{
		TFSOLO.WorldMaps.Active = null
		TFSOLO.PlayTransitionScreenEffects()
		TFSOLO.Screens.TC_TeamSelect.Enter()
	}
}
TFSOLO.WorldMaps.Test <- TFSOLO.WorldMaps.TestClass()