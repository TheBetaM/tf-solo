TFSOLO.BalancingFuncs.push(function(kv)
{
	// Giger Counter
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("30668")
	local attrib = prefab.GetKey("attributes", true)
	// Add no self damage taken
	local a1 = attrib.GetKey("no_self_dmg", true)
	a1.SetString("attribute_class","no_self_dmg")
	a1.SetInt("value", 1)
	// Add -75% sentry cost reduction
	local a2 = attrib.GetKey("mod sentry cost", true)
	a2.SetString("attribute_class","mod_sentry_cost")
	a2.SetFloat("value", 0.25)
	// Add sentry deals no damage, only knockback
	local a3 = attrib.GetKey("sentry_no_dmg", true)
	a3.SetString("attribute_class","sentry_no_dmg")
	a3.SetInt("value", 1)
})