TFSOLO.BalancingFuncs.push(function(kv)
{
	// Ambassador
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_ambassador")
	local attrib = prefab.FindKey("static_attrs")
	// Remove critical damage falloff
	attrib.RemoveSubKey("crit_dmg_falloff")
})