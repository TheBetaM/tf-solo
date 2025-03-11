TFSOLO.BalancingFuncs.push(function(kv)
{
	// Lollichop
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("739")
	local attrib = prefab.FindKey("attributes")
	// Remove Pyrovision
	attrib.RemoveSubKey("vision opt in flags")
	attrib.RemoveSubKey("pyrovision only DISPLAY ONLY")
	attrib.RemoveSubKey("pyrovision opt in DISPLAY ONLY")
	prefab.SetString("model_vision_filtered", "models/weapons/c_models/c_lollichop/c_lollichop.mdl")
	prefab.SetString("item_description","")
	
	// TODO: New design
})