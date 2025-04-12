// KOTH Sewer
::Merc <- {}
Merc.MissionID <- 8
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_HEAVY
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_HEAVY, "Bot 04"),
	
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 08"),
]
Merc.ObjectiveText <- "Win without touching the point"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Kill Rat Bastards using Ratkiller X"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 7

::M07_Weapon <- "models/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl"
PrecacheModel(M07_Weapon)

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
	OnGameEvent_controlpoint_starttouch = function(params)
	{
		local player = EntIndexToHScript(params.player)
		if (player.GetTeam() != Merc.ForcedTeam) return
		if (IsPlayerABot(player)) return
		if (Merc.RoundEnded) return
		Merc.ForceFail()
		Merc.ChatPrint("Main objective failed! Touched the point.")
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
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
			
			local line = "+300℅ damage vs rats\n-10℅ damage";
			Merc.DisplayTrMsg("Ratkiller X",line,10.0)
		} )
		
		// map script stuff because it overrides root table
		::OnScriptHook_OnTakeDamage <- function(params)
		{
			local victim = params.const_entity

			if (!(victim in TheNextBots))
				return
			
			if (victim != null && victim in TheNextBots)
				DispatchParticleEffect("blood_impact_red_01", params.damage_position, victim.GetAbsAngles() + Vector())
			
			if (params.weapon != null && params.weapon.GetClassname() == "tf_weapon_shotgun_hwg" && !IsPlayerABot(params.attacker))
				params.damage *= 3.0
		}
		
		::OnGameEvent_npc_hurt <- function(params)
		{
			local entity = EntIndexToHScript(params.entindex)

			if (!(entity in TheNextBots))
				return

			if (params.health - params.damageamount <= 0)
			{
				NetProps.SetPropInt(entity, "m_takedamage", DAMAGE_EVENTS_ONLY)

				local npc = TheNextBots[entity]
				npc.OnKilled(params)

				delete TheNextBots[entity]
				entity.Kill()
				
				local player = GetPlayerFromUserID(params.attacker_player)
				if (!IsPlayerABot(player) && params.weaponid == 14)
				{
					Merc.ExtraGet(1,1,1)
				}
			}
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

