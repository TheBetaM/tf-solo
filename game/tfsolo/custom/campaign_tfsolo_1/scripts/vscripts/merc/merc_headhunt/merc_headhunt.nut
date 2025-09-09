::Merc <- {}
Merc.ProjectName <- "merc_headhunt"
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

PrecacheSound("player/recharged.wav")
PrecacheSound("items/ammo_pickup.wav")
PrecacheSound("ui/trade_success.wav")

Merc.MissionID <- -1
Merc.MissionStarted <- false
Merc.ProgressLoaded <- false
Merc.InHub <- true

Merc.WeaponUnlocks <- [
	"The Scottish Resistance",
	"The Frontier Justice",
	"The Force-a-Nature",
	"The Direct Hit",
]
Merc.WeaponUnlockClass <- [
	"Heavy",
	"Demoman",
	"Scout",
	"Medic",
]

// Change level, wait for VScript table to reset, execute mission script
// Dedicated server needs "sv_allow_point_servercommand always"
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
	
	//if (IsDedicatedServer())
		ToConsole("changelevel "+targetmap+";wait 60;script_execute "+Merc.ProjectDir+"/missions/mission_"+Merc.MissionID+".nut;")
	//else
	//	ToConsole("map "+targetmap+";wait 60;script_execute "+Merc.ProjectDir+"/missions/mission_"+Merc.MissionID+".nut;")
	//ToConsole("disconnect;wait;maxplayers 32;map "+targetmap+";wait 60;script_execute "+Merc.ProjectDir+"/missions/mission_"+Merc.MissionID+".nut;")
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
	local wtextbox = Entities.FindByName(null, "wtext_monitor_red")
	wtextbox.AcceptInput("SetText",wtext,null,null)
	wtextbox = Entities.FindByName(null, "wtext_monitor_blu")
	wtextbox.AcceptInput("SetText",wtext,null,null)
	if (Merc.CSFlags[17] == 0)
	{
		Merc.CSFlags[17] = 1
		local ypos = 564
		if (Merc.Missions[Merc.MissionID].ForcedTeam == TF_TEAM_BLUE)
		{
			ypos = -564
		}
		SendGlobalGameEvent("show_annotation", {
			worldPosX = 920,
			worldPosY = ypos,
			worldPosZ = 130,
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
	}
}

Merc.BonusSelect <- function()
{
	if (Merc.MissionStarted || Merc.CutsceneActive || Merc.BriefingActive) return
	Merc.MissionID = 26
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

Merc.BonusStart <- function()
{
	Merc.MissionStarted = true
	Merc.Delay(1.0, function() { Merc.StartBonusPressed() } )
	EntFire("button_start_sfx_bonus","PlaySound")
	EntFire("button_start_glow_bonus","Disable")
}

Merc.UpdateMonitors <- function()
{
	local text_red = LOCM_MISSION_SELECT + "\n" + Merc.GetProgress(TF_TEAM_RED) + "%"
	if (Merc.RSVFlags[4] == 1)
		text_red += "\n+Recruit"
	else if (Merc.RSVFlags[4] == 2)
		text_red += "\n-No Lockers"
		
	if (Merc.RSVFlags[5] == 1)
		text_red += "\n+Headshot resist."
	else if (Merc.RSVFlags[5] == 2)
		text_red += "\n+Backstab immune"
	else if (Merc.RSVFlags[5] == 3)
		text_red += "\n-No Random Crits"
		
	if (Merc.RSVFlags[6] == 1)
		text_red += "\n+Speed Boost"
	else if (Merc.RSVFlags[6] == 2)
		text_red += "\n+See Teammates"
	else if (Merc.RSVFlags[6] == 3)
		text_red += "\n-No Ammopacks"
		
	local text_blu = LOCM_MISSION_SELECT + "\n" + Merc.GetProgress(TF_TEAM_BLUE) + "%"
	if (Merc.RSVFlags[7] == 1)
		text_blu += "\n+Recruit"
	else if (Merc.RSVFlags[7] == 2)
		text_blu += "\n-No Lockers"
		
	if (Merc.RSVFlags[8] == 1)
		text_blu += "\n+No Fall Damage"
	else if (Merc.RSVFlags[8] == 2)
		text_blu += "\n+Afterburn immune"
	else if (Merc.RSVFlags[8] == 3)
		text_blu += "\n-Crits Become Mini"
		
	if (Merc.RSVFlags[9] == 1)
		text_blu += "\n+Uber Boost"
	else if (Merc.RSVFlags[9] == 2)
		text_blu += "\n+Fatal Dmg. Resist"
	else if (Merc.RSVFlags[9] == 3)
		text_blu += "\n-No Healthkits"
	local wtext = Entities.FindByName(null, "wtext_monitor_red")
	wtext.AcceptInput("SetText",text_red,null,null)
	wtext = Entities.FindByName(null, "wtext_monitor_blu")
	wtext.AcceptInput("SetText",text_blu,null,null)
	
	SendGlobalGameEvent("solo_campaign_flag", {
		campaign = "headhunt",
		flag = "headhunt_progress",
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

Merc.UpdateWeaponDisplays <- function()
{
	for (local i = 0; i < Merc.WeaponUnlocks.len(); i++)
	{
		local wep = null
		local wunlock = Merc.GetWeaponUnlock(i)
		local wperks = Merc.GetWeaponPerks(i)
		local wtext = Merc.WeaponUnlocks[i] + "\n"
		wtext += "FOR THE " + Merc.WeaponUnlockClass[i] + "\n"
		local wcolor = "255 255 255 255"
		local wflag = i
		if (!wunlock)
		{
			wcolor = "255 0 0 255"
			wtext += "COMPLETE MORE\nBONUS OBJECTIVES\nTO UNLOCK!"
		}
		else if (Merc.RSVFlags[wflag] != 0)
		{
			wtext += "(UNLOCKED IN LOADOUT)\n"
		}
		else
		{
			wtext += "(HIT THIS TO UNLOCK!)\n"
		}
		
		while (wep = Entities.FindByName(wep, "wtext_weapon_" + i))
		{
			wep.AcceptInput("SetText",wtext,null,null)
			wep.AcceptInput("SetColor",wcolor,null,null)
		}
	}
}

Merc.ApplyEntProgress <- function()
{
	for (local i = 0; i < Merc.Missions.len(); i++)
	{
		local text = Merc.Missions[i].Title + "\n"
		local color = ""
		if (Merc.MissionStatus[i] == 0 && i < Merc.Missions.len() - 2)
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
	Merc.UpdateWeaponDisplays()
	Merc.ApplyCutsceneProgress()
}

Merc.WeaponSelect <- function(id)
{
	local flagID = id
	local csflagID = id + 8
	printl("[MERC] Selected weapon " + id)
	if (Merc.RSVFlags[flagID] != 0)
	{
		return
	}
	local unlock = Merc.GetWeaponUnlock(id)
	if (!unlock) return
	Merc.RSVFlags[flagID] = 1
	Merc.CSFlags[csflagID] = 1
	Merc.UpdateWeaponDisplays()
	
	SendGlobalGameEvent("solo_unlock_item", {
		item = Merc.WeaponUnlocks[id],
	})
	
	ClientPrint(null, HUD_PRINTTALK, "New weapon unlocked: " + Merc.WeaponUnlocks[id] + " for the " + Merc.WeaponUnlockClass[id])
	ClientPrint(null, HUD_PRINTTALK, "You can equip the new weapon in your item loadout menu.")
	EmitSoundEx({ sound_name = "ui/trade_success.wav", })
	
	Merc.SaveProgress()
}

Merc.SpawnMsg <- function()
{
	if (Merc.DebugMode >= 1)
	{
		ClientPrint(null, HUD_PRINTTALK, "["+LOCM_MODENAME+"] v" + Merc.Version + " Debug: " + Merc.DebugMode)
	}
	//ClientPrint(null, HUD_PRINTTALK, "["+LOCM_MODENAME+"] Type 'reset' in chat if you want to reset progress.")
	if (MaxClients().tointeger() < 5)
	{
		ClientPrint(null, HUD_PRINTTALK, "WARNING: Max players is less than 24. There may be issues or imbalance.")
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
		
		Merc.SpawnActorRED()
		Merc.SpawnActorBLU()
	
		Merc.SubsTimer = Merc.Timer(0.25, 0, MercSubsThink)
	}
	
	OnGameEvent_scorestats_accumulated_update = function(params)
	{
		Merc.Delays <- {}
		Merc.Timers <- []
	}
}
CollectEventsInScope(Merc.HubEvents)
