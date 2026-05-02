TFSOLO.BalancingFuncs.push(function(kv)
{
	// Pretty Boy's Pocket Pistol
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("773")
	local attrib = prefab.FindKey("attributes")
	// Remove existing atrributes
	attrib.RemoveSubKey("provide on active")
	attrib.RemoveSubKey("heal on hit for rapidfire")
	attrib.RemoveSubKey("fire rate bonus")
	attrib.RemoveSubKey("clip size penalty")
	// Add +50% weapon switch speed
	local a1 = attrib.GetKey("deploy time decreased", true)
	a1.SetString("attribute_class","mult_deploy_time")
	a1.SetFloat("value",0.5)
	// Add +100% secondary ammo
	local a2 = attrib.GetKey("maxammo secondary increased", true)
	a2.SetString("attribute_class","mult_maxammo_secondary")
	a2.SetFloat("value",2.0)
	// Add -75% reload speed
	local a3 = attrib.GetKey("Reload time increased", true)
	a3.SetString("attribute_class","mult_reload_time")
	a3.SetFloat("value",1.75)
})