TFSOLO.WorldMaps.MTTClass <- class extends TFSOLO.WorldMap
{
	Name = "Meet The Team"
	ActiveNode = -1
	constructor() { 
		Nodes = []
		SelectedNode = null
		ActiveNode = -1
		
		local Node1 = TFSOLO.WorldMapNode("Scout","cyoa/cyoa_icon_scout",TFSOLO.Cutscenes.MTT_Scout)
		local Node2 = TFSOLO.WorldMapNode("Soldier","cyoa/cyoa_icon_soldier",TFSOLO.Cutscenes.MTT_Soldier)
		local Node3 = TFSOLO.WorldMapNode("Pyro","cyoa/cyoa_icon_pyro",TFSOLO.Cutscenes.MTT_Pyro)
		local Node4 = TFSOLO.WorldMapNode("Demoman","cyoa/cyoa_icon_demoman",TFSOLO.Cutscenes.MTT_Demoman)
		local Node5 = TFSOLO.WorldMapNode("Heavy","cyoa/cyoa_icon_heavy",TFSOLO.Cutscenes.MTT_Heavy)
		local Node6 = TFSOLO.WorldMapNode("Engineer","cyoa/cyoa_icon_engineer",TFSOLO.Cutscenes.MTT_Engineer)
		local Node7 = TFSOLO.WorldMapNode("Medic","cyoa/cyoa_icon_medic",TFSOLO.Cutscenes.MTT_Medic)
		local Node8 = TFSOLO.WorldMapNode("Sniper","cyoa/cyoa_icon_sniper",TFSOLO.Cutscenes.MTT_Sniper)
		local Node9 = TFSOLO.WorldMapNode("Spy","cyoa/cyoa_icon_spy",TFSOLO.Cutscenes.MTT_Spy)
		
		Node1.PosX = "cs-0.5-100"
		Node1.PosY = "cs-0.5-100"
		Node2.PosX = "cs-0.5"
		Node2.PosY = "cs-0.5-100"
		Node3.PosX = "cs-0.5+100"
		Node3.PosY = "cs-0.5-100"
		Node4.PosX = "cs-0.5-100"
		Node4.PosY = "cs-0.5"
		Node5.PosX = "cs-0.5"
		Node5.PosY = "cs-0.5"
		Node6.PosX = "cs-0.5+100"
		Node6.PosY = "cs-0.5"
		Node7.PosX = "cs-0.5-100"
		Node7.PosY = "cs-0.5+100"
		Node8.PosX = "cs-0.5"
		Node8.PosY = "cs-0.5+100"
		Node9.PosX = "cs-0.5+100"
		Node9.PosY = "cs-0.5+100"
		
		Node1.Settings = {
			Map = "cp_well"
			PlayerClass = "scout"
			TeamSelected = 1
			MissionScript = "solo/mission/mtt/scout.nut"
			CvarGamemodeOverride = 3
		}
		Node2.Settings = {
			Map = "cp_granary"
			PlayerClass = "soldier"
			TeamSelected = 0
			MissionScript = "solo/mission/mtt/soldier.nut"
		}
		Node3.Settings = {
			Map = "plr_pipeline"
			PlayerClass = "pyro"
			TeamSelected = 0
			MissionScript = "solo/mission/mtt/pyro.nut"
		}
		Node4.Settings = {
			Map = "cp_gravelpit"
			PlayerClass = "demoman"
			TeamSelected = 1
			MissionScript = "solo/mission/mtt/demoman.nut"
		}
		Node5.Settings = {
			Map = "cp_dustbowl"
			PlayerClass = "heavyweapons"
			TeamSelected = 0
			MissionScript = "solo/mission/mtt/heavy.nut"
		}
		Node6.Settings = {
			Map = "tc_hydro"
			PlayerClass = "engineer"
			TeamSelected = 0
			MissionScript = "solo/mission/mtt/engineer.nut"
		}
		Node7.Settings = {
			Map = "koth_viaduct"
			PlayerClass = "medic"
			TeamSelected = 0
			MissionScript = "solo/mission/mtt/medic.nut"
			CvarGamemodeOverride = 2
		}
		Node8.Settings = {
			Map = "pl_goldrush"
			PlayerClass = "sniper"
			TeamSelected = 0
			MissionScript = "solo/mission/mtt/sniper.nut"
		}
		Node9.Settings = {
			Map = "ctf_2fort"
			PlayerClass = "spy"
			TeamSelected = 1
			MissionScript = "solo/mission/mtt/spy.nut"
		}
		
		Nodes.push(Node1)
		//Nodes.push(Node2)
		//Nodes.push(Node3)
		//Nodes.push(Node4)
		//Nodes.push(Node5)
		//Nodes.push(Node6)
		//Nodes.push(Node7)
		//Nodes.push(Node8)
		//Nodes.push(Node9)
	}
	
	function OnLoadSave()
	{
		local savekv = Solo.GetSaveData()
		local solokv = savekv.GetKey("Solo", true)
		local mttkv = solokv.GetKey("mtt", true)
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
		
		local IsComplete = true
		foreach (a in Nodes)
		{
			if (a.StateCompletionState < 1)
			{
				IsComplete = false
			}
		}
		if (IsComplete)
		{
			AwardAchievement(160, 1) // TFSOLO_SOLO_MTT_COMPLETE
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
			local mttkv = solokv.GetKey("mtt", true)
			local mapkv = mttkv.GetKey("node"+ActiveNode, true)
			mapkv.SetInt("state", Node.StateCompletionState)
			TFSOLO.SavePersistentData()
		}
		
		ActiveNode = -1
		SoloPanel.SetDrawActiveCircle(false)
		
		local IsComplete = true
		foreach (a in Nodes)
		{
			if (a.StateCompletionState < 1)
			{
				IsComplete = false
			}
		}
		if (IsComplete)
		{
			AwardAchievement(160, 1) // TFSOLO_SOLO_MTT_COMPLETE
		}
	}
}
TFSOLO.WorldMaps.MTT <- TFSOLO.WorldMaps.MTTClass()
TFSOLO.WorldMaps.ProgressTracking.push(TFSOLO.WorldMaps.MTT)