TFSOLO.BalancingFuncs.push(function(kv)
{
	// Gloves of Running Urgently
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_gru")
	local attrib = prefab.FindKey("attributes")
	// Remove health drain
	local statattr = prefab.GetKey("static_attrs", true)
	statattr.RemoveSubKey("mod_maxhealth_drain_rate")
	// Add Marked For Death while active
	local a1 = attrib.GetKey("provide on active", true)
	a1.SetString("attribute_class","provide_on_active")
	a1.SetInt("value", 1)
	local a2 = attrib.GetKey("self mark for death", true)
	a2.SetString("attribute_class","self_mark_for_death")
	a2.SetInt("value", 3)
	// Add -25% damage penalty
	local a3 = attrib.GetKey("damage penalty", true)
	a3.SetString("attribute_class","mult_dmg")
	a3.SetFloat("value", 0.75)
})