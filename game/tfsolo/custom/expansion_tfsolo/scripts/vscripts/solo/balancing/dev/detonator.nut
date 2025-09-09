TFSOLO.BalancingFuncs.push(function(kv)
{
	// Detonator
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_detonator")
	local attrib = prefab.FindKey("attributes")
	// Remove damage penalty
	attrib.RemoveSubKey("damage penalty")
	// Add +50% self damage push force
	local a1 = attrib.GetKey("self dmg push force increased", true)
	a1.SetString("attribute_class","self dmg push force increased")
	a1.SetFloat("value", 1.5)
})