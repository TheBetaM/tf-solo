TFSOLO.BalancingFuncs.push(function(kv)
{
	// Nostromo Napalmer
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("30474")
	local attrib = prefab.GetKey("attributes", true)
	// Add airblast dashes
	local a1 = attrib.GetKey("airblast_dashes", true)
	a1.SetString("attribute_class","airblast_dashes")
	a1.SetInt("value", 1)
})