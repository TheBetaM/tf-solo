// PD Farmageddon
::Merc <- {}
Merc.MissionID <- 8
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_HEAVY
Merc.ForcedTeam <- TF_TEAM_RED
Merc.WaitTimeConvar <- 1
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 05"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SOLDIER, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SNIPER, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SPY, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_ENGINEER, "Bot 12"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Kill Scarecrows using Repellant X"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 7

::M07_Weapon <- "models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl"
PrecacheModel(M07_Weapon)

Merc.AfterPlayerInv <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() != Merc.ForcedTeam) return
	if (IsPlayerABot(player)) return
	
	local index = PrecacheModel(M07_Weapon)
	local vm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(vm, "m_spawnflags", 1073741824)
	SetPropInt(vm, "m_nModelIndex", index)
	SetPropBool(vm, "m_bValidatedAttachedEntity", true)
	SetPropBool(vm, "m_AttributeManager.m_Item.m_bInitialized", true)
	vm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(vm)
	vm.SetModel(M07_Weapon)
	
	local armindex = PrecacheModel("models/weapons/c_models/c_heavy_arms.mdl")
	local armvm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(armvm, "m_spawnflags", 1073741824)
	SetPropInt(armvm, "m_nModelIndex", armindex)
	SetPropBool(armvm, "m_bValidatedAttachedEntity", true)
	SetPropBool(armvm, "m_AttributeManager.m_Item.m_bInitialized", true)
	armvm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(armvm)
	armvm.SetModel("models/weapons/c_models/c_heavy_arms.mdl")
	
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
	SetPropInt(wm, "m_fEffects", EF_BONEMERGE | EF_BONEMERGE_FASTCULL)
	
	local wsize = GetPropArraySize(player, "m_hMyWeapons")
	for (local i = 0; i < wsize; i++)
    {
        local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null || !weapon.IsValid() || weapon.GetClassname() == "tf_weapon_spellbook" || weapon.GetSlot() != 1) continue;
		weapon.Destroy()
        SetPropEntityArray(player, "m_hMyWeapons", null, i)
    }
	
	//local waxe = Entities.CreateByClassname("tf_weapon_minigun")
	local waxe = Entities.CreateByClassname("tf_weapon_shotgun_hwg")
    //SetPropInt(waxe, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 850)
    SetPropInt(waxe, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 11)
    SetPropBool(waxe, "m_AttributeManager.m_Item.m_bInitialized", true)
    SetPropBool(waxe, "m_bValidatedAttachedEntity", true)
	SetPropEntity(waxe, "m_hOwner", player)
	SetPropEntity(waxe, "m_hOwnerEntity", player)
	local index = GetModelIndex(M07_Weapon)
	SetPropInt(waxe, "m_iWorldModelIndex", index)
	SetPropIntArray(waxe, "m_nModelIndexOverrides", index, 0)
	
	SetPropEntity(vm, "m_hWeaponAssociatedWith", waxe)
	SetPropEntity(armvm, "m_hWeaponAssociatedWith", waxe)
	SetPropEntity(wm, "m_hWeaponAssociatedWith", waxe)
	SetPropEntity(waxe, "m_hExtraWearableViewModel", vm)
	SetPropEntity(waxe, "m_hExtraWearable", wm)
	
	waxe.SetTeam(player.GetTeam())
	waxe.SetOwner(player)
	
	local flags = GetPropInt(waxe, "m_Collision.m_usSolidFlags")
	SetPropInt(waxe, "m_Collision.m_usSolidFlags", flags | FSOLID_NOT_SOLID)
	flags = GetPropInt(waxe, "m_Collision.m_usSolidFlags")
	SetPropInt(waxe, "m_Collision.m_usSolidFlags", flags & ~(FSOLID_TRIGGER))
	
	SetPropInt(waxe, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
	SetPropInt(waxe, "m_clrRender", 0)
	
	Entities.DispatchSpawn(waxe)
	waxe.ValidateScriptScope()
	
	waxe.AcceptInput("SetParent", "!activator", player, player)
	waxe.AddAttribute("killstreak tier", 1.0, -1)
	//waxe.AddAttribute("attack projectiles", 1.0, -1)
	//waxe.AddAttribute("damage blast push", 40.0, -1)
	waxe.AddAttribute("damage bonus", 0.9, -1)
	
	SetPropEntityArray(player, "m_hMyWeapons", waxe, waxe.GetSlot())
	player.Weapon_Equip(waxe)
	
	player.EquipWearableViewModel(armvm)
	player.EquipWearableViewModel(vm)
	
	player.Weapon_Switch(waxe)
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		local ent = null
		while (ent = Entities.FindByName(ent, "cap_teleport_trigger_red"))
		{
			ent.Kill()
		}
		ent = null
		while (ent = Entities.FindByName(ent, "cap_teleport_heal"))
		{
			ent.Kill()
		}
		ent = null
		while (ent = Entities.FindByName(ent, "cap_teleport_trigger_blu"))
		{
			ent.Kill()
		}
		ent = null
		while (ent = Entities.FindByName(ent, "cap_teleport"))
		{
			ent.Kill()
		}
		ent = null
		while (ent = Entities.FindByClassname(ent, "func_capturezone"))
		{
			ent.Kill()
		}
		
		local trigger = SpawnEntityFromTable("func_capturezone", 
		{
			origin = Vector(480,2084,24),
			spawnflags = 1,
		})
		trigger.SetSize(Vector(-100,-100,-300), Vector(100,100,50))
		trigger.SetSolid(2)
		EntityOutputs.AddOutput(trigger, "OnCapTeam1_PD", "pd_logic", "ScoreRedPoints", "", 0, -1)
		EntityOutputs.AddOutput(trigger, "OnCapTeam2_PD", "pd_logic", "ScoreBluePoints", "", 0, -1)
	
		Merc.Delay(0.5, function() { 
			foreach (a in GetClients()) 
			{	
				if (!IsPlayerABot(a))
				{
					local ent = null
					while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
					{
						if (ent.GetOwner() == a)
						{
							SetPropInt(ent, "m_iSelectedSpellIndex", RandomInt(0,11))
							SetPropInt(ent, "m_iSpellCharges", 5)
						}
					}
				}
			}
			
			local line = "+400℅ damage vs Scarecrows\n-10℅ damage";
			Merc.DisplayTrMsg("Repellant X",line,10.0)
		} )
	}
	
	OnScriptHook_OnTakeDamage = function(params)
	{
		local victim = params.const_entity
		local attacker = params.attacker
		if (victim.GetClassname() != "tf_zombie") return
		if (attacker == null) return
		if (IsPlayerABot(attacker)) return
		if (params.weapon != null && params.weapon.GetClassname() == "tf_weapon_shotgun_hwg")
		{
			params.damage *= 4.0
			if (victim.GetHealth() - params.damage <= 0)
			{
				Merc.ExtraGet(1,1,1)
			}
		}
		
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

