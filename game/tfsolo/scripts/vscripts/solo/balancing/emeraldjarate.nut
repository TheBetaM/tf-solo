TFSOLO.BalancingFuncs.push(function(kv)
{
	// Emerald Jarate
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("554")
	local attrib = prefab.GetKey("attributes", true)
	// Set medigun prefab
	prefab.SetString("prefab","valve weapon_medigun")
	prefab.RemoveSubKey("model_player")
	prefab.SetString("extra_wearable","models/player/items/medic/hwn_medic_misc2.mdl")
	prefab.SetString("item_slot","secondary")
	// Set weapon mode to 10 (Emerald Jarate)
	local a1 = attrib.GetKey("lunchbox adds minicrits", true)
	a1.SetString("attribute_class","set_weapon_mode")
	a1.SetInt("value", 10)
	// TODO: description
})