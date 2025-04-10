// CP Vanguard
::Merc <- {}
Merc.MissionID <- 16
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_HEAVY
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED, 1, "Skateboarder"),
	Merc.Bot(TF_TEAM_RED, 1, "Lurker"),
	Merc.Bot(TF_TEAM_RED, 1, "Pyroland"),
	Merc.Bot(TF_TEAM_RED, 1, "Scot"),
	Merc.Bot(TF_TEAM_RED, 1, "Captain"),
	Merc.Bot(TF_TEAM_RED, 1, "Madman"),
	
	Merc.Bot(TF_TEAM_BLUE, 1, "Wanderer"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Veteran"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Egghead"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Colonel"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Win before time runs out"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1

::M16_Lives <- 3
::M16MissionTime <- 420
::M16Time <- M16MissionTime

function M16_Clock()
{
	if (Merc.RoundEnded) return
	if (M16Time > 0)
	{
		M16Time = M16Time - 1
		local minutes = M16Time / 60
		local seconds = M16Time - (minutes * 60)
		if (seconds > 9)
			Merc.ObjectiveExtraAdd = " ("+minutes+":"+seconds+")"
		else
			Merc.ObjectiveExtraAdd = " ("+minutes+":0"+seconds+")"
	}
	else
	{
		if (!Merc.ExtraFailed)
		{
			Merc.ExtraFail()
			Merc.ChatPrint("Bonus objective failed! Time ran out.")
		}
		Merc.ObjectiveExtraAdd = " (0:00)"
	}
	Merc.UpdateHUD()
}

Merc.BeforeRoundWin <- function(params)
{
	if (params.team == Merc.ForcedTeam && !Merc.ExtraFailed)
	{
		Merc.ExtraGet(1,0,0)
	}
}
Merc.BeforeRoundStart <- function(params) 
{
	M16Time = M16MissionTime
	M16_Lives <- 3
	Merc.ObjectiveTextAdd = " - Lives left: "+M16_Lives
	Merc.ObjectiveExtraAdd = ""
	Merc.Timer(1.0, 0, M16_Clock)
	local minutes = M16Time / 60
	local seconds = M16Time - (minutes * 60)
	if (seconds > 9)
		Merc.ObjectiveExtraAdd = " ("+minutes+":"+seconds+")"
	else
		Merc.ObjectiveExtraAdd = " ("+minutes+":0"+seconds+")"
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || IsPlayerABot(player)) return
		if (Merc.RoundEnded) return
		
		M16_Lives--
		if (M16_Lives == 0)
		{
			Merc.ForceFail()
		}
		Merc.ObjectiveTextAdd = " - Lives left: "+M16_Lives
		Merc.UpdateHUD()
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

