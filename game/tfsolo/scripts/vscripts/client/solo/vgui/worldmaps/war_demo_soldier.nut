TFSOLO.WorldMaps.WarDemoSoldierClass <- class extends TFSOLO.WorldMap
{
	Name = "WAR!"
	ActiveNode = -1
	constructor() { 
		Nodes = []
		SelectedNode = null
		ActiveNode = -1
		
		local Node1 = TFSOLO.WorldMapNode("Lumberyard","cyoa/cyoa_icon_soldier",null)
		local Node2 = TFSOLO.WorldMapNode("Sawmill","cyoa/cyoa_icon_soldier",null)
		local Node3 = TFSOLO.WorldMapNode("Gorge","cyoa/cyoa_icon_soldier",null)
		
		local Node4 = TFSOLO.WorldMapNode("Doublecross","cyoa/cyoa_icon_demoman",null)
		local Node5 = TFSOLO.WorldMapNode("Nucleus","cyoa/cyoa_icon_demoman",null)
		local Node6 = TFSOLO.WorldMapNode("Pipeline","cyoa/cyoa_icon_demoman",null)
		
		local Node7 = TFSOLO.WorldMapNode("VI Day","cyoa/cyoa_classchoice_icon",null)
		
		Node1.PosX = "cs-0.5-100"
		Node1.PosY = "cs-0.5-100"
		Node2.PosX = "cs-0.5-100"
		Node2.PosY = "cs-0.5"
		Node3.PosX = "cs-0.5-100"
		Node3.PosY = "cs-0.5+100"
		
		Node4.PosX = "cs-0.5+100"
		Node4.PosY = "cs-0.5-100"
		Node5.PosX = "cs-0.5+100"
		Node5.PosY = "cs-0.5"
		Node6.PosX = "cs-0.5+100"
		Node6.PosY = "cs-0.5+100"
		
		Node7.PosX = "cs-0.5"
		Node7.PosY = "cs-0.5+100"
		
		Node1.StateTeam = 3
		Node2.StateTeam = 3
		Node3.StateTeam = 3
		Node4.StateTeam = 2
		Node5.StateTeam = 2
		Node6.StateTeam = 2
		
		Node1.Settings = {
			Map = "arena_lumberyard"
			PlayerClass = "soldier"
			TeamSelected = 1
			MissionScript = "solo/mission/wardemosoldier/soldier1.nut"
		}
		Node2.Settings = {
			Map = "koth_sawmill"
			PlayerClass = "soldier"
			TeamSelected = 1
			MissionScript = "solo/mission/wardemosoldier/soldier2.nut"
		}
		Node3.Settings = {
			Map = "cp_gorge"
			PlayerClass = "soldier"
			TeamSelected = 1
			MissionScript = "solo/mission/wardemosoldier/soldier3.nut"
		}
		
		Node4.Settings = {
			Map = "ctf_doublecross"
			PlayerClass = "demoman"
			TeamSelected = 0
			MissionScript = "solo/mission/wardemosoldier/demo1.nut"
		}
		Node5.Settings = {
			Map = "koth_nucleus"
			PlayerClass = "demoman"
			TeamSelected = 0
			MissionScript = "solo/mission/wardemosoldier/demo2.nut"
		}
		Node6.Settings = {
			Map = "plr_pipeline"
			PlayerClass = "demoman"
			TeamSelected = 0
			MissionScript = "solo/mission/wardemosoldier/demo3.nut"
		}
		
		Node7.Settings = {
			Map = "koth_viaduct"
			PlayerClass = "soldier"
			TeamSelected = 1
			MissionScript = "solo/mission/wardemosoldier/finale.nut"
		}
		
		Nodes.push(Node1)
		Nodes.push(Node2)
		Nodes.push(Node3)
		Nodes.push(Node4)
		Nodes.push(Node5)
		Nodes.push(Node6)
		Nodes.push(Node7)
	}
	
	function OnLoadSave()
	{
		local savekv = Solo.GetSaveData()
		local solokv = savekv.GetKey("Solo", true)
		local mttkv = solokv.GetKey("wardemosoldier", true)
		foreach (i, a in Nodes)
		{
			if (mttkv.FindKey("node"+i) != null)
			{
				a.StateCompletionState = 1
			}
		}
	}
	
	function OnEnter()
	{
		SoloPanel.SetDrawGrid(true)
		
		if (ActiveNode != -1)
		{
			Nodes[ActiveNode].SetActiveCircle()
		}
	}
	
	function OnNodeSelect(id)
	{
		if (id >= 0 && Nodes[id].StateLocked == 0 && id != ActiveNode)
		{
			Nodes[id].SetActiveCircle()
			ActiveNode = id
			Nodes[id].Select()
		}
	}
	
	function OnBackButton()
	{
		TFSOLO.WorldMaps.Active = null
		TFSOLO.PlayTransitionScreenEffects()
		TFSOLO.Screens.WorldMapSelect.Enter()
	}
	
	function OnMapExit()
	{
		if (TFSOLO.WorldMaps.ActiveNode == null) return
		if (TFSOLO.WorldMaps.ActiveNode.WorldMap != this) return
		if (ActiveNode < 0) return
		
		local Node = Nodes[ActiveNode]
		local WonGame = (TFSOLO.WorldMaps.LastWinner == Node.Settings.TeamSelected + 2)
		if (WonGame)
		{
			Node.StateCompletionState = 1
			Node.StateCompletionSegments = 1
			Node.Update()
			
			local savekv = Solo.GetSaveData()
			local solokv = savekv.GetKey("Solo", true)
			local mttkv = solokv.GetKey("wardemosoldier", true)
			local mapkv = mttkv.GetKey("node"+ActiveNode, true)
			mapkv.SetInt("state", Node.StateCompletionState)
			TFSOLO.SavePersistentData()
		}
		
		ActiveNode = -1
		SoloPanel.SetDrawActiveCircle(false)
	}
}
TFSOLO.WorldMaps.WarDemoSoldier <- TFSOLO.WorldMaps.WarDemoSoldierClass()
TFSOLO.WorldMaps.ProgressTracking.push(TFSOLO.WorldMaps.WarDemoSoldier)