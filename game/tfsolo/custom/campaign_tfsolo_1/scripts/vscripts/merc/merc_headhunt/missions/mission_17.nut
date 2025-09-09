// CP Standin
::Merc <- {}
Merc.MissionID <- 17
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.WaitTimeConvar <- 1
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED, 1, "Dynamic"),
	Merc.Bot(TF_TEAM_RED, 2, "Hero"),
	Merc.Bot(TF_TEAM_RED, 2, "Caped"),
	Merc.Bot(TF_TEAM_RED, 2, "Flatliner"),
	Merc.Bot(TF_TEAM_RED, 1, "BonkBoy"),
	Merc.Bot(TF_TEAM_RED, 2, "Fighter"),
	Merc.Bot(TF_TEAM_RED, 2, "Showstopper"),
	
	Merc.Bot(TF_TEAM_BLUE, 1, "Blues"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Security"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Agent"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Punk"),
	Merc.Bot(TF_TEAM_BLUE, 1, "FederalSuit"),
]
Merc.ObjectiveText <- "Win rounds in a row"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 2
Merc.ObjectiveExtraText <- "Get kills" //while underwater"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 20
Merc.ResetMainOnRestart <- 0
Merc.ResetExtraOnRestart <- 0

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_round_win = function(params)
	{
		if (params.team == Merc.ForcedTeam)
		{
			Merc.MainGet(1,0,0)
			Merc.CheckObjectives()
			Merc.CheckExit()
		}
	}
	
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam) return
		
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer != null && !IsPlayerABot(aplayer))// && aplayer.GetWaterLevel() >= 3)
		{
			Merc.ExtraGet(1, 1, 1)
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

