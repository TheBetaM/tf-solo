TFSOLO.BalancingFuncs.push(function(kv)
{
	// Memory Maker
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("954")
	local attrib = prefab.FindKey("attributes")
	// Only usable by Spy, match sapper prefab
	prefab.SetString("prefab","weapon_sapper")
	local classuse = prefab.GetKey("used_by_classes", true)
	classuse.RemoveSubKey("scout")
	classuse.RemoveSubKey("sniper")
	classuse.RemoveSubKey("soldier")
	classuse.RemoveSubKey("demoman")
	classuse.RemoveSubKey("medic")
	classuse.RemoveSubKey("heavy")
	classuse.RemoveSubKey("pyro")
	classuse.SetInt("spy",1)
	prefab.RemoveSubKey("item_class")
	prefab.RemoveSubKey("item_slot")
	//prefab.RemoveSubKey("anim_slot")
	//prefab.SetString("model_world","models/weapons/c_models/c_8mm_camera/c_8mm_camera.mdl")
	// Add sapping objectives
	//local a1 = attrib.GetKey("sapper_on_objectives", true)
	//a1.SetString("attribute_class","sapper_on_objectives")
	//a1.SetInt("value", 1)
	// Add no sapping buildings
	//local a2 = attrib.GetKey("sapper_no_buildings", true)
	//a2.SetString("attribute_class","sapper_no_buildings")
	//a2.SetInt("value", 1)
	// Add destructible sapper
	//local a3 = attrib.GetKey("sapper_destructible", true)
	//a3.SetString("attribute_class","sapper_destructible")
	//a3.SetInt("value", 1)
})