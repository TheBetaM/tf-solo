TFSOLO.Screens <- {}
TFSOLO.Screens.Active <- null

TFSOLO.Screens.EventTag <- UniqueString()
getroottable()[TFSOLO.Screens.EventTag] <- {
	OnScriptHook_solopanel_command = function(params)
	{
		if (params.command == "solopanel_opened")
		{
			if (TFSOLO.Screens.Active == null)
			{
				printl("Spawning VGUI")
				if (!IsInGame())
				{
					SendToConsole("stopsound")
				}
				TFSOLO.Screens.WorldMapSelect.Enter()
			}
		}
	}
}
TFSOLO.Screens.EventTable <- getroottable()[TFSOLO.Screens.EventTag]
__CollectGameEventCallbacks(TFSOLO.Screens.EventTable)

TFSOLO.Screen <- class
{
	Name = "BaseScreen"
	
	constructor()
    { 

    }
	
	function Enter()
	{
		if (TFSOLO.Screens.Active != null)
		{
			TFSOLO.Screens.Active.Exit()
		}
		SoloPanel.ClearAllScriptPanels()
		TFSOLO.Screens.Active = this
		OnEnter()
	}
	function OnEnter()
	{
		
	}
	function Exit()
	{
		SoloPanel.SetDrawGrid(false)
		SoloPanel.SetDrawActiveCircle(false)
		SoloPanel.ClearNodePaths()
		SoloPanel.HideMainTooltip()
		OnExit()
	}
	function OnExit()
	{
	}
	function _tostring() return this.Name
}

IncludeScript("client/solo/vgui/screens/test.nut")
IncludeScript("client/solo/vgui/screens/teamselect.nut")
IncludeScript("client/solo/vgui/screens/cutscene.nut")
IncludeScript("client/solo/vgui/screens/mapselect.nut")
IncludeScript("client/solo/vgui/screens/tc_teamselect.nut")
IncludeScript("client/solo/vgui/screens/worldmapselect.nut")
