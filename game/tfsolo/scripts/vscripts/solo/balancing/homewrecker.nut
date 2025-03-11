TFSOLO.BalancingFuncs.push(function(kv)
{
	// Homewrecker
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("153")
	local attrib = prefab.FindKey("attributes")
	// Add knockback immunity while active
	local a1 = attrib.GetKey("provide on active", true)
	a1.SetString("attribute_class","provide_on_active")
	a1.SetInt("value", 1)
	local a2 = attrib.GetKey("damage force reduction", true)
	a2.SetString("attribute_class","damage_force_reduction")
	a2.SetFloat("value", 2.0)
	local a3 = attrib.GetKey("knockback_immunity_hidden", true)
	a3.SetString("attribute_class","knockback_immunity")
	a3.SetInt("value", 1)
})