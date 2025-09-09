TFSOLO.BalancingFuncs.push(function(kv)
{
	// Solemn Vow
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("413")
	local attrib = prefab.FindKey("attributes")
	// Remove existing attributes
	attrib.RemoveSubKey("fire rate penalty")
	attrib.RemoveSubKey("mod see enemy health")
	// Add -90% ranged damage taken while active
	local a1 = attrib.GetKey("provide on active", true)
	a1.SetString("attribute_class","provide_on_active")
	a1.SetInt("value", 1)
	local a2 = attrib.GetKey("dmg from ranged reduced", true)
	a2.SetString("attribute_class","dmg_from_ranged")
	a2.SetFloat("value", 0.1)
	// Add -75% movement speed while active
	local a3 = attrib.GetKey("move speed penalty", true)
	a3.SetString("attribute_class","mult_player_movespeed")
	a3.SetFloat("value", 0.25)
	// Add -75% deploy speed
	local a4 = attrib.GetKey("single wep deploy time increased", true)
	a4.SetString("attribute_class","mult_single_wep_deploy_time")
	a4.SetFloat("value", 1.75)
})