TFSOLO.BalancingFuncs.push(function(kv)
{
	// Third Degree
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("593")
	local attrib = prefab.FindKey("attributes")
	// Add +30% damage resistance to ranged sources while active
	local a1 = attrib.GetKey("dmg from ranged reduced", true)
	a1.SetString("attribute_class","dmg_from_ranged")
	a1.SetFloat("value", 0.7)
	// Add -50% weapon switch speed
	local a1 = attrib.GetKey("deploy time increased", true)
	a1.SetString("attribute_class","mult_deploy_time")
	a1.SetFloat("value",1.5)
})