// PL Spineyard
::Merc <- {}
Merc.MissionID <- 23
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_SNIPER
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 07"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_ENGINEER, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_HEAVY, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_DEMOMAN, "Bot 12"),
]
Merc.ObjectiveText <- "Win without touching the cart"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get kills with The Tommygun"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 3
Merc.AllowBuffs <- 0

::M19_Tommygun <- "models/props_tuscany/tommygun_01.mdl"
PrecacheModel("models/bots/vineyard_event/skeleton_sniper_mafia.mdl")
PrecacheModel(M19_Tommygun)

::M19_SpawnAsMafia <- function(player)
{
	player.SetCustomModelWithClassAnimations("models/player/sniper.mdl")
	
	Merc.Delay(0.5, function() { 
		player.AddCustomAttribute("hidden maxhealth non buffed", 500.0, -1)
		player.SetHealth(500)
		
		local group = player.FindBodygroupByName("hat")
		local groupent = player.GetBodygroup(group)
		local body = Entities.CreateByClassname("tf_wearable")
		DoEntFire("!self", "SetParent", "!activator", -1, player, body)
		body.SetModelSimple("models/bots/vineyard_event/skeleton_sniper_mafia.mdl")
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

Merc.BeforeRoundWin <- function(params)
{
	if (params.team == Merc.ForcedTeam)
	{
		Merc.MainGet(1,1,1)
	}
}

Merc.AfterPlayerInv <- function(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() != Merc.ForcedTeam || IsPlayerABot(player)) return
	
	local index = PrecacheModel(M19_Tommygun)
	local vm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(vm, "m_spawnflags", 1073741824)
	SetPropInt(vm, "m_nModelIndex", index)
	SetPropBool(vm, "m_bValidatedAttachedEntity", true)
	SetPropBool(vm, "m_AttributeManager.m_Item.m_bInitialized", true)
	vm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(vm)
	vm.SetModel(M19_Tommygun)
	
	local armindex = PrecacheModel("models/weapons/c_models/c_sniper_arms.mdl")
	local armvm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(armvm, "m_spawnflags", 1073741824)
	SetPropInt(armvm, "m_nModelIndex", armindex)
	SetPropBool(armvm, "m_bValidatedAttachedEntity", true)
	SetPropBool(armvm, "m_AttributeManager.m_Item.m_bInitialized", true)
	armvm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(armvm)
	armvm.SetModel("models/weapons/c_models/c_sniper_arms.mdl")
	
	local wm = Entities.CreateByClassname("tf_wearable_campaign_item")
	SetPropInt(wm, "m_spawnflags", 1073741824)
	SetPropInt(wm, "m_nModelIndex", index)
	SetPropBool(wm, "m_bValidatedAttachedEntity", true)
	SetPropBool(wm, "m_AttributeManager.m_Item.m_bInitialized", true)
	SetPropEntity(wm, "m_hOwnerEntity", player)
	wm.SetOwner(player)
	wm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(wm)
	wm.AcceptInput("SetParent", "!activator", player, player)
	SetPropInt(wm, "m_fEffects", EF_BONEMERGE | EF_BONEMERGE_FASTCULL);
	
	local wsize = GetPropArraySize(player, "m_hMyWeapons")
	for (local i = 0; i < wsize; i++)
    {
        local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null || !weapon.IsValid()) continue;
		if (weapon.GetSlot() != 1) continue;
		weapon.Destroy()
        SetPropEntityArray(player, "m_hMyWeapons", null, i)
    }
	
	local wsmg = Entities.CreateByClassname("tf_weapon_smg")
    SetPropInt(wsmg, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 16)
    SetPropBool(wsmg, "m_AttributeManager.m_Item.m_bInitialized", true)
    SetPropBool(wsmg, "m_bValidatedAttachedEntity", true)
	SetPropEntity(wsmg, "m_hOwner", player)
	SetPropEntity(wsmg, "m_hOwnerEntity", player)
	
	SetPropEntity(vm, "m_hWeaponAssociatedWith", wsmg)
	SetPropEntity(armvm, "m_hWeaponAssociatedWith", wsmg)
	SetPropEntity(wm, "m_hWeaponAssociatedWith", wsmg)
	SetPropEntity(wsmg, "m_hExtraWearableViewModel", vm)
	SetPropEntity(wsmg, "m_hExtraWearable", wm)
	
	wsmg.SetTeam(player.GetTeam())
	wsmg.SetOwner(player)
	
	local flags = GetPropInt(wsmg, "m_Collision.m_usSolidFlags")
	SetPropInt(wsmg, "m_Collision.m_usSolidFlags", flags | FSOLID_NOT_SOLID)
	flags = GetPropInt(wsmg, "m_Collision.m_usSolidFlags")
	SetPropInt(wsmg, "m_Collision.m_usSolidFlags", flags & ~(FSOLID_TRIGGER))
	
	SetPropInt(wsmg, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
	SetPropInt(wsmg, "m_clrRender", 0)
	
	Entities.DispatchSpawn(wsmg)
	wsmg.ValidateScriptScope()
	
	wsmg.AcceptInput("SetParent", "!activator", player, player)
	wsmg.AddAttribute("killstreak tier", 1.0, -1)
	wsmg.AddAttribute("damage bonus", 1.25, -1)
	wsmg.AddAttribute("maxammo secondary increased", 1.25, -1)
	wsmg.AddAttribute("clip size bonus", 1.6, -1)
	wsmg.AddAttribute("fire rate penalty", 1.25, -1)
	wsmg.AddAttribute("revolver use hit locations", 1, -1)
	
	SetPropEntityArray(player, "m_hMyWeapons", wsmg, wsmg.GetSlot())
	player.Weapon_Equip(wsmg)
	
	if (wsmg != null)
	{
		player.Weapon_Switch(wsmg)
	}
	player.EquipWearableViewModel(armvm)
	player.EquipWearableViewModel(vm)
	
	//player.AddCustomAttribute("hidden maxhealth non buffed", 500.0, -1)
	//player.SetHealth(500)
	
	/*
	local ent = null
	while (ent = Entities.FindByClassname(ent, "tf_wearable"))
	{
		if (ent.GetOwner() == player)
		{
			ent.DisableDraw()
		}
	}
	*/
	
	//M19_SpawnAsMafia(player)
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0) return
		if (!IsPlayerABot(player))
		{
			//player.SetCustomModelWithClassAnimations("models/bots/vineyard_event/skeleton_sniper_mafia.mdl")
			return
		}
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || IsPlayerABot(aplayer)) return
		
		if (params.weapon == "smg")
		{
			Merc.ExtraGet(1,1,1)
		}
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		Merc.Delay(0.5, function() { 
		foreach (a in GetClients()) 
		{	
			if (!IsPlayerABot(a))
			{
				//M19_SpawnAsMafia(a)
				local ent = null
				while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
				{
					if (ent.GetOwner() == a)
					{
						SetPropInt(ent, "m_iSelectedSpellIndex", 11)
						SetPropInt(ent, "m_iSpellCharges", 4)
					}
				}
			}
		}
		
		local line = "+Deals crits on headshots\n+25℅ damage and ammo\n-25℅ firing speed"
			Merc.DisplayTrMsg("The Tommygun",line,20.0)
		} )
	}
	
	OnGameEvent_controlpoint_starttouch = function(params)
	{
		local player = EntIndexToHScript(params.player)
		if (player.GetTeam() != Merc.ForcedTeam) return
		if (IsPlayerABot(player)) return
		if (!Merc.RoundEnded)
		{
			Merc.ForceFail()
			Merc.ChatPrint("Main objective failed! Touched the cart.");
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

