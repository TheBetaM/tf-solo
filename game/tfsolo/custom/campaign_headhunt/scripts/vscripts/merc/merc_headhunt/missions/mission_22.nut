// KOTH Rotunda
::Merc <- {}
Merc.MissionID <- 22
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_MEDIC
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED, 1, "FastFood"),
	Merc.Bot(TF_TEAM_RED, 2, "Guard"),
	Merc.Bot(TF_TEAM_RED, 1, "Barbecue"),
	Merc.Bot(TF_TEAM_RED, 2, "Hawaii"),
	Merc.Bot(TF_TEAM_RED, 1, "Metal"),
	Merc.Bot(TF_TEAM_RED, 2, "Roadie"),
	Merc.Bot(TF_TEAM_RED, 2, "Fizzy"),
	Merc.Bot(TF_TEAM_RED, 0, "Marksman"),
	Merc.Bot(TF_TEAM_RED, 0, "Phantom"),
	
	Merc.Bot(TF_TEAM_BLUE, 2, "Sleuth"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Detective"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Jogger"),
	Merc.Bot(TF_TEAM_BLUE, 2, "BlackMarket"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Clue"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Hitman"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Inspector"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Win without activating ÜberCharge"
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
	OnGameEvent_player_chargedeployed = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || IsPlayerABot(player)) return
		if (Merc.RoundEnded) return
		if (!Merc.ExtraFailed)
		{
			Merc.ExtraFail()
			Merc.ChatPrint("Bonus objective failed! ÜberCharge has been activated.")
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

