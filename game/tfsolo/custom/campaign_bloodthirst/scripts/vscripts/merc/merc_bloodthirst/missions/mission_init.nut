if (!("Merc" in getroottable()))
{
	Merc <- {}
}
Merc.DebugMode <- 0
Merc.ProjectName <- "merc_bloodthirst"
Merc.MapFile <- "merc_bloodthirst"
Merc.ProjectDir <- "merc/" + Merc.ProjectName

IncludeScript(Merc.ProjectDir+"/util.nut")
IncludeScript(Merc.ProjectDir+"/const.nut")
IncludeScript(Merc.ProjectDir+"/missions/mission_common.nut")
Merc.LoadB(Merc.ProjectDir+"/savedata.nut")

Convars.SetValue("mp_tournament", 0)
Convars.SetValue("mp_winlimit", 0)
Convars.SetValue("mp_maxrounds", 0)
Convars.SetValue("mp_forceautoteam", 1)
Convars.SetValue("mp_autoteambalance", 0)
Convars.SetValue("mp_allowspectators", 0)
Convars.SetValue("mp_bonusroundtime", 15)
Convars.SetValue("tf_bot_quota_mode", 0)
Convars.SetValue("tf_bot_quota", 0)
Convars.SetValue("tf_bot_count", 0)
Convars.SetValue("tf_bot_reevaluate_class_in_spawnroom", 0)
Convars.SetValue("tf_bot_keep_class_after_death", 1)
Convars.SetValue("mp_teams_unbalance_limit", 0)
Convars.SetValue("mp_waitingforplayers_time", 0)
Convars.SetValue("tf_arena_use_queue", 0)
Convars.SetValue("tf_forced_holiday", 2)
Convars.SetValue("tf_spells_enabled", 1)

Merc.BeforeRoundStart <- function(params) {}
Merc.AfterRoundStart <- function(params) {}
Merc.BeforeRoundWin <- function(params) {}
Merc.AfterRoundWin <- function(params) {}
Merc.BeforePlayerSpawn <- function(params) {}
Merc.AfterPlayerSpawn <- function(params) {}
Merc.BeforePlayerInv <- function(params) {}
Merc.AfterPlayerInv <- function(params) {}

Merc.CoreEventTag <- UniqueString()
getroottable()[Merc.CoreEventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		if (!Merc.InitDone)
		{
			if (Merc.AllowRecruits != 0)
			{
				if (Merc.ForcedTeam == TF_TEAM_RED)
				{
					if (Merc.RSVFlags[4] == 1)
					{
						local bot = Merc.Bot(TF_TEAM_RED, 2, "Bloodthirst_RecruitRED")
						bot.WarPaints = [[1151,285,0.0]]
						Merc.Bots.push(bot)
					}
				}
				else if (Merc.ForcedTeam == TF_TEAM_BLUE)
				{
					if (Merc.RSVFlags[7] == 1)
					{
						local bot = Merc.Bot(TF_TEAM_BLUE, 2, "Bloodthirst_RecruitBLU")
						bot.WarPaints = [[208,416,0.0]]
						Merc.Bots.push(bot)
					}
				}
			}
		}
		Merc.BeforeRoundStart(params)
		
		ToConsole("tf_bot_kick all")
		
		foreach (a in GetClients()) 
		{
			if (!IsPlayerABot(a))
			{
				a.RemoveHudHideFlags(HIDEHUD_ALL)
			}
			if (!IsPlayerABot(a) && a.GetTeam() >= 2 && a.GetTeam() != Merc.ForcedTeam)
			{
				a.ForceChangeTeam(Merc.ForcedTeam, true)
				a.ForceRegenerateAndRespawn()
			}
		}
		
		if (Merc.ResetExtraOnRestart != 0 || (Merc.RoundResult != Merc.ForcedTeam && Merc.ResetExtraOnFail == 1) || Merc.ObjectiveMainCount == Merc.ObjectiveMainMax)
		{
			Merc.ObjectiveExtraCount = 0
			Merc.ExtraDone = false
			Merc.ExtraFailed = false
		}
		if (Merc.ResetMainOnRestart != 0 || (Merc.RoundResult != Merc.ForcedTeam && Merc.ResetMainOnFail == 1) || Merc.ObjectiveMainCount == Merc.ObjectiveMainMax)
		{
			Merc.ObjectiveMainCount = 0
			Merc.MainDone = false
			Merc.MainFailed = false
		}
		if (Merc.ExitCancel == 1)
		{
			Merc.ExitCancel = 0
		}
		Merc.RoundEnded = false
		Merc.RoundResult = 0
		
		local bt = SpawnEntityFromTable("logic_script", {})
		AddThinkToEnt(bt,"MercBotThink")
		
		Merc.Delay(0.1, function() { 
			foreach (b in Merc.Bots) b.Start()
		} )
		Merc.Delay(0.5, function() { 
			Merc.UpdateHUD()
		} )
		Merc.Delay(5.0, function() { 
			//Merc.ChatPrint(LOCM_CHATHELP)
			local tperks = "Perks: "
			local thands = "Curses: "
			local hasperks = false, hashands = false
			if (Merc.ForcedTeam == TF_TEAM_RED)
			{
				if (Merc.RSVFlags[4] == 1)
				{
					tperks += "[+Recruit] "
					hasperks = true
				}
				else if (Merc.RSVFlags[4] == 2)
				{
					thands += "[-Darkness] "
					hashands = true
				}
				if (Merc.RSVFlags[5] == 1)
				{
					tperks += "[+25% Clip Size] "
					hasperks = true
				}
				else if (Merc.RSVFlags[5] == 2)
				{
					tperks += "[+50% Ammo] "
					hasperks = true
				}
				else if (Merc.RSVFlags[5] == 3)
				{
					thands += "[-Marked For Death] "
					hashands = true
				}
				if (Merc.RSVFlags[6] == 1)
				{
					tperks += "[+Taunt For Bullet Resist.] "
					hasperks = true
				}
				else if (Merc.RSVFlags[6] == 2)
				{
					tperks += "[+Taunt For Overheal] "
					hasperks = true
				}
				else if (Merc.RSVFlags[6] == 3)
				{
					thands += "[-Fatigue] "
					hashands = true
				}
			}
			
			if (Merc.ForcedTeam == TF_TEAM_BLUE)
			{
				if (Merc.RSVFlags[7] == 1)
				{
					tperks += "[+Recruit] "
					hasperks = true
				}
				else if (Merc.RSVFlags[7] == 2)
				{
					thands += "[-Darkness] "
					hashands = true
				}
				if (Merc.RSVFlags[8] == 1)
				{
					tperks += "[+25% Max HP] "
					hasperks = true
				}
				else if (Merc.RSVFlags[8] == 2)
				{
					tperks += "[+100% Max Overheal] "
					hasperks = true
				}
				else if (Merc.RSVFlags[8] == 3)
				{
					thands += "[-Mad Milked] "
					hashands = true
				}
				if (Merc.RSVFlags[9] == 1)
				{
					tperks += "[+Taunt For Blast Resist.] "
					hasperks = true
				}
				else if (Merc.RSVFlags[9] == 2)
				{
					tperks += "[+Taunt For Fright] "
					hasperks = true
				}
				else if (Merc.RSVFlags[9] == 3)
				{
					thands += "[-Bad Luck] "
					hashands = true
				}
			}
			if (hasperks) Merc.ChatPrint(tperks)
			if (hashands) Merc.ChatPrint(thands)
			Merc.UpdateHUD()
		} )
		Merc.InitDone = true
		Merc.TauntBoo = 0
		
		local ent = null
		if (Merc.ForcedTeam == TF_TEAM_RED && Merc.AllowHandicaps != 0)
		{
			if (Merc.RSVFlags[4] == 2)
			{
				local found = false
				while (ent = Entities.FindByClassname(ent, "env_fog_controller"))
				{
					ent.AcceptInput("SetColor", "0 0 0", null, null)
					ent.AcceptInput("SetColorSecondary", "0 0 0", null, null)
					ent.AcceptInput("SetEndDist", "1200", null, null)
					found = true
				}
				if (!found)
				{
					local prop = SpawnEntityFromTable("env_fog_controller", {
						fogenable = true,
						fogstart = 0.0,
						fogend = 1200.0,
						fogcolor = "0 0 0",
						fogcolor2 = "0 0 0",
					})
				}
			}
		}
		else if (Merc.ForcedTeam == TF_TEAM_BLUE && Merc.AllowHandicaps != 0)
		{
			if (Merc.RSVFlags[7] == 2)
			{
				local found = false;
				while (ent = Entities.FindByClassname(ent, "env_fog_controller"))
				{
					ent.AcceptInput("SetColor", "0 0 0", null, null)
					ent.AcceptInput("SetColorSecondary", "0 0 0", null, null)
					ent.AcceptInput("SetEndDist", "1200", null, null)
					ent.AcceptInput("SetRadial", "1", null, null)
					found = true
				}
				if (!found)
				{
					local prop = SpawnEntityFromTable("env_fog_controller", {
						fogenable = true,
						fogstart = 0.0,
						fogend = 1200.0,
						fogcolor = "0 0 0",
						fogcolor2 = "0 0 0",
						fogRadial = true,
					})
				}
			}
		}
		
		if (Merc.ForcedTeam == TF_TEAM_RED && Merc.AllowBuffs != 0)
		{
			if (Merc.RSVFlags[6] == 1)
			{
				local prop = SpawnEntityFromTable("logic_script", {})
				AddThinkToEnt(prop,"MercTauntBuffThink_1")
			}
			else if (Merc.RSVFlags[6] == 2)
			{
				local prop = SpawnEntityFromTable("logic_script", {})
				AddThinkToEnt(prop,"MercTauntBuffThink_2")
			}
		}
		else if (Merc.ForcedTeam == TF_TEAM_BLUE && Merc.AllowBuffs != 0)
		{
			if (Merc.RSVFlags[9] == 1)
			{
				local prop = SpawnEntityFromTable("logic_script", {})
				AddThinkToEnt(prop,"MercTauntBuffThink_3")
			}
			else if (Merc.RSVFlags[9] == 2)
			{
				local prop = SpawnEntityFromTable("logic_script", {})
				AddThinkToEnt(prop,"MercTauntBuffThink_4")
			}
		}
		
		foreach (a in GetClients()) 
		{
			if (!IsPlayerABot(a))
			{
				a.RemoveHudHideFlags(HIDEHUD_ALL)
				Merc.OnPlayerSpawn(a)
			}
		}
		
		Merc.SetHUD(Merc.PathHUD)
		Merc.UpdateHUD()
		Merc.AfterRoundStart(params)
	}

	OnGameEvent_teamplay_round_win = function(params)
	{
		Merc.BeforeRoundWin(params)
		Merc.RoundEnded = true
		Merc.RoundResult = params.team
		if (params.team == Merc.ForcedTeam)
		{
			if (Merc.ObjectiveText == LOCM_OBJECTIVE_GENERIC)
			{
				Merc.MainGet(1,0,0)
			}
			if (Merc.ObjectiveExtraText == LOCM_OBJECTIVE_GENERIC)
			{
				Merc.ExtraGet(1,0,0)
			}
			Merc.CheckExit()
		}
		else
		{
			//Merc.ChatPrint("You lost! Restarting the mission...")
		}
		Merc.AfterRoundWin(params)
	}
	
	OnGameEvent_post_inventory_application = function(params)
	{
		Merc.BeforePlayerInv(params)
		local player = GetPlayerFromUserID(params.userid)
		local name = GetPropString(player, "m_szNetname")
		if (IsPlayerABot(player)) 
		{
			local preset = player.GetPreset()
			if (preset == "")
			{
				foreach (i in Merc.Bots)
				{
					if (name == i.Name || name == i.Name + "(1)" || name == i.Name + "(2)")
					{
						i.UpdateResupply(player)
						Merc.AfterPlayerInv(params)
						return
					}
				}
			}
			else
			{
				foreach (i in Merc.Bots)
				{
					if (preset == i.Preset)
					{
						i.UpdateResupply(player)
						Merc.AfterPlayerInv(params)
						return
					}
				}
			}
			return
		}
		Merc.OnPlayerSpawn(player)
		Merc.GiveSpellbook(player)
		Merc.AfterPlayerInv(params)
	}
	
	OnGameEvent_player_spawn = function(params)
	{
		Merc.BeforePlayerSpawn(params)
		local player = GetPlayerFromUserID(params.userid)
		local name = GetPropString(player, "m_szNetname")
		if (IsPlayerABot(player)) 
		{
			local preset = player.GetPreset()
			if (preset == "")
			{
				foreach (i in Merc.Bots)
				{
					if (name == i.Name || name == i.Name + "(1)" || name == i.Name + "(2)")
					{
						i.OnSpawn(player)
						Merc.Delay(RandomFloat(0.01,0.49), function() {
							i.OnItems(player)
						} )
						Merc.AfterPlayerSpawn(params)
						return
					}
				}
			}
			else
			{
				foreach (i in Merc.Bots)
				{
					if (preset == i.Preset)
					{
						i.OnSpawn(player)
						Merc.Delay(RandomFloat(0.01,0.49), function() {
							i.OnItems(player)
						} )
						Merc.AfterPlayerSpawn(params)
						return
					}
				}
			}
			return
		}
		Merc.UpdateHUD()
		Merc.SpellRes[params.userid] <- [-1,0]
		Merc.GiveSpellbook(player)
		Merc.AfterPlayerSpawn(params)
	}
	
	OnGameEvent_player_activate = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (!IsPlayerABot(player) && player.GetTeam() >= 2 && player.GetTeam() != Merc.ForcedTeam)
		{
			player.ForceChangeTeam(Merc.ForcedTeam, true)
		}
	}
	
	OnGameEvent_player_say = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		local msg = params.text
		if (msg == "r")
		{
			if (Merc.ExitCancel != 0)
			{
				Merc.ExitCancel = 0
				Merc.ChatPrint("No longer cancelling the map transition.")
			}
			else if (Merc.RoundEnded)
			{
				Merc.ExitCancel = 1
				Merc.ChatPrint("Cancelling this map transition...")
			}
			else
			{
				Convars.SetValue("mp_restartgame_immediate", 1)
			}
		}
		if (msg == "c")
		{
			if (Merc.ExitCancel != 0)
			{
				Merc.ExitCancel = 0
				Merc.ChatPrint("No longer cancelling map transitions.")
			}
			else if (Merc.RoundEnded)
			{
				Merc.ExitCancel = 2
				Merc.ChatPrint("Cancelling all map transitions...")
			}
		}
		if (msg == "q")
		{
			Merc.ReturnTuHub()
		}
		if (Merc.DebugMode >= 1)
		{
			if (msg == "skip")
			{
				Merc.ObjectiveMainCount = Merc.ObjectiveMainMax
				Merc.ForceWin()
			}
			if (msg == "win")
			{
				Merc.ForceWin()
			}
			if (msg == "lose")
			{
				Merc.ForceFail()
			}
		}
	}
	
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		local name = GetPropString(player, "m_szNetname")
		if (IsPlayerABot(player)) 
		{
			local preset = player.GetPreset()
			if (preset == "")
			{
				foreach (i in Merc.Bots)
				{
					if (name == i.Name || name == i.Name + "(1)" || name == i.Name + "(2)")
					{
						i.OnDeath(player)
						return
					}
				}
			}
			else
			{
				foreach (i in Merc.Bots)
				{
					if (preset == i.Preset)
					{
						i.OnDeath(player)
						return
					}
				}
			}
			
			return
		}
		local ent = null
		while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
		{
			if (ent.GetOwner() == player)
			{
				Merc.SpellRes[params.userid] <- [GetPropInt(ent, "m_iSelectedSpellIndex"),GetPropInt(ent, "m_iSpellCharges")]
			}
		}
	}
	
	OnGameEvent_scorestats_accumulated_update = function(params)
	{
		// Cleans up timers at the end because the script will never be reloaded
		Merc.Delays <- {}
		Merc.Timers <- []
		ToConsole("tf_bot_kick all")
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.CoreEventTag])

