// KOTH Nucleus
::Merc <- {}
Merc.MissionID <- 12
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED, 0, "Troublemaker"),
	Merc.Bot(TF_TEAM_RED, 1, "CountHydrogen"),
	Merc.Bot(TF_TEAM_RED, 0, "Judge"),
	Merc.Bot(TF_TEAM_RED, 1, "Pilot"),
	Merc.Bot(TF_TEAM_RED, 0, "Fancy"),
	
	Merc.Bot(TF_TEAM_BLUE, 1, "Napalmer"),
	Merc.Bot(TF_TEAM_BLUE, 0, "ExpertOrdinance"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Airborne"),
	Merc.Bot(TF_TEAM_BLUE, 1, "RetroRebel"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Score points"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 15

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_score_changed = function(params)
	{
		local player = EntIndexToHScript(params.player)
		if (IsPlayerABot(player)) return
		
		local score = params.delta
		if (!Merc.ExtraDone && score > 0)
		{
			Merc.ExtraGet(score, 1, 1)
		}
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		local ent = null
		while (ent = Entities.FindByName(ent, "relay_capdoors"))
		{
			ent.AcceptInput("Trigger", "", null, null)
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])
