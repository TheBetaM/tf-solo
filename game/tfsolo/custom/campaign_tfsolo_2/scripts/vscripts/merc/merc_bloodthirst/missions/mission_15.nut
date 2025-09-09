// ZI Devastation
::Merc <- {}
Merc.MissionID <- 15
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 12"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 13"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 14"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 15"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 16"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 17"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Bot 18"),
]
Merc.ObjectiveText <- "Win the round as a Zombie"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Infect a Human as different classes"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 3
Merc.AllowTeamChange <- 1
Merc.CustomSpawnBLU <- 1
Merc.AllowRecruits <- 0
Merc.ResetMainOnRestart <- 0

Convars.SetValue("mp_disable_respawn_times", 1)

::M14Setup <- 0
::M04_BotHint1 <- null
::M04_BotHint2 <- null
::M14_ClassCheck <- {}

::M06_HintThink <- function()
{
	local count = 0
	foreach (a in GetClients()) 
	{	
		if (IsPlayerABot(a) && a.IsAlive() && a.GetTeam() == TF_TEAM_RED)
		{
			local pos1 = a.GetOrigin()
			pos1.z = pos1.z
			if (count == 0)
			{
				M04_BotHint1.SetAbsOrigin(pos1)
				count++
			}
			else if (count == 1)
			{
				M04_BotHint2.SetAbsOrigin(pos1)
				count++
				return -1
			}
		}
	}
	if (count == 1)
	{
		M04_BotHint2.SetAbsOrigin(M04_BotHint1.GetOrigin())
	}
	return -1
}

// ZI Override
::GetRandomPlayers <- function(count = 1)
{
    local players = []
    foreach (a in GetClients())
    {
        if (a != null && !IsPlayerABot(a))
			players.append(a)
    }
    count = players.len()
    return players
}

Merc.BeforeRoundStart <- function(params) 
{
	::M14_ClassCheck <- {}
	
	M04_BotHint1 = SpawnEntityFromTable("item_teamflag", 
	{
		origin = Vector(1028, -16, -100),
		TeamNum = 2,
	})
	M04_BotHint1.AcceptInput("ForceGlowDisabled","1",null,null)
	M04_BotHint1.AddFlag(FL_DONTTOUCH)
	SetPropFloat(M04_BotHint1,"m_flModelScale",0.0)
	M04_BotHint2 = SpawnEntityFromTable("item_teamflag", 
	{
		origin = Vector(1028, -16, -100),
		TeamNum = 2,
	})
	M04_BotHint2.AcceptInput("ForceGlowDisabled","1",null,null)
	M04_BotHint2.AddFlag(FL_DONTTOUCH)
	SetPropFloat(M04_BotHint2,"m_flModelScale",0.0)
	
	local tprop = SpawnEntityFromTable("logic_script", {})
	AddThinkToEnt(tprop,"M06_HintThink")
}

Merc.BeforeRoundWin <- function(params) 
{
	if (params.team == TF_TEAM_BLUE)
	{
		Merc.MainGet(1,1,1)
		Merc.CheckExit()
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		if (player.GetTeam() == TF_TEAM_BLUE) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || IsPlayerABot(aplayer)) return;
		if (aplayer.GetPlayerClass() in M14_ClassCheck) return
		
		Merc.ExtraGet(1,1,1)
		M14_ClassCheck[aplayer.GetPlayerClass()] <- 1
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

