IncludeScript("solo/mission/mission_common.nut")

Convars.SetValue("tf_gamemode_override", 3)

TFSOLO.MissionEventTag <- UniqueString()
getroottable()[TFSOLO.MissionEventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		
	}
	
	OnGameEvent_teamplay_round_win = function(params)
	{
		local team = Convars.GetStr("mp_humans_must_join_team") == "red" ? 2 : 3
		if (params.team == team)
		{
			Convars.SetValue("mp_maxrounds", 1)
		}
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[TFSOLO.MissionEventTag])