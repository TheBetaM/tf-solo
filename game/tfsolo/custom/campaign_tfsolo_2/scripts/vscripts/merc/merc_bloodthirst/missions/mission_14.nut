// ARENA Perks
::Merc <- {}
Merc.MissionID <- 14
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.WaitTimeConvar <- 1
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
Merc.ObjectiveExtraText <- "TBD"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	
	OnGameEvent_teamplay_round_start = function(params)
	{
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

