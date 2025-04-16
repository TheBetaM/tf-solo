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
	"models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl",
]
Merc.HandlerBLU_Attach <- [
	
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
	"competitive_winnerstate_idle",
	"taunt_cyoa_PDA_idle",
	"competitive_loserstate_idle",
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
	Merc.HandlerRED.SetSequence(Merc.HandlerRED.LookupSequence("competitive_winnerstate_idle"))
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
	
	Merc.HandlerRED.StopAnimation()
	Merc.HandlerRED.SetCycle(0)
	Merc.HandlerRED.ResetSequence(Merc.HandlerRED.GetSequence())
}

Merc.SpawnActorBLU <- function()
{
	if (Merc.HandlerBLU != null)
	{
		Merc.HandlerBLU.Destroy()
	}
	PrecacheModel("models/player/medic.mdl")
	Merc.HandlerBLU = Entities.CreateByClassname("funCBaseFlex")
	Merc.HandlerBLU.SetModel("models/player/medic.mdl")
	Merc.HandlerBLU.SetAbsOrigin(MHBLU_Origin)
	Merc.HandlerBLU.SetAbsAngles(QAngle(0, 0, 0))
	Merc.HandlerBLU.SetPlaybackRate(1.0)
	Merc.HandlerBLU.SetSkin(1)
	Merc.HandlerBLU.SetSequence(Merc.HandlerBLU.LookupSequence("taunt_cyoa_PDA_idle"))
	Merc.HandlerBLU.DispatchSpawn()
	Merc.HandlerBLU.EmitSound("Medic.Cheers01")
	SetPropString(Merc.HandlerBLU,"targetname","mhandler_blu")
	SetPropString(Merc.HandlerBLU,"m_iName","mhandler_blu")
	//SetPropInt(Merc.HandlerBLU,"m_nBody",3)
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
	
	Merc.HandlerBLU.StopAnimation()
	Merc.HandlerBLU.SetCycle(0)
	Merc.HandlerBLU.ResetSequence(Merc.HandlerBLU.GetSequence())
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
			if (self.GetCycle() > 0.999)
			{
				self.StopAnimation()
				self.SetCycle(0)
				self.ResetSequence(self.GetSequence())
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
			if (self.GetCycle() > 0.999)
			{
				self.StopAnimation()
				self.SetCycle(0)
				self.ResetSequence(self.GetSequence())
			}
			break;
		}
		default: { break; }
	}
	self.StudioFrameAdvance()
	return -1
}

Merc.ApplyCutsceneProgress <- function()
{
	if (Merc.RSVFlags[11] == 0)
	{
		local ent = null
		while (ent = Entities.FindByName(ent, "notice_secretpickup_1"))
		{
			SetPropInt(ent, "m_iTextureFrameIndex", 1)
			SetPropInt(ent, "texframeindex", 1)
		}
	}
	if (Merc.RSVFlags[12] == 0)
	{
		local ent = null
		while (ent = Entities.FindByName(ent, "notice_secretpickup_2"))
		{
			SetPropInt(ent, "m_iTextureFrameIndex", 1)
			SetPropInt(ent, "texframeindex", 1)
		}
	}
	for (local i = 0; i < Merc.Missions.len(); i++)
	{
		if (Merc.MissionStatus[i] < 2)
		{
			local ent = null
			while (ent = Entities.FindByName(ent,"missionprop_"+i))
			{
				ent.Kill()
			}
		}
	}
}

Merc.RandomEventRED <- function()
{
	
}

Merc.RandomEventBLU <- function()
{
	
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
			//Merc.CSFlags[0] = 1
			//Merc.CS_IntroRED()
			//csStarted = 1
		}
		else if (Merc.CSFlags[2] == 0 && prog >= 2)
		{
			// RED Choice 1
			//Merc.CSFlags[2] = 1
			//Merc.CS_Choice1_RED()
			//csStarted = 1
		}
		else if (Merc.CSFlags[3] == 0 && prog >= 4)
		{
			// RED Choice 2
			//Merc.CSFlags[3] = 1
			//Merc.CS_Choice2_RED()
			//csStarted = 1
		}
		else if (Merc.CSFlags[4] == 0 && prog >= 6)
		{
			// RED Choice 3
			//Merc.CSFlags[4] = 1
			//Merc.CS_Choice3_RED()
			//csStarted = 1
		}
		else if (Merc.CSFlags[12] == 0 && prog >= 10 && prog2 >= 10)
		{
			// RED Final Mission Available
			//Merc.CSFlags[12] = 1
			//Merc.CS_FinalMissionOpenRED()
			//csStarted = 1
		}
		else if (Merc.CSFlags[14] == 0 && Merc.MissionStatus[24] >= 2)
		{
			// RED Ending
			//Merc.CSFlags[14] = 1
			//Merc.CS_EndingRED()
			//csStarted = 1
		}
		else if (Merc.CSFlags[8] == 0 && bonus >= 3)
		{
			// RED Weapon 1
			//Merc.CSFlags[8] = 1
			//Merc.CS_Weapon1_RED()
			//csStarted = 1
		}
		else if (Merc.CSFlags[9] == 0 && bonus >= 9)
		{
			// RED Weapon 2
			//Merc.CSFlags[9] = 1
			//Merc.CS_Weapon2_RED()
			//csStarted = 1
		}
		else if (Merc.CSFlags[27] == 0 && bonus >= 13)
		{
			// RED 100%
			//Merc.CSFlags[27] = 1
			//Merc.CS_RED_Complete()
		}
		
		if (!Merc.CutsceneActive && csStarted == 0)
		{
			Merc.RandomEventRED()
		}
		
		local fade = Entities.FindByName(null, "fadeoverlay_red")
		SetPropInt(fade, "m_nRenderFX", Constants.ERenderFx.kRenderFxFadeFast)
		
		local voice = Entities.FindByName(null, "music_red")
		local msg = "Merc.RED.HubMusic"
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
			//Merc.CSFlags[1] = 1
			//Merc.CS_IntroBLU()
			//csStarted = 1
		}
		else if (Merc.CSFlags[5] == 0 && prog >= 2)
		{
			// BLU Choice 1
			//Merc.CSFlags[5] = 1
			//Merc.CS_Choice1_BLU()
			//csStarted = 1
		}
		else if (Merc.CSFlags[6] == 0 && prog >= 4)
		{
			// BLU Choice 2
			//Merc.CSFlags[6] = 1
			//Merc.CS_Choice2_BLU()
			//csStarted = 1
		}
		else if (Merc.CSFlags[7] == 0 && prog >= 6)
		{
			// BLU Choice 3
			//Merc.CSFlags[7] = 1
			//Merc.CS_Choice3_BLU()
			//csStarted = 1
		}
		else if (Merc.CSFlags[13] == 0 && prog >= 10 && prog2 >= 10)
		{
			// BLU Final Mission Available
			//Merc.CSFlags[13] = 1
			//Merc.CS_FinalMissionOpenBLU()
			//csStarted = 1
		}
		else if (Merc.CSFlags[15] == 0 && Merc.MissionStatus[25] >= 2)
		{
			// BLU Ending
			//Merc.CSFlags[15] = 1
			//Merc.CS_EndingBLU()
			//csStarted = 1
		}
		else if (Merc.CSFlags[10] == 0 && bonus >= 3)
		{
			// BLU Weapon 1
			//Merc.CSFlags[10] = 1
			//Merc.CS_Weapon1_BLU()
			//csStarted = 1
		}
		else if (Merc.CSFlags[11] == 0 && bonus >= 9)
		{
			// BLU Weapon 2
			//Merc.CSFlags[11] = 1
			//Merc.CS_Weapon2_BLU()
			//csStarted = 1
		}
		else if (Merc.CSFlags[28] == 0 && bonus >= 13)
		{
			// BLU 100%
			//Merc.CSFlags[28] = 1
			//Merc.CS_BLU_Complete()
		}
		
		if (!Merc.CutsceneActive && csStarted == 0)
		{
			Merc.RandomEventBLU()
		}
		
		local fade = Entities.FindByName(null, "fadeoverlay_blue")
		SetPropInt(fade, "m_nRenderFX", Constants.ERenderFx.kRenderFxFadeSlow)
		
		local voice = Entities.FindByName(null, "music_blue")
		local msg = "Merc.BLU.HubMusic"
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
	}
	else if (id == MercHubTrig.BLU_SecretPickups)
	{
		
	}
}

Merc.StartPressed <- function(isBLU)
{
	Merc.IsBLU = isBLU
	Merc.CutsceneActive = true
	Merc.BriefingActive = true
	//ClientPrint(null, HUD_PRINTTALK, "["+LOCM_MODENAME+"] Type 's' in chat to skip the briefing.")
	//Merc.StartBriefing()
	Merc.MissionStartCutscene(Merc.IsBLU)
	SendGlobalGameEvent("hide_annotation", {
		id = 10,
	})
	SendGlobalGameEvent("hide_annotation", {
		id = 11,
	})
	SendGlobalGameEvent("hide_annotation", {
		id = 15,
	})
	Merc.HideCrosshair()
}

Merc.MissionStartCutscene <- function(isBLU)
{
	if (Merc.MissionStarting) return
	Merc.MissionStarting = true
	Merc.ClearMonitorIcons()
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
	if (!IsDedicatedServer())
	{
		// it's buggy on changelevel, but in local it currently disconnects first, so that avoids the bugs here?
		//local viewcam = Entities.FindByName(null, "endview_" + team)
		//foreach (a in GetClients()) 
		//{
			//viewcam.AcceptInput("Enable","",a,null)
			//EntFireByHandle(viewcam, "Disable", "", 4.0, a, null)
			//EntFireByHandle(viewcam, "Kill", "", 4.0, a, null)
		//}
	}
	if (isBLU)
	{
		PrecacheScriptSound("Quest.DecodeHalloween")
		Merc.Delay(1.0, function() { 
			EmitSoundEx({ sound_name = "Quest.DecodeHalloween", })
		} )
	}
	else
	{
		PrecacheSound("ui/duel_challenge.wav")
		Merc.Delay(1.0, function() { 
			EmitSoundEx({ sound_name = "ui/duel_challenge.wav", })
		} )
	}
	Merc.Delay(4.9, function() { 
		ToConsole("tf_bot_kick all")
	} )
	
	Merc.Delay(5.0, function() { Merc.StartMission() } )
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
				SetPropString(self, "m_iszScriptThinkFunction", "")
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
	AddThinkToEnt(self, "InstSceneThink")
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

::BaseFlexThink <- function()
{
	self.StudioFrameAdvance()
    return -1
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

Merc.BottleShot <- function(id)
{
	//printl("shot " + id)
	caller.AcceptInput("Break","",caller,caller)
}