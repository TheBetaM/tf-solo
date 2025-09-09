PrecacheSound("ui/quest_status_tick_novice_complete.wav")
PrecacheSound("ui/quest_status_tick_novice.wav")
PrecacheSound("ui/quest_status_tick_advanced_complete.wav")
PrecacheSound("ui/quest_status_tick_advanced.wav")
PrecacheSound("ui/quest_status_tick_expert_complete.wav")
PrecacheSound("ui/quest_status_tick_expert.wav")
PrecacheSound("ui/duel_score_behind.wav")

//Mission settings
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.Bots <- []
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveTextAdd <- ""
Merc.ObjectiveExtraText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1
Merc.ObjectiveExtraAdd <- ""
Merc.PlayerConds <- []
Merc.PlayerAttribs <- []
Merc.PlayerSlotDisable <- []
Merc.AllowCustomWeapons <- 1
Merc.AllowRecruits <- 1
Merc.AllowHandicaps <- 1
Merc.ForceWinOnMainDone <- 0
Merc.ResetMainOnRestart <- 1
Merc.ResetMainOnFail <- 1
Merc.ResetExtraOnRestart <- 1
Merc.ResetExtraOnFail <- 1
Merc.IgnoreExtraCap <- 0
Merc.WaitTimeConvar <- 0
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"
Merc.RewardCreditsMain <- false
Merc.RewardCreditsBonus <- false

Merc.Bot <- class {
	Name = "Bot"
	Skill = TFBOT_MEDIUM
	Team = TF_TEAM_RED
	Class = TF_CLASS_SCOUT
	Handle = null
	Items = []
	Conds = []
	Attribs = []
	BotAttribs = []
	Flags = 0
	BotWpnFlags = 0
	Preset = "NoPresetGiven"
	
	constructor (bteam, bskill, pname)
	{
		Preset = pname
		Team = bteam
		Skill = bskill
	}
	
	function Start()
	{
		if (Flags == 1) return
		if (Team == TF_TEAM_RED)
			ToConsole("tf_bot_add preset "+Preset+" red "+TFBOT_SKILLS[Skill]+"")
		else
			ToConsole("tf_bot_add preset "+Preset+" blue "+TFBOT_SKILLS[Skill]+"")
	}
	
	function OnSpawn(player)
	{
		Handle = player
		foreach (i in Conds)
		{
			player.AddCond(i)
		}
	}
	function OnItems(player)
	{
		Handle = player
		foreach (i in Items)
		{
			player.GenerateAndWearItem(i)
		}
	}
	
	function UpdateResupply(player)
	{
		Handle = player
		
		foreach (i in BotAttribs)
		{
			player.AddBotAttribute(i)
		}
		if (BotWpnFlags != 0)
		{
			player.AddWeaponRestriction(BotWpnFlags)
		}
		if (Attribs.len() != 0)
		{
			foreach (i in Attribs)
			{
				player.RemoveCustomAttribute(i[0])
				player.AddCustomAttribute(i[0], i[1], i[2])
			}
		}
	}
}
Merc.BotGeneric <- class extends Merc.Bot 
{
	constructor (bteam, bskill, bclass, bname)
	{
		Preset = ""
		Name = bname
		Team = bteam
		Skill = bskill
		Class = bclass
	}
	
	function Start()
	{
		if (Flags == 1) return
		if (Team == TF_TEAM_RED)
			ToConsole("tf_bot_add 1 "+Merc.BotClassNames[Class]+" red "+TFBOT_SKILLS[Skill]+" \""+Name+"\" noquota")
		else
			ToConsole("tf_bot_add 1 "+Merc.BotClassNames[Class]+" blue "+TFBOT_SKILLS[Skill]+" \""+Name+"\" noquota")
	}
}

Merc.ChatPrint <- function(text)
{
	ClientPrint(null, HUD_PRINTTALK, text)
}

Merc.ForceChangeClass <- function(player, classIndex) {
	player.SetPlayerClass(classIndex)
	SetPropInt(player, "m_Shared.m_iDesiredPlayerClass", classIndex)
	player.ForceRegenerateAndRespawn()
}

Merc.ForceWin <- function() {
	local tempEnt = SpawnEntityFromTable("game_round_win", {
        switch_teams = 0,
        force_map_reset = 1,
		win_reason = 0,
		TeamNum = Merc.ForcedTeam
    })
	tempEnt.AcceptInput("RoundWin","",null,null)
	tempEnt.AcceptInput("Kill","",null,null)
}
	
Merc.ForceFail <- function() {
	local tempEnt = SpawnEntityFromTable("game_round_win", {
        switch_teams = 0,
        force_map_reset = 1,
		win_reason = 0,
		TeamNum = Merc.ForcedTeam == TF_TEAM_RED ? TF_TEAM_BLUE : TF_TEAM_RED
    })
	tempEnt.AcceptInput("RoundWin","",null,null)
	tempEnt.AcceptInput("Kill","",null,null)
}

Merc.SaveProgress <- function()
{
	local buffer = ""
	buffer += "Merc.SaveVersion<-" + Merc.SaveVersionTarget + "\n"
	buffer += "Merc.LastMissionID<-" + Merc.LastMissionID + "\n"
	buffer += "Merc.NGP<-" + Merc.NGP + "\n"
	buffer += "Merc.MissionStatus<-["
	foreach (i in Merc.MissionStatus) buffer += i + ","
	buffer = buffer.slice(0, buffer.len() - 1)
	buffer += "]\n"
	buffer += "Merc.CSFlags<-["
	foreach (i in Merc.CSFlags) buffer += i + ","
	buffer = buffer.slice(0, buffer.len() - 1)
	buffer += "]\n"
	buffer += "Merc.RSVFlags<-["
	foreach (i in Merc.RSVFlags) buffer += i + ","
	buffer = buffer.slice(0, buffer.len() - 1)
	buffer += "]\n"
	StringToFile("merc/" + Merc.ProjectName + "/savedata.nut", buffer)
	
	Entities.FindByClassname(null,"tf_gamerules").AcceptInput("SoloSaveData","",null,null)
}

Merc.ReturnTuHub <- function()
{
	if (Merc.DebugMode == 2) return
	
	Merc.CheckObjectives()
	Merc.SaveProgress()
	
	if (Merc.ExitCancel != 0) return
	
	ToConsole("mp_humans_must_join_team any")
	ToConsole("mp_humans_must_join_class any")
	ToConsole("cl_loadingimage_force 1")
	ToConsole("cl_loadingimage_override ../console/title_team_tough_break_widescreen")
	
	//if (IsDedicatedServer())
		ToConsole("changelevel " + Merc.MapFile)
	//else
	//	ToConsole("map " + Merc.MapFile)
	//ToConsole("disconnect;wait;maxplayers 32;map " + Merc.MapFile)
}

Merc.GetObjText <- function()
{
	local text = ""
	if (Merc.MainFailed)
	{
		text += Merc.ObjectiveText+" (FAIL)"+Merc.ObjectiveTextAdd
	}
	else
	{
		text += Merc.ObjectiveText
		if (Merc.ObjectiveMainMax > 1)
		{
			text += " ("+Merc.ObjectiveMainCount+"/"+Merc.ObjectiveMainMax+")"+Merc.ObjectiveTextAdd
		}
		else
		{
			text += Merc.ObjectiveTextAdd
		}
	}
	return text
}
Merc.GetBonusText <- function()
{
	local text = ""
	if (Merc.ExtraFailed)
	{
		text += "Bonus: "+Merc.ObjectiveExtraText+" (FAIL)"+Merc.ObjectiveExtraAdd
	}
	else
	{
		text += "Bonus: "+Merc.ObjectiveExtraText+" ("+Merc.ObjectiveExtraCount+"/"+Merc.ObjectiveExtraMax+")"+Merc.ObjectiveExtraAdd
	}
	return text
}

Merc.CheckObjectives <- function()
{
	if (Merc.ObjectiveMainCount >= Merc.ObjectiveMainMax)
	{
		if (Merc.MissionStatus[Merc.MissionID] < 2)
		{
			Merc.MissionStatus[Merc.MissionID] = 2
			Merc.RewardCreditsMain = true
		}
		if (Merc.ObjectiveExtraCount >= Merc.ObjectiveExtraMax)
		{
			if (Merc.MissionStatus[Merc.MissionID] < 3)
			{
				Merc.MissionStatus[Merc.MissionID] = 3
				Merc.RewardCreditsBonus = true
			}
		}
	}
}

Merc.CheckExit <- function()
{
	if (Merc.ObjectiveMainCount >= Merc.ObjectiveMainMax)
	{
		Merc.CheckObjectives()
		Merc.ChatPrint("Mission complete! Returning to hub...")
		if (Merc.DebugMode == 2) return
		Convars.SetValue("mp_restartblock", 2)
		
		local hParams = {
			reward_main = Merc.RewardCreditsMain,
			reward_bonus = Merc.RewardCreditsBonus,
		}
		FireScriptHook("campaign_mission_over", hParams)
		Merc.Delay(11.0, function() { 
			if (Merc.ExitCancel == 0)
			{
				foreach (a in GetClients()) 
				{	
					if (!IsPlayerABot(a))
					{
						a.AddHudHideFlags(HIDEHUD_ALL)
						ScreenFade(a, 0, 0, 0, 255, 2.0, 4.0, 2)
					}
				}
			}
		} )
		Merc.Delay(13.9, function() { Merc.ReturnTuHub() } )
	}
}

Merc.OnMainDone <- function() {}
Merc.OnExtraDone <- function() {}

Merc.ExtraGet <- function(amt, soundtype, soundtype2)
{
	Merc.ObjectiveExtraCount += amt
	if (Merc.ObjectiveExtraCount > Merc.ObjectiveExtraMax && Merc.IgnoreExtraCap == 0)
	{
		Merc.ObjectiveExtraCount = Merc.ObjectiveExtraMax
	}
	if (Merc.ObjectiveExtraCount >= Merc.ObjectiveExtraMax && !Merc.ExtraDone)
	{
		Merc.ExtraDone = true
		Merc.OnExtraDone()
		Merc.ChatPrint(LOCM_OBJECTIVE_EXTRA_COMPLETED)
		
		SendGlobalGameEvent("solohud_event", {
			key = "obj2done",
			value = "1",
		})
		
		if (soundtype2 == 1) EmitSoundEx({ sound_name = "ui/quest_status_tick_novice_complete.wav", })
		else if (soundtype2 == 2) EmitSoundEx({ sound_name = "ui/quest_status_tick_advanced_complete.wav", })
		else if (soundtype2 == 3) EmitSoundEx({ sound_name = "ui/quest_status_tick_expert_complete.wav", })
	}
	else if (!Merc.ExtraDone)
	{
		if (soundtype == 1) 
		{
			EmitSoundEx({ sound_name = "ui/quest_status_tick_novice.wav", })
		}
		else if (soundtype == 2) 
		{
			EmitSoundEx({ sound_name = "ui/quest_status_tick_advanced.wav", })
		}
		else if (soundtype == 3) 
		{
			EmitSoundEx({ sound_name = "ui/quest_status_tick_expert.wav", })
		}
		else if (soundtype == 4) 
		{
			EmitSoundEx({ sound_name = "ui/quest_status_tick_novice.wav", volume = 0.3 })
		}
	}
	Merc.UpdateHUD()
}

Merc.ExtraFail <- function()
{
	if (!Merc.ExtraFailed)
	{
		Merc.ExtraFailed = true
		SendGlobalGameEvent("solohud_event", {
			key = "obj2fail",
			value = "1",
		})
		Merc.UpdateHUD()
		EmitSoundEx({ sound_name = "ui/duel_score_behind.wav", })
	}
}

Merc.MainGet <- function(amt, soundtype, soundtype2)
{
	Merc.ObjectiveMainCount += amt
	if (Merc.ObjectiveMainCount > Merc.ObjectiveMainMax)
	{
		Merc.ObjectiveMainCount = Merc.ObjectiveMainMax
	}
	if (Merc.ObjectiveMainCount >= Merc.ObjectiveMainMax && !Merc.MainDone)
	{
		Merc.MainDone = true
		Merc.OnMainDone()
		Merc.ChatPrint(LOCM_OBJECTIVE_COMPLETED)
		
		SendGlobalGameEvent("solohud_event", {
			key = "obj1done",
			value = "1",
		})
		
		if (soundtype2 == 1) EmitSoundEx({ sound_name = "ui/quest_status_tick_novice_complete.wav", })
		else if (soundtype2 == 2) EmitSoundEx({ sound_name = "ui/quest_status_tick_advanced_complete.wav", })
		else if (soundtype2 == 3) EmitSoundEx({ sound_name = "ui/quest_status_tick_expert_complete.wav", })
		if (Merc.ForceWinOnMainDone != 0) Merc.ForceWin()
	}
	else if (!Merc.MainDone)
	{
		if (soundtype == 1) 
		{
			EmitSoundEx({ sound_name = "ui/quest_status_tick_novice.wav", })
		}
		else if (soundtype == 2) 
		{
			EmitSoundEx({ sound_name = "ui/quest_status_tick_advanced.wav", })
		}
		else if (soundtype == 3) 
		{
			EmitSoundEx({ sound_name = "ui/quest_status_tick_expert.wav", })
		}
		else if (soundtype == 4) 
		{
			EmitSoundEx({ sound_name = "ui/quest_status_tick_novice.wav", volume = 0.3 })
		}
	}
	Merc.UpdateHUD()
}

Merc.MainFail <- function()
{
	if (!Merc.MainFailed)
	{
		Merc.MainFailed = true
		SendGlobalGameEvent("solohud_event", {
			key = "obj1fail",
			value = "1",
		})
		Merc.UpdateHUD()
	}
}

Merc.PlayerSpeakResp <- function(concept)
{
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a) && a.IsAlive()) 
		{
			EntFireByHandle(a, "SpeakResponseConcept", concept, 0, a, a)
			return
		}
	}
}
Merc.PlayerSpeak <- function(clip)
{
	PrecacheScriptSound(clip)
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a) && a.IsAlive()) 
		{
			a.EmitSound(clip)
			return
		}
	}
}
Merc.PlayerSpeakRaw <- function(clip)
{
	PrecacheSound(clip)
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a) && a.IsAlive()) 
		{
			a.EmitSound(clip)
			return
		}
	}
}
Merc.AnnSpeakRaw <- function(clip)
{
	PrecacheSound(clip)
	Entities.FindByClassname(null, "tf_gamerules").AcceptInput("PlayVO",clip,null,null)
}
Merc.AnnSpeak <- function(clip)
{
	PrecacheScriptSound(clip)
	Entities.FindByClassname(null, "tf_gamerules").AcceptInput("PlayVO",clip,null,null)
}
Merc.ForceTaunt <- function(a, taunt)
{
	local weapon = Entities.CreateByClassname("tf_weapon_bat")
	local active_weapon = a.GetActiveWeapon()
	a.StopTaunt(true)
	a.RemoveCond(7)
	weapon.DispatchSpawn()
	SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", taunt)
	SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
	SetPropBool(weapon, "m_bForcePurgeFixedupStrings", true)
	SetPropEntity(a, "m_hActiveWeapon", weapon)
	SetPropInt(a, "m_iFOV", 0)
	a.HandleTauntCommand(0)
	SetPropEntity(a, "m_hActiveWeapon", active_weapon)
	weapon.Kill()
}
Merc.PlayerForceTaunt <- function(taunt)
{
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a)) 
		{
			Merc.ForceTaunt(a, taunt)
		}
	}
}

Merc.OnPlayerSpawn <- function(player)
{
	foreach (i in Merc.PlayerConds)
	{
		player.AddCond(i)
	}
	foreach (i in Merc.PlayerSlotDisable)
	{
		local heldWeapon = GetPropEntityArray(player, "m_hMyWeapons", i)
		if (heldWeapon == null) continue
		if (heldWeapon.GetSlot() != i) continue
		heldWeapon.Destroy()
		SetPropEntityArray(player, "m_hMyWeapons", null, i)
		break
	}
	if (Merc.PlayerAttribs.len() != 0)
	{
		Merc.Delay(1.0, function() {
			foreach (i in Merc.PlayerAttribs)
			{
				player.RemoveCustomAttribute(i[0])
				player.AddCustomAttribute(i[0], i[1], i[2])
			} 
		} )
	}
	
	if (Merc.ForcedTeam == TF_TEAM_RED)
	{
		if (Merc.RSVFlags[5] == 1)
		{
			Merc.Delay(1.0, function() {
				player.RemoveCustomAttribute("SET BONUS: no death from headshots")
				player.AddCustomAttribute("SET BONUS: no death from headshots", 1, -1)
			} )
		}
		if (Merc.RSVFlags[5] == 2)
		{
			Merc.Delay(1.0, function() {
				player.RemoveCustomAttribute("cannot be backstabbed")
				player.AddCustomAttribute("cannot be backstabbed", 1, -1)
			} )
		}
		else if (Merc.RSVFlags[5] == 3 && Merc.AllowHandicaps != 0)
		{
			Merc.Delay(1.0, function() {
				player.RemoveCustomAttribute("crit mod disabled hidden")
				player.AddCustomAttribute("crit mod disabled hidden", 0, -1)
			} )
		}
		if (Merc.RSVFlags[6] == 1)
		{
			Merc.Delay(0.5, function() {
				player.AddCondEx(TF_COND_SPEED_BOOST, 10.0, null)
			} )
		}
		else if (Merc.RSVFlags[6] == 2)
		{
			player.RemoveCond(TF_COND_TEAM_GLOWS)
			Merc.Delay(0.5, function() {
				player.AddCond(TF_COND_TEAM_GLOWS)
			} )
		}
	}
	else if (Merc.ForcedTeam == TF_TEAM_BLUE)
	{
		if (Merc.RSVFlags[8] == 1)
		{
			Merc.Delay(1.0, function() {
				player.RemoveCustomAttribute("cancel falling damage")
				player.AddCustomAttribute("cancel falling damage", 1, -1)
			} )
		}
		else if (Merc.RSVFlags[8] == 2)
		{
			Merc.Delay(1.0, function() {
				player.RemoveCustomAttribute("afterburn immunity")
				player.AddCustomAttribute("afterburn immunity", 1, -1)
			} )
		}
		else if (Merc.RSVFlags[8] == 3 && Merc.AllowHandicaps != 0)
		{
			Merc.Delay(1.0, function() {
				player.RemoveCustomAttribute("crits_become_minicrits")
				player.AddCustomAttribute("crits_become_minicrits", 1, -1)
			} )
		}
		if (Merc.RSVFlags[9] == 1)
		{
			Merc.Delay(0.5, function() {
				player.AddCondEx(TF_COND_INVULNERABLE, 8.0, null)
			} )
		}
		else if (Merc.RSVFlags[9] == 2)
		{
			Merc.Delay(0.5, function() {
				player.AddCond(TF_COND_PREVENT_DEATH)
			} )
		}
	}
}

Merc.SetupConvars <- function()
{
	Convars.SetValue("mp_enableroundwaittime", Merc.WaitTimeConvar)
	
	if (Merc.ForcedTeam == TF_TEAM_RED)
		Convars.SetValue("mp_humans_must_join_team", "red")
	else if (Merc.ForcedTeam == TF_TEAM_BLUE)
		Convars.SetValue("mp_humans_must_join_team", "blue")
	else
		Convars.SetValue("mp_humans_must_join_team", "any")
	
	if (Merc.ForcedClass != 0)
		Convars.SetValue("mp_humans_must_join_class", TF_CLASS_NAMES[Merc.ForcedClass])
	else
		Convars.SetValue("mp_humans_must_join_class", "any")
}

Merc.OnUpdateHUD <- function() {}
Merc.OnSetHUD <- function(path) {}

Merc.HUD_String <- function(tkey, tvalue)
{
	SendGlobalGameEvent("solohud_string", {
		key = tkey,
		value = tvalue
	})
}
Merc.HUD_Int <- function(tkey, tvalue)
{
	SendGlobalGameEvent("solohud_int", {
		key = tkey,
		value = tvalue
	})
}
Merc.HUD_Float <- function(tkey, tvalue)
{
	SendGlobalGameEvent("solohud_float", {
		key = tkey,
		value = tvalue
	})
}
Merc.HUD_Event <- function(tkey, tvalue)
{
	SendGlobalGameEvent("solohud_event", {
		key = tkey,
		value = tvalue
	})
}

Merc.SetHUD <- function(path)
{
	SetSoloObjectivesResFile(path)
	Merc.OnSetHUD(path)
}

Merc.UpdateHUD <- function()
{
	Merc.HUD_String("objective1", Merc.GetObjText())
	Merc.HUD_String("objective2", Merc.GetBonusText())
	Merc.OnUpdateHUD()
}

