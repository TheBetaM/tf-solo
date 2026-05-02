TFSOLO.BalancingFuncs.push(function(kv)
{
	// Baby Face's Blaster
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("772")
	local attrib = prefab.FindKey("attributes")
	// Remove boost loss on damage
	attrib.RemoveSubKey("lose hype on take damage")
	// Reduce boost loss on air jumps from 75% to 10%
	local a1 = attrib.FindKey("hype resets on jump")
	a1.SetInt("value", 10)
})