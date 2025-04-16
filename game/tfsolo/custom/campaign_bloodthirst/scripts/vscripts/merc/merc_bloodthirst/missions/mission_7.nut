// CP Freaky Fair
::Merc <- {}
Merc.MissionID <- 7
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [ 
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 05"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SOLDIER, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SNIPER, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SPY, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_ENGINEER, "Bot 12"),
]
Merc.ObjectiveText <- "Earn credits"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 12000
Merc.ObjectiveExtraText <- "TBD"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 5
Merc.Canteen <- 1
Merc.ForceWinOnMainDone <- 1

::M08_FreakScope <- null

function CalculateClassCurrencyLevel(player)
{ 
	local classEntry = GetClassEntry(player)
	return banks[player.GetTeam()] - (classEntry["nonRefundableAmountSpent"] + classEntry["refundableAmountSpent"])
}

::M08_CashCheck <- function()
{
	if (M08_FreakScope == null)
	{
		local ent = null
		while (ent = Entities.FindByName(ent, "scripto"))
		{
			M08_FreakScope <- ent.GetScriptScope()
		}
		return -1
	}
	local before = Merc.ObjectiveMainCount
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a)) 
		{
			local b = M08_FreakScope.CalculateClassCurrencyLevel(a)
			local c = M08_FreakScope.GetClassEntry(a)
			Merc.ObjectiveMainCount = (b + c["nonRefundableAmountSpent"] + c["refundableAmountSpent"])
			if (Merc.ObjectiveMainCount >= Merc.ObjectiveMainMax && !Merc.RoundEnded)
			{
				Merc.MainGet(0,1,1)
			}
			if (Merc.ObjectiveMainCount != before)
			{
				Merc.UpdateHUD()
			}
			return -1
		}
	}
	return -1
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			ent.AcceptInput("SetSetupTime", "1", null, null)
		}
		while (ent = Entities.FindByClassname(ent, "team_control_point_master"))
		{
			SetPropInt(ent,"m_iInvalidCapWinner",2)
		}
		while (ent = Entities.FindByName(ent, "Merasmus_yapline_case"))
		{
			ent.Destroy()
		}
		while (ent = Entities.FindByName(ent, "cap_blue_2"))
		{
			EntityOutputs.AddOutput(ent,"OnCapTeam1","scripto","RunScriptCode","AwardCreditsToTeam(2,600);",0,-1)
		}
		while (ent = Entities.FindByName(ent, "scripto"))
		{
			M08_FreakScope <- ent.GetScriptScope()
		}
		
		local prop = SpawnEntityFromTable("logic_script", {})
		AddThinkToEnt(prop,"M08_CashCheck")
	}
	
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			ent.Destroy()
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

