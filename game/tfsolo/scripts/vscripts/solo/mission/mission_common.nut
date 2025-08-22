IncludeScript("solo/mission/mission_util.nut")

Convars.SetValue("mp_tournament", 0)
Convars.SetValue("mp_winlimit", 0)
Convars.SetValue("mp_forceautoteam", 0)
Convars.SetValue("mp_autoteambalance", 0)
Convars.SetValue("mp_allowspectators", 0)
Convars.SetValue("mp_bonusroundtime", 15)
Convars.SetValue("tf_bot_quota_mode", 0)
Convars.SetValue("tf_bot_quota", 0)
Convars.SetValue("tf_bot_count", 0)
Convars.SetValue("tf_bot_reevaluate_class_in_spawnroom", 0)
Convars.SetValue("tf_bot_keep_class_after_death", 1)
Convars.SetValue("mp_teams_unbalance_limit", 0)
Convars.SetValue("mp_waitingforplayers_time", 0)
Convars.SetValue("tf_arena_use_queue", 0)
Convars.SetValue("mp_maxrounds", 0)
Convars.SetValue("tf_bot_quota_use_presets", 1)

TFSOLO.MissionCommonEventTag <- UniqueString()
getroottable()[TFSOLO.MissionCommonEventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		
	}
	
	OnGameEvent_teamplay_round_win = function(params)
	{
		
	}
	
	OnGameEvent_mvm_mission_complete = function(params)
	{
		
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[TFSOLO.MissionCommonEventTag])