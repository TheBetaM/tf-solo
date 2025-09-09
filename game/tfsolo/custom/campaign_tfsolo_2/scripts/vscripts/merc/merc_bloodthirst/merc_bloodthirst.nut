::Merc <- {}
Merc.ProjectName <- "merc_bloodthirst"
Merc.MapFile <- GetMapName()
Merc.DebugMode <- 0
Merc.ProjectDir <- "merc/" + Merc.ProjectName

IncludeScript(Merc.ProjectDir + "/util.nut")
IncludeScript(Merc.ProjectDir + "/const.nut")
IncludeScript(Merc.ProjectDir + "/hubconst.nut")
IncludeScript(Merc.ProjectDir + "/mission.nut")
IncludeScript(Merc.ProjectDir + "/progress.nut")
IncludeScript(Merc.ProjectDir + "/cutscenes.nut")

Convars.SetValue("mp_tournament", 0)
Convars.SetValue("mp_winlimit", 0)
ToConsole("mp_timelimit 0")
Convars.SetValue("mp_forceautoteam", 0)
Convars.SetValue("tf_player_movement_restart_freeze", 0)
Convars.SetValue("mp_disable_respawn_times", 1)
Convars.SetValue("mp_autoteambalance", 0)
Convars.SetValue("tf_bot_quota_mode", 0)
Convars.SetValue("tf_bot_quota", 0)
Convars.SetValue("tf_bot_count", 0)
Convars.SetValue("tf_bot_reevaluate_class_in_spawnroom", 0)
Convars.SetValue("tf_bot_keep_class_after_death", 1)
Convars.SetValue("mp_teams_unbalance_limit", 0)
Convars.SetValue("mp_allowspectators", 0)
Convars.SetValue("tf_spawn_glows_duration", 0)
Convars.SetValue("tf_dropped_weapon_lifetime", 0)
Convars.SetValue("tf_roundstarttalk_disable", 1)
Convars.SetValue("tf_forced_holiday", 2)
Convars.SetValue("tf_spells_enabled", 1)

PrecacheSound("player/recharged.wav")
PrecacheSound("items/ammo_pickup.wav")
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "spell_pumpkin_mirv_bits_red" })
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "spell_pumpkin_mirv_bits_blue" })

Merc.MissionID <- -1
Merc.MissionStarted <- false
Merc.ProgressLoaded <- false
Merc.SpellCosts <- [1,1,1,1,1,1,1,2,1,2,2,2,1,1,1,1]
Merc.SpellShop_RED <- [MSpells.Heal, MSpells.Pumpkins, MSpells.Jump, MSpells.Mouse, MSpells.Lightning, MSpells.Meteor]
Merc.SpellShop_BLU <- [MSpells.Fire, MSpells.Bats, MSpells.Teleport, MSpells.Invis, MSpells.Skeletons, MSpells.Monoculus]
Merc.Spell_RED <- 0
Merc.Spell_BLU <- 0

::MercSendToConsole <- function(t)
{
	if (IsDedicatedServer())
		SendToServerConsole(t);
	else
		SendToConsole(t);
}

Merc.ChangeLevelWithBuffer <- function(targetmap)
{
	Merc.SaveProgress()

	ToConsole("mp_timelimit 0")
	if (Merc.Missions[Merc.MissionID].ForcedTeam == TF_TEAM_RED)
	{
		ToConsole("mp_humans_must_join_team red")
		if (RandomInt(0, 1) == 1)
		{
			ToConsole("cl_loadingimage_override ../console/background01_widescreen")
		}
		else
		{
			ToConsole("cl_loadingimage_override ../console/background02_widescreen")
		}
	}
	else if (Merc.Missions[Merc.MissionID].ForcedTeam == TF_TEAM_BLUE)
	{
		ToConsole("mp_humans_must_join_team blue")
		ToConsole("cl_loadingimage_override ../console/title_blue_widescreen")
	}
	else
	{
		ToConsole("mp_humans_must_join_team any")
	}
	if (Merc.Missions[Merc.MissionID].ForcedClass == 0)
	{
		ToConsole("mp_humans_must_join_class any")
	}
	else
	{
		ToConsole("mp_humans_must_join_class " + TF_CLASS_NAMES[Merc.Missions[Merc.MissionID].ForcedClass])
	}
	if (Merc.Missions[Merc.MissionID].MOverride == 0)
	{
		ToConsole("tf_gamemode_override 0")
	}
	else
	{
		ToConsole("tf_gamemode_override 1")
	}
	
	//if (IsDedicatedServer())
		ToConsole("changelevel "+targetmap+";wait 60;script_execute "+Merc.ProjectDir+"/missions/mission_"+Merc.MissionID+".nut;")
	//else
	//	ToConsole("map "+targetmap+";wait 60;script_execute "+Merc.ProjectDir+"/missions/mission_"+Merc.MissionID+".nut;")
}

// Map file name is different in workshop downloads, so the name is passed through the boot buffer
Merc.ReturnTuHub <- function()
{
	Merc.SaveProgress()
	// changelevel breaks cosmetics in listen server
	//if (IsDedicatedServer())
		ToConsole("changelevel " + Merc.MapFile)
	//else
	//	ToConsole("disconnect;wait;maxplayers 32;map " + Merc.MapFile)
}
Merc.LoadBuffer <- function(t)
{
	local b = FileToString(t)
	md <- compilestring(b)
	md()
}

Merc.StartMission <- function()
{
	if (Merc.MissionID < 0) return
	if (Merc.DebugMode >= 2)
	{
		ClientPrint(null, HUD_PRINTTALK, "[DEBUG] Mission " + Merc.MissionID + " start.")
		return
	}
	Merc.LastMissionID = Merc.MissionID
	if (Merc.MissionID >= Merc.MissionStatus.len())
	{
		// bonus
	}
	else
	{
		Merc.ChangeLevelWithBuffer(Merc.Missions[Merc.MissionID].Map)
	}
}

::MercBellButtonMoveThink <- function()
{
	local o = self.GetOrigin()
	if (o.z < 122)
	{
		o.z += FrameTime() * 60.0
		self.SetAbsOrigin(o)
	}
	else
	{
		SetPropString(self, "m_iszScriptThinkFunction", "")
	}
}

Merc.MissionSelect <- function(id)
{
	if (Merc.MissionStarted || Merc.CutsceneActive || Merc.BriefingActive) return
	if (id == Merc.MissionID) return
	if (id >= Merc.MissionStatus.len())
	{
		//Merc.BonusSelect()
		return
	}
	if (Merc.MissionStatus[id] == 0) return
	Merc.MissionID = id
	printl("[MERC] Selected mission " + id)
	local missiontextID = Merc.MissionID + 1
	local wtext = Merc.Missions[Merc.MissionID].Title + "\n"
	wtext += Merc.Missions[Merc.MissionID].MapName + "\n"
	wtext += Merc.Missions[Merc.MissionID].ModeName + "\n\n"
	wtext += "As " + Merc.Missions[Merc.MissionID].PlayerClassName + "\n"
	if (Merc.MissionID == 24)
	{
		wtext = Merc.Missions[Merc.MissionID].Title + "\n"
		wtext += "As " + Merc.Missions[Merc.MissionID].PlayerClassName + "\n"
		if (Merc.MissionStatus[10] >= 2)
		{
			wtext += "-1000 HP start\n"
		}
		if (Merc.MissionStatus[11] >= 2)
		{
			wtext += "+DRACULA Marked\n"
		}
	}
	else if (Merc.MissionID == 25)
	{
		wtext = Merc.Missions[Merc.MissionID].Title + "\n"
		wtext += "As " + Merc.Missions[Merc.MissionID].PlayerClassName + "\n"
		if (Merc.MissionStatus[22] >= 2)
		{
			wtext += "+300 HP headstart\n"
		}
		if (Merc.MissionStatus[23] >= 2)
		{
			wtext += "+On Hit: Mark For Death\n"
		}
	}
	local wtextbox = Entities.FindByName(null, "wtext_monitor_red")
	wtextbox.AcceptInput("SetText",wtext,null,null)
	wtextbox = Entities.FindByName(null, "wtext_monitor_blu")
	wtextbox.AcceptInput("SetText",wtext,null,null)
	if (Merc.CSFlags[17] == 0)
	{
		Merc.CSFlags[17] = 1
		local xpos = 728
		local ypos = 564
		local zpos = 126
		if (Merc.Missions[Merc.MissionID].ForcedTeam == TF_TEAM_BLUE)
		{
			xpos = 750
			ypos = -507
			zpos = 150
		}
		SendGlobalGameEvent("show_annotation", {
			worldPosX = xpos,
			worldPosY = ypos,
			worldPosZ = zpos,
			id = 11,
			text = "HIT THIS TO START THE MISSION!",
			lifetime = -1,
		})
	}
	EmitSoundEx({ sound_name = "player/recharged.wav", })
	if (Merc.Missions[Merc.MissionID].ForcedTeam == TF_TEAM_RED)
	{
		EntFire("button_start_glow_red","Enable")
	}
	else
	{
		EntFire("button_start_glow_blu","Enable")
		EntFire("button_start_glow_blu","Start")
		local button = Entities.FindByName(null, "button_start_blu")
		AddThinkToEnt(button, "MercBellButtonMoveThink")
	}
	
	local team = "blu"
	if (Merc.Missions[Merc.MissionID].ForcedTeam == TF_TEAM_RED)
	{
		team = "red"
	}
	local spell = Merc.Missions[Merc.MissionID].Spell + 1
	Merc.ClearMonitorIcons()
	local ent = null
	while (ent = Entities.FindByName(ent,"missionspell_team_" + spell))
	{
		ent.AcceptInput("Enable","",null,null)
	}
}

Merc.BonusSelect <- function()
{
	if (Merc.MissionStarted || Merc.CutsceneActive || Merc.BriefingActive) return
	Merc.MissionID = 30
	printl("[MERC] Selected mission " + Merc.MissionID)
	EmitSoundEx({ sound_name = "player/recharged.wav", })
	EntFire("button_start_glow_bonus","Enable")
}

Merc.RequestStart <- function(isBLU)
{
	if (Merc.MissionStarted || Merc.MissionStarting || Merc.CutsceneActive || Merc.BriefingActive) return
	if (Merc.MissionID < 0) return
	if (Merc.MissionID >= Merc.MissionStatus.len())
	{
		Merc.BonusStart()
		return
	}
	if (isBLU && Merc.Missions[Merc.MissionID].ForcedTeam == TF_TEAM_RED) return
	if (!isBLU && Merc.Missions[Merc.MissionID].ForcedTeam == TF_TEAM_BLUE) return
	if (isBLU && !Merc.HubEnteredBLU) return
	if (!isBLU && !Merc.HubEnteredRED) return
	Merc.MissionStarted = true
	Merc.Delay(0.5, function() { Merc.StartPressed(isBLU) } )
	if (isBLU)
	{
		EntFire("button_start_sfx_blu","PlaySound")
	}
	else
	{
		EntFire("button_start_sfx_red","PlaySound")
	}
	EntFire("button_start_glow_blu","Disable")
	EntFire("button_start_glow_red","Disable")
}

Merc.ClearMonitorIcons <- function()
{
	local ent = null;
	while (ent = Entities.FindByName(ent,"missionspell_*"))
	{
		ent.AcceptInput("Disable","",null,null)
	}
}
Merc.UpdateMonitors <- function()
{
	local text_red = LOCM_MISSION_SELECT_RED + "\n" + Merc.GetProgress(TF_TEAM_RED) + "%";
	if (Merc.RSVFlags[4] == 1)
		text_red += "\n+Recruit";
	else if (Merc.RSVFlags[4] == 2)
		text_red += "\n-Darkness";
		
	if (Merc.RSVFlags[5] == 1)
		text_red += "\n+25% Clip Size";
	else if (Merc.RSVFlags[5] == 2)
		text_red += "\n+50% Ammo";
	else if (Merc.RSVFlags[5] == 3)
		text_red += "\n-Marked For Death";
		
	if (Merc.RSVFlags[6] == 1)
		text_red += "\n+Bullet Res. Taunt";
	else if (Merc.RSVFlags[6] == 2)
		text_red += "\n+Overheal Taunt";
	else if (Merc.RSVFlags[6] == 3)
		text_red += "\n-Fatigue";
		
	local text_blu = LOCM_MISSION_SELECT_BLU + "\n" + Merc.GetProgress(TF_TEAM_BLUE) + "%";
	if (Merc.RSVFlags[7] == 1)
		text_blu += "\n+Recruit";
	else if (Merc.RSVFlags[7] == 2)
		text_blu += "\n-Darkness";
		
	if (Merc.RSVFlags[8] == 1)
		text_blu += "\n+25% Max Health";
	else if (Merc.RSVFlags[8] == 2)
		text_blu += "\n+100% Max Overheal";
	else if (Merc.RSVFlags[8] == 3)
		text_blu += "\n-Mad Milked";
		
	if (Merc.RSVFlags[9] == 1)
		text_blu += "\n+Blast Res. Taunt";
	else if (Merc.RSVFlags[9] == 2)
		text_blu += "\n+Fright Taunt";
	else if (Merc.RSVFlags[9] == 3)
		text_blu += "\n-Bad Luck";
	local wtext = Entities.FindByName(null, "wtext_monitor_red")
	wtext.AcceptInput("SetText",text_red,null,null)
	wtext = Entities.FindByName(null, "wtext_monitor_blu")
	wtext.AcceptInput("SetText",text_blu,null,null)
	Merc.ClearMonitorIcons()
	
	SendGlobalGameEvent("solo_campaign_flag", {
		campaign = "bloodthirst",
		flag = "bloodthirst_progress",
		count = Merc.GetProgressAll(),
		setflag = true,
	})
}

Merc.ResetMonitors <- function()
{
	Merc.UpdateMonitors()
	EntFire("monitor_red", "SetCamera", "cam_mission_red")
	EntFire("monitor_blu", "SetCamera", "cam_mission_blu")
}

Merc.ApplyEntProgress <- function()
{
	for (local i = 0; i < Merc.Missions.len(); i++)
	{
		local text = Merc.Missions[i].Title + "\n"
		local color = ""
		if (Merc.MissionStatus[i] == 0 && i > 25)
		{
			if (i == 26 || i == 28)
			{
				text += LOCM_MISSION_LOCKED_BONUS
			}
			else if (i == 27)
			{
				text += LOCM_MISSION_SECRET_RED
			}
			else
			{
				text += LOCM_MISSION_SECRET_BLU
			}
			color = "255 0 0 255"
		}
		else if (Merc.MissionStatus[i] == 0 && i < 24)
		{
			text += LOCM_MISSION_LOCKED
			color = "255 0 0 255"
		}
		else if (Merc.MissionStatus[i] == 0)
		{
			text += LOCM_MISSION_FINAL_LOCKED
			color = "255 0 0 255"
		}
		else if (Merc.MissionStatus[i] == 1)
		{
			text += LOCM_MISSION_OPEN
			color = "0 255 0 255"
		}
		else if (Merc.MissionStatus[i] == 2)
		{
			text += LOCM_MISSION_CLEARED
			color = "255 255 255 255"
		}
		else
		{
			text += LOCM_MISSION_COMPLETED
			color = "255 200 0 255"
		}
		
		local button = null
		while (button = Entities.FindByName(button, "wtext_mission_" + i))
		{
			button.AcceptInput("SetText",text,null,null)
			button.AcceptInput("SetColor",color,null,null)
		}
	}
	Merc.ResetMonitors()
	Merc.ApplyCutsceneProgress()
}

Merc.UpdateShopDisplays <- function()
{
	local ent = null
	while (ent = Entities.FindByName(ent,"shopspell_*"))
	{
		ent.AcceptInput("Disable","",null,null)
	}
	ent = null
	local spell_red = Merc.Spell_RED + 1
	local spell_blu = Merc.Spell_BLU + 1
	while (ent = Entities.FindByName(ent,"shopspell_red_"+spell_red))
	{
		ent.AcceptInput("Enable","",null,null)
	}
	ent = null
	while (ent = Entities.FindByName(ent,"shopspell_blu_"+spell_blu))
	{
		ent.AcceptInput("Enable","",null,null)
	}
	
	local basetext = "UPGRADE SPELLS\nHIT THIS TO SELECT\nHIT THE BOOK TO BUY\n"
	local wtext = null
	local count_red = Merc.RSVFlags[Merc.Spell_RED+13] + 1
	local count_blu = Merc.RSVFlags[Merc.Spell_BLU+13] + 1
	local text_red = basetext + "CREDITS: "+ Merc.RSVFlags[0] +"\nCOST: " + Merc.SpellCosts[Merc.Spell_RED]
	local text_red2 = "x " + count_red
	local text_blu = basetext + "CREDITS: "+ Merc.RSVFlags[1] +"\nCOST: " + Merc.SpellCosts[Merc.Spell_BLU]
	local text_blu2 = "x " + count_blu
	while (wtext = Entities.FindByName(wtext,"wtext_shop_red"))
	{
		wtext.AcceptInput("SetText",text_red,null,null)
	}
	wtext = null
	while (wtext = Entities.FindByName(wtext,"wtext_shop_blu"))
	{
		wtext.AcceptInput("SetText",text_blu,null,null)
	}
	wtext = null
	while (wtext = Entities.FindByName(wtext,"wtext_shop_red_amount"))
	{
		wtext.AcceptInput("SetText",text_red2,null,null)
	}
	wtext = null
	while (wtext = Entities.FindByName(wtext,"wtext_shop_blu_amount"))
	{
		wtext.AcceptInput("SetText",text_blu2,null,null)
	}
}

Merc.ShopSelect <- function(id)
{
	if (Merc.MissionStarted || Merc.CutsceneActive || Merc.BriefingActive) return
	
	if (id == 0)
	{
		foreach (i,v in Merc.SpellShop_RED)
		{
			if (Merc.Spell_RED == v)
			{
				if (i < Merc.SpellShop_RED.len() - 1)
				{
					Merc.Spell_RED = Merc.SpellShop_RED[i + 1]
				}
				else
				{
					Merc.Spell_RED = Merc.SpellShop_RED[0]
				}
				break
			}
		}
	}
	else
	{
		foreach (i,v in Merc.SpellShop_BLU)
		{
			if (Merc.Spell_BLU == v)
			{
				if (i < Merc.SpellShop_BLU.len() - 1)
				{
					Merc.Spell_BLU = Merc.SpellShop_BLU[i + 1]
				}
				else
				{
					Merc.Spell_BLU = Merc.SpellShop_BLU[0]
				}
				break
			}
		}
	}
	
	Merc.UpdateShopDisplays()
}

Merc.ShopBuy <- function(id)
{
	if (Merc.MissionStarted || Merc.CutsceneActive || Merc.BriefingActive) return
	
	local cost = Merc.SpellCosts[Merc.Spell_RED]
	local credits = Merc.RSVFlags[0]
	if (id == 0)
	{
		if (cost > credits) return
		Merc.RSVFlags[0] -= cost
		Merc.RSVFlags[Merc.Spell_RED+13]++
		DispatchParticleEffect("spell_pumpkin_mirv_bits_red", Vector(470,914,115), Vector(0,0,0))
	}
	else
	{
		cost = Merc.SpellCosts[Merc.Spell_BLU]
		credits = Merc.RSVFlags[1]
		if (cost > credits) return
		Merc.RSVFlags[1] -= cost
		Merc.RSVFlags[Merc.Spell_BLU+13]++
		DispatchParticleEffect("spell_pumpkin_mirv_bits_blue", Vector(336,-736,115), Vector(0,0,0))
	}
	EmitSoundEx({ sound_name = "player/recharged.wav", })
	local max = 0
	for (local i = 13; i < 25; i++)
	{
		if (Merc.RSVFlags[i] > max)
		{
			max = Merc.RSVFlags[i]
		}
	}
	Merc.RSVFlags[25] = max
	
	Merc.UpdateShopDisplays()
}

Merc.SpawnMsg <- function()
{
	if (Merc.DebugMode >= 1)
	{
		ClientPrint(null, HUD_PRINTTALK, "["+LOCM_MODENAME+"] v" + Merc.Version + " Debug: " + Merc.DebugMode);
	}
	//ClientPrint(null, HUD_PRINTTALK, "["+LOCM_MODENAME+"] Type 'reset' in chat if you want to reset progress.");
	if (MaxClients().tointeger() < 5)
	{
		ClientPrint(null, HUD_PRINTTALK, "WARNING: Max players is less than 24. There may be issues or imbalance.");
	}
	if (!Merc.MissionStarted)
	{
		Merc.MissionID = -1
		Merc.ResetMonitors()
	}
	if (Convars.GetInt("sv_allow_wait_command") == 0)
	{
		local msg1 = "ERROR! sv_allow_wait_command is set to 0 - the mode won't work!"
		ClientPrint(null, HUD_PRINTTALK, msg1)
		printl(msg1)
	}
	if (Convars.GetInt("tv_enable") == 1)
	{
		local msg2 = "ERROR! tv_enable is set to 1 - the mode won't work!"
		ClientPrint(null, HUD_PRINTTALK, msg2)
		printl(msg2)
	}
	if (IsDedicatedServer())
	{
		if (Convars.GetStr("sv_allow_point_servercommand") != "always")
		{
			local msg3 = "ERROR! sv_allow_point_servercommand is not set to always - the mode won't work!"
			ClientPrint(null, HUD_PRINTTALK, msg3)
			printl(msg3)
		}
	}
	else
	{
		if (Convars.GetInt("cl_drawmonitors") == 0)
		{
			local msg4 = "WARNING: cl_drawmonitors is set to 0 - screens won't be visible!"
			ClientPrint(null, HUD_PRINTTALK, msg4)
			printl(msg4)
		}
	}
}

Merc.HubEvents <- {
	OnGameEvent_player_activate = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (IsPlayerABot(player)) return
		if (Merc.ProgressLoaded) return
		Merc.ProgressLoaded = true
		Merc.LoadBuffer("merc/" + Merc.ProjectName + "/savedata.nut")
		Merc.UpdateProgress()
	}
	
	OnGameEvent_player_say = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		local msg = params.text
		
		if (!Merc.MissionStarting && Merc.BriefingActive)
		{
			if (msg == "s" || msg == "r")
			{
				//ClientPrint(null, HUD_PRINTTALK, "Briefing skipped.")
				Merc.EndBriefing()
			}
		}
		if (msg == "reset")
		{
			if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
			ClientPrint(null, HUD_PRINTTALK, "Campaign progress has been reset.")
			Merc.ResetProgress()
			Convars.SetValue("mp_restartgame_immediate", 1)
		}
		if (Merc.DebugMode >= 1)
		{
			if (msg == "unlock")
			{
				ClientPrint(null, HUD_PRINTTALK, "All missions unlocked.")
				Merc.DebugUnlockAll()
				Convars.SetValue("mp_restartgame_immediate", 1)
			}
			if (msg == "handred")
			{
				EntFire("monitor_red", "SetCamera", "cam_handler_red")
			}
			if (msg == "handblu")
			{
				EntFire("monitor_blu", "SetCamera", "cam_handler_blu")
			}
			if (msg == "mred")
			{
				EntFire("monitor_red", "SetCamera", "cam_mission_red")
			}
			if (msg == "mblu")
			{
				EntFire("monitor_blu", "SetCamera", "cam_mission_blu")
			}
			if (msg == "mbonus")
			{
				EntFire("door_bonus", "Open")
			}
			if (msg == "mtest1")
			{
				SetPropString(Entities.FindByName(null, "subtitles_grey"), "m_iszMessage", "test1")
				EntFire("subtitles_grey","Display")
			}
		}
	}
	
	OnGameEvent_player_spawn = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		local name = GetPropString(player, "m_szNetname")
		if (IsPlayerABot(player)) 
		{
			local preset = player.GetPreset()
			if (preset == "")
			{
				foreach (i in Merc.HubBots)
				{
					if (name == i.Name)
					{
						i.OnSpawn(player)
						Merc.Delay(RandomFloat(0.1,0.2), function() {
							i.OnItems(player)
						} )
						return
					}
				}
			}
			else
			{
				foreach (i in Merc.HubBots)
				{
					if (preset == i.Preset)
					{
						i.OnSpawn(player)
						Merc.Delay(RandomFloat(0.1,0.2), function() {
							i.OnItems(player)
						} )
						return
					}
				}
			}
			return
		}
		
		player.AddHudHideFlags(HIDEHUD_HEALTH)
		player.AddHudHideFlags(HIDEHUD_BONUS_PROGRESS)
		player.AddHudHideFlags(HIDEHUD_BUILDING_STATUS)
		player.AddHudHideFlags(HIDEHUD_CLOAK_AND_FEIGN)
		player.AddHudHideFlags(HIDEHUD_PIPES_AND_CHARGE)
		player.AddHudHideFlags(HIDEHUD_METAL)
		player.AddHudHideFlags(HIDEHUD_MATCH_STATUS)
	}
	
	OnGameEvent_post_inventory_application = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		local name = GetPropString(player, "m_szNetname")
		if (IsPlayerABot(player)) 
		{
			local preset = player.GetPreset()
			if (preset == "")
			{
				foreach (i in Merc.HubBots)
				{
					if (name == i.Name)
					{
						i.UpdateResupply(player)
						return
					}
				}
			}
			else
			{
				foreach (i in Merc.HubBots)
				{
					if (preset == i.Preset)
					{
						i.UpdateResupply(player)
						return
					}
				}
			}
			return
		}
		
		if (!Merc.HubEnteredRED && !Merc.HubEnteredBLU)
		{
			Merc.Delay(1.5, function() { 
				Merc.SpawnMsg()
			} )
		}
	}

	OnGameEvent_teamplay_round_start = function(params)
	{
		Merc.MissionID = -1
		Merc.MissionStarted = false
		Merc.CutsceneActive = false
		Merc.BriefingActive = false
		Merc.HubEnteredRED = false
		Merc.HubEnteredBLU = false
		Merc.MissionStarting = false
		Merc.CutsceneID = -1
		Merc.SubsActive = false
		Merc.HandlerRED <- null
		Merc.HandlerBLU <- null
		Merc.Spell_RED = Merc.SpellShop_RED[0]
		Merc.Spell_BLU = Merc.SpellShop_BLU[0]
		
		local button = Entities.FindByName(null, "button_start_blu")
		button.SetAbsOrigin(Vector(761,-514,74.5))
		
		Convars.SetValue("mp_waitingforplayers_cancel", 1)
		Convars.SetValue("tf_player_movement_restart_freeze", 0)
		ToConsole("tf_bot_kick all")
		if (Merc.RSVFlags[4] == 1) 
			Merc.HubBots[2].Flags = 0
		else
			Merc.HubBots[2].Flags = 1
		if (Merc.RSVFlags[7] == 1) 
			Merc.HubBots[3].Flags = 0
		else
			Merc.HubBots[3].Flags = 1
		
		Merc.Delay(0.5, function() { 
			foreach (b in Merc.HubBots) b.Start()
		} )
		
		Merc.ApplyEntProgress()
		Merc.UpdateShopDisplays()
		
		Merc.SpawnActorRED()
		Merc.SpawnActorBLU()
	
		Merc.SubsTimer = Merc.Timer(0.25, 0, MercSubsThink)
	}
	
	OnGameEvent_scorestats_accumulated_update = function(params)
	{
		Merc.Delays <- {}
		Merc.Timers <- []
		ToConsole("tf_bot_kick all")
	}
}
CollectEventsInScope(Merc.HubEvents)
