// PL Badwater
::Merc <- {}
Merc.MissionID <- 8
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_BLUE, 1, "Commando"),
	Merc.Bot(TF_TEAM_BLUE, 2, "General"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Foster"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Elite"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Robotic"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Ward"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Liquidator"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Cleaner"),
	
	Merc.Bot(TF_TEAM_RED, 1, "Inspired"),
	Merc.Bot(TF_TEAM_RED, 1, "Sleepy3"),
	Merc.Bot(TF_TEAM_RED, 1, "Sleepy"),
	Merc.Bot(TF_TEAM_RED, 1, "Sleepy2"),
	Merc.Bot(TF_TEAM_RED, 1, "Bruised"),
	Merc.Bot(TF_TEAM_RED, 1, "Rugged"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get kills"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 25

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam) return;
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer != null && !IsPlayerABot(aplayer))
		{
			Merc.ExtraGet(1, 1, 1)
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])
