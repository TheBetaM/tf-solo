// PL Bloodwater
::Merc <- {}
Merc.MissionID <- 25
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_MEDIC
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED, 2, "Bloodthirst_HandlerRED"),
	
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_SOLDIER, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_PYRO, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_DEMOMAN, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_HEAVY, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_ENGINEER, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_MEDIC, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_SNIPER, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_SPY, "Bot 09"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SCOUT, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SOLDIER, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_PYRO, "Bot 12"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_DEMOMAN, "Bot 13"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_HEAVY, "Bot 14"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_ENGINEER, "Bot 15"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_MEDIC, "Bot 16"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SNIPER, "Bot 17"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SPY, "Bot 18"),
]
Merc.ObjectiveText <- "Reach full health"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 10000
Merc.ObjectiveExtraText <- "Capture points"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 3
Merc.ForceWinOnMainDone <- 1
Merc.AllowBuffs <- 0

Convars.SetValue("mp_disable_respawn_times", 1)

::M25_DraculaItem1 <- "models/workshop/player/items/medic/sf14_vampiric_vesture/sf14_vampiric_vesture.mdl"
::M25_DraculaItem2 <- "models/workshop/player/items/medic/hwn2023_power_spike/hwn2023_power_spike.mdl"
PrecacheModel(M25_DraculaItem1)
PrecacheModel(M25_DraculaItem2)
::M25_HealthBonus <- 0

::MRemOutput <- function(a,b,c,d,e)
{
	EntityOutputs.RemoveOutput(a,b,c,d,e)
}

::M25_UpdateHealth <- function()
{
	if (Merc.RoundEnded) return
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a))
		{
			Merc.ObjectiveMainCount = a.GetHealth()
			if (Merc.ObjectiveMainCount >= Merc.ObjectiveMainMax)
			{
				Merc.MainGet(0,1,1)
			}
			Merc.UpdateHUD()
			return
		}
	}
}

::M25_SpawnAsDracula <- function(player)
{
	player.SetHealth(150 + M25_HealthBonus)
	local wsize = GetPropArraySize(player, "m_hMyWeapons")
	for (local i = 0; i < wsize; i++)
    {
        local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null || !weapon.IsValid()) continue;
		if (weapon.GetClassname() == "tf_weapon_spellbook") continue;
		weapon.Destroy()
        SetPropEntityArray(player, "m_hMyWeapons", null, i)
    }
	local ent = null
	while (ent = Entities.FindByClassname(ent, "tf_wearable"))
	{
		if (ent.GetOwner() == player)
		{
			ent.DisableDraw()
		}
	}
	
	local waxe = Entities.CreateByClassname("tf_weapon_syringegun_medic")
    SetPropInt(waxe, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 36)
    SetPropBool(waxe, "m_AttributeManager.m_Item.m_bInitialized", true)
    SetPropBool(waxe, "m_bValidatedAttachedEntity", true)
	SetPropEntity(waxe, "m_hOwner", player)
	SetPropEntity(waxe, "m_hOwnerEntity", player)
	
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
	waxe.AddAttribute("Projectile speed increased", 1.2, -1)
	waxe.AddAttribute("damage bonus", 1.5, -1)
	waxe.AddAttribute("item style override", 1.0, -1)
	//waxe.AddAttribute("set_item_texture_wear", 0.6, -1)
	//waxe.AddAttribute("paintkit_proto_def_index", 102.0, -1)
	
	SetPropEntityArray(player, "m_hMyWeapons", waxe, waxe.GetSlot())
	player.Weapon_Equip(waxe)
	
	if (waxe != null)
	{
		player.Weapon_Switch(waxe)
	}
	
	Merc.Delay(1.0, function() {
		player.SetHealth(150 + M25_HealthBonus)
		player.AddCustomAttribute("hidden maxhealth non buffed", 10000.0, -1)
		player.AddCustomAttribute("maxammo primary increased", 90.0, -1)
		player.AddCustomAttribute("ammo regen", 90.0, -1)
		player.AddCustomAttribute("cancel falling damage", 1.0, -1)
		player.AddCustomAttribute("cannot be backstabbed", 1.0, -1)
		player.AddCustomAttribute("heal on kill", 500.0, -1)
		if (Merc.MissionStatus[23] >= 2)
		{
			player.AddCustomAttribute("mark for death", 1.0, -1)
		}
	} )
	Merc.Delay(1.5, function() {
		player.Taunt(0,0)
		
		local index1 = PrecacheModel(M25_DraculaItem1)
		local hat1 = Entities.CreateByClassname("tf_wearable")
		SetPropInt(hat1, "m_spawnflags", 1073741824)
		SetPropInt(hat1, "m_nModelIndex", index1)
		SetPropInt(hat1, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 116)
		SetPropBool(hat1, "m_bValidatedAttachedEntity", true)
		SetPropBool(hat1, "m_AttributeManager.m_Item.m_bInitialized", true)
		SetPropEntity(hat1, "m_hOwner", player)
		SetPropEntity(hat1, "m_hOwnerEntity", player)
		hat1.SetTeam(player.GetTeam())
		Entities.DispatchSpawn(hat1)
		hat1.SetModel(M25_DraculaItem1)
		hat1.SetOwner(player)
		hat1.AcceptInput("SetParent", "!activator", player, player)
		
		local index2 = PrecacheModel(M25_DraculaItem2)
		local hat2 = Entities.CreateByClassname("tf_wearable")
		SetPropInt(hat2, "m_spawnflags", 1073741824)
		SetPropInt(hat2, "m_nModelIndex", index2)
		SetPropInt(hat2, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 116)
		SetPropBool(hat2, "m_bValidatedAttachedEntity", true)
		SetPropBool(hat2, "m_AttributeManager.m_Item.m_bInitialized", true)
		SetPropEntity(hat2, "m_hOwner", player)
		SetPropEntity(hat2, "m_hOwnerEntity", player)
		hat2.SetTeam(player.GetTeam())
		Entities.DispatchSpawn(hat2)
		hat2.SetModel(M25_DraculaItem2)
		hat2.SetOwner(player)
		hat2.AcceptInput("SetParent", "!activator", player, player)
	} )
	player.Teleport(true, Vector(-885,-1518,7020), true, QAngle(0, 90, 0), true, Vector(0, 0, 0))
}

Merc.AfterPlayerInv <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() != Merc.ForcedTeam) return
	if (IsPlayerABot(player)) return
	if (Merc.RoundEnded) return
	
	player.SetHealth(150 + M25_HealthBonus)
	//M25_SpawnAsDracula(player)
	player.Teleport(true, Vector(-885,-1518,7020), true, QAngle(0, 90, 0), true, Vector(0, 0, 0))
}

Merc.BeforeRoundStart <- function(params) 
{
	if (Merc.MissionStatus[22] >= 2)
	{
		M25_HealthBonus <- 300
	}
	
	local ent = null
	while (ent = Entities.FindByClassname(ent, "item_healthkit_full"))
	{
		ent.SetTeam(TF_TEAM_RED)
	}
	ent = null
	while (ent = Entities.FindByClassname(ent, "item_healthkit_medium"))
	{
		ent.SetTeam(TF_TEAM_RED)
	}
	ent = null
	while (ent = Entities.FindByClassname(ent, "item_healthkit_small"))
	{
		ent.SetTeam(TF_TEAM_RED)
	}
	ent = null
	while (ent = Entities.FindByClassname(ent, "mapobj_cart_dispenser"))
	{
		ent.Kill()
	}
	ent = null
	while (ent = Entities.FindByName(ent, "dispenser_touch_trigger"))
	{
		ent.Kill()
	}
	ent = null
	while (ent = Entities.FindByName(ent, "door1_door_close_trigger"))
	{
		ent.Kill()
	}
	ent = null
	while (ent = Entities.FindByName(ent, "cap_2_relay"))
	{
		MRemOutput(ent,"OnTrigger","door1_trigger","Kill","")
		MRemOutput(ent,"OnTrigger","door2_door","Close","")
	}
	ent = null
	while (ent = Entities.FindByName(ent, "both_doors_closed_killbrush"))
	{
		ent.Kill()
	}
	
	
	ent = null
	while (ent = Entities.FindByClassname(ent, "func_regenerate"))
	{
		local team = ent.GetTeam()
		if (team == Merc.ForcedTeam)
		{
			ent.SetAbsOrigin(Vector(0,0,-8000))
			ent.SetSize(Vector(-0.1,-0.1,-0.1),Vector(0.1,0.1,0.1))
		}
	}
	ent = null
	while (ent = Entities.FindByClassname(ent, "team_round_timer"))
	{
		EntFireByHandle(ent, "SetSetupTime", "1", -1, ent, ent)
	}
	
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a))
		{
			a.SetHealth(150 + M25_HealthBonus)
		}
	}
	
	Merc.Delay(0.5, function() { 
		foreach (a in GetClients()) 
		{	
			if (!IsPlayerABot(a))
			{
				a.SetHealth(150 + M25_HealthBonus)
				M25_SpawnAsDracula(a)
			}
		}
	} )
	
	Merc.Timer(0.25, 0, function() {
		M25_UpdateHealth()
	} )
	
	Merc.Delay(2.5, function() { 
		local tperks = "Completion Bonus: "
		local hasperks = false
		if (Merc.MissionStatus[22] >= 2)
		{
			tperks += "[+300 HP headstart] "
			hasperks = true
		}
		if (Merc.MissionStatus[23] >= 2)
		{
			tperks += "[+DRACULA gains On Hit: Marked For Death]"
			hasperks = true
		}
		if (hasperks) Merc.ChatPrint(tperks)
	} )
	
	Merc.Delay(5.0, function() { 
		local line = "+On Kill: Heal 500 HP\n-No Medigun or Melee"
		if (Merc.MissionStatus[23] >= 2)
		{
			line = "+On Hit: Apply Marked For Death\n" + line
		}
		Merc.DisplayTrMsg("The Bloodsucker",line,10.0)
	} )
	
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || IsPlayerABot(player)) return
		Merc.ForceFail()
	}
	
	OnGameEvent_teamplay_point_captured = function(params)
	{
		Merc.ExtraGet(1,1,1)
		if (Merc.ObjectiveExtraCount >= 3)
		{
			local ent = null
			while (ent = Entities.FindByClassname(ent, "trigger_capture_area"))
			{
				ent.Kill()
			}
		}
	}
	
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			ent.Kill()
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

