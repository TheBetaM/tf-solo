TFSOLO.BalancingFuncs.push(function(kv)
{
	// Buffalo Steak Sandvich
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("311")
	local attrib = prefab.FindKey("attributes")
	// Remove +20% damage vulnerability
	attrib.RemoveSubKey("energy buff dmg taken multiplier")
})