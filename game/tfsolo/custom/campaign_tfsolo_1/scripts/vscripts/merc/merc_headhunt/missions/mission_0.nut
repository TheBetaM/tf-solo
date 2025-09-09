// KOTH Badlands
::Merc <- {}
Merc.MissionID <- 0
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_BLUE, 0, "PublicEnemy"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Frymaster"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Scoper"),
	Merc.Bot(TF_TEAM_BLUE, 0, "WarHead"),
	Merc.Bot(TF_TEAM_BLUE, 0, "Combat"),
	
	Merc.Bot(TF_TEAM_RED, 0, "Knight"),
	Merc.Bot(TF_TEAM_RED, 1, "Milkman"),
	Merc.Bot(TF_TEAM_RED, 1, "DumpsterDiver"),
	Merc.Bot(TF_TEAM_RED, 1, "Convict"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Kill the enemy Medic"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 3

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (params.userid == 0 || !IsPlayerABot(player) || IsPlayerABot(aplayer)) return
		if (player.entindex() == Merc.Bots[4].Handle.entindex())
		{
			Merc.ExtraGet(1, 1, 1)
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

