// RD Crypt
::Merc <- {}
Merc.MissionID <- 14
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 06"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_DEMOMAN, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SOLDIER, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SNIPER, "Bot 11"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Capture the enemy's Soulflask"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1

::M02MissionTime <- 7 * 60
::M02Time <- M02MissionTime

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_ctf_flag_captured = function(params)
	{
		if (params.capping_team == Merc.ForcedTeam)
		{
			Merc.ExtraGet(1,1,1)
		}
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		local rd = Entities.FindByClassname(null, "tf_logic_robot_destruction")
		SetPropInt(rd, "m_nMaxPoints", 500)
		SetPropInt(rd, "m_nRedScore", 50)
		SetPropInt(rd, "m_nRedTargetPoints", 50)
		
		local ent = Entities.FindByName(null, "red_flag")
		ent.AcceptInput("Enable", "", null, null)
		
		Merc.Delay(0.5, function() { 
			foreach (a in GetClients()) 
			{	
				if (!IsPlayerABot(a))
				{
					local ent = null
					while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
					{
						if (ent.GetOwner() == a)
						{
							SetPropInt(ent, "m_iSelectedSpellIndex", 5)
							SetPropInt(ent, "m_iSpellCharges", 3)
						}
					}
				}
			}
		} )
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

