TFSOLO.WorldMaps <- {}
TFSOLO.WorldMaps.Active <- null
TFSOLO.WorldMaps.ActiveNode <- null
TFSOLO.WorldMaps.Ingame <- false
TFSOLO.WorldMaps.LastWinner <- 0

TFSOLO.WorldMapNode <- class
{
	Name = "Base Node"
	Icon = ""
	PosX = "cs-0.5"
	PosY = "cs-0.5"
	Tooltip = ""
	Cutscene = null
	Panel = null
	WorldMap = null
	ID = 0
	
	StateLocked = 0
	StateCreditsType = 0
	StateStarCount = 0
	StateHasItem = 0
	StateCompletionState = 0
	StateCompletionSegments = 1
	StateTeam = 0
	
	Map = ""
	PlayerClass = "any"
	
	function Select()
	{
		if (Cutscene != null)
		{
			Cutscene.Enter()
		}
		else
		{
			OnSelect()
		}
	}
	function OnSelect()
	{
		if (StateLocked != 0)
			return
		if (Map.find("workshop_") == null)
		{
			TFSOLO.PlayerData.Map = Map
		}
		else
		{
			TFSOLO.PlayerData.Map = "workshop/" + Map.slice(9)
		}
		TFSOLO.PlayerData.PlayerClass = PlayerClass
		
		TFSOLO.WorldMaps.Ingame = true
		TFSOLO.WorldMaps.ActiveNode = this
		TFSOLO.StartMission()
	}
	function SetActiveCircle()
	{
		local PosX = Panel.GetXPos()
		local PosY = Panel.GetYPos()
		local SizeX = Panel.GetWide()
		local SizeY = Panel.GetTall()
		PosX += SizeX / 2.0
		PosY += (SizeY / 2.0) - 46
		SoloPanel.SetActiveCirclePos(PosX, PosY)
	}
	function Update()
	{
		local kvNode = {
			ControlName		="CSoloNodePanel"
			xpos			=PosX
			ypos			=PosY
			iconName		=Icon
			nodeText		=Name
			nodeID			=ID
			tooltipText		=Tooltip
			isLocked		=StateLocked
			hasCredits		=StateCreditsType
			hasStarCount	=StateStarCount
			hasItem			=StateHasItem
			completionState	=StateCompletionState
			completionSegments =StateCompletionSegments
			nodeTeam 		=StateTeam
		}
		SoloPanel.ApplyPanelSettings(Panel, kvNode)
	}
	function OnMapExit()
	{
		
	}
	
	constructor(aname, amap, aicon, acts) { 
		Name = aname
		Map = amap
		Icon = aicon
		Cutscene = acts
		PosX = "cs-0.5"
		PosY = "cs-0.5"
		Tooltip = ""
		Panel = null
		WorldMap = null
		PlayerClass = "any"
		ID = 0
		StateLocked = 0
		StateCreditsType = 0
		StateStarCount = 0
		StateHasItem = 0
		StateCompletionState = 0
		StateCompletionSegments = 1
	}
	function _tostring() return this.Name
}

TFSOLO.WorldMap <- class
{
	function Enter()
	{
		TFSOLO.WorldMaps.Active = this
		TFSOLO.Screens.MapSelect.Enter()
		SelectedNode = null
		OnEnter()
	}
	function OnEnter()
	{
		
	}
	
	function NodeSelect(id)
	{
		if (SelectedNode == Nodes[id]) return
		SelectedNode = Nodes[id]
		OnNodeSelect(id)
	}
	function OnNodeSelect(id)
	{
		
	}
	
	function OnMapExit()
	{
		
	}
	
	Name = "Base World Map"
	Nodes = []
	SelectedNode = null
	
	constructor() {
		Name = "Base World Map"
		Nodes = []
		SelectedNode = null
	}
	function _tostring() return this.Name
}

IncludeScript("client/solo/vgui/worldmaps/test.nut")
IncludeScript("client/solo/vgui/worldmaps/tc_worldmap.nut")


TFSOLO.WorldMapEventTag <- UniqueString()
getroottable()[TFSOLO.WorldMapEventTag] <- {
	OnScriptHook_LevelShutdownPostEntity = function(params)
	{
		if (TFSOLO.WorldMaps.Ingame)
		{
			SoloPanel.ForceOpen()
			if (TFSOLO.WorldMaps.ActiveNode != null)
			{
				TFSOLO.WorldMaps.ActiveNode.OnMapExit()
				if (TFSOLO.WorldMaps.ActiveNode.WorldMap != null)
				{
					if (TFSOLO.WorldMaps.ActiveNode.WorldMap != TFSOLO.WorldMaps.Active)
					{
						TFSOLO.WorldMaps.ActiveNode.WorldMap.Enter()
					}
					TFSOLO.WorldMaps.ActiveNode.WorldMap.OnMapExit()
				}
			}
		}
		TFSOLO.WorldMaps.ActiveNode = null
		TFSOLO.WorldMaps.LastWinner = 0
		TFSOLO.WorldMaps.Ingame = false
	}
	
	OnGameEvent_teamplay_round_win = function(params)
	{
		TFSOLO.WorldMaps.LastWinner = params.team
	}
}
TFSOLO.WorldMapEventTable <- getroottable()[TFSOLO.WorldMapEventTag]
__CollectGameEventCallbacks(TFSOLO.WorldMapEventTable)
