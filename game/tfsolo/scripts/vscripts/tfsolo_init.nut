printl("[TFSOLO] Server Init")
::TFSOLO <- {}
::TFMOD <- 1
::TFSOLO.IsCampaign <- Convars.GetInt("tf_gamemode_campaign") != 0
::TFSOLO.IsSolo <- Convars.GetInt("tf_gamemode_solo") != 0
::TFSOLO.UseMapFixes <- true
::TFSOLO.MapEntryCvar <- Convars.GetStr("tfsolo_mapentry")

IncludeScript("solo/util.nut")
IncludeScript("solo/serverutil.nut")
IncludeScript("solo/itemschema.nut")
IncludeScript("solo/botstats.nut")
if (IsDedicatedServer())
{
	IncludeScript("client/solo/preload_items.nut")
}
if (TFSOLO.IsSolo)
{
	IncludeScript("solo/soloinit.nut")
}
if (TFSOLO.IsSolo || TFSOLO.IsCampaign)
{
	IncludeScript("solo/credits.nut")
}
if (TFSOLO.UseMapFixes && TFSOLO.MapEntryCvar != null && TFSOLO.MapEntryCvar.len() != 0)
{
	try { IncludeScript("mapfix/"+TFSOLO.MapEntryCvar+ ".nut"); } catch(e) { }
}
else if (TFSOLO.UseMapFixes)
{
	try { IncludeScript("mapfix/"+GetMapName()+ ".nut"); } catch(e) { }
}

TFSOLO.CoreEventTag <- UniqueString()
getroottable()[TFSOLO.CoreEventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[TFSOLO.CoreEventTag])

