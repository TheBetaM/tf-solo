printl("[TFSOLO] Game Init")
TFSOLO <- {}

DoIncludeScript("client/util.nut", this)
ClearGameEventCallbacks()
IncludeScript("solo/util.nut")
IncludeScript("client/savedata.nut")
IncludeScript("solo/itemschema.nut")

TFSOLO.CoreEventTag <- UniqueString()
getroottable()[TFSOLO.CoreEventTag] <- {
	OnGameEvent_player_death = function(params)
	{
	}
	
	OnGameEvent_localplayer_changeteam = function(params)
	{
	}
}
TFSOLO.CoreEventTable <- getroottable()[TFSOLO.CoreEventTag]
__CollectGameEventCallbacks(TFSOLO.CoreEventTable)