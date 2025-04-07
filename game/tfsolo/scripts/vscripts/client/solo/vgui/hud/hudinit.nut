TFSOLO.Hud <- {}
TFSOLO.Hud.IsActive <- 0
TFSOLO.Hud.IsHosting <- 0
TFSOLO.Hud.ActiveFile <- ""
TFSOLO.HudScreens <- {}
TFSOLO.HudScreens.Active <- null
TFSOLO.Hud.IsSetup <- function()
{
	return ( (TFSOLO.Hud.IsActive != 0) || ("SoloHUD" in getroottable()) )
}

IncludeScript("client/solo/vgui/hud/hudscreen.nut")

TFSOLO.Hud.EventTag <- UniqueString()
getroottable()[TFSOLO.Hud.EventTag] <- {
	OnScriptHook_solohud_init = function(params)
	{
		TFSOLO.Hud.IsHosting = 1
	}
	
	OnScriptHook_LevelShutdownPostEntity = function(params)
	{
		// Clean up panel on map exit
		if (TFSOLO.HudScreens.Active != null)
		{
			TFSOLO.HudScreens.Active.Exit()
		}
		TFSOLO.HudScreens.Active = null
		TFSOLO.Hud.IsActive = 0
		TFSOLO.Hud.IsHosting = 0
		if (!TFSOLO.Hud.IsSetup()) return;
		SoloHUD.ResetResFile()
		SoloHUD.ReinitializeEverything()
	}
	
	OnScriptHook_solohud_file_changed = function(params)
	{
		if (!TFSOLO.Hud.IsSetup()) return;
		TFSOLO.Hud.ActiveFile <- SoloHUD.GetResFile().tolower()
		if (TFSOLO.HudScreens.Active != null)
		{
			TFSOLO.HudScreens.Active.Exit()
		}
		TFSOLO.HudScreens.Active = null
		if (TFSOLO.Hud.ActiveFile in TFSOLO.HudScreens)
		{
			TFSOLO.HudScreens[TFSOLO.Hud.ActiveFile].Enter()
		}
	}
	
	OnGameEvent_solohud_int = function(params)
	{
		if (!TFSOLO.Hud.IsSetup()) return;
		SoloHUD.SetDialogVariableInt(params.key, params.value)
		SoloHUD.InvalidateLayout(true, false)
	}
	
	OnGameEvent_solohud_float = function(params)
	{
		if (!TFSOLO.Hud.IsSetup()) return;
		SoloHUD.SetDialogVariableFloat(params.key, params.value)
		SoloHUD.InvalidateLayout(true, false)
	}
	
	OnGameEvent_solohud_string = function(params)
	{
		if (!TFSOLO.Hud.IsSetup()) return;
		SoloHUD.SetDialogVariable(params.key, params.value)
		if (TFSOLO.HudScreens.Active != null)
		{
			TFSOLO.HudScreens.Active.OnString(params.key, params.value)
		}
		//SoloHUD.InvalidateLayout(true, false)
	}
	
	OnGameEvent_solohud_event = function(params)
	{
		if (!TFSOLO.Hud.IsSetup()) return;
		if (TFSOLO.HudScreens.Active != null)
		{
			TFSOLO.HudScreens.Active.OnEvent(params.key, params.value)
		}
	}
	
	OnScriptHook_solohud_think = function(params)
	{
		if (TFSOLO.HudScreens.Active != null)
		{
			TFSOLO.HudScreens.Active.OnThink()
		}
	}
	
	OnGameEvent_player_spawn = function(params)
	{
		if (TFSOLO.Hud.IsActive == 0 && params.team > 1)
		{
			if (UserIsClient(params.userid))
			{
				SoloHUD.SyncResFile()
				if (TFSOLO.HudScreens.Active != null)
				{
					TFSOLO.HudScreens.Active.Exit()
				}
				TFSOLO.HudScreens.Active = null
				TFSOLO.Hud.IsActive = 1
				TFSOLO.Hud.ActiveFile <- SoloHUD.GetResFile().tolower()
				if (TFSOLO.Hud.ActiveFile in TFSOLO.HudScreens)
				{
					TFSOLO.HudScreens[TFSOLO.Hud.ActiveFile].Enter()
				}
			}
		}
	}
}
TFSOLO.Hud.EventTable <- getroottable()[TFSOLO.Hud.EventTag]
__CollectGameEventCallbacks(TFSOLO.Hud.EventTable)
