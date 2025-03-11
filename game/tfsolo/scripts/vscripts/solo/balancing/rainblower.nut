TFSOLO.BalancingFuncs.push(function(kv)
{
	// Rainblower
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("741")
	local attrib = prefab.FindKey("attributes")
	// Remove Pyrovision
	attrib.RemoveSubKey("vision opt in flags")
	attrib.RemoveSubKey("pyrovision only DISPLAY ONLY")
	attrib.RemoveSubKey("pyrovision opt in DISPLAY ONLY")
	prefab.SetString("model_vision_filtered", "models/weapons/c_models/c_rainblower/c_rainblower.mdl")
	prefab.SetString("item_description","")
	
	// TODO: New design
	
	// Add firing forward pull
	//local a1 = attrib.GetKey("firing_forward_pull", true)
	//a1.SetString("attribute_class","firing_forward_pull")
	//a1.SetFloat("value", 2.0)
	// Add spin-up time
	//local a2 = attrib.GetKey("mod_flamethrower_spinup_time", true)
	//a2.SetString("attribute_class","mod_flamethrower_spinup_time")
	//a2.SetFloat("value", 1.0)
})