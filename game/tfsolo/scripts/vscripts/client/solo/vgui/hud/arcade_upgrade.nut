TFSOLO.HudScreens.ArcadeUpgrade <- class extends TFSOLO.HudScreen
{
	Name = "ArcadeUpgradeHUD"
	constructor() {}
	
	function OnEnter()
	{
		SendToConsole("pause")
		local holder = SoloHUD.FindPanelRoot("VictoryPanelNormal")
		holder.RequestFocus(0)
		holder.MakePopup(true,false)
		holder.MoveToFront()
		holder.SetKeyBoardInputEnabled(true)
		holder.SetMouseInputEnabled(true)
		holder.SetMouseInputEnabled(true)
		local button = SoloHUD.FindPanelRoot("DoneButton")
		button.SetMouseInputEnabled(true)
		button.SetKeyBoardInputEnabled(true)
		SoloHUD.AddActionSignalTargetForPanel(holder)
		SoloHUD.AddActionSignalTargetForPanel(button)
	}
	function OnExit()
	{
		SendToConsole("pause")
		SoloHUD.SetKeyBoardInputEnabled(false)
		SoloHUD.SetMouseInputEnabled(false)
		TFSOLO.Hud.ActiveFile <- ""
		TFSOLO.HudScreens.Active = null
		SoloHUD.ResetResFile()
	}
}
TFSOLO.HudScreens["resource/ui/solo/arcade/upgradepanel.res"] <- TFSOLO.HudScreens.ArcadeUpgrade()

TFSOLO.ArcadeUpgradeHUDEventTag <- UniqueString()
getroottable()[TFSOLO.ArcadeUpgradeHUDEventTag] <- {
	OnScriptHook_solohud_command = function(params)
	{
		if (TFSOLO.HudScreens.Active != TFSOLO.HudScreens["resource/ui/solo/arcade/upgradepanel.res"]) return;
		if (params.command == "done")
		{
			TFSOLO.HudScreens.Active.Exit()
		}
	}
}
TFSOLO.ArcadeUpgradeHUDEventTable <- getroottable()[TFSOLO.ArcadeUpgradeHUDEventTag]
__CollectGameEventCallbacks(TFSOLO.ArcadeUpgradeHUDEventTable)