TFSOLO.BalancingFuncs.push(function(kv)
{
	// Quackenbirdt
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("947")
	local attrib = prefab.GetKey("attributes", true)
	// Set weapon mode to 11
	//local a1 = attrib.GetKey("", true)
	//a1.SetString("attribute_class","set_weapon_mode")
	//a1.SetInt("value", 11)
})