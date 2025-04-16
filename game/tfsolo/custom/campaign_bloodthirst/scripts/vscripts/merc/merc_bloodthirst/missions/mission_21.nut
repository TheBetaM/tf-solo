// CP Mann Manor
::Merc <- {}
Merc.MissionID <- 21
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_DEMOMAN
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 12"),
]
Merc.ObjectiveText <- "Defeat all enemies"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 12
Merc.ObjectiveExtraText <- "Capture the point"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 2
Merc.AllowBuffs <- 0
Merc.ForceWinOnMainDone <- 1

Merc.Bots[0].Flags = 4
Merc.Bots[0].Lives = 3
Merc.Bots[1].Flags = 4
Merc.Bots[1].Lives = 2
Merc.Bots[2].Flags = 4
Merc.Bots[2].Lives = 1
Merc.Bots[3].Flags = 4
Merc.Bots[3].Lives = 2
Merc.Bots[4].Flags = 4
Merc.Bots[4].Lives = 2
Merc.Bots[5].Flags = 4
Merc.Bots[5].Lives = 3
Merc.Bots[6].Flags = 4
Merc.Bots[6].Lives = 2
Merc.Bots[7].Flags = 4
Merc.Bots[7].Lives = 1
Merc.Bots[8].Flags = 4
Merc.Bots[8].Lives = 2
Merc.Bots[9].Flags = 4
Merc.Bots[9].Lives = 1
Merc.Bots[10].Flags = 4
Merc.Bots[10].Lives = 2
Merc.Bots[11].Flags = 4
Merc.Bots[11].Lives = 1

::SecretPickupProp <- "models/props_halloween/gargoyle_ghost.mdl"
PrecacheModel(SecretPickupProp)
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })
PrecacheScriptSound("Halloween.Haunted")
::M21_Bigaxe <- "models/weapons/c_models/c_bigaxe/c_bigaxe.mdl"
PrecacheModel("models/bots/headless_hatman.mdl")
PrecacheModel(M21_Bigaxe)

::M21_SpawnAsHHH <- function(player)
{
	player.SetCustomModelWithClassAnimations("models/player/demo.mdl")
	//player.AddCond(TF_COND_MELEE_ONLY)
	//player.RemoveCond(TF_COND_HALLOWEEN_TINY)
	//player.AddCond(TF_COND_HALLOWEEN_GIANT)
	
	Merc.Delay(0.5, function() { 
		player.AddCustomAttribute("hidden maxhealth non buffed", 2000.0, -1)
		player.SetHealth(2000)
		//player.Taunt(0,0)
		local group = player.FindBodygroupByName("hat")
		local groupent = player.GetBodygroup(group)
		local body = Entities.CreateByClassname("tf_wearable")
		DoEntFire("!self", "SetParent", "!activator", -1, player, body)
		body.SetModelSimple("models/bots/headless_hatman.mdl")
		SetPropEntity(body, "m_hOwnerEntity", player)
		SetPropInt(body, "m_Collision.m_usSolidFlags", Constants.FSolid.FSOLID_NOT_SOLID)
		SetPropInt(body, "m_CollisionGroup", 11)
		SetPropInt(body, "m_bValidatedAttachedEntity", 1)
		SetPropInt(body, "m_iTeamNum", player.GetTeam())
		SetPropInt(body, "m_fEffects", 129)
		SetPropInt(body, "m_AttributeManager.m_Item.m_bInitialized", 1)
		Entities.DispatchSpawn(body)
		SetPropInt(player, "m_nRenderFX", 6)
		body.SetBodygroup(group, groupent)
		player.SetForcedTauntCam(1)
		player.Taunt(0,0)
	} )
	Merc.Delay(2.0, function() { 
		player.SetForcedTauntCam(0)
	} )
}

::SecretPickupGet <- function()
{
	Merc.RSVFlags[12] = 1
}
function SpawnSecretPickup(x, y, z)
{
	local prop = SpawnEntityFromTable("tf_halloween_pickup", {
		origin       = Vector(x,y,z - 18.0),
		angles       = QAngle(0,RandomInt(0, 181),0),
		targetname   = "mercduck",
		model 		 = SecretPickupProp,
		powerup_model = SecretPickupProp,
		pickup_particle = "taunt_headbutt_impact_stars",
		pickup_sound = "Halloween.Haunted",
		automaterialize = false,
		TeamNum = Merc.ForcedTeam,
		teamnumber = Merc.ForcedTeam,
	})
	prop.SetTeam(Merc.ForcedTeam)
	prop.ValidateScriptScope()
	prop.ConnectOutput("OnBluePickup", "SecretPickupGet")
}

Merc.BotOnLivesDepleted <- function(a) 
{
	Merc.MainGet(1,1,1)
}

Merc.BeforeRoundStart <- function(params) 
{
	Merc.Bots[0].Flags = 4
	Merc.Bots[0].Lives = 3
	Merc.Bots[1].Flags = 4
	Merc.Bots[1].Lives = 2
	Merc.Bots[2].Flags = 4
	Merc.Bots[2].Lives = 1
	Merc.Bots[3].Flags = 4
	Merc.Bots[3].Lives = 2
	Merc.Bots[4].Flags = 4
	Merc.Bots[4].Lives = 2
	Merc.Bots[5].Flags = 4
	Merc.Bots[5].Lives = 3
	Merc.Bots[6].Flags = 4
	Merc.Bots[6].Lives = 2
	Merc.Bots[7].Flags = 4
	Merc.Bots[7].Lives = 1
	Merc.Bots[8].Flags = 4
	Merc.Bots[8].Lives = 2
	Merc.Bots[9].Flags = 4
	Merc.Bots[9].Lives = 1
	Merc.Bots[10].Flags = 4
	Merc.Bots[10].Lives = 2
	Merc.Bots[11].Flags = 4
	Merc.Bots[11].Lives = 1
	
	if (Merc.RSVFlags[12] == 0)
	{
		SpawnSecretPickup(-3402,2058,-590)
	}
	
	Merc.Delay(1.0, function() { 
		local line = "+2000 Max Health\n+Knockback immunity\n-100℅ soul"
		Merc.DisplayTrMsg("H.H.H.'s Headtaker",line,10.0)
	} )
}

Merc.AfterPlayerInv <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() != Merc.ForcedTeam) return
	if (IsPlayerABot(player)) return
	
	local wsize = GetPropArraySize(player, "m_hMyWeapons")
	for (local i = 0; i < wsize; i++)
    {
        local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null || !weapon.IsValid() || weapon.GetClassname() == "tf_weapon_spellbook") continue;
		weapon.Destroy()
        SetPropEntityArray(player, "m_hMyWeapons", null, i)
    }
	
	local waxe = Entities.CreateByClassname("tf_weapon_sword")
    SetPropInt(waxe, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 266)
    SetPropBool(waxe, "m_AttributeManager.m_Item.m_bInitialized", true)
    SetPropBool(waxe, "m_bValidatedAttachedEntity", true)
	SetPropEntity(waxe, "m_hOwner", player)
	SetPropEntity(waxe, "m_hOwnerEntity", player)
	local index = GetModelIndex(M21_Bigaxe)
	SetPropInt(waxe, "m_iWorldModelIndex", index)
	SetPropIntArray(waxe, "m_nModelIndexOverrides", index, 0)
	
	waxe.SetTeam(player.GetTeam())
	waxe.SetOwner(player)
	
	local flags = GetPropInt(waxe, "m_Collision.m_usSolidFlags")
	SetPropInt(waxe, "m_Collision.m_usSolidFlags", flags | FSOLID_NOT_SOLID)
	flags = GetPropInt(waxe, "m_Collision.m_usSolidFlags")
	SetPropInt(waxe, "m_Collision.m_usSolidFlags", flags & ~(FSOLID_TRIGGER))
	
	Entities.DispatchSpawn(waxe)
	waxe.ValidateScriptScope()
	
	waxe.AcceptInput("SetParent", "!activator", player, player)
	waxe.AddAttribute("killstreak tier", 1.0, -1)
	waxe.AddAttribute("damage force reduction", 0, -1)
	
	SetPropEntityArray(player, "m_hMyWeapons", waxe, waxe.GetSlot())
	player.Weapon_Equip(waxe)
	
	if (waxe != null)
	{
		player.Weapon_Switch(waxe)
	}
	
	player.AddCustomAttribute("hidden maxhealth non buffed", 2000.0, -1)
	player.AddCustomAttribute("damage force reduction", 0, -1)
	player.SetHealth(2000)
	
	M21_SpawnAsHHH(player)
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_point_captured = function(params)
	{
		if (params.team != Merc.ForcedTeam) return
		Merc.ExtraGet(1,1,1)
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

