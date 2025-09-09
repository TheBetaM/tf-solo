TFSOLO.BalancingFuncs.push(function(kv)
{
	// Robo-Sandvich
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("863")
	local attrib = prefab.FindKey("attributes")
	// Only usable by Spy, match sapper prefab
	prefab.SetString("prefab","weapon_sapper")
	local classuse = prefab.GetKey("used_by_classes", true)
	classuse.RemoveSubKey("heavy")
	classuse.SetInt("spy",1)
	local statattr = prefab.GetKey("static_attrs", true)
	statattr.RemoveSubKey("item_meter_charge_type")
	statattr.RemoveSubKey("item_meter_charge_rate")
	statattr.RemoveSubKey("meter_label")
	attrib.RemoveSubKey("lunchbox adds minicrits")
	attrib.RemoveSubKey("special taunt")
	attrib.RemoveSubKey("allowed in medieval mode")
	//prefab.SetString("model_world","models/weapons/c_models/c_sandwich/c_robo_sandwich.mdl")
	// Add sapping pickups and dropped weapons
	//local a1 = attrib.GetKey("sapper_on_pickups", true)
	//a1.SetString("attribute_class","sapper_on_pickups")
	//a1.SetInt("value", 1)
	// Add destructible sapper
	//local a2 = attrib.GetKey("sapper_destructible", true)
	//a2.SetString("attribute_class","sapper_destructible")
	//a2.SetInt("value", 1)
})