TFSOLO.BalancingFuncs.push(function(kv)
{
	// Dalokohs Bar
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("159")
	local attrib = prefab.FindKey("attributes")
	// Add +50% eating speed
	local a1 = attrib.GetKey("provide on active", true)
	a1.SetString("attribute_class","provide_on_active")
	a1.SetInt("value", 1)
	local a2 = attrib.GetKey("gesture speed increase", true)
	a2.SetString("attribute_class","mult_gesture_time")
	a2.SetFloat("value", 1.5)
})