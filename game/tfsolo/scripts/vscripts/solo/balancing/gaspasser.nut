TFSOLO.BalancingFuncs.push(function(kv)
{
	// Gas Passer
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("1180")
	local attrib = prefab.GetKey("attributes", true)
	local statattrib = prefab.FindKey("static_attrs")
	// Allow spawning/resupplying with it
	statattrib.RemoveSubKey("item_meter_resupply_denied")
	statattrib.RemoveSubKey("grenades1_resupply_denied")
	statattrib.RemoveSubKey("item_meter_starts_empty_DISPLAY_ONLY")
	statattrib.RemoveSubKey("item_meter_charge_type_3_DISPLAY_ONLY")
	// Shorten charge time from 60s to 20s, reduce damage needed from 750 to 400
	statattrib.SetInt("item_meter_charge_rate", 20)
	statattrib.SetInt("item_meter_damage_for_full_charge", 400)
})