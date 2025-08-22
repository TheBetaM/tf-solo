TFSOLO.BalancingFuncs.push(function(kv)
{
	// Equalizer
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("128")
	local attrib = prefab.FindKey("attributes")
	// Add 75 health on kill
	local a1 = attrib.GetKey("heal on kill", true)
	a1.SetString("attribute_class","heal_on_kill")
	a1.SetInt("value", 75)
})