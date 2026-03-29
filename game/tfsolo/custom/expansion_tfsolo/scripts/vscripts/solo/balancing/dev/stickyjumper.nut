TFSOLO.BalancingFuncs.push(function(kv)
{
	// Stickybomb Jumper
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("265")
	local attrib = prefab.FindKey("attributes")
	// Remove max sticky penalty
	attrib.RemoveSubKey("max pipebombs decreased")
})