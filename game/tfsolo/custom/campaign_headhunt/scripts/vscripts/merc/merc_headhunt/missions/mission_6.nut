// CTF Pelican Peak
::Merc <- {}
Merc.MissionID <- 6
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_BLUE, 1, "Miner"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Goggles"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Muchacho"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Vacationeer"),
	Merc.Bot(TF_TEAM_BLUE, 2, "BigChief"),
	Merc.Bot(TF_TEAM_BLUE, 2, "TTG_Sam"),
	Merc.Bot(TF_TEAM_BLUE, 2, "TTG_Max"),
	
	Merc.Bot(TF_TEAM_RED, 1, "Marshal"),
	Merc.Bot(TF_TEAM_RED, 1, "Fester"),
	Merc.Bot(TF_TEAM_RED, 0, "Beanie"),
	Merc.Bot(TF_TEAM_RED, 1, "Kilt"),
	Merc.Bot(TF_TEAM_RED, 1, "Hunter"),	
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get assists"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 3

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0) return
		if (!IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam) return
		
		local aplayer = GetPlayerFromUserID(params.assister)
		if (aplayer != null && !IsPlayerABot(aplayer))
		{
			Merc.ExtraGet(1, 1, 1)
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

