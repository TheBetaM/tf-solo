
::TFSOLO.Settings <- FileToScriptTable("scriptdata/mission.cfg")
if (TFSOLO.Settings == null)
{
	TFSOLO.Settings = {}
	printl("[TFSOLO] Failed to load mission settings!")
}
::TFSOLO.CanRetry <- false

IncludeScript("solo/gamemodes/gamemode.nut")
IncludeScript("solo/mapmodes/mapmode.nut")
IncludeScript("solo/botmodes/botmode.nut")

Convars.SetValue("mp_tournament", 0)
Convars.SetValue("mp_winlimit", 0)
//ToConsole("mp_timelimit 0")
Convars.SetValue("mp_forceautoteam", 0)
Convars.SetValue("mp_autoteambalance", 0)
//Convars.SetValue("mp_allowspectators", 0)
Convars.SetValue("mp_bonusroundtime", 15)
Convars.SetValue("tf_bot_count", 0)
Convars.SetValue("tf_bot_quota_mode", "fill")
Convars.SetValue("tf_bot_quota", 24)
//Convars.SetValue("tf_bot_reevaluate_class_in_spawnroom", 0)
//Convars.SetValue("tf_bot_keep_class_after_death", 1)
Convars.SetValue("mp_teams_unbalance_limit", 0)
Convars.SetValue("mp_waitingforplayers_time", 0)
Convars.SetValue("tf_arena_use_queue", 0)
Convars.SetValue("mp_maxrounds", 1)
Convars.SetValue("tf_bot_quota_use_presets", 1)

TFSOLO.DebugWin <- function() {
	local tempEnt = SpawnEntityFromTable("game_round_win", {
        switch_teams = 0,
        force_map_reset = 1,
		win_reason = 0,
		TeamNum = Convars.GetStr("mp_humans_must_join_team") == "red" ? 2 : 3
    })
	tempEnt.AcceptInput("RoundWin","",null,null)
	tempEnt.AcceptInput("Kill","",null,null)
}
TFSOLO.DebugFail <- function() {
	local tempEnt = SpawnEntityFromTable("game_round_win", {
        switch_teams = 0,
        force_map_reset = 1,
		win_reason = 0,
		TeamNum = Convars.GetStr("mp_humans_must_join_team") == "red" ? 3 : 2
    })
	tempEnt.AcceptInput("RoundWin","",null,null)
	tempEnt.AcceptInput("Kill","",null,null)
}

::IsWorkshopMap <- GetMapName().find("workshop/") != null
::MapWorkshopID <- "0"
if (IsWorkshopMap)
{
	if (GetMapName().find("ugc") != null)
	{
		local pos = GetMapName().find("ugc") + 3
		MapWorkshopID = GetMapName().slice(pos)
	}
}

if ("MissionScript" in TFSOLO.Settings && TFSOLO.Settings.MissionScript.len() != 0)
{
	IncludeScript(TFSOLO.Settings.MissionScript)
	TFSOLO.CanRetry = true
	Convars.SetValue("mp_maxrounds", 0)
}

TFSOLO.SoloEventTag <- UniqueString()
getroottable()[TFSOLO.SoloEventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		local tf_gamerules = Entities.FindByClassname(null, "tf_gamerules")
		SetSoloObjectivesResFile("")
		if (TFSOLO.Settings.Medieval == 1)
		{
			NetProps.SetPropBool(tf_gamerules, "m_bPlayingMedieval", true)
		}
		else if (TFSOLO.Settings.Medieval == 2)
		{
			NetProps.SetPropBool(tf_gamerules, "m_bPlayingMedieval", false)
		}
		if (IsMannVsMachineMode())
		{
			Convars.SetValue("tf_bot_quota", 6)
			Convars.SetValue("tf_bot_difficulty", 3)
		}
		if (IsWorkshopMap)
		{
			ClientPrint(null, 3, "You can check out this map on the Steam Workshop:") 
			ClientPrint(null, 3, "https://steamcommunity.com/sharedfiles/filedetails/?id=" + MapWorkshopID)
		}
	}
	
	OnGameEvent_teamplay_round_win = function(params)
	{
		if (IsWorkshopMap)
		{
			ClientPrint(null, 3, "You can check out this map on the Steam Workshop:") 
			ClientPrint(null, 3, "https://steamcommunity.com/sharedfiles/filedetails/?id=" + MapWorkshopID)
		}
		
		local team = Convars.GetStr("mp_humans_must_join_team") == "red" ? 2 : 3
		local hParams = {
			playerTeam = team,
			playerWon = (params.team == team),
			full_round = params.full_round,
		}
		if (!TFSOLO.CanRetry || params.team == team)
		{
			FireScriptHook("solo_mission_over", hParams)
		}
	}
	
	OnGameEvent_mvm_mission_complete = function(params)
	{
		
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
	
	OnGameEvent_teamplay_game_over = function(params)
	{
		ToConsole("disconnect")
	}
	
}
__CollectGameEventCallbacks(getroottable()[TFSOLO.SoloEventTag])
