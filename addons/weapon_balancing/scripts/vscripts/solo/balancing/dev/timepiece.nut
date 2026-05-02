TFSOLO.BalancingFuncs.push(function(kv)
{
	// Enthusiast's Timepiece
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("297")
	local attrib = prefab.FindKey("attributes")
	prefab.SetString("item_description","")
	// Set weapon mode to 10 (Bounce)
	local a1 = attrib.GetKey("invis_cloak_type_bounce", true)
	a1.SetString("attribute_class","set_weapon_mode")
	a1.SetInt("value", 10)
	// Add firing while deployed
	local a2 = attrib.GetKey("invis_allow_deploy_firing", true)
	a2.SetString("attribute_class","invis_allow_deploy_firing")
	a2.SetInt("value", 1)
	// Add empty cloak meter on holster
	local a3 = attrib.GetKey("invis_reset_meter_holster", true)
	a3.SetString("attribute_class","invis_reset_meter_holster")
	a3.SetInt("value", 1)
})