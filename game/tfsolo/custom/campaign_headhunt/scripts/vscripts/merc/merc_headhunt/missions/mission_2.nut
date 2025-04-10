// KOTH Cachoeira
::Merc <- {}
Merc.MissionID <- 2
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_BLUE, 1, "Batter"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Firefighter"),
	Merc.Bot(TF_TEAM_BLUE, 1, "GasJockey"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Explosive"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Block"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Rifleman"),
	
	Merc.Bot(TF_TEAM_RED, 1, "Raider"),
	Merc.Bot(TF_TEAM_RED, 0, "Silly"),
	Merc.Bot(TF_TEAM_RED, 1, "Stuntman"),
	Merc.Bot(TF_TEAM_RED, 1, "Haircut"),
	Merc.Bot(TF_TEAM_RED, 1, "Archer2"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 2
Merc.ObjectiveExtraText <- "Get environmental kills"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 2
Merc.ResetMainOnRestart <- 0
Merc.ResetExtraOnRestart <- 0

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam) return
		local atplayer = GetPlayerFromUserID(params.attacker)
		local aplayer = GetPlayerFromUserID(params.assister)
		local inflict = EntIndexToHScript(params.inflictor_entindex)
		if (atplayer != null && !IsPlayerABot(atplayer))
		{
			if (params.weapon == "world" || params.weapon == "helicopter" || params.weapon == "piranha")
			{
				Merc.ExtraGet(1, 1, 1)
			}
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])
