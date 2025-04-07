Merc.Weapon <- class {
	Name = "WPN"
	Model = "models/weapons/c_models/c_8mm_camera/c_8mm_camera.mdl"
	Attribs = []
	Desc = ""
	
	constructor (name, model, a)
	{
		Name = name
		Model = model
		Attribs = a
	}
}

Merc.Weapons <- [
	Merc.Weapon("The Thick Tank", "models/weapons/c_models/c_gascan/c_gascan.mdl",[  
	["damage bonus", 1.15],
	["dmg taken from fire increased", 1.1],
	["dmg taken from bullets increased", 1.1],
	]),
	Merc.Weapon("The Bottled Sorrow", "models/workshop/player/items/demo/taunt_scotsmans_stagger/taunt_scotsmans_stagger.mdl",[  
	["slow enemy on hit major", 3.0],
	["move speed bonus", 1.05],
	["single wep holster time increased", 1.5],
	["fire rate penalty", 1.25],
	]),
	Merc.Weapon("The Cut Above", "models/weapons/c_models/c_sd_cleaver/c_sd_cleaver.mdl",[  
	["bleeding duration", 10.0],
	["dmg taken from blast increased", 1.1],
	["dmg taken from bullets increased", 1.1],
	]),
	Merc.Weapon("The Shocking Truth", "models/workshop/player/items/medic/tauntdoctors_defibrillators/tauntdoctors_defibrillators.mdl",[  
	["self dmg push force increased", 2.0],
	["damage force increase", 4.0],
	["damage blast push", 4.0],
	["move speed bonus", 1.05],
	["hit self on miss", 1],
	["single wep deploy time increased", 1.5],
	]),
]
Merc.Weapons[0].Desc = @"+15% damage
-10% bullet/fire resist"
Merc.Weapons[1].Desc = @"+Slow Target for 3s
+5% move speed
-25% swing speed
-50% holster speed"
Merc.Weapons[2].Desc = @"+On Hit: Bleed for 10s
-10% bullet/expl. resist"
Merc.Weapons[3].Desc = @"+400% push force
+5% move speed
-On Miss: Hit yourself
-25% deploy speed"

Merc.MeleeClassnames <- [
    "tf_weapon_bat",
    "tf_weapon_bat",
    "tf_weapon_club",
    "tf_weapon_shovel",
    "tf_weapon_bottle",
    "tf_weapon_bonesaw",
    "tf_weapon_fireaxe",
    "tf_weapon_fireaxe",
    "tf_weapon_knife",
    "tf_weapon_wrench",
    "tf_weapon_bat",
]
Merc.ArmsList <- [
	"models/weapons/c_models/c_scout_arms.mdl",
	"models/weapons/c_models/c_scout_arms.mdl",
	"models/weapons/c_models/c_sniper_arms.mdl",
	"models/weapons/c_models/c_soldier_arms.mdl",
	"models/weapons/c_models/c_demo_arms.mdl",
	"models/weapons/c_models/c_medic_arms.mdl",
	"models/weapons/c_models/c_heavy_arms.mdl",
	"models/weapons/c_models/c_pyro_arms.mdl",
	"models/weapons/c_models/c_spy_arms.mdl",
	"models/weapons/c_models/c_engineer_arms.mdl",
	"models/weapons/c_models/c_scout_arms.mdl",
]

Merc.EquipWeapon <- function(player, wid, perks)
{
	local mercWeapon = Merc.Weapons[wid]
	local index = PrecacheModel(mercWeapon.Model)
	local vm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(vm, "m_spawnflags", 1073741824)
	SetPropInt(vm, "m_nModelIndex", index)
	SetPropBool(vm, "m_bValidatedAttachedEntity", true)
	SetPropBool(vm, "m_AttributeManager.m_Item.m_bInitialized", true)
	vm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(vm)
	vm.SetModel(mercWeapon.Model)
	
	local armindex = PrecacheModel(Merc.ArmsList[player.GetPlayerClass()])
	local armvm = Entities.CreateByClassname("tf_wearable_vm")
	SetPropInt(armvm, "m_spawnflags", 1073741824)
	SetPropInt(armvm, "m_nModelIndex", index)
	SetPropBool(armvm, "m_bValidatedAttachedEntity", true)
	SetPropBool(armvm, "m_AttributeManager.m_Item.m_bInitialized", true)
	armvm.SetTeam(player.GetTeam())
	Entities.DispatchSpawn(armvm)
	armvm.SetModel(Merc.ArmsList[player.GetPlayerClass()])
	
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
	
    local weapon = Entities.CreateByClassname(Merc.MeleeClassnames[player.GetPlayerClass()])
    SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 30758)
    SetPropBool(weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
    SetPropBool(weapon, "m_bValidatedAttachedEntity", true)
	SetPropEntity(weapon, "m_hOwner", player)
	SetPropEntity(weapon, "m_hOwnerEntity", player)
	
	SetPropEntity(vm, "m_hWeaponAssociatedWith", weapon)
	SetPropEntity(armvm, "m_hWeaponAssociatedWith", weapon)
	SetPropEntity(wm, "m_hWeaponAssociatedWith", weapon)
	SetPropEntity(weapon, "m_hExtraWearableViewModel", vm)
	SetPropEntity(weapon, "m_hExtraWearable", wm)
	
    weapon.SetTeam(player.GetTeam())
	weapon.SetOwner(player)
	
	foreach (i in mercWeapon.Attribs)
	{
		weapon.AddAttribute(i[0], i[1], -1)
	}
	local flags = GetPropInt(weapon, "m_Collision.m_usSolidFlags")
	SetPropInt(weapon, "m_Collision.m_usSolidFlags", flags | FSOLID_NOT_SOLID)
	flags = GetPropInt(weapon, "m_Collision.m_usSolidFlags")
	SetPropInt(weapon, "m_Collision.m_usSolidFlags", flags & ~(FSOLID_TRIGGER))
	
	SetPropInt(weapon, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
	SetPropInt(weapon, "m_clrRender", 0)
	
    Entities.DispatchSpawn(weapon)
	weapon.ValidateScriptScope()
	
	weapon.AcceptInput("SetParent", "!activator", player, player)
    for (local i = 0; i < 8; i++)
    {
        local heldWeapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
        if (heldWeapon == null)
            continue
        if (heldWeapon.GetSlot() != weapon.GetSlot())
            continue
		
		local vment = null
		while(vment = Entities.FindByClassname(vment, "tf_wearable_vm"))
		{
			local vmwep = GetPropEntity(vment, "m_hWeaponAssociatedWith")
			if (vmwep == heldWeapon)
			{
				vment.Destroy()
			}
		}
		while(vment = Entities.FindByClassname(vment, "tf_wearable_campaign_item"))
		{
			local vmwep = GetPropEntity(vment, "m_hWeaponAssociatedWith")
			if (vmwep == heldWeapon)
			{
				vment.Destroy()
			}
		}
		
        heldWeapon.Destroy()
        SetPropEntityArray(player, "m_hMyWeapons", null, i)
        break
    }
	if (player.GetPlayerClass() == TF_CLASS_SPY)
	{
		SetPropEntityArray(player, "m_hMyWeapons", weapon, 1)
	}
	else
	{
		SetPropEntityArray(player, "m_hMyWeapons", weapon, weapon.GetSlot())
	}
	
	if (perks == 1)
	{
		weapon.AddAttribute("kill eater", 0.0, -1)
	}
	else if (perks == 2)
	{
		weapon.AddAttribute("kill eater", 0.0, -1)
		weapon.AddAttribute("killstreak tier", 1.0, -1)
	}
	
    player.Weapon_Equip(weapon)
	player.EquipWearableViewModel(armvm)
	player.EquipWearableViewModel(vm)
	
    return weapon
}

Merc.EquipWeaponAndSwitch <- function(player, wid)
{
	local weapon = Merc.EquipWeapon(player, wid, 2)
    player.Weapon_Switch(weapon)
	
    return weapon
}