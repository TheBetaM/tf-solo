// KOTH Sharkbay
::Merc <- {}
Merc.MissionID <- 10
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_PYRO
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_BLUE, 2, "Rider"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Diplomat"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Guzzler"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Stuntman2"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Biker"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Daring"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Emergency"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Boater"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Criminal"),
	
	Merc.Bot(TF_TEAM_RED, 2, "Delinquent"),
	Merc.Bot(TF_TEAM_RED, 1, "FederalExpress"),
	Merc.Bot(TF_TEAM_RED, 1, "Juggernaut"),
	Merc.Bot(TF_TEAM_RED, 2, "Prof"),
	Merc.Bot(TF_TEAM_RED, 2, "Wetsuit"),
	Merc.Bot(TF_TEAM_RED, 1, "Bushman"),
	Merc.Bot(TF_TEAM_RED, 2, "Rogue"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Kill enemies without taking damage from them"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 6

::M10_DamageArray <- {}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_hurt = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0) return
		if (IsPlayerABot(player)) return
		
		local aplayer = GetPlayerFromUserID(params.attacker)
		M10_DamageArray[params.attacker] <- 1
	}
	
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0) return
		if (!IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam) return
		
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer != null && !IsPlayerABot(aplayer) && M10_DamageArray[params.userid] == 0)
		{
			Merc.ExtraGet(1, 1, 1)
		}
	}
	
	OnGameEvent_post_inventory_application = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0) return
		if (!IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam) return
		M10_DamageArray[params.userid] <- 0
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		M10_DamageArray <- {}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

