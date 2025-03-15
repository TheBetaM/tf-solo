TFSOLO.BalancingFuncs.push(function(kv)
{
	// Blutsauger
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("36")
	local attrib = prefab.FindKey("attributes")
	// Add 0.5% charge gain on hit
	local a1 = attrib.GetKey("add uber charge on hit", true)
	a1.SetString("attribute_class","add_onhit_ubercharge")
	a1.SetFloat("value", 0.005)
})