// CP Metalworks
::Merc <- {}
Merc.MissionID <- 4
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_SOLDIER
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_BLUE, 1, "Ninja"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Conqueror"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Tricorne"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Escapist"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Angry"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Plague"),
	
	Merc.Bot(TF_TEAM_RED, 0, "Witcher"),
	Merc.Bot(TF_TEAM_RED, 1, "Mirror"),
	Merc.Bot(TF_TEAM_RED, 1, "Tartan"),
	Merc.Bot(TF_TEAM_RED, 1, "Sharpshooter"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Don't let BLU capture any points"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_point_captured = function(params)
	{
		if (params.team != Merc.ForcedTeam && !Merc.ExtraFailed)
		{
			Merc.ExtraFail()
			Merc.ChatPrint("Bonus objective failed! BLU capped a point.")
		}
	}
	
	OnGameEvent_teamplay_round_win = function(params)
	{
		if (params.team == Merc.ForcedTeam && !Merc.ExtraFailed)
		{
			Merc.ExtraGet(1,0,0)
			Merc.CheckObjectives()
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

