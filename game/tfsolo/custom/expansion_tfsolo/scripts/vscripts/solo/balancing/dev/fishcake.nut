TFSOLO.BalancingFuncs.push(function(kv)
{
	// Fishcake
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("433")
	local attrib = prefab.FindKey("attributes")
	// Set regeneration time to 25 seconds
	local statattr = prefab.GetKey("static_attrs", true)
	statattr.SetInt("item_meter_charge_rate", 25)
	// Description for new Fishcake design
	prefab.SetString("item_description","#TF_SpaceChem_Fishcake_Desc_Solo")
	attrib.RemoveSubKey("lunchbox adds maxhealth bonus")
	local a1 = attrib.GetKey("lunchbox adds minicrits", true)
	a1.SetString("attribute_class","set_weapon_mode")
	a1.SetInt("value", 7)
})