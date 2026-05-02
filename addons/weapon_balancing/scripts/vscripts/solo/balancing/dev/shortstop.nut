TFSOLO.BalancingFuncs.push(function(kv)
{
	// Shortstop
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_shortstop")
	local attrib = prefab.FindKey("attributes")
	// Remove 50% reload speed penalty
	attrib.RemoveSubKey("reload time increased hidden")
})