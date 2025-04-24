printl("[TFSOLO] Server Init")
::TFSOLO <- {}
::TFMOD <- 1
::TFSOLO.IsCampaign <- Convars.GetInt("tf_gamemode_campaign") != 0
::TFSOLO.IsSolo <- Convars.GetInt("tf_gamemode_solo") != 0

IncludeScript("solo/util.nut")
IncludeScript("solo/serverutil.nut")
IncludeScript("solo/itemschema.nut")
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

