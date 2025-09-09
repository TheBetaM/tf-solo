// CTF Landfall
::Merc <- {}
Merc.MissionID <- 14
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED, 1, "Bonk"),
	Merc.Bot(TF_TEAM_RED, 1, "Octo"),
	Merc.Bot(TF_TEAM_RED, 1, "Bearded"),
	Merc.Bot(TF_TEAM_RED, 2, "Captain2"),
	Merc.Bot(TF_TEAM_RED, 0, "Carl"),
	Merc.Bot(TF_TEAM_RED, 1, "Fitness"),
	
	Merc.Bot(TF_TEAM_BLUE, 1, "Tourist"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Cameraman"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Quackers"),
	Merc.Bot(TF_TEAM_BLUE, 0, "Tyrant"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Reggae"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Don't let RED capture any flags"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1

Merc.BeforeRoundWin <- function(params) 
{
	if (params.team == Merc.ForcedTeam && !Merc.ExtraFailed)
	{
		Merc.ExtraGet(1,0,0)
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_ctf_flag_captured = function(params)
	{
		if (params.capping_team != Merc.ForcedTeam && !Merc.ExtraFailed)
		{
			Merc.ExtraFail()
			Merc.ChatPrint("Bonus objective failed! RED captured a flag.");
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])
