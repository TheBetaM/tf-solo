TFSOLO.BalancingFuncs.push(function(kv)
{
	// Dragon's Fury
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("1178")
	local attrib = prefab.GetKey("attributes", true)
	local statattrib = prefab.FindKey("static_attrs")
	// Remove airblast cost penalty
	statattrib.SetString("airblast cost scale hidden","0.2")
	statattrib.RemoveSubKey("dragons fury negative properties")
	// Remove 50% repressurization rate on airblast
	if (IsServer())
	{
		Convars.SetValue("tf_fireball_airblast_recharge_penalty", 0.99)
	}
})