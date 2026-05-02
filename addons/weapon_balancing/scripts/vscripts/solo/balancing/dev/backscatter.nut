TFSOLO.BalancingFuncs.push(function(kv)
{
	// Back Scatter
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("1103")
	local attrib = prefab.FindKey("attributes")
	// Replace 20% inaccuracy with 20% more accuracy
	attrib.RemoveSubKey("spread penalty")
	local a1 = attrib.GetKey("weapon spread bonus", true)
	a1.SetString("attribute_class","mult_spread_scale")
	a1.SetFloat("value", 0.8)
})