// CTF Turbine
::Merc <- {}
Merc.MissionID <- 18
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED, 1, "Brainiac"),
	Merc.Bot(TF_TEAM_RED, 2, "MadDoc"),
	Merc.Bot(TF_TEAM_RED, 2, "Moonman"),
	Merc.Bot(TF_TEAM_RED, 2, "Speedster"),
	Merc.Bot(TF_TEAM_RED, 2, "Upgraded"),
	Merc.Bot(TF_TEAM_RED, 2, "Tsar"),
	Merc.Bot(TF_TEAM_RED, 1, "LordCockswain"),
	
	Merc.Bot(TF_TEAM_BLUE, 1, "Operator"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Classic"),
	Merc.Bot(TF_TEAM_BLUE, 1, "AirRaider"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Safeguard"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Spiky"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Deal damage to enemies"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1500

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_hurt = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer != null && !IsPlayerABot(aplayer))
		{
			local amount = params.damageamount
			if (amount > 200)
			{
				amount = 200
			}
			Merc.ExtraGet(amount, 0, 1)
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

