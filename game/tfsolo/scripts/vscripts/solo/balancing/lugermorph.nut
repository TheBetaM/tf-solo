TFSOLO.BalancingFuncs.push(function(kv)
{
	// Lugermorph
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("160")
	// Match pistol prefab, only usable by Enigneer
	prefab.SetString("prefab","")
	prefab.SetInt("baseitem",0)
	prefab.SetInt("enabled",1)
	prefab.SetString("base_item_name","TF_WEAPON_PISTOL")
	prefab.SetInt("inspect_panel_dist",31)
	prefab.SetString("particle_suffix","pistol")
	local statattrib = prefab.GetKey("static_attrs", true)
	statattrib.SetFloat("weapon_stattrak_module_scale",0.723)
	statattrib.SetString("min_viewmodel_offset","10 0 -10")
	local classuse = prefab.FindKey("used_by_classes")
	classuse.RemoveSubKey("scout")
	
	// TODO: New design
	
	// Repeat for other item ID
	prefab = key1.FindKey("294")
	prefab.SetString("prefab","")
	prefab.SetInt("baseitem",0)
	prefab.SetInt("enabled",1)
	prefab.SetString("base_item_name","TF_WEAPON_PISTOL")
	prefab.SetInt("inspect_panel_dist",31)
	prefab.SetString("particle_suffix","pistol")
	statattrib = prefab.GetKey("static_attrs", true)
	statattrib.SetFloat("weapon_stattrak_module_scale",0.723)
	statattrib.SetString("min_viewmodel_offset","10 0 -10")
	classuse = prefab.FindKey("used_by_classes")
	classuse.RemoveSubKey("scout")
})