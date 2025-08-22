Merc.MissionStatus <- [
	1,1,0,0,0,0,0,0,0,0,0,0,
	1,1,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0]
Merc.CSFlags <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
Merc.RSVFlags <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
Merc.NGP <- 0
Merc.LastMissionID <- -1
Merc.RoundEndTime <- Convars.GetFloat("mp_bonusroundtime")
Merc.InitDone <- false
Merc.MainDone <- false
Merc.MainFailed <- false
Merc.ExtraDone <- false
Merc.ExtraFailed <- false
Merc.RoundEnded <- false
Merc.RoundResult <- 0
Merc.ExitCancel <- 0

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
Merc.AllowBuffs <- 1
Merc.CustomSpawnRED <- 0
Merc.CustomSpawnBLU <- 0
Merc.SpellRes <- {}
Merc.Canteen <- 0
Merc.TauntBoo <- 0

::AttrConv <- function(i)
{
	local b = blob(4)
	b.writen(i,105)
	b.seek(0)
	local v = b.readn(102)
	b.flush()
	return v
}

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
	Lives = 0
	OrigName = "notset"
	BotAdded = 0
	WarPaints = []
	Styles = []
	SpellType = [-1,1.0]
	SpawnPos = Vector(0,0,0)
	SpawnRot = 0
	ExtraData = []
	
	constructor (bteam, bskill, pname)
	{
		Preset = pname
		Team = bteam
		Skill = bskill
		Items = []
		Conds = []
		Attribs = []
		BotAttribs = []
		Flags = 0
		BotWpnFlags = 0
		Lives = 0
		OrigName = "notset"
		BotAdded = 0
		WarPaints = []
		Styles = []
		SpellType = [-1,1.0]
		SpawnPos = Vector(0,0,0)
		SpawnRot = 0
		ExtraData = []
	}
	
	function Start()
	{
		BotAdded = 0
		if (OrigName == "notset")
		{
			OrigName = Name
		}
		AddBot()
	}
	
	function AddBot()
	{
		if (Flags == 1) return
		if (BotAdded != 0) return
		BotAdded = 1
		if (Team == TF_TEAM_RED)
			ToConsole("tf_bot_add preset "+Preset+" red "+TFBOT_SKILLS[Skill]+"")
		else
			ToConsole("tf_bot_add preset "+Preset+" blue "+TFBOT_SKILLS[Skill]+"")
	}
	function KickBot()
	{
		if (BotAdded == 0) return
		ToConsole("tf_bot_kick \""+Name+"\"")
	}
	
	function OnSpawn(player)
	{
		Handle = player
		if (Merc.CustomSpawnRED != 0 && player.GetTeam() == TF_TEAM_RED) return
		if (Merc.CustomSpawnBLU != 0 && player.GetTeam() == TF_TEAM_BLUE) return
		foreach (i in Conds)
		{
			player.AddCond(i)
		}
		if (Flags & 2)
		{
			player.Teleport(true, SpawnPos, true, QAngle(0, SpawnRot, 0), true, Vector(0, 0, 0))
		}
	}
	function OnItems(player)
	{
		Handle = player
		if (Merc.CustomSpawnRED != 0 && player.GetTeam() == TF_TEAM_RED) return
		if (Merc.CustomSpawnBLU != 0 && player.GetTeam() == TF_TEAM_BLUE) return
		foreach (i in Items)
		{
			player.GenerateAndWearItem(i)
		}
	}
	
	function UpdateResupply(player)
	{
		Handle = player
		
		if (Merc.CustomSpawnRED != 0 && player.GetTeam() == TF_TEAM_RED) return
		if (Merc.CustomSpawnBLU != 0 && player.GetTeam() == TF_TEAM_BLUE) return
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
		if (SpellType[0] != -1)
		{
			local wsize = GetPropArraySize(player, "m_hMyWeapons")
			local wbook = null
			for (local i = 0; i < wsize; i++)
			{
				local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
				if (weapon == null || !weapon.IsValid()) continue;
				if (weapon.GetClassname() == "tf_weapon_spellbook")
				{
					wbook = weapon
				}
			}
			if (wbook != null)
			{
				SetPropInt(wbook,"m_iSelectedSpellIndex",SpellType[0])
				SetPropInt(wbook,"m_iSpellCharges",9)
				player.Weapon_Switch(wbook)
				SetPropEntity(player,"m_hActiveWeapon",wbook)
				player.AddCustomAttribute("disable weapon switch", 1.0, -1)
				SetPropEntity(player,"m_hActiveWeapon",wbook)
			}
		}
		if (WarPaints.len() != 0 || Styles.len() != 0)
		{
			local wsize = GetPropArraySize(player, "m_hMyWeapons")
			for (local i = 0; i < wsize; i++)
			{
				local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
				local item = GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")
				if (weapon == null || !weapon.IsValid()) continue;
				foreach (i in WarPaints)
				{
					if (i[0] == item)
					{
						weapon.AddAttribute("paintkit_proto_def_index", AttrConv(i[1]), -1)
						if (i.len() > 2)
						{
							weapon.AddAttribute("set_item_texture_wear", i[2], -1)
						}
						else
						{
							weapon.AddAttribute("set_item_texture_wear", 0.0, -1)
						}
						if (i.len() > 3)
						{
							weapon.AddAttribute("custom_paintkit_seed_lo", AttrConv(i[3]), -1)
							if (i.len() > 4)
							{
								weapon.AddAttribute("custom_paintkit_seed_hi", AttrConv(i[4]), -1)
							}
							else
							{
								weapon.AddAttribute("custom_paintkit_seed_hi", 0, -1)
							}
						}
					}
				}
				foreach (i in Styles)
				{
					if (i[0] == item)
					{
						if (i[1] != -1)
						{
							weapon.AddAttribute("item style override", i[1], -1)
						}
						if (i.len() > 2 && i[2] != -1)
						{
							weapon.AddAttribute("is_festivized", 1, -1)
						}
						if (i.len() > 3 && i[3] != -1)
						{
							weapon.AddAttribute("is australium item", 1, -1)
						}
						if (i.len() > 4 && i[4] != -1)
						{
							weapon.AddAttribute("set item tint RGB", i[4], -1)
						}
						if (i.len() > 5 && i[5] != -1)
						{
							weapon.AddAttribute("attach particle effect", i[5], -1)
						}
						if (i.len() > 6 && i[6] != -1)
						{
							weapon.AddAttribute("killstreak tier", i[6], -1)
						}
						if (i.len() > 7 && i[7] != -1)
						{
							weapon.AddAttribute("killstreak idleeffect", i[7], -1)
						}
						if (i.len() > 8 && i[8] != -1)
						{
							weapon.AddAttribute("killstreak effect", i[8], -1)
						}
						if (i.len() > 9 && i[9] != -1)
						{
							weapon.AddAttribute("kill eater", AttrConv(i[9]), -1)
						}
						if (i.len() > 10 && i[10] != -1)
						{
							weapon.AddAttribute("weapon_uses_stattrak_module", 1, -1)
						}
						if (i.len() > 11 && i[11] != -1)
						{
							weapon.AddAttribute("paintkit_proto_def_index", AttrConv(i[11]), -1)
						}
					}
				}
			}
		}
	}
	
	function OnDeath(player)
	{
		Handle = player
		if (Flags & 4)
		{
			if (Lives > 1)
			{
				Lives--
				Name = OrigName + " (" + Lives + "x)"
				SetFakeClientConVarValue(player, "name", Name)
				Merc.BotOnLifeLost(this)
			}
			else
			{
				local name = GetPropString(player, "m_szNetname")
				Merc.Delay(1.0, function() {
					ToConsole("tf_bot_kick \""+name+"\"")
				} )
				Merc.BotOnLivesDepleted(this)
			}
		}
		
	}
	
	function SwitchToBook()
	{
		try 
		{
			if (Handle == null) 
			{
				return -1
			}
		}
		catch (e)
		{
			return -1
		}
		local player = Handle
		local wsize = GetPropArraySize(player, "m_hMyWeapons")
		local wbook = null
		for (local i = 0; i < wsize; i++)
		{
			local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
			if (weapon == null || !weapon.IsValid()) continue;
			if (weapon.GetClassname() == "tf_weapon_spellbook")
			{
				wbook = weapon
			}
		}
		if (wbook != null)
		{
			SetPropInt(wbook,"m_iSelectedSpellIndex",SpellType[0])
			SetPropInt(wbook,"m_iSpellCharges",9)
			player.Weapon_Switch(wbook)
			SetPropEntity(player,"m_hActiveWeapon",wbook)
			player.AddCustomAttribute("disable weapon switch", 1.0, -1)
			SetPropEntity(player,"m_hActiveWeapon",wbook)
		}
	}
	
	function BotThink()
	{
		try 
		{
			if (Handle == null) 
			{
				return -1
			}
		}
		catch (e)
		{
			return -1
		}
		if (SpellType[0] != -1)
		{
			local wsize = GetPropArraySize(Handle, "m_hMyWeapons")
			local wbook = null
			for (local i = 0; i < wsize; i++)
			{
				local weapon = GetPropEntityArray(Handle, "m_hMyWeapons", i)
				if (weapon == null || !weapon.IsValid()) continue;
				if (weapon.GetClassname() == "tf_weapon_spellbook")
				{
					wbook = weapon
				}
			}
			if (wbook != null)
			{
				if (wbook != Handle.GetActiveWeapon())
				{
					Handle.Weapon_Switch(wbook)
					SetPropEntity(Handle,"m_hActiveWeapon",wbook)
					Handle.AddCustomAttribute("disable weapon switch", 1.0, -1)
					SetPropEntity(Handle,"m_hActiveWeapon",wbook)
				}
				local charges = GetPropInt(wbook,"m_iSpellCharges")
				if (charges != 0 && charges != 9)
				{
					SetPropFloat(Handle,"m_flNextAttack",Time() + SpellType[1])
					SetPropInt(wbook,"m_iSpellCharges",9)
					Merc.BotOnSpell(this,wbook)
				}
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
		Items = []
		Conds = []
		Attribs = []
		BotAttribs = []
		Flags = 0
		BotWpnFlags = 0
		Lives = 0
		OrigName = "notset"
		BotAdded = 0
		WarPaints = []
		Styles = []
		SpellType = [-1,1.0]
		SpawnPos = Vector(0,0,0)
		SpawnRot = 0
		ExtraData = []
	}
	
	function Start()
	{
		BotAdded = 0
		if (OrigName == "notset")
		{
			OrigName = Name
		}
		AddBot()
	}
	
	function AddBot()
	{
		if (Flags & 1) return
		if (Flags & 4)
		{
			Name = OrigName + " (" + Lives + "x)"
		}
		if (BotAdded != 0) return
		BotAdded = 1
		if (Team == TF_TEAM_RED)
			ToConsole("tf_bot_add 1 "+Merc.BotClassNames[Class]+" red "+TFBOT_SKILLS[Skill]+" \""+Name+"\" noquota")
		else
			ToConsole("tf_bot_add 1 "+Merc.BotClassNames[Class]+" blue "+TFBOT_SKILLS[Skill]+" \""+Name+"\" noquota")
	}
}

Merc.BotOnSpell <- function(a,book) { }
Merc.BotOnLifeLost <- function(a) { }
Merc.BotOnLivesDepleted <- function(a) { }

::MercBotThink <- function() {
	foreach (i in Merc.Bots){
		i.BotThink()
	}
}

Merc.LoadB <- function(t)
{
	local b = FileToString(t)
	md <- compilestring(b)
	md()
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
	ToConsole("tf_gamemode_override 0")
	ToConsole("cl_loadingimage_force 1")
	ToConsole("cl_loadingimage_override ../console/title_team_tough_break_widescreen")
	
	//if (IsDedicatedServer())
		ToConsole("changelevel " + Merc.MapFile)
	//else
	//	ToConsole("map " + Merc.MapFile)
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
				// Spell currency
				if (Merc.ForcedTeam == TF_TEAM_RED)
				{
					Merc.RSVFlags[0]++
				}
				else
				{
					Merc.RSVFlags[1]++
				}
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

Merc.ForceExtraDone <- function (soundtype2)
{
	if (Merc.ExtraDone) return
	Merc.ExtraDone = true
	Merc.OnExtraDone()
	Merc.ChatPrint(LOCM_OBJECTIVE_EXTRA_COMPLETED)
	if (soundtype2 == 1) EmitSoundEx({ sound_name = "ui/quest_status_tick_novice_complete.wav", })
	else if (soundtype2 == 2) EmitSoundEx({ sound_name = "ui/quest_status_tick_advanced_complete.wav", })
	else if (soundtype2 == 3) EmitSoundEx({ sound_name = "ui/quest_status_tick_expert_complete.wav", })
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
	if (Merc.CustomSpawnRED != 0 && player.GetTeam() == TF_TEAM_RED) return
	if (Merc.CustomSpawnBLU != 0 && player.GetTeam() == TF_TEAM_BLUE) return
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
		if (Merc.RSVFlags[5] == 1 && Merc.AllowBuffs != 0)
		{
			Merc.Delay(1.0, function() {
				player.RemoveCustomAttribute("clip size bonus")
				player.AddCustomAttribute("clip size bonus", 1.25, -1)
			} )
		}
		if (Merc.RSVFlags[5] == 2 && Merc.AllowBuffs != 0)
		{
			Merc.Delay(1.0, function() {
				player.RemoveCustomAttribute("maxammo primary increased")
				player.RemoveCustomAttribute("maxammo secondary increased")
				player.AddCustomAttribute("maxammo primary increased", 1.5, -1)
				player.AddCustomAttribute("maxammo secondary increased", 1.5, -1)
			} )
		}
		else if (Merc.RSVFlags[5] == 3 && Merc.AllowHandicaps != 0)
		{
			Merc.Delay(1.0, function() {
				player.AddCond(TF_COND_MARKEDFORDEATH)
			} )
		}
		if (Merc.RSVFlags[6] == 3 && Merc.AllowHandicaps != 0)
		{
			Merc.Delay(1.0, function() {
				local hp = player.GetMaxHealth() / 10
				player.SetHealth(hp.tointeger())
			} )
		}
	}
	else if (Merc.ForcedTeam == TF_TEAM_BLUE)
	{
		if (Merc.RSVFlags[8] == 1 && Merc.AllowBuffs != 0)
		{
			Merc.Delay(1.0, function() {
				local hp = player.GetMaxHealth() / 10
				local targethp = player.GetMaxHealth() + hp.tointeger()
				player.RemoveCustomAttribute("hidden maxhealth non buffed")
				player.AddCustomAttribute("hidden maxhealth non buffed", targethp, -1)
				player.SetHealth(targethp)
			} )
		}
		else if (Merc.RSVFlags[8] == 2 && Merc.AllowBuffs != 0)
		{
			Merc.Delay(1.0, function() {
				player.RemoveCustomAttribute("overheal bonus")
				player.AddCustomAttribute("overheal bonus", 2.0, -1)
			} )
		}
		else if (Merc.RSVFlags[8] == 3 && Merc.AllowHandicaps != 0)
		{
			Merc.Delay(1.0, function() {
				player.AddCond(TF_COND_MAD_MILK)
			} )
		}
		if (Merc.RSVFlags[9] == 3)
		{
			Merc.Delay(0.5, function() {
				player.RemoveCustomAttribute("crit does no damage")
				player.AddCustomAttribute("crit does no damage", 1.0, -1)
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

::MercTauntBuffThink_1 <- function()
{
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a) && a.IsTaunting())
		{
			if (!a.InCond(TF_COND_MEDIGUN_SMALL_BULLET_RESIST))
			{
				a.AddCondEx(TF_COND_MEDIGUN_SMALL_BULLET_RESIST,10.0,a)
			}
		}
	}
}
::MercTauntBuffThink_2 <- function()
{
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a) && a.IsTaunting())
		{
			if (a.GetHealth() >= a.GetMaxHealth())
			{
				local hp = a.GetMaxHealth() * 1.5
				a.SetHealth(hp.tointeger())
			}
		}
	}
}
::MercTauntBuffThink_3 <- function()
{
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a) && a.IsTaunting())
		{
			if (!a.InCond(TF_COND_MEDIGUN_SMALL_BLAST_RESIST))
			{
				a.AddCondEx(TF_COND_MEDIGUN_SMALL_BLAST_RESIST,10.0,a)
			}
		}
	}
}
::MercTauntBuffThink_4 <- function()
{
	if (Merc.TauntBoo != 0) return
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a) && a.IsTaunting())
		{
			Merc.TauntBoo = 1
			local ghost = SpawnEntityFromTable("ghost", {
				origin       = a.GetOrigin(),
				angles       = a.GetAbsAngles(),
				rendermode	 = kRenderNone,
			})
			Merc.Delay(0.5, function() {
				ghost.Kill()
				a.RemoveCond(TF_COND_STUNNED)
			} )
			Merc.Delay(5.0, function() {
				Merc.TauntBoo = 0
			} )
		}
	}
}

Merc.GetEnemyTeam <- function()
{
	if (Merc.ForcedTeam == TF_TEAM_RED)
	{
		return TF_TEAM_BLUE
	}
	return TF_TEAM_RED
}

Merc.ArrayContains <- function(a, e)
{
	foreach (i,v in a)
	{
		if (v == e) return i
	}
	return null
}

Merc.ActionItemIDs <- [233,234,241,280,281,282,283,284,286,288,362,364,365,493,542,599,577,729,790,791,928,1037,1126,1195,5086,5087,5718,5741,5772,5773]

Merc.GiveSpellbook <- function(player)
{
	local wsize = GetPropArraySize(player, "m_hMyWeapons")
	local wbook = null
	local bookclass = "tf_weapon_spellbook"
	for (local i = 0; i < wsize; i++)
    {
        local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null || !weapon.IsValid()) continue;
		if (weapon.GetClassname() == bookclass)
		{
			wbook = weapon
			wbook.ValidateScriptScope()
			if (!("LastSpellCount" in wbook.GetScriptScope()))
			{
				wbook.GetScriptScope()["LastSpellCount"] <- -1
				wbook.GetScriptScope()["LastSpellType"] <- -9
				AddThinkToEnt(wbook,"MercSpellbookThink")
			}
		}
		else if (weapon.GetSlot() == 5 && weapon.GetClassname() != "tf_weapon_pda_engineer_destroy" && weapon.GetClassname() != "tf_weapon_builder")
		{
			weapon.Destroy()
			SetPropEntityArray(player, "m_hMyWeapons", null, i)
		}
    }
	
	if (wbook == null)
	{
		local ent = null
		if (Merc.Canteen != 0)
		{
			while (ent = Entities.FindByClassname(ent, "tf_powerup_bottle"))
			{
				if (ent.GetOwner() == player) { return; }
			}
		}
		while (ent = Entities.FindByClassname(ent, "tf_wearable_campaign_item"))
		{
			if (ent.GetOwner() == player) { ent.Destroy() }
		}
		while (ent = Entities.FindByClassname(ent, bookclass))
		{
			if (ent.GetOwner() == player) { ent.Destroy() }
		}
		while (ent = Entities.FindByClassname(ent, "tf_powerup_bottle"))
		{
			if (ent.GetOwner() == player) { ent.Destroy() }
		}
		while (ent = Entities.FindByClassname(ent, "tf_wearable"))
		{
			if (ent.GetOwner() == player) { 
				local item = GetPropInt(ent, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")
				if (Merc.ArrayContains(Merc.ActionItemIDs,item) != null)
				{
					ent.Destroy()
				}
			}
		}
		wbook = Entities.CreateByClassname("tf_weapon_spellbook")
		SetPropInt(wbook, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 1069)
		SetPropBool(wbook, "m_AttributeManager.m_Item.m_bInitialized", true)
		SetPropBool(wbook, "m_bValidatedAttachedEntity", true)
		SetPropEntity(wbook, "m_hOwner", player)
		SetPropEntity(wbook, "m_hOwnerEntity", player)
		SetPropString(wbook, "m_iszName", "loanerbook")
		wbook.SetTeam(player.GetTeam())
		wbook.SetOwner(player)
		local flags = GetPropInt(wbook, "m_Collision.m_usSolidFlags")
		SetPropInt(wbook, "m_Collision.m_usSolidFlags", flags | FSOLID_NOT_SOLID)
		flags = GetPropInt(wbook, "m_Collision.m_usSolidFlags")
		SetPropInt(wbook, "m_Collision.m_usSolidFlags", flags & ~(FSOLID_TRIGGER))
		Entities.DispatchSpawn(wbook)
		wbook.AcceptInput("SetParent", "!activator", player, player)
		player.Weapon_Equip(wbook)
		
		local pm = Entities.FindByClassname(null, "tf_player_manager")
		local userid = GetPropIntArray(pm, "m_iUserID", player.entindex())
		local rsv = [-1,0]
		if (userid in Merc.SpellRes)
		{
			rsv = Merc.SpellRes[userid]
		}
		SetPropInt(wbook, "m_iSelectedSpellIndex", rsv[0])
		SetPropInt(wbook, "m_iSpellCharges", rsv[1])
		wbook.ValidateScriptScope()
		wbook.GetScriptScope()["LastSpellCount"] <- rsv[1]
		wbook.GetScriptScope()["LastSpellType"] <- rsv[0]
		AddThinkToEnt(wbook,"MercSpellbookThink")
	}
}

::MercSpellbookThink <- function()
{
	local spell = GetPropInt(self,"m_iSelectedSpellIndex")
	local count = GetPropInt(self,"m_iSpellCharges")
	if ((count != 0 && LastSpellCount <= 0) || (spell != LastSpellType && spell >= 0))
	{
		if (spell < 12 && spell >= 0)
		{
			SetPropInt(self,"m_iSpellCharges",Merc.RSVFlags[spell+13]+1)
		}
		else if (spell == 14)
		{
			SetPropInt(self,"m_iSpellCharges",Merc.RSVFlags[15]+1)
		}
	}
	LastSpellCount <- count
	LastSpellType <- spell
	return -1
}

Merc.DisplayTrMsg <- function(header,txt,time)
{
	local train = SpawnEntityFromTable("tf_logic_training_mode", {})
	local rules = Entities.FindByClassname(null, "tf_gamerules")
	SetPropBool(rules, "m_bIsInTraining", true)
	SetPropBool(rules, "m_bIsTrainingHUDVisible", true)
	train.AcceptInput("ShowTrainingObjective",header,null,null)
	train.AcceptInput("ShowTrainingMsg",txt,null,null)
	
	Merc.Delay(time, function() { 
		local rules = Entities.FindByClassname(null, "tf_gamerules")
		SetPropBool(rules, "m_bIsInTraining", false)
		SetPropBool(rules, "m_bIsTrainingHUDVisible", false)
		Entities.FindByClassname(null, "tf_logic_training_mode").Destroy()
	} )
}
Merc.SetTrMsg <- function(header,txt)
{
	local train = Entities.FindByClassname(null, "tf_logic_training_mode")
	if (train != null)
	{
		train.AcceptInput("ShowTrainingObjective",header,null,null)
		train.AcceptInput("ShowTrainingMsg",txt,null,null)
	}
}

