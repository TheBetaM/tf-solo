TFSOLO.BalancingFuncs.push(function(kv)
{
	// Pyrovision Goggles
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("pyrovision_goggles")
	local attrib = prefab.FindKey("attributes")
	// Remove Pyrovision
	attrib.RemoveSubKey("vision opt in flags")
	attrib.RemoveSubKey("pyrovision opt in DISPLAY ONLY")
	prefab.SetString("item_description","")
})