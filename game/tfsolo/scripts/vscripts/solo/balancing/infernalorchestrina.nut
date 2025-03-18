TFSOLO.BalancingFuncs.push(function(kv)
{
	// Infernal Orchestrina
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("745")
	local attrib = prefab.FindKey("attributes")
	// Set as Pyro secondary
	prefab.SetString("item_slot","secondary")
	prefab.SetString("item_description","")
	prefab.SetString("item_class","tf_weapon_parachute_secondary")
	prefab.SetString("anim_slot","FORCE_NOT_USED")
	prefab.SetString("model_player","models/player/items/pyro/mtp_backpack.mdl")
	prefab.SetString("extra_wearable","models/player/items/pyro/mtp_backpack.mdl")
	prefab.RemoveSubKey("model_player_per_class")
	// Remove Pyrovision requirement
	prefab.RemoveSubKey("vision_filter_flags")
	attrib.RemoveSubKey("vision opt in flags")
	attrib.RemoveSubKey("pyrovision only DISPLAY ONLY")
	attrib.RemoveSubKey("pyrovision opt in DISPLAY ONLY")
})