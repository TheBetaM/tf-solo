TFSOLO.WorldMaps.TCClass <- class extends TFSOLO.WorldMap
{
	Name = "TC Map"
	MapGenerated = 0
	BackgroundPanel = null
	ActiveNode = -1
	CounterMap = null
	MapTeam = 0
	PlayerClassNames = [
		"civilian",
		"scout",
		"sniper",
		"soldier",
		"demoman",
		"medic",
		"heavyweapons",
		"pyro",
		"spy",
		"engineer",
		"civilian"
	]
	
	constructor() { 
		Name = "TC Map"
		MapGenerated = 0
		
		Nodes = []
		SelectedNode = null
		ActiveNode = -1
		CounterMap = null
	}
	
	function Reset()
	{
		MapGenerated = 0
		ActiveNode = -1
	}
	
	function OnMapExit()
	{
		if (TFSOLO.WorldMaps.ActiveNode == null) return
		if (TFSOLO.WorldMaps.ActiveNode.WorldMap != this) return
		if (ActiveNode < 0) return
		
		local Node = Nodes[ActiveNode]
		local WonGame = (TFSOLO.WorldMaps.LastWinner == MapTeam)
		Node.StateLocked = 1
		Node.StateTeam = TFSOLO.WorldMaps.LastWinner
		Node.StateCompletionState = 1
		Node.StateCompletionSegments = 1
		Node.Update()
		
		local MapName = Node.Settings.Map
		local savekv = Solo.GetSaveData()
		local solokv = savekv.GetKey("Solo", true)
		local tckv = solokv.GetKey("tc", true)
		local mapkv = tckv.GetKey(MapName, true)
		mapkv.SetInt("team", TFSOLO.WorldMaps.LastWinner)
		TFSOLO.SavePersistentData()
		
		ActiveNode = -1
		SoloPanel.SetDrawActiveCircle(false)
		
		local DoneCount = 0
		foreach (a in Nodes)
		{
			if (a.StateLocked == 1)
			{
				DoneCount++
			}
		}
		if (DoneCount > Nodes.len() / 2)
		{
			Reset()
			TFSOLO.WorldMaps.Active = null
			TFSOLO.PlayTransitionScreenEffects()
			TFSOLO.Screens.TC_TeamSelect.Enter()
		}
	}
	
	function CheckMapTags(TagsKey, Tags)
	{
		local pass = 0
		foreach (a in Tags)
		{
			if (TagsKey.FindKey(a) != null)
			{
				pass++
			}
		}
		if (pass == Tags.len())
		{
			return true
		}
		return false
	}
	function CheckAnyMapTags(TagsKey, Tags)
	{
		local pass = 0
		foreach (a in Tags)
		{
			if (TagsKey.FindKey(a) != null)
			{
				return true
			}
		}
		return false
	}
	
	function GenerateNode(Node, MapKey, tckv, MapFile)
	{
		Node.Name = MapKey.GetString("name")
		Node.Tooltip = LocalizeString(MapKey.GetString("modename"))
		
		// Settings
		local TagsKey = MapKey.GetKey("tags", true)
		Node.Settings.Map <- MapFile
		Node.Settings.TeamSelected <- 0
		if (MapTeam == 3)
		{
			Node.Settings.TeamSelected <- 1
		}
		Node.Settings.PlayerClass <- "any"
		Node.Settings.GameMode <- "standard"
		Node.Settings.MapMode <- "standard"
		Node.Settings.BotMode <- "standard"
		
		if (RandomInt(0,4) == 0)
		{
			local GameModes = []
			
			if ( CheckMapTags(TagsKey, ["cp_count","symm"]) && !CheckAnyMapTags(TagsKey, ["koth","arena_pd"]) )
			{
				GameModes.push("koth")
			}
			if ( CheckMapTags(TagsKey, ["cp_count","symm"]) && !CheckAnyMapTags(TagsKey, ["arena","arena_pd"]) )
			{
				GameModes.push("arena")
			}
			
			if (GameModes.len() != 0)
			{
				local pos = RandomInt(0, GameModes.len() - 1)
				local mode = GameModes[pos]
				local AllowClassLock = true
				Node.Settings.GameMode <- mode
				
				if (mode == "koth")
				{
					Node.Tooltip = LocalizeString("#Gametype_Koth")
				}
				else if (mode == "arena")
				{
					Node.Tooltip = LocalizeString("#Gametype_Arena")
				}
				
				if (AllowClassLock && RandomInt(0,20) == 0)
				{
					Node.Settings.PlayerClass <- PlayerClassNames[RandomInt(1,9)]
				}
				
				Node.Name = Node.Name + "*"
			}
		}
		else
		{
			if (RandomInt(0,20) == 0)
			{
				Node.Settings.PlayerClass <- PlayerClassNames[RandomInt(1,9)]
			}
		}
		if (RandomInt(0,100) == 0 && !CheckAnyMapTags(TagsKey, ["mdv"]))
		{
			Node.Settings.Medieval <- 1
			Node.Tooltip = LocalizeString("#GameType_Medieval") + " " + Node.Tooltip
			Node.Name = Node.Name + "*"
		}
		
		// Progression
		if (tckv.FindKey(MapFile) != null)
		{
			local mapkv = tckv.FindKey(MapFile)
			Node.StateTeam = mapkv.GetInt("team")
			Node.StateCompletionState = 1
			Node.StateCompletionSegments = 1
		}
		
		// Visuals
		if (Node.Settings.PlayerClass != "any")
		{
			Node.Icon = "cyoa/cyoa_icon_" + Node.Settings.PlayerClass
			if (Node.Settings.PlayerClass == "heavyweapons")
			{
				Node.Icon = "cyoa/cyoa_icon_heavy"
			}
		}
		else
		{
			Node.Icon = "cyoa/cyoa_classchoice_icon"
		}
		
	}
	
	function GenerateMap()
	{
		local savekv = Solo.GetSaveData()
		local solokv = savekv.GetKey("Solo", true)
		local tckv = solokv.GetKey("tc", true)
	
		Nodes.clear()
		
		local NodeCount = RandomInt(12,15)
		local MapPoolFull = TFSOLO.ValidMaps.slice()
		local MapPool = []
		if (CounterMap != null && CounterMap.MapGenerated != 0)
		{
			for (local i = 0; i < CounterMap.Nodes.len(); i++)
			{
				if (MapPoolFull.find(CounterMap.Nodes[i].Settings.Map))
				{
					MapPoolFull.remove(MapPoolFull.find(CounterMap.Nodes[i].Settings.Map))
				}
			}
		}
		for (local i = 0; i < MapPoolFull.len() - 1; i++)
		{
			local MapKey = TFSOLO.GetMapEntry(MapPoolFull[i])
			local TagsKey = MapKey.GetKey("tags", true)
			if (TagsKey.FindKey("theme_hallow") != null)
			{
				MapPoolFull.remove(i)
				i--
			}
			else if (TagsKey.FindKey("theme_xmas") != null)
			{
				MapPoolFull.remove(i)
				i--
			}
			else if (TagsKey.FindKey("theme_invasion") != null)
			{
				MapPoolFull.remove(i)
				i--
			}
			else if (TagsKey.FindKey("theme_bread") != null)
			{
				MapPoolFull.remove(i)
				i--
			}
			else if (TagsKey.FindKey("mvm") != null)
			{
				MapPoolFull.remove(i)
				i--
			}
			else if (TagsKey.FindKey("vsh") != null)
			{
				MapPoolFull.remove(i)
				i--
			}
			else if (TagsKey.GetInt("stages") > 1)
			{
				MapPoolFull.remove(i)
				i--
			}
		}
		for (local i = 0; i < NodeCount; i++)
		{
			local randpos = RandomInt(0, MapPoolFull.len() - 1)
			MapPool.push(MapPoolFull[randpos])
			MapPoolFull.remove(randpos)
		}
		MapPoolFull.clear()
		
		local xoffset = -150
		local yoffset = -100
		for (local i = 0; i < NodeCount; i++)
		{
			local MapKey = TFSOLO.GetMapEntry(MapPool[i])
			local Node = TFSOLO.WorldMapNode("Node","",null)
			GenerateNode(Node, MapKey, tckv, MapPool[i])
			
			if (xoffset > 0)
			{
				Node.PosX = "cs-0.5+" + xoffset
			}
			else if (xoffset < 0)
			{
				Node.PosX = "cs-0.5" + xoffset
			}
			if (yoffset > 0)
			{
				Node.PosY = "cs-0.5+" + yoffset
			}
			else if (yoffset < 0)
			{
				Node.PosY = "cs-0.5" + yoffset
			}
			xoffset += 75
			if (xoffset > 150)
			{
				yoffset += 100
				xoffset = -150
			}
			
			Nodes.push(Node)
		}
		
		MapGenerated = 1
		TFSOLO.Screens.Active.GenerateNodes()
	}
	
	function OnNodeSelect(id)
	{
		if (id >= 0 && Nodes[id].StateLocked == 0 && id != ActiveNode)
		{
			Nodes[id].SetActiveCircle()
			ActiveNode = id
			if (CounterMap != null)
			{
				CounterMap.ActiveNode = -1
			}
			Nodes[id].Select()
		}
	}
	
	function OnEnter()
	{
		if (MapGenerated == 0)
		{
			GenerateMap()
		}
		
		local bgcolorval = "HUDRedTeam"
		if (TFSOLO.PlayerData.TeamSelected == 1)
		{
			bgcolorval = "HUDBlueTeam"
		}
		
		local kvBackgroundPanel = {
			ControlName=	"ImagePanel"
			fieldName=		"WorldMapBackgroundImage"
			xpos=			"cs-0.5"
			ypos=			"cs-0.5"
			zpos=			"0"
			wide=			"350"
			tall=			"o1"
			visible=		"1"
			enabled=		"1"
			scaleImage=		"1"
			image=			"cyoa/cyoa_bg_icon_globe"
			proportionaltoparent=	"1"
			mouseinputenabled=	"0"
			keyboardinputenabled= "0"
			drawcolor=		bgcolorval
		}
		SoloPanel.CreatePanelRoot(kvBackgroundPanel)
		SoloPanel.SetDrawGrid(true)
		
		if (ActiveNode != -1)
		{
			Nodes[ActiveNode].SetActiveCircle()
		}
		
	}
}
TFSOLO.WorldMaps.TC_RED <- TFSOLO.WorldMaps.TCClass()
TFSOLO.WorldMaps.TC_BLU <- TFSOLO.WorldMaps.TCClass()
TFSOLO.WorldMaps.TC_RED.CounterMap = TFSOLO.WorldMaps.TC_BLU
TFSOLO.WorldMaps.TC_RED.Name = "RED Control"
TFSOLO.WorldMaps.TC_RED.MapTeam = 2
TFSOLO.WorldMaps.TC_BLU.CounterMap = TFSOLO.WorldMaps.TC_RED
TFSOLO.WorldMaps.TC_BLU.Name = "BLU Control"
TFSOLO.WorldMaps.TC_BLU.MapTeam = 3


