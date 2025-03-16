TFSOLO.BalancingFuncs.push(function(kv)
{
	// Fortified Compound
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("1092")
	local attrib = prefab.GetKey("attributes", true)
	// Add arrows explode on impact after 3 seconds
	local a1 = attrib.GetKey("arrows_explode_time", true)
	a1.SetString("attribute_class","arrows_explode_time")
	a1.SetInt("value", 3)
	// Add -20% damage penalty
	local a2 = attrib.GetKey("damage penalty", true)
	a2.SetString("attribute_class","mult_dmg")
	a2.SetFloat("value", 0.8)
})