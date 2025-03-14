TFSOLO.BalancingFuncs.push(function(kv)
{
	// Southern Hospitality
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("155")
	local attrib = prefab.FindKey("attributes")
	// Remove existing attribues
	//attrib.RemoveSubKey("crit mod disabled")
	//attrib.RemoveSubKey("bleeding duration")
	//attrib.RemoveSubKey("dmg taken from fire increased")
})