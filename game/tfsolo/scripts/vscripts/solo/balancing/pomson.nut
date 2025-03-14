TFSOLO.BalancingFuncs.push(function(kv)
{
	// Pomson 6000
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("588")
	local attrib = prefab.FindKey("attributes")
	// Add projectile penetration/bison projectile properties
	local a1 = attrib.GetKey("energy weapon penetration", true)
	a1.SetString("attribute_class","energy_weapon_penetration")
	a1.SetInt("value", 1)
})