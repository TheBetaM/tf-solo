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
	
	// TODO: New design
})