printl("[TFSOLO] VGUI Init")

TFSOLO.ConfigKV <- FileToKeyValues("cfg/solo/solo_config.txt")

IncludeScript("client/solo/vgui/playerdata.nut")
IncludeScript("client/solo/vgui/maputil.nut")
IncludeScript("client/solo/vgui/animations.nut")
IncludeScript("client/solo/vgui/screens/screen.nut")
IncludeScript("client/solo/vgui/cutscenes/cutscene.nut")
IncludeScript("client/solo/vgui/worldmaps/worldmap.nut")
IncludeScript("client/solo/vgui/missionstart.nut")
IncludeScript("client/solo/vgui/hud/hudinit.nut")

TFSOLO.VguiEventTag <- UniqueString()
getroottable()[TFSOLO.VguiEventTag] <- {
	OnScriptHook_solopanel_open = function(params)
	{
		TFSOLO.PlayMenuOpenEffects()
	}
}
TFSOLO.VguiEventTable <- getroottable()[TFSOLO.VguiEventTag]
__CollectGameEventCallbacks(TFSOLO.VguiEventTable)