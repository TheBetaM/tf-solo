TFSOLO.BalancingFuncs.push(function(kv)
{
	// Half-Zatoichi
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("357")
	local attrib = prefab.FindKey("attributes")
	// Only usable by Demoman
	local classuse = prefab.GetKey("used_by_classes", true)
	classuse.RemoveSubKey("soldier")
})