IncludeScript("solo/mission/mission_common.nut")

Convars.SetValue("tf_gamemode_override", 3)
Convars.SetValue("tf_force_holidays_off", 1)

TFSOLO.MissionBots <- [
	TFSOLO.MissionBot(TF_TEAM_RED, 1, "FastFood"),
	TFSOLO.MissionBot(TF_TEAM_RED, 2, "Guard"),
	TFSOLO.MissionBot(TF_TEAM_RED, 1, "Barbecue"),
	TFSOLO.MissionBot(TF_TEAM_RED, 2, "Hawaii"),
	TFSOLO.MissionBot(TF_TEAM_RED, 1, "Metal"),
	TFSOLO.MissionBot(TF_TEAM_RED, 2, "Roadie"),
	TFSOLO.MissionBot(TF_TEAM_RED, 2, "Fizzy"),
	TFSOLO.MissionBot(TF_TEAM_RED, 0, "Marksman"),
	TFSOLO.MissionBot(TF_TEAM_RED, 0, "Phantom"),
	
	TFSOLO.MissionBot(TF_TEAM_BLUE, 2, "Sleuth"),
	TFSOLO.MissionBot(TF_TEAM_BLUE, 2, "Detective"),
	TFSOLO.MissionBot(TF_TEAM_BLUE, 2, "Jogger"),
	TFSOLO.MissionBot(TF_TEAM_BLUE, 2, "BlackMarket"),
	TFSOLO.MissionBot(TF_TEAM_BLUE, 2, "Clue"),
	TFSOLO.MissionBot(TF_TEAM_BLUE, 2, "Hitman"),
	TFSOLO.MissionBot(TF_TEAM_BLUE, 2, "Inspector"),
]

TFSOLO.MissionEventTag <- UniqueString()
getroottable()[TFSOLO.MissionEventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "game_text_tf"))
		{
			ent.Destroy()
		}
		
		local gamerules = Entities.FindByClassname(null, "tf_gamerules")
		gamerules.AcceptInput("SetBlueTeamGoalString","#koth_setup_goal",null,null)
	}
	
	OnGameEvent_teamplay_round_win = function(params)
	{
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[TFSOLO.MissionEventTag])