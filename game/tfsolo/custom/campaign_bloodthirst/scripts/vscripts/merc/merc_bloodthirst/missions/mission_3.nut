// PASS SkullTown
::Merc <- {}
Merc.MissionID <- 3
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_SOLDIER, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_MEDIC, "Bot 04"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SPY, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_DEMOMAN, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SOLDIER, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 10"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get kills with the SKULL!"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 4

::M15_Scope <- null

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		Convars.SetValue("tf_passtime_teammate_steal_time", 1)
	
		local ent = Entities.FindByClassname(null, "logic_script")
		local manager = Entities.FindByClassname(null, "tf_player_manager")
		M15_Scope = ent.GetScriptScope()
		foreach (a in GetClients())
		{	
			a.ValidateScriptScope()
			local params = {}
			params.userid <- GetPropIntArray(manager, "m_iUserID", a.entindex())
			M15_Scope["OnGameEvent_player_spawn"](params)
		}
		
		MercDelay(0.5, function() { 
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
	
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0) return
		if (!IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || IsPlayerABot(aplayer)) return
		if (params.weapon != "player") return
		Merc.ExtraGet(1,1,1)
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

