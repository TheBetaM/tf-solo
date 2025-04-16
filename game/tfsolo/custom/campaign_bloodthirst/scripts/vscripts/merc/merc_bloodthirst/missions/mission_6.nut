// KOTH Slime
::Merc <- {}
Merc.MissionID <- 6
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_ENGINEER
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Bot 06"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SOLDIER, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SNIPER, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SPY, "Bot 12"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_ENGINEER, "Bot 13"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get kills using The Salmann Creator"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 6
Merc.ForceWinOnMainDone <- 1

::M05_Weapon <- "models/passtime/ball/passtime_ball.mdl"
PrecacheModel(M05_Weapon)

::M05_RatCooldown <- 0.0
::M06_SlimeScope <- null
::M06_SalmannRange <- 600.0 //32768.0

::M05_RatThink <- function()
{
	if (M05_RatCooldown > 0.0)
	{
		M05_RatCooldown -= FrameTime()
		return -1
	}
	
	foreach (a in GetClients()) 
	{	
		local w = a.GetActiveWeapon()
		
		if (!IsPlayerABot(a) && a.IsAlive() && w != null && w.GetSlot() == 1)
		{
			local buttons = GetPropInt(a, "m_nButtons")
			local isAttacking = buttons & IN_ATTACK
			local rat = null
			
			if (!isAttacking)
			{
				continue
			}
			M05_RatCooldown = 10.0
			
			local trace =
			{
				start = a.EyePosition(),
				end = a.EyePosition() + (a.EyeAngles().Forward() * M06_SalmannRange),
				ignore = a
			}
			if (!TraceLineEx(trace))
			{
				continue
			}
			
			local prop = SpawnEntityFromTable("info_target", {
				origin = trace.pos,
				angles = QAngle(0, RandomInt(0,360), 0),
			})
			local salmann = M06_SlimeScope.SpawnSalmann(prop)
			salmann.ValidateScriptScope()
			salmann.GetScriptScope()["MercMinion"] <- 1
			prop.Kill()
		}
	}
	return -1
}

Merc.AfterPlayerInv <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() != Merc.ForcedTeam) return
	if (IsPlayerABot(player)) return
	
	PrecacheModel(M05_Weapon)
	
	local index = PrecacheModel(M05_Weapon)
	local vm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(vm, "m_spawnflags", 1073741824)
	SetPropInt(vm, "m_nModelIndex", index)
	SetPropBool(vm, "m_bValidatedAttachedEntity", true)
	SetPropBool(vm, "m_AttributeManager.m_Item.m_bInitialized", true)
	vm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(vm)
	vm.SetModel(M05_Weapon)
	
	local armindex = PrecacheModel("models/weapons/c_models/c_engineer_arms.mdl")
	local armvm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(armvm, "m_spawnflags", 1073741824)
	SetPropInt(armvm, "m_nModelIndex", armindex)
	SetPropBool(armvm, "m_bValidatedAttachedEntity", true)
	SetPropBool(armvm, "m_AttributeManager.m_Item.m_bInitialized", true)
	armvm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(armvm)
	armvm.SetModel("models/weapons/c_models/c_engineer_arms.mdl")
	
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
	
	local waxe = Entities.CreateByClassname("tf_weapon_laser_pointer")
    SetPropInt(waxe, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 140)
    SetPropBool(waxe, "m_AttributeManager.m_Item.m_bInitialized", true)
    SetPropBool(waxe, "m_bValidatedAttachedEntity", true)
	SetPropEntity(waxe, "m_hOwner", player)
	SetPropEntity(waxe, "m_hOwnerEntity", player)
	local index = GetModelIndex(M05_Weapon)
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
	waxe.AddAttribute("engy sentry damage bonus", 0.5, -1)
	
	SetPropEntityArray(player, "m_hMyWeapons", waxe, waxe.GetSlot())
	player.Weapon_Equip(waxe)
	
	player.EquipWearableViewModel(armvm)
	player.EquipWearableViewModel(vm)
	
	player.Weapon_Switch(waxe)
}

Merc.BeforeRoundStart <- function(params) 
{
	foreach (a in Merc.Bots)
	{
		a.Flags = 2
		a.SpawnPos = Vector(2390,-905,-124)
		if (a.Team == TF_TEAM_BLUE)
		{
			a.SpawnPos = Vector(-2390,-905,-124)
		}
	}
	
	local slimescript = Entities.FindByName(null, "logic_script_slime")
	M06_SlimeScope = slimescript.GetScriptScope()
	M05_RatCooldown = 0.0
	
	local prop = SpawnEntityFromTable("logic_script", {})
	AddThinkToEnt(prop,"M05_RatThink")
	
	Merc.Delay(0.5, function() { 
		local line = "+Creates Salmanns\n-50℅ Sentry Gun damage";
		Merc.DisplayTrMsg("The Salmann Creator",line,10.0)
	} )
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam) return
		
		local inf = EntIndexToHScript(params.inflictor_entindex)
		if (inf.GetClassname() == "tf_zombie")
		{
			inf.ValidateScriptScope()
			if ("MercMinion" in inf.GetScriptScope())
			{
				Merc.ExtraGet(1,1,1)
			}
		}
	}
	
	OnGameEvent_player_spawn = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam)
		{
			local ent = null
			while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
			{
				if (ent.GetOwner() == player)
				{
					SetPropInt(ent, "m_iSelectedSpellIndex", 8)
					SetPropInt(ent, "m_iSpellCharges", 1)
				}
			}
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

