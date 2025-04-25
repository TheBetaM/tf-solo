TFSOLO.WorldMaps.TCClass <- class extends TFSOLO.WorldMap
{
	Name = "TC Map"
	MapGenerated = 0
	BackgroundPanel = null
	ActiveNode = -1
	CounterMap = null
	MapTeam = 0
	
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
		
		local MapName = Node.Map
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
	
	function GenerateMap()
	{
		local savekv = Solo.GetSaveData()
		local solokv = savekv.GetKey("Solo", true)
		local tckv = solokv.GetKey("tc", true)
	
		Nodes.clear()
		
		local NodeCount = RandomInt(9,15)
		local MapPoolFull = TFSOLO.ValidMaps.slice()
		local MapPool = []
		if (CounterMap != null && CounterMap.MapGenerated != 0)
		{
			for (local i = 0; i < CounterMap.Nodes.len(); i++)
			{
				if (MapPoolFull.find(CounterMap.Nodes[i].Map))
				{
					MapPoolFull.remove(MapPoolFull.find(CounterMap.Nodes[i].Map))
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
			local Node = TFSOLO.WorldMapNode(MapKey.GetString("name"),MapPool[i],"",null)
			
			Node.Tooltip = LocalizeString(MapKey.GetString("modename"))
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
			
			if (tckv.FindKey(Node.Map) != null)
			{
				local mapkv = tckv.FindKey(Node.Map)
				Node.StateTeam = mapkv.GetInt("team")
				Node.StateCompletionState = 1
				Node.StateCompletionSegments = 1
			}
			
			if (RandomInt(1,10) == 1)
			{
				local pick = RandomInt(1,9)
				switch (pick)
				{
					case 1:
					{
						Node.Icon = "cyoa/cyoa_icon_scout"
						Node.PlayerClass = "scout"
						break;
					}
					case 2:
					{
						Node.Icon = "cyoa/cyoa_icon_soldier"
						Node.PlayerClass = "soldier"
						break;
					}
					case 3:
					{
						Node.Icon = "cyoa/cyoa_icon_pyro"
						Node.PlayerClass = "pyro"
						break;
					}
					case 4:
					{
						Node.Icon = "cyoa/cyoa_icon_demoman"
						Node.PlayerClass = "demoman"
						break;
					}
					case 5:
					{
						Node.Icon = "cyoa/cyoa_icon_heavy"
						Node.PlayerClass = "heavyweapons"
						break;
					}
					case 6:
					{
						Node.Icon = "cyoa/cyoa_icon_engineer"
						Node.PlayerClass = "engineer"
						break;
					}
					case 7:
					{
						Node.Icon = "cyoa/cyoa_icon_medic"
						Node.PlayerClass = "medic"
						break;
					}
					case 8:
					{
						Node.Icon = "cyoa/cyoa_icon_sniper"
						Node.PlayerClass = "sniper"
						break;
					}
					case 9:
					{
						Node.Icon = "cyoa/cyoa_icon_spy"
						Node.PlayerClass = "spy"
						break;
					}
					default:
					{
						Node.Icon = "cyoa/cyoa_classchoice_icon"
						break;
					}
				}
				
			}
			else
			{
				Node.Icon = "cyoa/cyoa_classchoice_icon"
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


