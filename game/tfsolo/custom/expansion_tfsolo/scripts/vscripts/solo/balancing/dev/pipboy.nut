TFSOLO.BalancingFuncs.push(function(kv)
{
	// Pip-Boy
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("519")
	local attrib = prefab.FindKey("attributes")
	// Match PDA prefab
	prefab.SetString("prefab","weapon_pda")
	prefab.RemoveSubKey("item_class")
	prefab.RemoveSubKey("item_slot")
	prefab.RemoveSubKey("model_player")
	prefab.SetString("extra_wearable","models/workshop_partner/player/items/engineer/bet_pb/bet_pb.mdl")
	// Add no manual building destruction
	local a1 = attrib.GetKey("no_manual_building_destroy", true)
	a1.SetString("attribute_class","no_manual_building_destroy")
	a1.SetInt("value", 1)
})