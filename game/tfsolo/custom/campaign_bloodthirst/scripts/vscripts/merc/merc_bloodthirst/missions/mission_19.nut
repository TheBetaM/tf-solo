// PD Pit of Death
::Merc <- {}
Merc.MissionID <- 19
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_SPY
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.WaitTimeConvar <- 1
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Bot 07"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_HEAVY, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SOLDIER, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 12"),
]
Merc.ObjectiveText <- "Deposit souls in the Underworld"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 50
Merc.ObjectiveExtraText <- "Kill enemies with pumpkin bombs"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 9
Merc.ForceWinOnMainDone <- 1

Convars.SetValue("tf_allow_taunt_switch", 2)

::M17_Weapon <- "models/passtime/ball/passtime_ball_halloween.mdl"
PrecacheModel(M17_Weapon)
::M17_Pumpkin <- "models/props_halloween/pumpkin_explode.mdl"
PrecacheModel(M17_Pumpkin)

::M17_Lives <- 5
::M17_Holograms <- {}
::M17_PumpkinCooldown <- 0.0
::M17_PumpkinRange <- 300.0 //32768.0

::M17_Think <- function()
{
	if (M17_PumpkinCooldown > 0.0)
	{
		M17_PumpkinCooldown -= FrameTime()
	}
	
	local count = 0
	local ent = null
	while (ent = Entities.FindByClassname(ent, "tf_pumpkin_bomb"))
	{
		count++
	}
	
	foreach (a in GetClients()) 
	{	
		local w = a.GetActiveWeapon()
		if (IsPlayerABot(a) || !a.IsAlive()) continue;
		if (w != null && w.GetSlot() == 1 && !a.IsStealthed() && !a.IsFullyInvisible())
		{
			local buttons = GetPropInt(a, "m_nButtons")
			local isAttacking = buttons & IN_ATTACK
			
			local trace =
			{
				start = a.EyePosition(),
				end = a.EyePosition() + (a.EyeAngles().Forward() * M17_PumpkinRange),
				ignore = a
			}
			if (!TraceLineEx(trace) || !trace.hit)
			{
				if (a.entindex() in M17_Holograms)
				{
					M17_Holograms[a.entindex()].DisableDraw()
				}
				continue;
			}
			local target = trace.pos
			if (a.entindex() in M17_Holograms)
			{
				M17_Holograms[a.entindex()].EnableDraw()
				M17_Holograms[a.entindex()].SetOrigin(target)
			}
			
			if (isAttacking && M17_PumpkinCooldown <= 0.0 && count < 50)
			{
				local prop = SpawnEntityFromTable("tf_pumpkin_bomb", {
					origin       = target,
					angles       = QAngle(0, RandomInt(0,360), 0),
				})
				M17_PumpkinCooldown = 1.0
				a.RemoveDisguise()
			}
		}
		else
		{
			if (a.entindex() in M17_Holograms)
			{
				M17_Holograms[a.entindex()].DisableDraw()
			}
		}
	}
	return -1
}

::M17_ScoreChange <- function(player, ent)
{
	Merc.MainGet(1, 0, 1)
}

::M17_GivePumpkin <- function(player)
{
	PrecacheModel(M17_Weapon)
	
	local index = PrecacheModel(M17_Weapon)
	local vm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(vm, "m_spawnflags", 1073741824)
	SetPropInt(vm, "m_nModelIndex", index)
	SetPropBool(vm, "m_bValidatedAttachedEntity", true)
	SetPropBool(vm, "m_AttributeManager.m_Item.m_bInitialized", true)
	vm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(vm)
	vm.SetModel(M17_Weapon)
	
	local armindex = PrecacheModel("models/weapons/c_models/c_spy_arms.mdl")
	local armvm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(armvm, "m_spawnflags", 1073741824)
	SetPropInt(armvm, "m_nModelIndex", armindex)
	SetPropBool(armvm, "m_bValidatedAttachedEntity", true)
	SetPropBool(armvm, "m_AttributeManager.m_Item.m_bInitialized", true)
	armvm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(armvm)
	armvm.SetModel("models/weapons/c_models/c_spy_arms.mdl")
	
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
	
	local waxe = Entities.CreateByClassname("tf_weapon_sapper")
    SetPropInt(waxe, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 735)
    SetPropBool(waxe, "m_AttributeManager.m_Item.m_bInitialized", true)
    SetPropBool(waxe, "m_bValidatedAttachedEntity", true)
	SetPropEntity(waxe, "m_hOwner", player)
	SetPropEntity(waxe, "m_hOwnerEntity", player)
	local index = GetModelIndex(M17_Weapon)
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
	
	SetPropEntityArray(player, "m_hMyWeapons", waxe, waxe.GetSlot())
	player.Weapon_Equip(waxe)
	
	player.EquipWearableViewModel(armvm)
	player.EquipWearableViewModel(vm)
	
	player.Weapon_Switch(waxe)
	SetPropEntity(player, "m_hActiveWeapon", waxe)
	
	Merc.Delay(1.0, function() { 
		if (player.entindex() in M17_Holograms)
		{
			M17_Holograms[player.entindex()].Destroy()
		}
		local prop = SpawnEntityFromTable("prop_dynamic_override", {
			origin = Vector(0,0,-4000),
			angles = QAngle(0,RandomInt(0,360),0),
			model = M17_Pumpkin,
			targetname = "mercprop",
			solid = 0,
		})
		SetPropInt(prop, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
		SetPropInt(prop, "m_clrRender", (128 << 24))
		M17_Holograms[player.entindex()] <- prop
		prop.DisableDraw()
	} )
}

::M17_SpawnAsSkeleton <- function(player)
{
	player.SetCustomModelWithClassAnimations("models/player/spy.mdl")
	
	Merc.Delay(0.5, function() { 
		local group = player.FindBodygroupByName("hat")
		local groupent = player.GetBodygroup(group)
		local body = Entities.CreateByClassname("tf_wearable")
		DoEntFire("!self", "SetParent", "!activator", -1, player, body)
		body.SetModelSimple("models/bots/skeleton_sniper/skeleton_sniper.mdl")
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

Merc.AfterPlayerSpawn <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() != Merc.ForcedTeam) return
	if (IsPlayerABot(player)) return
	M17_SpawnAsSkeleton(player)
}

Merc.AfterPlayerInv <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() != Merc.ForcedTeam) return
	if (IsPlayerABot(player)) return
	M17_GivePumpkin(player)
}

Merc.BeforeRoundStart <- function(params) 
{
	M17_Holograms = {}
	M17_Lives <- 5
	Merc.ObjectiveTextAdd = " - Lives left: "+M17_Lives
	
	local prop = SpawnEntityFromTable("logic_script", {})
	AddThinkToEnt(prop,"M17_Think")
	
	local ent = null
	while (ent = Entities.FindByClassname(ent, "tf_logic_player_destruction"))
	{
		ent.ValidateScriptScope()
		ent.GetScriptScope()["ScoreChange"] <- function(){
			M17_ScoreChange(activator,caller)
		}
		ent.ConnectOutput("OnBlueScoreChanged","ScoreChange")
		SetPropInt(ent, "m_nMaxPoints", 100)
	}
	
	Merc.Delay(3.0, function() { 
		local line = "+Places pumpkin bombs\n-Removes disguise on use";
		Merc.DisplayTrMsg("The Nasty Surprise",line,10.0)
	} )
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0) return
		if (!IsPlayerABot(player))
		{
			if (Merc.RoundEnded) return
			if (params.death_flags & 32) return
			
			player.SetCustomModelWithClassAnimations("models/bots/skeleton_sniper/skeleton_sniper.mdl")
			M17_Lives--
			if (M17_Lives == 0)
			{
				Merc.ForceFail()
			}
			Merc.ObjectiveTextAdd = " - Lives left: "+M17_Lives
			Merc.UpdateHUD()
			return
		}
		if (player.GetTeam() == Merc.ForcedTeam) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || IsPlayerABot(aplayer)) return
		
		if (params.weapon == "tf_pumpkin_bomb" || params.weapon == "spellbook_mirv")
		{
			Merc.ExtraGet(1,1,1)
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

