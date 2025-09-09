TFSOLO.BalancingFuncs.push(function(kv)
{
	// Degreaser
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_degreaser")
	local attrib = prefab.GetKey("attributes", true)
	// Add reverse airblast
	local a1 = attrib.GetKey("reverse_airblast", true)
	a1.SetString("attribute_class","reverse_airblast")
	a1.SetInt("value", 1)
})