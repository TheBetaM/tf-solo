TFSOLO.BalancingFuncs.push(function(kv)
{
	// AWPer Hand
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("851")
	local attrib = prefab.GetKey("attributes", true)
	// Add +50% headshot damage
	local a1 = attrib.GetKey("headshot damage increase", true)
	a1.SetString("attribute_class","headshot_damage_modify")
	a1.SetFloat("value", 1.5)
	// Add -80% primary ammo
	local a1 = attrib.GetKey("maxammo primary reduced", true)
	a1.SetString("attribute_class","mult_maxammo_primary")
	a1.SetFloat("value", 0.2)
})