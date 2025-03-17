TFSOLO.BalancingFuncs.push(function(kv)
{
	// Big Kill
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("161")
	local attrib = prefab.GetKey("attributes", true)
	// Add last shot crits
	local a1 = attrib.GetKey("last_shot_crits", true)
	a1.SetString("attribute_class","last_shot_crits")
	a1.SetInt("value", 1)
	// Add -50% clip size
	local a2 = attrib.GetKey("clip size penalty", true)
	a2.SetString("attribute_class","mult_clipsize")
	a2.SetFloat("value", 0.5)
	// Disable random crits
	local a3 = attrib.GetKey("crit mod disabled", true)
	a3.SetString("attribute_class","mult_crit_chance")
	a3.SetInt("value",0)
})