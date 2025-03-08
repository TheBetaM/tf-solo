TFSOLO.BalancingFuncs.push(function(kv)
{
	// Sun-on-a-Stick
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("349")
	local attrib = prefab.FindKey("attributes")
	// Add ignite on hit for 2 seconds
	local a1 = attrib.GetKey("Set DamageType Ignite", true)
	a1.SetString("attribute_class","set_dmgtype_ignite")
	a1.SetInt("value",1)
	local a2 = attrib.GetKey("afterburn duration time", true)
	a2.SetString("attribute_class","afterburn_duration_time")
	a2.SetFloat("value",2.0)
	// Disable random crits
	local a3 = attrib.GetKey("crit mod disabled", true)
	a3.SetString("attribute_class","mult_crit_chance")
	a3.SetInt("value",0)
})