// PLR Bonesaw
::Merc <- {}
Merc.MissionID <- 16
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_PYRO
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Bot 08"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SOLDIER, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_ENGINEER, "Bot 12"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 13"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SNIPER, "Bot 14"),
]
Merc.ObjectiveText <- "Win with a team of 10 or more"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 10
Merc.ObjectiveExtraText <- "Get kills with The Bone Breaker"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 2
Merc.AllowRecruits <- 0
Merc.IgnoreMainCap <- 1

Convars.SetValue("mp_friendlyfire", 1)

::M04_Bigaxe <- "models/weapons/c_models/c_bigaxe/c_bigaxe_burnt.mdl"
PrecacheModel(M04_Bigaxe)

::SecretPickupProp <- "models/props_halloween/gargoyle_ghost.mdl"
PrecacheModel(SecretPickupProp)
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })
PrecacheScriptSound("Halloween.Haunted")

::M15SkeletonSpots <- [
	[1696,1696,-1656],
	[1122,1124,-1663],
	[-97,-125,-1519],
]

::PlayerModelFiles <- [
	"scout",
	"scout",
	"sniper",
	"soldier",
	"demo",
	"medic",
	"heavy",
	"pyro",
	"spy",
	"engineer",
	"scout",
]

::M15_SpawnAsSkeleton <- function(player)
{
	local model = PlayerModelFiles[player.GetPlayerClass()]
	player.SetCustomModelWithClassAnimations("models/player/"+model+".mdl")
	
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
	} )
}
::M15_UpdateTeamCount <- function()
{
	if (Merc.RoundEnded) return
	Merc.ObjectiveMainCount = 0
	foreach (a in GetClients()) 
	{	
		if (IsPlayerABot(a) && a.GetTeam() == Merc.ForcedTeam)
		{
			Merc.ObjectiveMainCount++
		}
	}
	Merc.UpdateHUD()
}

function M15_SpawnSkeleton(x, y, z)
{
	local prop = SpawnEntityFromTable("tf_zombie", {
		origin = Vector(x,y,z - 0.0),
	})
	prop.ValidateScriptScope()
	prop.GetScriptScope()["SkelDead"] <- function(){
		local hit = activator;
		if (hit.GetClassname() != "player")
		{
			hit = activator.GetOwner()
			if (hit == null) return
			if (hit.GetClassname() != "player") return
		}
		if (IsPlayerABot(hit)) return
		if (hit.GetTeam() != Merc.ForcedTeam) return
		//Merc.ExtraGet(1,1,1)
	}
	prop.ConnectOutput("OnDeath","SkelDead")
}

::M15_SpawnSkeletons <- function()
{
	foreach (i in M15SkeletonSpots)
	{
		M15_SpawnSkeleton(i[0],i[1],i[2])
	}
}

::M15_CheckWin <- function()
{
	if (Merc.ObjectiveMainCount >= Merc.ObjectiveMainMax)
	{
		Merc.MainGet(0,1,1)
		Merc.ForceWin()
	}
	else
	{
		Merc.ChatPrint("Main objective failed! Not enough teammates.");
		Merc.ForceFail()
	}
}

::MRemOutput <- function(a,b,c,d,e)
{
	EntityOutputs.RemoveOutput(a,b,c,d,e)
}

::SecretPickupGet <- function()
{
	MercRSVFlags[11] = 1
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
	});
	prop.SetTeam(Merc.ForcedTeam)
	prop.ValidateScriptScope()
	prop.ConnectOutput("OnBluePickup", "SecretPickupGet")
}

Merc.AfterPlayerInv <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	if (IsPlayerABot(player))
	{
		M15_SpawnAsSkeleton(player)
		M15_UpdateTeamCount()
		return
	}
	if (player.GetTeam() != Merc.ForcedTeam) return
	
	local index = PrecacheModel(M04_Bigaxe)
	local vm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(vm, "m_spawnflags", 1073741824)
	SetPropInt(vm, "m_nModelIndex", index)
	SetPropBool(vm, "m_bValidatedAttachedEntity", true)
	SetPropBool(vm, "m_AttributeManager.m_Item.m_bInitialized", true)
	vm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(vm)
	vm.SetModel(M04_Bigaxe)
	SetPropFloat(vm,"m_flModelScale",0.6)
	
	local armindex = PrecacheModel("models/weapons/c_models/c_pyro_arms.mdl")
	local armvm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(armvm, "m_spawnflags", 1073741824)
	SetPropInt(armvm, "m_nModelIndex", armindex)
	SetPropBool(armvm, "m_bValidatedAttachedEntity", true)
	SetPropBool(armvm, "m_AttributeManager.m_Item.m_bInitialized", true)
	armvm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(armvm)
	armvm.SetModel("models/weapons/c_models/c_pyro_arms.mdl")
	
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
	SetPropFloat(wm,"m_flModelScale",0.6)
	
	local wsize = GetPropArraySize(player, "m_hMyWeapons")
	for (local i = 0; i < wsize; i++)
    {
        local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null || !weapon.IsValid() || weapon.GetClassname() == "tf_weapon_spellbook" || weapon.GetSlot() != 2) continue;
		weapon.Destroy()
        SetPropEntityArray(player, "m_hMyWeapons", null, i)
    }
	
	local waxe = Entities.CreateByClassname("tf_weapon_fireaxe")
    SetPropInt(waxe, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 593)
    SetPropBool(waxe, "m_AttributeManager.m_Item.m_bInitialized", true)
    SetPropBool(waxe, "m_bValidatedAttachedEntity", true)
	SetPropEntity(waxe, "m_hOwner", player)
	SetPropEntity(waxe, "m_hOwnerEntity", player)
	local index = GetModelIndex(M04_Bigaxe)
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
	waxe.AddAttribute("crit vs burning players", 1.0, -1)
	waxe.AddAttribute("dmg penalty vs nonburning", 0.5, -1)
	
	SetPropEntityArray(player, "m_hMyWeapons", waxe, waxe.GetSlot())
	player.Weapon_Equip(waxe)
	
	player.EquipWearableViewModel(armvm)
	player.EquipWearableViewModel(vm)
	
	player.Weapon_Switch(waxe)
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		player.SetCustomModelWithClassAnimations("models/bots/skeleton_sniper/skeleton_sniper.mdl")
		if (Merc.RoundEnded) return
		if (player.GetTeam() == TF_TEAM_RED)
		{
			player.ForceChangeTeam(TF_TEAM_BLUE, true)
		}
		else
		{
			player.ForceChangeTeam(TF_TEAM_RED, true)
		}
		M15_UpdateTeamCount()
		
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || IsPlayerABot(aplayer)) return
		
		if (params.weapon == "thirddegree")
		{
			Merc.ExtraGet(1,1,1)
		}
	}
	
	OnGameEvent_player_team = function(params)
	{
		M15_UpdateTeamCount()
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		if (Merc.RSVFlags[11] == 0)
		{
			//SpawnSecretPickup(-1856,1408,6874)
		}
		
		local ent = Entities.FindByName(null, "red_path_15")
		MRemOutput(ent,"OnPass","tf_gamerules","PlayVOBlue","Bonesaw.RoundLost_Blu")
		MRemOutput(ent,"OnPass","tf_gamerules","PlayVORed","Bonesaw.RoundWon_Red")
		ent = Entities.FindByName(null, "blu_path_15")
		MRemOutput(ent,"OnPass","tf_gamerules","PlayVOBlue","Bonesaw.RoundWon_Blu")
		MRemOutput(ent,"OnPass","tf_gamerules","PlayVORed","Bonesaw.RoundLost_Red")
		ent = Entities.FindByName(null, "ssplr_timer")
		MRemOutput(ent,"OnSetupFinished","tf_gamerules","PlayVO","Bonesaw.RoundStart")
		ent = Entities.FindByName(null, "ssplr_timer")
		MRemOutput(ent,"OnSetupFinished","tf_gamerules","PlayVO","Bonesaw.RoundStart")
		ent = Entities.FindByName(null, "relay_hhh_checkpoint")
		MRemOutput(ent,"OnTrigger","tf_gamerules","PlayVO","Bonesaw.hhh")
		ent = null
		while (ent = Entities.FindByClassname(ent, "trigger_multiple"))
		{
			MRemOutput(ent,"OnStartTouch","tf_gamerules","PlayVORed","Bonesaw.AllyHacking_Red")
			MRemOutput(ent,"OnStartTouch","tf_gamerules","PlayVOBlue","Bonesaw.AllyHacking_Blu")
			MRemOutput(ent,"OnStartTouch","tf_gamerules","PlayVORed","Bonesaw.EnemyHacking_Red")
			MRemOutput(ent,"OnStartTouch","tf_gamerules","PlayVOBlue","Bonesaw.EnemyHacking_Blu")
			MRemOutput(ent,"OnStartTouch","tf_gamerules","PlayVORed","Bonesaw.AllyHackingClose_Red")
			MRemOutput(ent,"OnStartTouch","tf_gamerules","PlayVOBlue","Bonesaw.AllyHackingClose_Blu")
			MRemOutput(ent,"OnStartTouch","tf_gamerules","PlayVORed","Bonesaw.EnemyHackingClose_Red")
			MRemOutput(ent,"OnStartTouch","tf_gamerules","PlayVOBlue","Bonesaw.EnemyHackingClose_Blue")
			MRemOutput(ent,"OnStartTouch","tf_gamerules","PlayVORed","Bonesaw.Money_red")
			MRemOutput(ent,"OnStartTouch","tf_gamerules","PlayVOBlue","Bonesaw.Noney_Blu")
		}
		ent = null
		while (ent = Entities.FindByName(ent, "static_grave_red"))
		{
			if (GetPropInt(ent, "m_iSolidity") == 1)
			{
				ent.Destroy()
			}
		}
		ent = null
		while (ent = Entities.FindByName(ent, "static_grave_blue"))
		{
			if (GetPropInt(ent, "m_iSolidity") == 1)
			{
				ent.Destroy()
			}
		}
		ent = Entities.FindByName(null, "relay_red_capture_cart")
		ent.ValidateScriptScope()
		ent.ConnectOutput("OnTrigger","Merc_ForceFail")
		MRemOutput(ent,"OnTrigger","relay_red_teleport_to_final_island","Trigger","")
		MRemOutput(ent,"OnTrigger","blu_spawn_loser","Enable","")
		MRemOutput(ent,"OnTrigger","red_spawn_winner","Enable","")
		MRemOutput(ent,"OnTrigger","red_spawn_primary","Disable","")
		MRemOutput(ent,"OnTrigger","blu_spawn_primary","Disable","")
		ent = Entities.FindByName(null, "relay_blu_capture_cart")
		ent.ValidateScriptScope()
		ent.ConnectOutput("OnTrigger","M15_CheckWin")
		MRemOutput(ent,"OnTrigger","relay_blu_teleport_to_final_island","Trigger","")
		MRemOutput(ent,"OnTrigger","blu_spawn_winner","Enable","")
		MRemOutput(ent,"OnTrigger","red_spawn_loser","Enable","")
		MRemOutput(ent,"OnTrigger","red_spawn_primary","Disable","")
		MRemOutput(ent,"OnTrigger","blu_spawn_primary","Disable","")
		
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
							SetPropInt(ent, "m_iSelectedSpellIndex", 9)
							SetPropInt(ent, "m_iSpellCharges", 3)
						}
					}
				}
			}
			
			local line = "+100℅ critical hit vs burning skeletons\n-50℅ damage vs non-burning skeletons";
			Merc.DisplayTrMsg("The Bone Breaker",line,10.0)
		} )
		
		M15_SpawnSkeletons()
		Merc.Timer(60.0, 0, function() {
			M15_SpawnSkeletons()
		} )
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

