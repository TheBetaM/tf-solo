// KOTH Los Muertos
::Merc <- {}
Merc.MissionID <- 2
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_SOLDIER
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SOLDIER, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_MEDIC, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_HEAVY, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_PYRO, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_DEMOMAN, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SNIPER, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SPY, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_ENGINEER, "Bot 09"),
	
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_HEAVY, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 12"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 13"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 14"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 15"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 16"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 17"),
]
Merc.ObjectiveText <- "Win without getting scared"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get rid of ghosts using the Ghost Buster"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 16

PrecacheModel("models/props_halloween/ghost.mdl")
PrecacheModel("models/props_halloween/ghost_no_hat.mdl")
PrecacheModel("models/props_soho/trashbag001.mdl")
PrecacheScriptSound("Halloween.Haunted")
PrecacheScriptSound("Halloween.GhostMoan")
PrecacheScriptSound("Halloween.GhostBoo")
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "ghost_appearation" })

::M12_Weapon <- "models/workshop_partner/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl"
PrecacheModel(M12_Weapon)

::M23GhostSpots <- [
	[-2676,400,4],
	[-4421,1721,-20],
	[-4389,2426,44],
	[-4421,3133,-20],
	[-3685,2415,44],
	[-5070,2425,108],
	[-5033,1082,12],
	[-3875,3601,-52],
	[-2671,3252,108],
	[-2671,1618,108],
]

function M23_PlayerThink()
{
	if (self.IsSnared() && !Merc.RoundEnded)
	{
		Merc.ForceFail()
		Merc.ChatPrint("Main objective failed! Got scared.")
	}
	
	return -1
}

::M23_GhostThink <- function()
{
	try
	{
		self.SetOrigin(mghost.GetOrigin())
	}
	catch (e)
	{
		self.Kill()
	}
	return -1
}

function M23_SpawnGhost(x, y, z)
{
	local ghost = SpawnEntityFromTable("ghost", {
		origin = Vector(x,y,z - 0.0),
		angles = QAngle(0,RandomInt(0, 180),0),
	})
	ghost.AddFlag(FL_NOTARGET)
	local prop = SpawnEntityFromTable("prop_dynamic", {
		origin = ghost.GetOrigin(),
		angles = ghost.GetAngles(),
		model = "models/props_soho/trashbag001.mdl",
		targetname = "mghost",
		max_health = 1000,
		health = 1000,
		solid = 6,
	})
	SetPropInt(prop, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
	SetPropInt(prop, "m_clrRender", 0)
	prop.SetCollisionGroup(25)
	prop.SetSize(Vector(-32, -32, 0), Vector(32, 32, 64))
	prop.SetSolid(3)
	prop.SetTeam(TF_TEAM_BLUE)
	prop.ValidateScriptScope()
	prop.GetScriptScope()["mghost"] <- ghost
	prop.GetScriptScope()["GhostState"] <- 0
	prop.GetScriptScope()["GhostHit"] <- function(){
		if (GhostState != 0) return
		if (IsPlayerABot(activator)) return
		GhostState = 1
		
		local userid = activator.GetUserID()
		SendGlobalGameEvent("npc_hurt", {
			entindex = self.entindex(),
			health = 1000,
			attacker_player = userid,
			damageamount = 100,
		})
		Merc.ExtraGet(1,1,1)
		try
		{
			if (mghost != null)
			{
				DispatchParticleEffect("ghost_appearation", mghost.GetOrigin(), mghost.GetAngles())
				mghost.Kill()
			}
		}
		catch (e)
		{
			
		}
		self.Kill()
	}
	prop.ConnectOutput("OnTakeDamage", "GhostHit")
	AddThinkToEnt(prop,"M23_GhostThink")
	
	
}

::M23_SpawnGhosts <- function()
{
	foreach (i in M23GhostSpots)
	{
		M23_SpawnGhost(i[0],i[1],i[2])
	}
}

::TauntNeeded <- false

::M12_PlayerThink <- function()
{
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a))
		{
			if (a.IsSnared() && !Merc.RoundEnded)
			{
				Merc.ForceFail()
				Merc.ChatPrint("Main objective failed! Got scared.")
				return -1
			}
		}
	}
	
	return -1
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
	if (player.GetTeam() != Merc.ForcedTeam) return
	if (IsPlayerABot(player)) return
	
	PrecacheModel(M12_Weapon)
	
	local index = PrecacheModel(M12_Weapon)
	local vm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(vm, "m_spawnflags", 1073741824)
	SetPropInt(vm, "m_nModelIndex", index)
	SetPropBool(vm, "m_bValidatedAttachedEntity", true)
	SetPropBool(vm, "m_AttributeManager.m_Item.m_bInitialized", true)
	vm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(vm)
	vm.SetModel(M12_Weapon)
	
	local armindex = PrecacheModel("models/weapons/c_models/c_soldier_arms.mdl")
	local armvm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(armvm, "m_spawnflags", 1073741824)
	SetPropInt(armvm, "m_nModelIndex", armindex)
	SetPropBool(armvm, "m_bValidatedAttachedEntity", true)
	SetPropBool(armvm, "m_AttributeManager.m_Item.m_bInitialized", true)
	armvm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(armvm)
	armvm.SetModel("models/weapons/c_models/c_soldier_arms.mdl")
	
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
        if (weapon == null || !weapon.IsValid() || weapon.GetClassname() == "tf_weapon_spellbook" || weapon.GetSlot() != 0) continue;
		weapon.Destroy()
        SetPropEntityArray(player, "m_hMyWeapons", null, i)
    }
	
	local waxe = Entities.CreateByClassname("tf_weapon_rocketlauncher")
    SetPropInt(waxe, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 18)
    SetPropBool(waxe, "m_AttributeManager.m_Item.m_bInitialized", true)
    SetPropBool(waxe, "m_bValidatedAttachedEntity", true)
	SetPropEntity(waxe, "m_hOwner", player)
	SetPropEntity(waxe, "m_hOwnerEntity", player)
	local index = GetModelIndex(M12_Weapon)
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
	waxe.AddAttribute("Blast radius increased", 1.25, -1)
	waxe.AddAttribute("damage penalty", 0.9, -1)
	
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
		local prop = SpawnEntityFromTable("logic_script", {})
		AddThinkToEnt(prop,"M12_PlayerThink")
		
		M23_SpawnGhosts()
		Merc.Timer(30.0, 0, function() {
			M23_SpawnGhosts()
		} )
		
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
							SetPropInt(ent, "m_iSelectedSpellIndex", 4)
							SetPropInt(ent, "m_iSpellCharges", 3)
						}
					}
				}
			}
			
			local line = "+Splash damage hits ghosts\n+25℅ explosion radius\n-10℅ damage"
			Merc.DisplayTrMsg("The Ghost Buster",line,10.0)
		} )
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

