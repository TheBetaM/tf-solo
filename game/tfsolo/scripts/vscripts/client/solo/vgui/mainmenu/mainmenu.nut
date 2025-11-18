SoloMainMenu <- {}

IncludeScript("client/solo/vgui/mainmenu/classlineup.nut")

SoloMainMenu.InitDone <- false

SoloMainMenu.Init <- function()
{
	if (SoloMainMenu.InitDone)
	{
		return
	}
	printl("[TFSOLO] MainMenuInit")
	SoloMainMenu.InitDone = true
	SoloMainMenu.InitClassLineup()
}


TFSOLO.MainMenuEventTag <- UniqueString()
getroottable()[TFSOLO.MainMenuEventTag] <- {
	OnScriptHook_PostInventoryReceived = function(params)
	{
		// Online
		SoloMainMenu.Init()
	}
	
	OnScriptHook_EconUIClosed = function(params)
	{
		if (!IsInGame())
		{
			SoloMainMenu.UpdateClassLineup()
		}
	}
	
	OnGameEvent_mainmenu_stabilized = function(params)
	{
		// Offline
		if (!ConnectedOnline())
		{
			SoloMainMenu.Init()
		}
	}
	
	OnScriptHook_solo_save_reset = function(params)
	{
		MainMenu.ClearAllScriptPanels()
	}
	
	OnScriptHook_LevelInitPreEntity = function(params)
	{
		// Clean up panel on map start
		MainMenu.ClearAllScriptPanels()
	}
	
	OnScriptHook_LevelDisconnect = function(params)
	{
		// Clean up panel on map exit
		SoloMainMenu.InitDone = false
		MainMenu.ClearAllScriptPanels()
		SoloMainMenu.Init()
	}
}
TFSOLO.MainMenuEventTable <- getroottable()[TFSOLO.MainMenuEventTag]
__CollectGameEventCallbacks(TFSOLO.MainMenuEventTable)

