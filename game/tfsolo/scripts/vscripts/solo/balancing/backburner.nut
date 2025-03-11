TFSOLO.BalancingFuncs.push(function(kv)
{
	// Backburner
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_backburner")
	local attrib = prefab.GetKey("attributes", true)
	local statattrib = prefab.FindKey("static_attrs")
	// Remove airblast cost penalty
	statattrib.RemoveSubKey("airblast cost increased")
	// Add no random critical hits
	local a1 = attrib.GetKey("crit mod disabled", true)
	a1.SetString("attribute_class","mult_crit_chance")
	a1.SetInt("value",0)
})