Merc.CutsceneActive <- false
Merc.BriefingActive <- false
Merc.HubEnteredRED <- false
Merc.HubEnteredBLU <- false
Merc.IsBLU <- false
Merc.MissionStarting <- false
Merc.BriefingFuncs <- []
Merc.CutsceneID <- -1
Merc.SubsActive <- false
Merc.SubsType <- 0
Merc.SubsIcon <- ""
Merc.SubsText <- ""
Merc.SubsTimer <- null
Merc.LastChoiceResult <- -1
Merc.ChoiceType <- 0
Merc.ChoiceProp1 <- null
Merc.ChoiceProp2 <- null
Merc.BadAnswerCount <- 0

Merc.HandlerRED <- null
Merc.HandlerBLU <- null
Merc.HandlerRED_Attach <- [
	"models/workshop/player/items/all_class/dec17_truckers_topper/dec17_truckers_topper_engineer.mdl",
	"models/workshop/player/items/all_class/cc_summer2015_support_spurs/cc_summer2015_support_spurs_engineer.mdl",
	"models/workshop/player/items/engineer/sum24_desk_engineer_style4/sum24_desk_engineer_style4.mdl",
	"models/workshop/player/items/engineer/hwn2015_western_beard/hwn2015_western_beard.mdl",
]
Merc.HandlerBLU_Attach <- [
	"models/workshop/player/items/scout/sbox2014_ticket_boy/sbox2014_ticket_boy.mdl",
	"models/workshop/player/items/scout/dec18_millennial_mercenary/dec18_millennial_mercenary.mdl",
	"models/workshop/player/items/all_class/jogon/jogon_scout.mdl",
	"models/workshop/player/items/scout/dec15_hot_heels/dec15_hot_heels.mdl",
]
foreach (a in Merc.HandlerRED_Attach)
{
	PrecacheModel(a)
}
foreach (a in Merc.HandlerBLU_Attach)
{
	PrecacheModel(a)
}
Merc.Handler_Anims <- [
	"taunt_killer_time_intro",
	"taunt_the_homerunners_hobby",
	"taunt_cyoa_PDA_idle",
	"competitive_loserstate_idle",
	"competitive_winnerstate_idle",
]
::MHBLU_BlinkTimer <- 0.0
::MHBLU_BlinkState <- 0
::MHBLU_BlinkAnim <- 0.0
::MHRED_Anim <- 0
::MHBLU_Anim <- 1
::MHRED_Origin <- Vector(-1596,14,77)
::MHBLU_Origin <- Vector(-2087,-9,75)

Merc.SpawnActorRED <- function()
{
	if (Merc.HandlerRED != null)
	{
		Merc.HandlerRED.Destroy()
	}
	PrecacheModel("models/player/engineer.mdl")
	Merc.HandlerRED = Entities.CreateByClassname("funCBaseFlex")
	Merc.HandlerRED.SetModel("models/player/engineer.mdl")
	Merc.HandlerRED.SetAbsOrigin(MHRED_Origin)
	Merc.HandlerRED.SetAbsAngles(QAngle(0, 0, 0))
	Merc.HandlerRED.SetPlaybackRate(1.0)
	Merc.HandlerRED.SetSequence(Merc.HandlerRED.LookupSequence("taunt_killer_time_intro"))
	Merc.HandlerRED.DispatchSpawn()
	Merc.HandlerRED.EmitSound("Engineer.Cheers01")
	SetPropString(Merc.HandlerRED,"targetname","mhandler_red")
	SetPropString(Merc.HandlerRED,"m_iName","mhandler_red")
	SetPropInt(Merc.HandlerRED,"m_nBody",1)
	AddThinkToEnt(Merc.HandlerRED, "MercHandlerThinkRED")
	
	foreach (a in Merc.HandlerRED_Attach)
	{
		local ent = SpawnEntityFromTable("prop_dynamic_ornament", {
			model = a,
			InitialOwner = "mhandler_red",
		})
		ent.AcceptInput("SetParent", "!activator", Merc.HandlerRED, Merc.HandlerRED)
		SetPropInt(ent, "m_fEffects", EF_BONEMERGE | EF_BONEMERGE_FASTCULL)
	}
}

Merc.SpawnActorBLU <- function()
{
	if (Merc.HandlerBLU != null)
	{
		Merc.HandlerBLU.Destroy()
	}
	PrecacheModel("models/player/scout.mdl")
	Merc.HandlerBLU = Entities.CreateByClassname("funCBaseFlex")
	Merc.HandlerBLU.SetModel("models/player/scout.mdl")
	Merc.HandlerBLU.SetAbsOrigin(MHBLU_Origin)
	Merc.HandlerBLU.SetAbsAngles(QAngle(0, 0, 0))
	Merc.HandlerBLU.SetPlaybackRate(1.0)
	Merc.HandlerBLU.SetSkin(1)
	Merc.HandlerBLU.SetSequence(Merc.HandlerBLU.LookupSequence("taunt_the_homerunners_hobby"))
	Merc.HandlerBLU.DispatchSpawn()
	Merc.HandlerBLU.EmitSound("Scout.Cheers01")
	SetPropString(Merc.HandlerBLU,"targetname","mhandler_blu")
	SetPropString(Merc.HandlerBLU,"m_iName","mhandler_blu")
	SetPropInt(Merc.HandlerBLU,"m_nBody",3)
	AddThinkToEnt(Merc.HandlerBLU, "MercHandlerThinkBLU")
	
	foreach (a in Merc.HandlerBLU_Attach)
	{
		local ent = SpawnEntityFromTable("prop_dynamic_ornament", {
			model = a,
			InitialOwner = "mhandler_blu",
			skin = 1,
		})
		ent.AcceptInput("SetParent", "!activator", Merc.HandlerBLU, Merc.HandlerBLU)
		SetPropInt(ent, "m_fEffects", EF_BONEMERGE | EF_BONEMERGE_FASTCULL)
	}
}

Merc.HandlerRED_SetAnim <- function(a,reset = 0)
{
	MHRED_Anim = a
	Merc.HandlerRED.SetSequence(Merc.HandlerRED.LookupSequence(Merc.Handler_Anims[a]))
	if (reset == 0)
	{
		Merc.HandlerRED.ResetSequence(Merc.HandlerRED.GetSequence())
	}
}
Merc.HandlerBLU_SetAnim <- function(a,reset = 0)
{
	MHBLU_Anim = a
	Merc.HandlerBLU.SetSequence(Merc.HandlerBLU.LookupSequence(Merc.Handler_Anims[a]))
	if (reset == 0)
	{
		Merc.HandlerBLU.ResetSequence(Merc.HandlerBLU.GetSequence())
	}
}

::SetFlex <- function(i,w)
{
	SetPropFloatArray(self,"m_flexWeight",w,i)
}

::MercHandlerThinkRED <- function()
{
	switch (MHRED_Anim) {
		case 0: 
		{
			if (self.GetCycle() > 0.98)
			{
				self.StopAnimation()
				self.SetCycle(0.65)
				self.ResetSequence(self.GetSequence())
			}
			if (self.GetCycle() < 0.65)
			{
				self.SetCycle(0.65)
			}
			break;
		}
		default: { break; }
	}
	SetFlex(24,1.0)
	self.StudioFrameAdvance()
	return -1
}

::MercHandlerThinkBLU <- function()
{
	switch (MHBLU_Anim) {
		case 1: 
		{
			if (self.GetCycle() > 0.98)
			{
				self.StopAnimation()
				self.SetCycle(0.74)
				self.ResetSequence(self.GetSequence())
			}
			if (self.GetCycle() < 0.74)
			{
				self.SetCycle(0.74)
			}
			break;
		}
		default: { break; }
	}
	MHBLU_BlinkTimer -= FrameTime()
	if (MHBLU_BlinkState == 0)
	{
		MHBLU_BlinkAnim -= FrameTime() * 10.0
		if (MHBLU_BlinkAnim < 0.0)
		{
			MHBLU_BlinkAnim = 0.0
		}
	}
	else
	{
		MHBLU_BlinkAnim += FrameTime() * 10.0
		if (MHBLU_BlinkAnim > 1.0)
		{
			MHBLU_BlinkAnim = 1.0
		}
	}
	SetFlex(0,MHBLU_BlinkAnim)
	SetFlex(1,MHBLU_BlinkAnim)
	SetFlex(2,MHBLU_BlinkAnim)
	SetFlex(3,MHBLU_BlinkAnim)
	if (MHBLU_BlinkTimer < 0.0)
	{
		if (MHBLU_BlinkState == 0)
		{
			MHBLU_BlinkState = 1
			MHBLU_BlinkTimer = RandomFloat(0.1,0.4)
		}
		else
		{
			MHBLU_BlinkState = 0
			MHBLU_BlinkTimer = RandomFloat(2.0,10.0)
		}
	}
	
	SetFlex(22,1.0)
	
	self.StudioFrameAdvance()
	return -1
}

Merc.ApplyCutsceneProgress <- function()
{
	if (Merc.CSFlags[16] == 0)
	{
		local ent = null
		while (ent = Entities.FindByName(ent, "notice_pcorner"))
		{
			SetPropInt(ent, "m_iTextureFrameIndex", 1)
			SetPropInt(ent, "texframeindex", 1)
		}
	}
	if (Merc.RSVFlags[10] == 0)
	{
		local ent = null
		while (ent = Entities.FindByName(ent, "notice_friendly"))
		{
			SetPropInt(ent, "m_iTextureFrameIndex", 1)
			SetPropInt(ent, "texframeindex", 1)
		}
	}
}

Merc.RandomEventRED <- function()
{
	if (Merc.RSVFlags[4] == 1 && RandomInt(0,1) == 0)
	{
		local delay = RandomFloat(0.5,1.5)
		local part = Entities.FindByName(null, "recruit_voicepart_red")
		Merc.Delay(delay, function() { 
			Merc.BotSpeak(2,"toughbreak_win_contract_soldier")
			local pos = Merc.HubBots[2].Handle.GetOrigin()
			part.SetAbsOrigin(pos + Vector(0,0,65)) //30
			part.AcceptInput("Start","",null,null)
		} )
		Merc.Delay(2.0 + delay, function() { 
			part.SetAbsOrigin(Vector(450,929,0))
		} )
	}
	else
	{
		
	}
}

Merc.RandomEventBLU <- function()
{
	if (Merc.RSVFlags[7] == 1 && RandomInt(0,1) == 0)
	{
		local delay = RandomFloat(0.5,1.5)
		local part = Entities.FindByName(null, "recruit_voicepart_blu")
		Merc.Delay(delay, function() { 
			Merc.BotSpeak(3,"toughbreak_win_contract_sniper")
			local pos = Merc.HubBots[3].Handle.GetOrigin()
			part.SetAbsOrigin(pos + Vector(0,0,65)) //30
			part.AcceptInput("Start","",null,null)
		} )
		Merc.Delay(2.0 + delay, function() { 
			part.SetAbsOrigin(Vector(309,-835,0))
		} )
	}
	else
	{
		
	}
}

Merc.TrigEnter <- function(id)
{
	if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
	local csStarted = 0
	if (id == MercHubTrig.RED_Enter && !Merc.HubEnteredRED)
	{
		Merc.HubEnteredRED = true
		local prog = Merc.GetProgCount(TF_TEAM_RED, false)
		local prog2 = Merc.GetProgCount(TF_TEAM_BLUE, false)
		local bonus = Merc.GetProgCount(TF_TEAM_RED, true)
		if (Merc.CSFlags[0] == 0)
		{
			// RED Intro
			Merc.CSFlags[0] = 1
			Merc.CS_IntroRED()
			csStarted = 1
		}
		else if (Merc.CSFlags[2] == 0 && prog >= 2)
		{
			// RED Choice 1
			Merc.CSFlags[2] = 1
			Merc.CS_Choice1_RED()
			csStarted = 1
		}
		else if (Merc.CSFlags[3] == 0 && prog >= 4)
		{
			// RED Choice 2
			Merc.CSFlags[3] = 1
			Merc.CS_Choice2_RED()
			csStarted = 1
		}
		else if (Merc.CSFlags[4] == 0 && prog >= 6)
		{
			// RED Choice 3
			Merc.CSFlags[4] = 1
			Merc.CS_Choice3_RED()
			csStarted = 1
		}
		else if (Merc.CSFlags[12] == 0 && prog >= 10 && prog2 >= 10)
		{
			// RED Final Mission Available
			Merc.CSFlags[12] = 1
			Merc.CS_FinalMissionOpenRED()
			csStarted = 1
		}
		else if (Merc.CSFlags[14] == 0 && Merc.MissionStatus[24] >= 2)
		{
			// RED Ending
			Merc.CSFlags[14] = 1
			Merc.CS_EndingRED()
			csStarted = 1
		}
		else if (Merc.CSFlags[8] == 0 && bonus >= 3)
		{
			// RED Weapon 1
			Merc.CSFlags[8] = 1
			Merc.CS_Weapon1_RED()
			csStarted = 1
		}
		else if (Merc.CSFlags[9] == 0 && bonus >= 9)
		{
			// RED Weapon 2
			Merc.CSFlags[9] = 1
			Merc.CS_Weapon2_RED()
			csStarted = 1
		}
		else if (Merc.CSFlags[18] == 0 && bonus >= 13)
		{
			// RED 100%
			Merc.CSFlags[18] = 1
			Merc.CS_RED_Complete()
		}
		
		if (!Merc.CutsceneActive && csStarted == 0)
		{
			Merc.RandomEventRED()
		}
		
		local fade = Entities.FindByName(null, "fadeoverlay_red")
		SetPropInt(fade, "m_nRenderFX", Constants.ERenderFx.kRenderFxFadeFast)
	}
	else if (id == MercHubTrig.BLU_Enter && !Merc.HubEnteredBLU)
	{
		Merc.HubEnteredBLU = true
		local prog = Merc.GetProgCount(TF_TEAM_BLUE, false)
		local prog2 = Merc.GetProgCount(TF_TEAM_RED, false)
		local bonus = Merc.GetProgCount(TF_TEAM_BLUE, true)
		if (Merc.CSFlags[1] == 0)
		{
			// BLU Intro
			Merc.CSFlags[1] = 1
			Merc.CS_IntroBLU()
			csStarted = 1
		}
		else if (Merc.CSFlags[5] == 0 && prog >= 2)
		{
			// BLU Choice 1
			Merc.CSFlags[5] = 1
			Merc.CS_Choice1_BLU()
			csStarted = 1
		}
		else if (Merc.CSFlags[6] == 0 && prog >= 4)
		{
			// BLU Choice 2
			Merc.CSFlags[6] = 1
			Merc.CS_Choice2_BLU()
			csStarted = 1
		}
		else if (Merc.CSFlags[7] == 0 && prog >= 6)
		{
			// BLU Choice 3
			Merc.CSFlags[7] = 1
			Merc.CS_Choice3_BLU()
			csStarted = 1
		}
		else if (Merc.CSFlags[13] == 0 && prog >= 10 && prog2 >= 10)
		{
			// BLU Final Mission Available
			Merc.CSFlags[13] = 1
			Merc.CS_FinalMissionOpenBLU()
			csStarted = 1
		}
		else if (Merc.CSFlags[15] == 0 && Merc.MissionStatus[25] >= 2)
		{
			// BLU Ending
			Merc.CSFlags[15] = 1
			Merc.CS_EndingBLU()
			csStarted = 1
		}
		else if (Merc.CSFlags[10] == 0 && bonus >= 3)
		{
			// BLU Weapon 1
			Merc.CSFlags[10] = 1
			Merc.CS_Weapon1_BLU()
			csStarted = 1
		}
		else if (Merc.CSFlags[11] == 0 && bonus >= 9)
		{
			// BLU Weapon 2
			Merc.CSFlags[11] = 1
			Merc.CS_Weapon2_BLU()
			csStarted = 1
		}
		else if (Merc.CSFlags[19] == 0 && bonus >= 13)
		{
			// BLU 100%
			Merc.CSFlags[19] = 1
			Merc.CS_BLU_Complete()
		}
		
		if (!Merc.CutsceneActive && csStarted == 0)
		{
			Merc.RandomEventBLU()
		}
		
		local fade = Entities.FindByName(null, "fadeoverlay_blue")
		SetPropInt(fade, "m_nRenderFX", Constants.ERenderFx.kRenderFxFadeSlow)
	}
	else if (id == MercHubTrig.RED_PCorner)
	{
		if (Merc.CSFlags[16] != 0) return
		Merc.CSFlags[16] = 1
		Merc.CS_PCorner()
	}
}

Merc.StartPressed <- function(isBLU)
{
	Merc.IsBLU = isBLU
	Merc.CutsceneActive = true
	Merc.BriefingActive = true
	ClientPrint(null, HUD_PRINTTALK, "Type 's' in chat to skip the briefing.")
	Merc.StartBriefing()
	SendGlobalGameEvent("hide_annotation", { id = 10, })
	SendGlobalGameEvent("hide_annotation", { id = 11, })
	SendGlobalGameEvent("hide_annotation", { id = 15, })
	Merc.HideCrosshair()
}

Merc.StartBonusPressed <- function()
{
	Merc.CutsceneActive = true
	Merc.BriefingActive = true
	SendGlobalGameEvent("hide_annotation", {
		id = 10,
	})
	SendGlobalGameEvent("hide_annotation", {
		id = 11,
	})
	SendGlobalGameEvent("hide_annotation", {
		id = 15,
	})
	if (Merc.MissionStarting) return
	Convars.SetValue("mp_restartblock", 2)
	Merc.MissionStarting = true
	foreach (a in GetClients()) 
	{
		a.AddHudHideFlags(HIDEHUD_ALL)
	}
	local mfade = Entities.FindByName(null, "endfade")
	EntFireByHandle(mfade, "Fade", wtext, 2.5, null, null)
	
	PrecacheSound("ui/duel_challenge.wav")
	Merc.Delay(1.0, function() { 
		EmitSoundEx({ sound_name = "ui/duel_challenge.wav", })
	} )
	Merc.Delay(4.9, function() { 
		ToConsole("tf_bot_kick all")
	} )
	
	Merc.Delay(5.0, function() { Merc.StartMission() } )
	
	Merc.Delay(10.0, function() { 
		foreach (a in GetClients()) 
		{
			a.RemoveHudHideFlags(HIDEHUD_ALL)
		}
		ClientPrint(null, HUD_PRINTTALK, "ERROR: If you're still here then something went wrong!")
		Convars.SetValue("mp_restartblock", 0)
	} )
}

Merc.MissionStartCutscene <- function(isBLU)
{
	if (Merc.MissionStarting) return
	Convars.SetValue("mp_restartblock", 2)
	Merc.MissionStarting = true
	EntFire("monitor_red", "SetCamera", "cam_mission_red")
	EntFire("monitor_blu", "SetCamera", "cam_mission_blu")
	local team = "red"
	if (isBLU) team = "blu"
	local wtext = LOCM_MISSION_STARTING + "\n"
	wtext += Merc.Missions[Merc.MissionID].MapName + "\n"
	wtext += Merc.Missions[Merc.MissionID].ModeName + "\n"
	local mtext = Entities.FindByName(null, "wtext_monitor_" + team)
	mtext.AcceptInput("SetText",wtext,null,null)
	local mfade = Entities.FindByName(null, "endfade")
	EntFireByHandle(mfade, "Fade", wtext, 2.5, null, null)
	foreach (a in GetClients()) 
	{
		a.AddHudHideFlags(HIDEHUD_ALL)
	}
	/* last minute removal due to bug causing invisible models :(
	local viewcam = Entities.FindByName(null, "endview_" + team)
	foreach (a in GetClients()) 
	{
		viewcam.AcceptInput("Enable","",a,null)
		EntFireByHandle(viewcam, "Disable", "", 4.0, a, null)
		EntFireByHandle(viewcam, "Kill", "", 4.0, a, null)
	}
	*/
	PrecacheSound("ui/duel_challenge.wav")
	Merc.Delay(1.0, function() { 
		EmitSoundEx({ sound_name = "ui/duel_challenge.wav", })
	} )
	Merc.Delay(4.9, function() { 
		ToConsole("tf_bot_kick all")
	} )
	
	Merc.Delay(5.0, function() { Merc.StartMission() } )
	
	Merc.Delay(10.0, function() { 
		foreach (a in GetClients()) 
		{
			a.RemoveHudHideFlags(HIDEHUD_ALL)
		}
		ClientPrint(null, HUD_PRINTTALK, "ERROR: If you're still here then something went wrong!")
		Convars.SetValue("mp_restartblock", 0)
	} )
}

Merc.EndCutsceneGeneric <- function()
{
	if (Merc.BriefingActive || Merc.MissionStarted || Merc.MissionStarting) return
	Merc.CutsceneActive = false
	Merc.UpdateMonitors()
	EntFire("monitor_red", "SetCamera", "cam_mission_red")
	EntFire("monitor_blu", "SetCamera", "cam_mission_blu")
}

Merc.EndBriefing <- function()
{
	local ent = null
	while (ent = Entities.FindByName(ent, "monitor_audio_red"))
	{
		ent.AcceptInput("Volume","0",null,null)
	}
	ent = null
	while (ent = Entities.FindByName(ent, "monitor_audio_blu"))
	{
		ent.AcceptInput("Volume","0",null,null)
	}
	Merc.SubsActive = false
	Merc.MissionStartCutscene(Merc.IsBLU)
}

function InstSceneThink()
{
	local ent = null
	while( ent = Entities.FindByClassname(ent, "instanced_scripted_scene") )
	{
		local player = GetPropEntity(ent, "m_hOwner")
		if (player != null && !IsPlayerABot(player) && GetPropBool(ent, "m_bIsBackground") == false)
		{
			if (ent.ValidateScriptScope() && ent.GetScriptScope().keys().find("MercTest") == null)
			{
				ent.GetScriptScope()["MercTest"] <- 1
				local scene = GetPropString(ent, "m_iszSceneFile")
				if (ArrayContains(Merc.SceneFiles_Yes, scene))
				{
					Merc.LastChoiceResult = 1
				}
				else if (ArrayContains(Merc.SceneFiles_No, scene))
				{
					Merc.LastChoiceResult = 2
				}
				else if (ArrayContains(Merc.SceneFiles_Left, scene))
				{
					Merc.LastChoiceResult = 3
				}
				else if (ArrayContains(Merc.SceneFiles_Right, scene))
				{
					Merc.LastChoiceResult = 4
				}
				else
				{
					Merc.LastChoiceResult = 0
				}
				SetPropString(Entities.FindByClassname(null, "tf_gamerules"), "m_iszScriptThinkFunction", "")
				SendGlobalGameEvent("hide_annotation", { id = 10, })
				SendGlobalGameEvent("hide_annotation", { id = 11, })
				Merc.Delay(2.0, function() { 
					Merc.ChoiceComplete()
				} )
			}
		}
	}
}

Merc.StartChoice <- function()
{
	if (Merc.MissionStarted || Merc.MissionStarting) return
	AddThinkToEnt(Entities.FindByClassname(null, "tf_gamerules"), "InstSceneThink")
}

::MercSubsThink <- function()
{
	if (!Merc.SubsActive) return
	local subs_ent = "subtitles_grey"
	if (Merc.SubsType == 1) subs_ent = "subtitles_red"
	if (Merc.SubsType == 2) subs_ent = "subtitles_blue"
	SetPropString(Entities.FindByName(null, subs_ent), "m_iszMessage", Merc.SubsText)
	EntFire(subs_ent,"Display")
}

Merc.SetMonitorHandlerRED <- function(brief = false)
{
	if (Merc.MissionStarting) return
	EntFire("monitor_red", "SetCamera", "cam_handler_red")
}
Merc.SetMonitorHandlerBLU <- function()
{
	if (Merc.MissionStarting) return
	EntFire("monitor_blu", "SetCamera", "cam_handler_blu")
}
Merc.SetMonitorHandlerRED_BLU <- function()
{
	if (Merc.MissionStarting) return
	EntFire("monitor_red", "SetCamera", "cam_handler_blu")
}
Merc.SetMonitorHandlerBLU_RED <- function()
{
	if (Merc.MissionStarting) return
	EntFire("monitor_blu", "SetCamera", "cam_handler_red")
}
Merc.StartAudioRED <- function(msg, time, delay = 0.5)
{
	if (Merc.MissionStarting) return
	local part = Entities.FindByName(null, "handler_red_voicepart")
	local voice = Entities.FindByName(null, "monitor_audio_red")
	local handler = Entities.FindByName(null, "handler_red")
	voice.PrecacheSoundScript(msg)
	local ent = null
	while (ent = Entities.FindByName(ent, "monitor_audio_red"))
	{
		ent.AcceptInput("Volume","0",null,null)
		SetPropString(ent, "message", msg)
		SetPropString(ent, "m_iszSound", msg)
	}
	Merc.Delay(delay, function() { 
		part.SetAbsOrigin(Vector(-1603,3,120))
		part.AcceptInput("Start","",null,null)
		EntFire("monitor_audio_red","PlaySound")
	} )
	Merc.Delay(time + delay, function() { 
		part.SetAbsOrigin(Vector(-1603,3,0))
	} )
}
Merc.StartAudioBLU <- function(msg, time, delay = 0.5)
{
	if (Merc.MissionStarting) return
	local part = Entities.FindByName(null, "handler_blu_voicepart")
	local voice = Entities.FindByName(null, "monitor_audio_blu")
	local handler = Entities.FindByName(null, "handler_blu")
	voice.PrecacheSoundScript(msg)
	local ent = null
	while (ent = Entities.FindByName(ent, "monitor_audio_blu"))
	{
		ent.AcceptInput("Volume","0",null,null)
		SetPropString(ent, "message", msg)
		SetPropString(ent, "m_iszSound", msg)
	}
	Merc.Delay(delay, function() { 
		part.SetAbsOrigin(Vector(-2095,3,120))
		part.AcceptInput("Start","",null,null)
		EntFire("monitor_audio_blu","PlaySound")
	} )
	Merc.Delay(time + delay, function() { 
		part.SetAbsOrigin(Vector(-2095,3,0))
	} )
}

Merc.StartAudioRED_BLU <- function(msg, time, delay = 0.5)
{
	if (Merc.MissionStarting) return
	local part = Entities.FindByName(null, "handler_blu_voicepart")
	local voice = Entities.FindByName(null, "monitor_audio_red")
	local handler = Entities.FindByName(null, "handler_blu")
	voice.PrecacheSoundScript(msg)
	local ent = null
	while (ent = Entities.FindByName(ent, "monitor_audio_red"))
	{
		ent.AcceptInput("Volume","0",null,null)
		SetPropString(ent, "message", msg)
		SetPropString(ent, "m_iszSound", msg)
	}
	Merc.Delay(delay, function() { 
		part.SetAbsOrigin(Vector(-2095,3,120))
		part.AcceptInput("Start","",null,null)
		EntFire("monitor_audio_red","PlaySound")
	} )
	Merc.Delay(time + delay, function() { 
		part.SetAbsOrigin(Vector(-2095,3,0))
	} )
}
Merc.StartAudioBLU_RED <- function(msg, time, delay = 0.5)
{
	if (Merc.MissionStarting) return
	local part = Entities.FindByName(null, "handler_red_voicepart")
	local voice = Entities.FindByName(null, "monitor_audio_blu")
	local handler = Entities.FindByName(null, "handler_red")
	voice.PrecacheSoundScript(msg)
	local ent = null
	while (ent = Entities.FindByName(ent, "monitor_audio_blu"))
	{
		ent.AcceptInput("Volume","0",null,null)
		SetPropString(ent, "message", msg)
		SetPropString(ent, "m_iszSound", msg)
	}
	Merc.Delay(delay, function() { 
		part.SetAbsOrigin(Vector(-1603,3,120))
		part.AcceptInput("Start","",null,null)
		EntFire("monitor_audio_blu","PlaySound")
	} )
	Merc.Delay(time + delay, function() { 
		part.SetAbsOrigin(Vector(-1603,3,0))
	} )
}

Merc.StartSubs <- function(msg, subtype = 0)
{
	if (Merc.MissionStarting) return
	Merc.SubsActive = true
	Merc.SubsType = subtype
	Merc.SubsText = msg
}
Merc.EndSubs <- function()
{
	Merc.SubsActive = false
}

Merc.Briefing_0 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M00", 6.9)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_RED_M01) } )
	Merc.Delay(6.9 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_1 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M01", 14.0)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_RED_M02_1) } )
	Merc.Delay(8.4 + 0.5, function() { Merc.StartSubs(SUB_RED_M02_2) } )
	Merc.Delay(14.0 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_2 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M02", 7.0)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_RED_M03) } )
	Merc.Delay(7.0 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_3 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M03", 9.0)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_RED_M04_1) } )
	Merc.Delay(6.2 + 0.5, function() { Merc.StartSubs(SUB_RED_M04_2) } )
	Merc.Delay(9.0 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_4 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M04", 9.7)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_RED_M05_1) } )
	Merc.Delay(8.1 + 0.5, function() { Merc.StartSubs(SUB_RED_M05_2) } )
	Merc.Delay(9.7 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_5 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M05", 15.1)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_RED_M06_1) } )
	Merc.Delay(6.2 + 0.5, function() { Merc.StartSubs(SUB_RED_M06_2) } )
	Merc.Delay(9.0 + 0.5, function() { Merc.StartSubs(SUB_RED_M06_3) } )
	Merc.Delay(15.1 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_6 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M06", 10.3)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_RED_M07_1) } )
	Merc.Delay(4.4 + 0.5, function() { Merc.StartSubs(SUB_RED_M07_2) } )
	Merc.Delay(10.3 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_7 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M07", 8.2)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_RED_M08_1) } )
	Merc.Delay(4.2 + 0.5, function() { Merc.StartSubs(SUB_RED_M08_2) } )
	Merc.Delay(8.2 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_8 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M08", 9.6)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_RED_M09_1) } )
	Merc.Delay(4.2 + 0.5, function() { Merc.StartSubs(SUB_RED_M09_2) } )
	Merc.Delay(9.6 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_9 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M09", 15.0)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_RED_M10_1) } )
	Merc.Delay(6.0 + 0.5, function() { Merc.StartSubs(SUB_RED_M10_2) } )
	Merc.Delay(11.1 + 0.5, function() { Merc.StartSubs(SUB_RED_M10_3) } )
	Merc.Delay(15.0 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_10 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M10", 10.0)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_RED_M11_1) } )
	Merc.Delay(4.3 + 0.5, function() { Merc.StartSubs(SUB_RED_M11_2) } )
	Merc.Delay(10.0 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_11 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M11", 10.2)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_RED_M12_1) } )
	Merc.Delay(5.3 + 0.5, function() { Merc.StartSubs(SUB_RED_M12_2) } )
	Merc.Delay(10.2 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_12 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M12", 6.2)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_BLU_M01) } )
	Merc.Delay(6.2 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_13 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M13", 7.8)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_BLU_M02_1) } )
	Merc.Delay(5.8 + 0.5, function() { Merc.StartSubs(SUB_BLU_M02_2) } )
	Merc.Delay(7.8 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_14 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M14", 13.0)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_BLU_M03_1) } )
	Merc.Delay(3.7 + 0.5, function() { Merc.StartSubs(SUB_BLU_M03_2) } )
	Merc.Delay(10.3 + 0.5, function() { Merc.StartSubs(SUB_BLU_M03_3) } )
	Merc.Delay(13.0 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_15 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M15", 8.0)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_BLU_M04_1) } )
	Merc.Delay(7.0 + 0.5, function() { Merc.StartSubs(SUB_BLU_M04_2) } )
	Merc.Delay(8.0 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_16 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M16", 8.3)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_BLU_M05_1) } )
	Merc.Delay(7.2 + 0.5, function() { Merc.StartSubs(SUB_BLU_M05_2) } )
	Merc.Delay(8.3 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_17 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M17", 10.0)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_BLU_M06_1) } )
	Merc.Delay(3.3 + 0.5, function() { Merc.StartSubs(SUB_BLU_M06_2) } )
	Merc.Delay(10.0 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_18 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M18", 10.9)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_BLU_M07_1) } )
	Merc.Delay(8.3 + 0.5, function() { Merc.StartSubs(SUB_BLU_M07_2) } )
	Merc.Delay(10.9 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_19 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M19", 9.5)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_BLU_M08_1) } )
	Merc.Delay(7.9 + 0.5, function() { Merc.StartSubs(SUB_BLU_M08_2) } )
	Merc.Delay(9.5 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_20 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M20", 9.5)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_BLU_M09_1) } )
	Merc.Delay(4.9 + 0.5, function() { Merc.StartSubs(SUB_BLU_M09_2) } )
	Merc.Delay(9.5 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_21 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M21", 11.0)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_BLU_M10_1) } )
	Merc.Delay(5.4 + 0.5, function() { Merc.StartSubs(SUB_BLU_M10_2) } )
	Merc.Delay(11.0 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_22 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M22", 6.5)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_BLU_M11_1) } )
	Merc.Delay(5.8 + 0.5, function() { Merc.StartSubs(SUB_BLU_M11_2) } )
	Merc.Delay(6.5 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_23 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M23", 8.3)
	Merc.Delay(0.5, function() { Merc.StartSubs(SUB_BLU_M12_1) } )
	Merc.Delay(4.2 + 0.5, function() { Merc.StartSubs(SUB_BLU_M12_2) } )
	Merc.Delay(8.3 + 1.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_24 <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M24.1", 1.8, 0.0)
	Merc.StartSubs(SUB_RED_M13_1)
	
	Merc.Delay(1.8, function() {
	Merc.SetMonitorHandlerRED_BLU()
	Merc.StartSubs(SUB_RED_M13_2, 2)
	Merc.StartAudioRED_BLU("Merc.HandlerBLU.M24.2", 2.1, 0.0) 
	} )
	
	Merc.Delay(3.9, function() { 
	Merc.SetMonitorHandlerRED()
	Merc.StartSubs(SUB_RED_M13_3)
	Merc.StartAudioRED("Merc.HandlerRED.M24.3", 4.4, 0.0) 
	} )
	
	Merc.Delay(8.3, function() { 
	Merc.SetMonitorHandlerRED_BLU()
	Merc.StartSubs(SUB_RED_M13_4, 2)
	Merc.StartAudioRED_BLU("Merc.HandlerBLU.M24.4", 2.1, 0.0)
	} )
	
	Merc.Delay(10.4, function() { 
	Merc.SetMonitorHandlerRED()
	Merc.StartSubs(SUB_RED_M13_5)
	Merc.StartAudioRED("Merc.HandlerRED.M24.5", 3.5, 0.0) 
	} )
	
	Merc.Delay(13.9, function() { 
	Merc.SetMonitorHandlerRED_BLU()
	Merc.StartSubs(SUB_RED_M13_6, 2)
	Merc.StartAudioRED_BLU("Merc.HandlerBLU.M24.6", 5.0, 0.0) 
	} )
	
	Merc.Delay(18.9, function() { 
	Merc.SetMonitorHandlerRED()
	Merc.StartSubs(SUB_RED_M13_7)
	Merc.StartAudioRED("Merc.HandlerRED.M24.7", 3.9, 0.0) 
	} )
	
	Merc.Delay(22.8, function() { 
	Merc.SetMonitorHandlerRED_BLU()
	Merc.StartSubs(SUB_RED_M13_8, 2)
	Merc.StartAudioRED_BLU("Merc.HandlerBLU.M24.8", 2.2, 0.0) 
	} )
	
	Merc.Delay(25.0, function() { 
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.M24.9", 5.3) 
	} )
	Merc.Delay(25.5, function() { 
	Merc.StartSubs(SUB_RED_M13_9)
	} )
	
	Merc.Delay(31.0, function() { Merc.EndBriefing() } )
}

Merc.Briefing_25 <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M25.1", 1.5, 0.0)
	Merc.StartSubs(SUB_BLU_M13_1)
	
	Merc.Delay(1.5, function() { 
	Merc.SetMonitorHandlerBLU_RED()
	Merc.StartSubs(SUB_BLU_M13_2, 1)
	Merc.StartAudioBLU_RED("Merc.HandlerRED.M25.2", 1.6, 0.0) 
	} )
	
	Merc.Delay(3.1, function() { 
	Merc.SetMonitorHandlerBLU()
	Merc.StartSubs(SUB_BLU_M13_3)
	Merc.StartAudioBLU("Merc.HandlerBLU.M25.3", 3.5, 0.0) 
	} )
	
	Merc.Delay(6.6, function() { 
	Merc.SetMonitorHandlerBLU_RED()
	Merc.StartSubs(SUB_BLU_M13_4, 1)
	Merc.StartAudioBLU_RED("Merc.HandlerRED.M25.4", 2.1, 0.0) 
	} )
	
	Merc.Delay(8.7, function() { 
	Merc.SetMonitorHandlerBLU()
	Merc.StartSubs(SUB_BLU_M13_5)
	Merc.StartAudioBLU("Merc.HandlerBLU.M25.5", 3.6, 0.0) 
	} )
	
	Merc.Delay(12.3, function() { 
	Merc.SetMonitorHandlerBLU_RED()
	Merc.StartSubs(SUB_BLU_M13_6, 1)
	Merc.StartAudioBLU_RED("Merc.HandlerRED.M25.6", 4.7, 0.0) 
	} )
	
	Merc.Delay(17.0, function() { 
	Merc.SetMonitorHandlerBLU()
	Merc.StartSubs(SUB_BLU_M13_7)
	Merc.StartAudioBLU("Merc.HandlerBLU.M25.7", 3.4, 0.0) 
	} )
	
	Merc.Delay(20.4, function() { 
	Merc.SetMonitorHandlerBLU_RED()
	Merc.StartSubs(SUB_BLU_M13_8, 1)
	Merc.StartAudioBLU_RED("Merc.HandlerRED.M25.8", 1.8, 0.0) 
	} )
	
	Merc.Delay(22.2, function() { 
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.M25.9", 4.5) 
	} )
	Merc.Delay(22.7, function() { 
	Merc.StartSubs(SUB_BLU_M13_9)
	} )
	
	Merc.Delay(27.7, function() { Merc.EndBriefing() } )
}

Merc.BriefingFuncs <- [
	Merc.Briefing_0,
	Merc.Briefing_1,
	Merc.Briefing_2,
	Merc.Briefing_3,
	Merc.Briefing_4,
	Merc.Briefing_5,
	Merc.Briefing_6,
	Merc.Briefing_7,
	Merc.Briefing_8,
	Merc.Briefing_9,
	Merc.Briefing_10,
	Merc.Briefing_11,
	Merc.Briefing_12,
	Merc.Briefing_13,
	Merc.Briefing_14,
	Merc.Briefing_15,
	Merc.Briefing_16,
	Merc.Briefing_17,
	Merc.Briefing_18,
	Merc.Briefing_19,
	Merc.Briefing_20,
	Merc.Briefing_21,
	Merc.Briefing_22,
	Merc.Briefing_23,
	Merc.Briefing_24,
	Merc.Briefing_25,
]

Merc.ForceWinRED <- function()
{
	EntFire("roundwin_red","RoundWin")
	EntFire("winpart_red","Start")
}
Merc.ForceWinBLU <- function()
{
	EntFire("roundwin_blue","RoundWin")
	EntFire("winpart_blue","Start")
}
Merc.StopMusic <- function()
{
	local ent = null
	while (ent = Entities.FindByName(ent, "music_red"))
	{
		ent.AcceptInput("Volume","0",null,null)
	}
	ent = null
	while (ent = Entities.FindByName(ent, "music_blue"))
	{
		ent.AcceptInput("Volume","0",null,null)
	}
}
Merc.FadeMusic <- function()
{
	local ent = null
	while (ent = Entities.FindByName(ent, "music_red"))
	{
		ent.AcceptInput("FadeOut","1",null,null)
	}
	ent = null
	while (ent = Entities.FindByName(ent, "music_blue"))
	{
		ent.AcceptInput("FadeOut","1",null,null)
	}
}
Merc.PlayerSpeakResp <- function(concept)
{
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a)) 
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
		if (!IsPlayerABot(a)) 
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
		if (!IsPlayerABot(a)) 
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
Merc.BotSpeakResp <- function(a, concept)
{
	EntFireByHandle(Merc.HubBots[a].Handle, "SpeakResponseConcept", concept, 0, a, a)
}
Merc.BotSpeak <- function(a, clip)
{
	PrecacheScriptSound(clip)
	Merc.HubBots[a].Handle.EmitSound(clip)
}
Merc.BotSpeakRaw <- function(a, clip) // no dsp effects, facial yes
{
	PrecacheSound(clip)
	Merc.HubBots[a].Handle.EmitSound(clip)
}
Merc.HideCrosshair <- function()
{
	foreach (a in GetClients()) 
	{
		a.AddHudHideFlags(HIDEHUD_CROSSHAIR)
	}
}
Merc.BotTaunt <- function(a, b, c)
{
	Merc.HubBots[a].Handle.Taunt(b,c)
}
Merc.BotTauntSlot <- function(a, b)
{
	Merc.HubBots[a].Handle.HandleTauntCommand(b)
}
Merc.BotScene <- function(a, clip, delay = 0.0)
{
	Merc.HubBots[a].Handle.PlayScene(clip,delay)
}

Merc.CS_IntroRED <- function()
{
	Merc.SetMonitorHandlerRED()
	EntFire("titlecard_red", "Enable")
	
	local voice = Entities.FindByName(null, "music_red")
	local msg = "Merc.RED.IntroMusic"
	voice.PrecacheSoundScript(msg)
	local ent = null
	while (ent = Entities.FindByName(ent, "music_red"))
	{
		ent.AcceptInput("Volume","0",null,null)
		SetPropString(ent, "message", msg)
		SetPropString(ent, "m_iszSound", msg)
	}
	ent = null
	while (ent = Entities.FindByName(ent, "music_blue"))
	{
		ent.AcceptInput("Volume","0",null,null)
	}
	EntFire("music_red","PlaySound")
	
	Merc.Delay(5.0, function() { 
		EntFire("titlecard_red", "Disable")
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.StartAudioRED("Merc.HandlerRED.Intro", 9.0)
	} )
	Merc.Delay(5.0 + 0.5, function() {
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.StartSubs(SUB_RED_INTRO_1)
	} )
	Merc.Delay(5.0 + 6.3 + 0.5, function() { 
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.StartSubs(SUB_RED_INTRO_2)
	} )
	Merc.Delay(5.0 + 9.0 + 1.0, function() { 
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.EndSubs()
		Merc.EndCutsceneGeneric()
	} )
}

Merc.CS_IntroBLU <- function()
{
	Merc.SetMonitorHandlerBLU()
	EntFire("titlecard_blue", "Enable")
	
	local voice = Entities.FindByName(null, "music_blue")
	local msg = "Merc.BLU.IntroMusic"
	voice.PrecacheSoundScript(msg)
	local ent = null
	while (ent = Entities.FindByName(ent, "music_blue"))
	{
		ent.AcceptInput("Volume","0",null,null)
		SetPropString(ent, "message", msg)
		SetPropString(ent, "m_iszSound", msg)
	}
	ent = null
	while (ent = Entities.FindByName(ent, "music_red"))
	{
		ent.AcceptInput("Volume","0",null,null)
	}
	EntFire("music_blue","PlaySound")
	
	Merc.Delay(5.0, function() { 
		EntFire("titlecard_blue", "Disable")
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.StartAudioBLU("Merc.HandlerBLU.Intro", 10.7)
	} )
	Merc.Delay(5.0 + 0.5, function() { 
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.StartSubs(SUB_BLU_INTRO_1)
	} )
	Merc.Delay(5.0 + 6.3 + 0.5, function() { 
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.StartSubs(SUB_BLU_INTRO_2)
	} )
	Merc.Delay(5.0 + 10.7 + 1.0, function() { 
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.EndSubs()
		Merc.EndCutsceneGeneric()
	} )
}

Merc.CS_EndingRED <- function()
{
	Merc.CutsceneActive = true
	Merc.SaveProgress()
	
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.Ending", 11.8)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_RED_Ending_1)
	} )
	Merc.Delay(5.5 + 0.5, function() { 
		Merc.StartSubs(SUB_RED_Ending_2)
	} )
	
	Merc.Delay(11.5 + 1.0, function() { 
		Merc.EndSubs()
	} )
	
	Merc.Delay(13.0, function() { 
		Merc.ForceWinRED()
		local team = "red"
		local wtext = LOCM_MISSION_STARTING + "\n"
		wtext += "Brazil" + "\n"
		wtext += "King of the Hill" + "\n"
		local mtext = Entities.FindByName(null, "wtext_monitor_" + team)
		mtext.AcceptInput("SetText",wtext,null,null)
		EntFire("monitor_red", "SetCamera", "cam_mission_red")
		foreach (a in GetClients()) 
		{
			AwardAchievement(a.entindex(), 151, 1)
		}
	} )
	
	Merc.HideCrosshair()
}

Merc.CS_EndingBLU <- function()
{
	Merc.CutsceneActive = true
	Merc.SaveProgress()
	
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.Ending", 11.5)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_BLU_Ending_1)
	} )
	Merc.Delay(6.0 + 0.5, function() { 
		Merc.StartSubs(SUB_BLU_Ending_2)
	} )
	
	Merc.Delay(11.5 + 1.0, function() { 
		Merc.EndSubs()
	} )
	
	Merc.Delay(13.0, function() { 
		
		Merc.ForceWinBLU()
		local team = "blu"
		local wtext = LOCM_MISSION_STARTING + "\n"
		wtext += "Brazil" + "\n"
		wtext += "King of the Hill" + "\n"
		local mtext = Entities.FindByName(null, "wtext_monitor_" + team)
		mtext.AcceptInput("SetText",wtext,null,null)
		EntFire("monitor_blu", "SetCamera", "cam_mission_blu")
		foreach (a in GetClients()) 
		{
			AwardAchievement(a.entindex(), 151, 1)
		}
	} )
	
	Merc.HideCrosshair()
}

Merc.CS_FinalMissionOpenRED <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.FinalMissionOpen", 8.1)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_RED_FinalMissionOpen)
	} )
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 860,
		worldPosY = 407,
		worldPosZ = 140,
		id = 15,
		text = "The final mission is now available!",
		lifetime = 10.0,
	})
	Merc.Delay(8.1 + 1.0, function() { 
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.EndSubs()
		Merc.EndCutsceneGeneric()
	} )
}

Merc.CS_FinalMissionOpenBLU <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.FinalMissionOpen", 10.6)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_BLU_FinalMissionOpen_1)
	} )
	Merc.Delay(7.5 + 0.5, function() { 
		Merc.StartSubs(SUB_BLU_FinalMissionOpen_2)
	} )
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 914,
		worldPosY = -972,
		worldPosZ = 140,
		id = 15,
		text = "The final mission is now available!",
		lifetime = 10.0,
	})
	Merc.Delay(10.6 + 1.0, function() { 
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.EndSubs()
		Merc.EndCutsceneGeneric()
	} )
}

Merc.CS_Weapon1_RED <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.Weapon1", 4.7)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_RED_Weapon_1)
	} )
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 503,
		worldPosY = 321,
		worldPosZ = 140,
		id = 15,
		text = "New weapon unlocked!",
		lifetime = 7.0,
	})
	Merc.Delay(4.7 + 1.0, function() {
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.EndSubs()
		Merc.EndCutsceneGeneric()
	} )
}

Merc.CS_Weapon2_RED <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.Weapon2", 3.6)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_RED_Weapon_2)
	} )
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 1049,
		worldPosY = 110,
		worldPosZ = 140,
		id = 15,
		text = "New weapon unlocked!",
		lifetime = 7.0,
	})
	Merc.Delay(3.6 + 1.0, function() { 
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.EndSubs()
		Merc.EndCutsceneGeneric()
	} )
}

Merc.CS_Weapon1_BLU <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.Weapon1", 4.0)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_BLU_Weapon_1)
	} )
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 501,
		worldPosY = -362,
		worldPosZ = 140,
		id = 15,
		text = "New weapon unlocked!",
		lifetime = 7.0,
	})
	Merc.Delay(4.0 + 1.0, function() { 
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.EndSubs()
		Merc.EndCutsceneGeneric()
	} )
}

Merc.CS_Weapon2_BLU <- function()
{
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.Weapon2", 5.0)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_BLU_Weapon_2)
	} )
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 1049,
		worldPosY = -110,
		worldPosZ = 140,
		id = 15,
		text = "New weapon unlocked!",
		lifetime = 7.0,
	})
	Merc.Delay(5.0 + 1.0, function() { 
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.EndSubs()
		Merc.EndCutsceneGeneric()
	} )
}

Merc.CS_PCorner <- function()
{
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.PCorner", 5.0)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_RED_PCorner)
	} )
	Merc.Delay(5.0 + 1.0, function() { 
		if (Merc.BriefingActive || Merc.CutsceneActive || Merc.MissionStarted || Merc.MissionStarting) return
		Merc.EndSubs()
		Merc.EndCutsceneGeneric()
	} )
}

Merc.CS_RED_Complete <- function()
{
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 1049,
		worldPosY = 110,
		worldPosZ = 140,
		id = 15,
		text = "100 percent complete! All unlocked weapons are now killstreak weapons!",
		lifetime = 15.0,
	})
	foreach (a in GetClients()) 
	{
		AwardAchievement(a.entindex(), 152, 1)
	}
}

Merc.CS_BLU_Complete <- function()
{
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 1049,
		worldPosY = -110,
		worldPosZ = 140,
		id = 15,
		text = "100 percent complete! All unlocked weapons are now killstreak weapons!",
		lifetime = 15.0,
	})
	foreach (a in GetClients()) 
	{
		AwardAchievement(a.entindex(), 152, 1)
	}
}

Merc.CS_Choice1_RED <- function()
{
	Merc.CutsceneActive = true
	Merc.LastChoiceResult = -1
	Merc.ChoiceType = 0
	Merc.BadAnswerCount = 0
	
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.Choice1.Intro", 9.3)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_RED_Choice1_Intro_1)
	} )
	Merc.HubBots[2].Flags = 2
	Merc.HubBots[2].Start()
	
	Merc.Delay(6.4 + 0.5, function() { 
		Merc.StartSubs(SUB_RED_Choice1_Intro_2)
	} )
	Merc.Delay(9.0 + 0.5, function() { 
		Merc.CS_Choice1_RED_Start()
	} )
	
	Merc.Delay(39.0 + 0.5, function() {
		if (Merc.LastChoiceResult != -1) return
		Merc.StartAudioRED("Merc.HandlerRED.Choice1.Idle", 1.5, 0.0)
		Merc.StartSubs(SUB_RED_Choice1_Idle)
		Merc.Delay(1.5 + 0.5, function() {
			if (Merc.LastChoiceResult != -1) return
			Merc.EndSubs()
		} )
	} )
	
	Merc.Delay(99.0 + 0.5, function() {
		if (Merc.LastChoiceResult != -1) return
		SetPropString(self, "m_iszScriptThinkFunction", "")
		SendGlobalGameEvent("hide_annotation", { id = 10, })
		SendGlobalGameEvent("hide_annotation", { id = 11, })
		Merc.StartAudioRED("Merc.HandlerRED.Choice1.NoAnswer", 3.2, 0.0)
		Merc.StartSubs(SUB_RED_Choice1_NoAnswer)
		Merc.Delay(3.2 + 0.5, function() {
			Merc.EndSubs()
			Merc.EndCutsceneGeneric()
			Merc.HubBots[2].Flags = 1
			Merc.HubBots[2].Kick()
		} )
	} )
	
}

Merc.CS_Choice1_RED_Start <- function()
{
	Merc.EndSubs()
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 989,
		worldPosY = 622,
		worldPosZ = 170,
		id = 10,
		text = "[ %voice_menu_1% ] RESPOND USING VOICE MENU",
		lifetime = -1,
	})
	Merc.StartChoice()
}

Merc.CS_Choice2_RED <- function()
{
	Merc.CutsceneActive = true
	Merc.LastChoiceResult = -1
	Merc.ChoiceType = 1
	Merc.BadAnswerCount = 0
	
	local model1 = "models/player/items/demo/stunt_helmet.mdl"
	local model2 = "models/player/items/sniper/knife_shield.mdl"
	PrecacheModel(model1)
	PrecacheModel(model2)
	
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.Choice2.Intro", 7.8)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_RED_Choice2_Intro_1)
	} )
	
	Merc.ChoiceProp1 = SpawnEntityFromTable("prop_dynamic_override", {
		origin       = Vector(973,626,123),
		angles       = QAngle(0,0,0),
		model 		 = model1,
		targetname   = "mprop",
		max_health   = 1000,
		health 		 = 1000,
		solid		 = 6,
	})
	Merc.ChoiceProp2 = SpawnEntityFromTable("prop_dynamic_override", {
		origin       = Vector(973,501,78),
		angles       = QAngle(0,0,0),
		model 		 = model2,
		targetname   = "mprop",
		max_health   = 1000,
		health 		 = 1000,
		solid		 = 6,
	})
	
	Merc.Delay(2.3, function() { 
		Merc.StartSubs(SUB_RED_Choice2_Intro_2)
	} )
	Merc.Delay(9.0 + 1.0, function() { 
		Merc.CS_Choice2_RED_Start()
	} )
	
	Merc.Delay(99.0 + 1.0, function() {
		if (Merc.LastChoiceResult != -1) return
		SetPropString(self, "m_iszScriptThinkFunction", "")
		SendGlobalGameEvent("hide_annotation", { id = 10, })
		SendGlobalGameEvent("hide_annotation", { id = 11, })
		Merc.RSVFlags[5] = 2
		Merc.StartAudioRED("Merc.HandlerRED.Choice2.NoAnswer", 4.1, 0.0)
		Merc.StartSubs(SUB_RED_Choice2_NoAnswer)
		Merc.Delay(4.1 + 0.5, function() {
			Merc.EndSubs()
			Merc.EndCutsceneGeneric()
			Merc.ChoiceProp1.Destroy()
			Merc.ChoiceProp2.Destroy()
			
		} )
	} )
}

Merc.CS_Choice2_RED_Start <- function()
{
	Merc.EndSubs()
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 973,
		worldPosY = 626,
		worldPosZ = 130,
		id = 10,
		text = "[ %voice_menu_1% ] LEFT - NO HEADSHOTS",
		lifetime = -1,
	})
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 973,
		worldPosY = 501,
		worldPosZ = 130,
		id = 11,
		text = "[ %voice_menu_1% ] RIGHT - NO BACKSTABS",
		lifetime = -1,
	})
	Merc.StartChoice()
}

Merc.CS_Choice3_RED <- function()
{
	Merc.CutsceneActive = true
	Merc.LastChoiceResult = -1
	Merc.ChoiceType = 2
	Merc.BadAnswerCount = 0
	
	local model1 = "models/pickups/pickup_powerup_haste.mdl"
	local model2 = "models/pickups/pickup_powerup_king.mdl"
	PrecacheModel(model1)
	PrecacheModel(model2)
	
	Merc.SetMonitorHandlerRED()
	Merc.StartAudioRED("Merc.HandlerRED.Choice3.Intro", 13.0)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_RED_Choice3_Intro_1)
	} )
	
	Merc.ChoiceProp1 = SpawnEntityFromTable("prop_dynamic_override", {
		origin       = Vector(973,626,90),
		angles       = QAngle(0,180,0),
		model 		 = model1,
		targetname   = "mprop",
		max_health   = 1000,
		health 		 = 1000,
		solid		 = 6,
	})
	Merc.ChoiceProp2 = SpawnEntityFromTable("prop_dynamic_override", {
		origin       = Vector(973,501,90),
		angles       = QAngle(0,0,0),
		model 		 = model2,
		targetname   = "mprop",
		max_health   = 1000,
		health 		 = 1000,
		solid		 = 6,
	})
	
	Merc.Delay(5.2 + 0.5, function() { 
		Merc.StartSubs(SUB_RED_Choice3_Intro_2)
	} )
	Merc.Delay(10.8 + 0.5, function() { 
		Merc.StartSubs(SUB_RED_Choice3_Intro_3)
	} )
	Merc.Delay(13.0 + 0.5, function() { 
		Merc.CS_Choice3_RED_Start()
	} )
	
	Merc.Delay(103.0 + 1.0, function() {
		if (Merc.LastChoiceResult != -1) return
		SetPropString(self, "m_iszScriptThinkFunction", "")
		SendGlobalGameEvent("hide_annotation", { id = 10, })
		SendGlobalGameEvent("hide_annotation", { id = 11, })
		Merc.RSVFlags[6] = 2
		Merc.StartAudioRED("Merc.HandlerRED.Choice3.NoAnswer", 4.4, 0.0)
		Merc.StartSubs(SUB_RED_Choice3_NoAnswer)
		Merc.Delay(4.5 + 0.5, function() {
			Merc.EndSubs()
			Merc.EndCutsceneGeneric()
			Merc.ChoiceProp1.Destroy()
			Merc.ChoiceProp2.Destroy()
		} )
	} )
}

Merc.CS_Choice3_RED_Start <- function()
{
	Merc.EndSubs()
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 973,
		worldPosY = 626,
		worldPosZ = 130,
		id = 10,
		text = "[ %voice_menu_1% ] LEFT - SPEED BOOST",
		lifetime = -1,
	})
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 973,
		worldPosY = 501,
		worldPosZ = 130,
		id = 11,
		text = "[ %voice_menu_1% ] RIGHT - SEE TEAMMATES",
		lifetime = -1,
	})
	Merc.StartChoice()
}

Merc.CS_Choice1_BLU <- function()
{
	Merc.CutsceneActive = true
	Merc.LastChoiceResult = -1
	Merc.ChoiceType = 3
	Merc.BadAnswerCount = 0
	
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.Choice1.Intro", 8.0)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_BLU_Choice1_Intro_1)
	} )
	Merc.HubBots[3].Flags = 2
	Merc.HubBots[3].Start()
	
	Merc.Delay(5.3 + 0.5, function() { 
		Merc.StartSubs(SUB_BLU_Choice1_Intro_2)
	} )
	Merc.Delay(8.0 + 1.0, function() { 
		Merc.CS_Choice1_BLU_Start()
	} )
	
	Merc.Delay(38.0 + 1.0, function() {
		if (Merc.LastChoiceResult != -1) return
		Merc.StartAudioBLU("Merc.HandlerBLU.Choice1.Idle", 2.3, 0.0)
		Merc.StartSubs(SUB_BLU_Choice1_Idle)
		Merc.Delay(2.3 + 0.5, function() {
			if (Merc.LastChoiceResult != -1) return
			Merc.EndSubs()
		} )
	} )
	
	Merc.Delay(98.0 + 1.0, function() {
		if (Merc.LastChoiceResult != -1) return
		SetPropString(self, "m_iszScriptThinkFunction", "")
		SendGlobalGameEvent("hide_annotation", { id = 10, })
		SendGlobalGameEvent("hide_annotation", { id = 11, })
		Merc.StartAudioBLU("Merc.HandlerBLU.Choice1.NoAnswer", 4.5, 0.0)
		Merc.StartSubs(SUB_BLU_Choice1_NoAnswer)
		Merc.Delay(4.5 + 0.5, function() {
			Merc.EndSubs()
			Merc.EndCutsceneGeneric()
			Merc.HubBots[3].Flags = 1
			Merc.HubBots[3].Kick()
		} )
	} )
}

Merc.CS_Choice1_BLU_Start <- function()
{
	Merc.EndSubs()
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 989,
		worldPosY = -634,
		worldPosZ = 170,
		id = 10,
		text = "[ %voice_menu_1% ] RESPOND USING VOICE MENU",
		lifetime = -1,
	})
	Merc.StartChoice()
}

Merc.CS_Choice2_BLU <- function()
{
	Merc.CutsceneActive = true
	Merc.LastChoiceResult = -1
	Merc.ChoiceType = 4
	Merc.BadAnswerCount = 0
	
	local model1 = "models/weapons/c_models/c_rocketboots_soldier.mdl"
	local model2 = "models/player/items/sniper/croc_shield.mdl"
	PrecacheModel(model1)
	PrecacheModel(model2)
	
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.Choice2.Intro", 10.0)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_BLU_Choice2_Intro_1)
	} )
	
	Merc.ChoiceProp1 = SpawnEntityFromTable("prop_dynamic_override", {
		origin       = Vector(965,-512,117),
		angles       = QAngle(0,180,0),
		model 		 = model1,
		targetname   = "mprop",
		max_health   = 1000,
		health 		 = 1000,
		solid		 = 6,
	})
	Merc.ChoiceProp2 = SpawnEntityFromTable("prop_dynamic_override", {
		origin       = Vector(965,-629,89),
		angles       = QAngle(0,0,0),
		model 		 = model2,
		targetname   = "mprop",
		max_health   = 1000,
		health 		 = 1000,
		solid		 = 6,
	})

	Merc.Delay(2.4 + 0.5, function() { 
		Merc.StartSubs(SUB_BLU_Choice2_Intro_2)
	} )
	Merc.Delay(8.0 + 0.5, function() { 
		Merc.StartSubs(SUB_BLU_Choice2_Intro_3)
	} )
	Merc.Delay(10.0 + 1.0, function() { 
		Merc.CS_Choice2_BLU_Start()
	} )
	
	Merc.Delay(100.0 + 1.0, function() {
		if (Merc.LastChoiceResult != -1) return
		SetPropString(self, "m_iszScriptThinkFunction", "")
		SendGlobalGameEvent("hide_annotation", { id = 10, })
		SendGlobalGameEvent("hide_annotation", { id = 11, })
		Merc.RSVFlags[8] = 2
		Merc.StartAudioBLU("Merc.HandlerBLU.Choice2.NoAnswer", 6.5, 0.0)
		Merc.StartSubs(SUB_BLU_Choice2_NoAnswer)
		Merc.Delay(6.5 + 0.5, function() {
			Merc.EndSubs()
			Merc.EndCutsceneGeneric()
			Merc.ChoiceProp1.Destroy()
			Merc.ChoiceProp2.Destroy()
		} )
	} )
}

Merc.CS_Choice2_BLU_Start <- function()
{
	Merc.EndSubs()
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 965,
		worldPosY = -512,
		worldPosZ = 130,
		id = 10,
		text = "[ %voice_menu_1% ] LEFT - NO FALL DAMAGE",
		lifetime = -1,
	})
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 965,
		worldPosY = -629,
		worldPosZ = 130,
		id = 11,
		text = "[ %voice_menu_1% ] RIGHT - NO AFTERBURN",
		lifetime = -1,
	})
	Merc.StartChoice()
}

Merc.CS_Choice3_BLU <- function()
{
	Merc.CutsceneActive = true
	Merc.LastChoiceResult = -1
	Merc.ChoiceType = 5
	Merc.BadAnswerCount = 0
	
	local model1 = "models/pickups/pickup_powerup_regen.mdl"
	local model2 = "models/pickups/pickup_powerup_defense.mdl"
	PrecacheModel(model1)
	PrecacheModel(model2)
	
	Merc.SetMonitorHandlerBLU()
	Merc.StartAudioBLU("Merc.HandlerBLU.Choice3.Intro", 18.1)
	Merc.Delay(0.5, function() { 
		Merc.StartSubs(SUB_BLU_Choice3_Intro_1)
	} )
	
	Merc.ChoiceProp1 = SpawnEntityFromTable("prop_dynamic_override", {
		origin       = Vector(965,-512,90),
		angles       = QAngle(0,180,0),
		model 		 = model1,
		targetname   = "mprop",
		max_health   = 1000,
		health 		 = 1000,
		solid		 = 6,
	})
	Merc.ChoiceProp2 = SpawnEntityFromTable("prop_dynamic_override", {
		origin       = Vector(965,-629,90),
		angles       = QAngle(0,0,0),
		model 		 = model2,
		targetname   = "mprop",
		max_health   = 1000,
		health 		 = 1000,
		solid		 = 6,
	})
	
	Merc.Delay(7.3 + 0.5, function() { 
		Merc.StartSubs(SUB_BLU_Choice3_Intro_2)
	} )
	Merc.Delay(15.6 + 0.5, function() { 
		Merc.StartSubs(SUB_BLU_Choice3_Intro_3)
	} )
	Merc.Delay(18.1 + 1.0, function() { 
		Merc.CS_Choice3_BLU_Start()
	} )
	
	Merc.Delay(108.1 + 1.0, function() {
		if (Merc.LastChoiceResult != -1) return
		SetPropString(self, "m_iszScriptThinkFunction", "")
		SendGlobalGameEvent("hide_annotation", { id = 10, })
		SendGlobalGameEvent("hide_annotation", { id = 11, })
		Merc.RSVFlags[9] = 2
		Merc.StartAudioBLU("Merc.HandlerBLU.Choice3.NoAnswer", 9.4, 0.0)
		Merc.StartSubs(SUB_BLU_Choice3_NoAnswer)
		Merc.Delay(9.4 + 0.5, function() {
			Merc.EndSubs()
			Merc.EndCutsceneGeneric()
			Merc.ChoiceProp1.Destroy()
			Merc.ChoiceProp2.Destroy()
		} )
	} )
}

Merc.CS_Choice3_BLU_Start <- function()
{
	Merc.EndSubs()
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 965,
		worldPosY = -512,
		worldPosZ = 130,
		id = 10,
		text = "[ %voice_menu_1% ] LEFT - ÜBER BOOST",
		lifetime = -1,
	})
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 965,
		worldPosY = -629,
		worldPosZ = 130,
		id = 11,
		text = "[ %voice_menu_1% ] RIGHT - PREVENT DEATH ONCE",
		lifetime = -1,
	})
	Merc.StartChoice()
}

Merc.ChoiceComplete <- function()
{
	switch (Merc.ChoiceType) {
		case 0: 
		{
			if (Merc.LastChoiceResult == 1)
			{
				Merc.RSVFlags[4] = 1
				Merc.StartAudioRED("Merc.HandlerRED.Choice1.Chosen1", 3.5, 0.0)
				Merc.StartSubs(SUB_RED_Choice1_Chosen1)
				Merc.Delay(4.5 + 0.5, function() { 
					Merc.EndSubs()
					Merc.EndCutsceneGeneric()
				} )
			}
			else if (Merc.LastChoiceResult == 2)
			{
				Merc.StartAudioRED("Merc.HandlerRED.Choice1.Chosen2", 3.4, 0.0)
				Merc.StartSubs(SUB_RED_Choice1_Chosen2)
				Merc.Delay(3.8 + 0.5, function() { 
					Merc.EndSubs()
					Merc.EndCutsceneGeneric()
					Merc.HubBots[2].Flags = 1
					Merc.HubBots[2].Kick()
				} )
			}
			else
			{
				if (Merc.BadAnswerCount == 0)
				{
					Merc.BadAnswerCount = 1
					Merc.StartAudioRED("Merc.HandlerRED.Choice1.BadAnswer1", 1.7, 0.0)
					Merc.StartSubs(SUB_RED_Choice1_BadAnswer1)
					Merc.Delay(1.6, function() { 
						Merc.CS_Choice1_RED_Start()
					} )
				}
				else if (Merc.BadAnswerCount == 1)
				{
					Merc.BadAnswerCount = 2
					Merc.StartAudioRED("Merc.HandlerRED.Choice1.BadAnswer2", 3.7, 0.0)
					Merc.StartSubs(SUB_RED_Choice1_BadAnswer2)
					Merc.Delay(3.0, function() { 
						Merc.CS_Choice1_RED_Start()
					} )
				}
				else if (Merc.BadAnswerCount == 2)
				{
					Merc.BadAnswerCount = 3
					Merc.StartAudioRED("Merc.HandlerRED.Choice1.BadAnswer3", 3.4, 0.0)
					Merc.StartSubs(SUB_RED_Choice1_BadAnswer3)
					Merc.Delay(3.4, function() { 
						Merc.CS_Choice1_RED_Start()
					} )
				}
				else
				{
					Merc.RSVFlags[4] = 2
					Merc.StartAudioRED("Merc.HandlerRED.Choice1.Chosen3", 5.6, 0.0)
					Merc.StartSubs(SUB_RED_Choice1_Chosen3)
					Merc.Delay(5.8 + 0.5, function() { 
						Merc.EndSubs()
						Merc.EndCutsceneGeneric()
						Merc.HubBots[2].Flags = 1
						Merc.HubBots[2].Kick()
					} )
				}
			}
			break;
		}
		case 1: 
		{
			if (Merc.LastChoiceResult == 3)
			{
				Merc.RSVFlags[5] = 1
				Merc.StartAudioRED("Merc.HandlerRED.Choice2.Chosen1", 2.9, 0.0)
				Merc.StartSubs(SUB_RED_Choice2_Chosen1)
				Merc.Delay(2.7 + 0.5, function() { 
					Merc.EndSubs()
					Merc.EndCutsceneGeneric()
					Merc.ChoiceProp1.Destroy()
					Merc.ChoiceProp2.Destroy()
				} )
			}
			else if (Merc.LastChoiceResult == 4)
			{
				Merc.RSVFlags[5] = 2
				Merc.StartAudioRED("Merc.HandlerRED.Choice2.Chosen2", 2.9, 0.0)
				Merc.StartSubs(SUB_RED_Choice2_Chosen2)
				Merc.Delay(2.7 + 0.5, function() { 
					Merc.EndSubs()
					Merc.EndCutsceneGeneric()
					Merc.ChoiceProp1.Destroy()
					Merc.ChoiceProp2.Destroy()
				} )
			}
			else
			{
				if (Merc.BadAnswerCount == 0)
				{
					Merc.BadAnswerCount = 1
					Merc.StartAudioRED("Merc.HandlerRED.Choice2.BadAnswer1", 3.2, 0.0)
					Merc.StartSubs(SUB_RED_Choice2_BadAnswer1)
					Merc.Delay(2.4, function() { 
						Merc.CS_Choice2_RED_Start()
					} )
				}
				else
				{
					Merc.RSVFlags[5] = 3
					Merc.StartAudioRED("Merc.HandlerRED.Choice2.Chosen3", 6.0, 0.0)
					Merc.StartSubs(SUB_RED_Choice2_Chosen3)
					Merc.Delay(6.7 + 0.5, function() { 
						Merc.EndSubs()
						Merc.EndCutsceneGeneric()
						Merc.ChoiceProp1.Destroy()
						Merc.ChoiceProp2.Destroy()
					} )
				}
			}
			break;
		}
		case 2: 
		{
			if (Merc.LastChoiceResult == 3)
			{
				Merc.RSVFlags[6] = 1
				Merc.StartAudioRED("Merc.HandlerRED.Choice3.Chosen1", 2.6, 0.0)
				Merc.StartSubs(SUB_RED_Choice3_Chosen1)
				Merc.Delay(2.8 + 0.5, function() { 
					Merc.EndSubs()
					Merc.EndCutsceneGeneric()
					Merc.ChoiceProp1.Destroy()
					Merc.ChoiceProp2.Destroy()
				} )
			}
			else if (Merc.LastChoiceResult == 4)
			{
				Merc.RSVFlags[6] = 2
				Merc.StartAudioRED("Merc.HandlerRED.Choice3.Chosen2", 3.0, 0.0)
				Merc.StartSubs(SUB_RED_Choice3_Chosen2)
				Merc.Delay(3.4 + 0.5, function() { 
					Merc.EndSubs()
					Merc.EndCutsceneGeneric()
					Merc.ChoiceProp1.Destroy()
					Merc.ChoiceProp2.Destroy()
				} )
			}
			else
			{
				if (Merc.BadAnswerCount == 0)
				{
					Merc.BadAnswerCount = 1
					Merc.StartAudioRED("Merc.HandlerRED.Choice3.BadAnswer1", 2.8, 0.0)
					Merc.StartSubs(SUB_RED_Choice3_BadAnswer1)
					Merc.Delay(2.8, function() { 
						Merc.CS_Choice3_RED_Start()
					} )
				}
				else
				{
					Merc.RSVFlags[6] = 3
					Merc.StartAudioRED("Merc.HandlerRED.Choice3.Chosen3", 4.0, 0.0)
					Merc.StartSubs(SUB_RED_Choice3_Chosen3)
					Merc.Delay(4.4 + 0.5, function() { 
						Merc.EndSubs()
						Merc.EndCutsceneGeneric()
						Merc.ChoiceProp1.Destroy()
						Merc.ChoiceProp2.Destroy()
					} )
				}
			}
			break;
		}
		case 3: 
		{
			if (Merc.LastChoiceResult == 1)
			{
				Merc.RSVFlags[7] = 1
				Merc.StartAudioBLU("Merc.HandlerBLU.Choice1.Chosen1", 3.1, 0.0)
				Merc.StartSubs(SUB_BLU_Choice1_Chosen1)
				Merc.Delay(3.1 + 0.5, function() { 
					Merc.EndSubs()
					Merc.EndCutsceneGeneric()
				} )
			}
			else if (Merc.LastChoiceResult == 2)
			{
				Merc.StartAudioBLU("Merc.HandlerBLU.Choice1.Chosen2", 2.4, 0.0)
				Merc.StartSubs(SUB_BLU_Choice1_Chosen2)
				Merc.Delay(2.4 + 0.5, function() { 
					Merc.EndSubs()
					Merc.EndCutsceneGeneric()
					Merc.HubBots[3].Flags = 1
					Merc.HubBots[3].Kick()
				} )
			}
			else
			{
				if (Merc.BadAnswerCount == 0)
				{
					Merc.BadAnswerCount = 1
					Merc.StartAudioBLU("Merc.HandlerBLU.Choice1.BadAnswer1", 2.8, 0.0)
					Merc.StartSubs(SUB_BLU_Choice1_BadAnswer1)
					Merc.Delay(2.8, function() { 
						Merc.CS_Choice1_BLU_Start()
					} )
				}
				else if (Merc.BadAnswerCount == 1)
				{
					Merc.BadAnswerCount = 2
					Merc.StartAudioBLU("Merc.HandlerBLU.Choice1.BadAnswer2", 4.1, 0.0)
					Merc.StartSubs(SUB_BLU_Choice1_BadAnswer2)
					Merc.Delay(4.1, function() { 
						Merc.CS_Choice1_BLU_Start()
					} )
				}
				else if (Merc.BadAnswerCount == 2)
				{
					Merc.BadAnswerCount = 3
					Merc.StartAudioBLU("Merc.HandlerBLU.Choice1.BadAnswer3", 3.4, 0.0)
					Merc.StartSubs(SUB_BLU_Choice1_BadAnswer3)
					Merc.Delay(3.4, function() { 
						Merc.CS_Choice1_BLU_Start()
					} )
				}
				else
				{
					Merc.RSVFlags[7] = 2
					Merc.StartAudioBLU("Merc.HandlerBLU.Choice1.Chosen3", 6.2, 0.0)
					Merc.StartSubs(SUB_BLU_Choice1_Chosen3)
					Merc.Delay(6.2 + 0.5, function() { 
						Merc.EndSubs()
						Merc.EndCutsceneGeneric()
						Merc.HubBots[3].Flags = 1
						Merc.HubBots[3].Kick()
					} )
				}
			}
			break;
		}
		case 4: 
		{
			if (Merc.LastChoiceResult == 3)
			{
				Merc.RSVFlags[8] = 1
				Merc.StartAudioBLU("Merc.HandlerBLU.Choice2.Chosen1", 3.5, 0.0)
				Merc.StartSubs(SUB_BLU_Choice2_Chosen1)
				Merc.Delay(3.5 + 0.5, function() { 
					Merc.EndSubs()
					Merc.EndCutsceneGeneric()
					Merc.ChoiceProp1.Destroy()
					Merc.ChoiceProp2.Destroy()
				} )
			}
			else if (Merc.LastChoiceResult == 4)
			{
				Merc.RSVFlags[8] = 2
				Merc.StartAudioBLU("Merc.HandlerBLU.Choice2.Chosen2", 3.2, 0.0)
				Merc.StartSubs(SUB_BLU_Choice2_Chosen2)
				Merc.Delay(3.2 + 0.5, function() { 
					Merc.EndSubs()
					Merc.EndCutsceneGeneric()
					Merc.ChoiceProp1.Destroy()
					Merc.ChoiceProp2.Destroy()
				} )
			}
			else
			{
				if (Merc.BadAnswerCount == 0)
				{
					Merc.BadAnswerCount = 1
					Merc.StartAudioBLU("Merc.HandlerBLU.Choice2.BadAnswer1", 2.5, 0.0)
					Merc.StartSubs(SUB_BLU_Choice2_BadAnswer1)
					Merc.Delay(2.5, function() { 
						Merc.CS_Choice2_BLU_Start()
					} )
				}
				else
				{
					Merc.RSVFlags[8] = 3
					Merc.StartAudioBLU("Merc.HandlerBLU.Choice2.Chosen3", 6.8, 0.0)
					Merc.StartSubs(SUB_BLU_Choice2_Chosen3)
					Merc.Delay(6.8 + 0.5, function() { 
						Merc.EndSubs()
						Merc.EndCutsceneGeneric()
						Merc.ChoiceProp1.Destroy()
						Merc.ChoiceProp2.Destroy()
					} )
				}
			}
			break;
		}
		case 5: 
		{
			if (Merc.LastChoiceResult == 3)
			{
				Merc.RSVFlags[9] = 1
				Merc.StartAudioBLU("Merc.HandlerBLU.Choice3.Chosen1", 4.3, 0.0)
				Merc.StartSubs(SUB_BLU_Choice3_Chosen1)
				Merc.Delay(4.3 + 0.5, function() { 
					Merc.EndSubs()
					Merc.EndCutsceneGeneric()
					Merc.ChoiceProp1.Destroy()
					Merc.ChoiceProp2.Destroy()
				} )
			}
			else if (Merc.LastChoiceResult == 4)
			{
				Merc.RSVFlags[9] = 2
				Merc.StartAudioBLU("Merc.HandlerBLU.Choice3.Chosen2", 5.0, 0.0)
				Merc.StartSubs(SUB_BLU_Choice3_Chosen2)
				Merc.Delay(5.0 + 0.5, function() { 
					Merc.EndSubs()
					Merc.EndCutsceneGeneric()
					Merc.ChoiceProp1.Destroy()
					Merc.ChoiceProp2.Destroy()
				} )
			}
			else
			{
				if (Merc.BadAnswerCount == 0)
				{
					Merc.BadAnswerCount = 1
					Merc.StartAudioBLU("Merc.HandlerBLU.Choice3.BadAnswer1", 2.0, 0.0)
					Merc.StartSubs(SUB_BLU_Choice3_BadAnswer1)
					Merc.Delay(2.0, function() { 
						Merc.CS_Choice3_BLU_Start()
					} )
				}
				else
				{
					Merc.RSVFlags[9] = 3
					Merc.StartAudioBLU("Merc.HandlerBLU.Choice3.Chosen3", 6.0, 0.0)
					Merc.StartSubs(SUB_BLU_Choice3_Chosen3)
					Merc.Delay(6.0 + 0.5, function() { 
						Merc.EndSubs()
						Merc.EndCutsceneGeneric()
						Merc.ChoiceProp1.Destroy()
						Merc.ChoiceProp2.Destroy()
					} )
				}
			}
			break;
		}
		default: { break; }
	}
}

Merc.StartBriefing <- function()
{
	switch (Merc.MissionID) {
		case 0: { Merc.Briefing_0(); break; }
		case 1: { Merc.Briefing_1(); break; }
		case 2: { Merc.Briefing_2(); break; }
		case 3: { Merc.Briefing_3(); break; }
		case 4: { Merc.Briefing_4(); break; }
		case 5: { Merc.Briefing_5(); break; }
		case 6: { Merc.Briefing_6(); break; }
		case 7: { Merc.Briefing_7(); break; }
		case 8: { Merc.Briefing_8(); break; }
		case 9: { Merc.Briefing_9(); break; }
		case 10: { Merc.Briefing_10(); break; }
		case 11: { Merc.Briefing_11(); break; }
		case 12: { Merc.Briefing_12(); break; }
		case 13: { Merc.Briefing_13(); break; }
		case 14: { Merc.Briefing_14(); break; }
		case 15: { Merc.Briefing_15(); break; }
		case 16: { Merc.Briefing_16(); break; }
		case 17: { Merc.Briefing_17(); break; }
		case 18: { Merc.Briefing_18(); break; }
		case 19: { Merc.Briefing_19(); break; }
		case 20: { Merc.Briefing_20(); break; }
		case 21: { Merc.Briefing_21(); break; }
		case 22: { Merc.Briefing_22(); break; }
		case 23: { Merc.Briefing_23(); break; }
		case 24: { Merc.Briefing_24(); break; }
		case 25: { Merc.Briefing_25(); break; }
		default: { Merc.Briefing_0(); break; }
	}
}

