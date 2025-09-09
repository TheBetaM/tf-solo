// KOTH Slasher
::Merc <- {}
Merc.MissionID <- 3
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.WaitTimeConvar <- 1
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 05"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SPY, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_DEMOMAN, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SOLDIER, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 11"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "TBD"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 4

::MRemOutput <- function(a,b,c,d,e)
{
	EntityOutputs.RemoveOutput(a,b,c,d,e)
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		local ent = null
		while (ent = Entities.FindByName(ent, "spawner_roulette"))
		{
			MRemOutput(ent,"OnCase05","merasmus_relay","Trigger","")
			EntityOutputs.AddOutput(ent,"OnCase05","skeleton_normal_relay","Trigger","",0,-1)
		}
		
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
							SetPropInt(ent, "m_iSelectedSpellIndex", 6)
							SetPropInt(ent, "m_iSpellCharges", 5)
						}
					}
				}
			}
		} )
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

