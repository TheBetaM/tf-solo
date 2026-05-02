TFSOLO.BalancingFuncs.push(function(kv)
{
	// Shooting Star
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("30665")
	local attrib = prefab.GetKey("attributes", true)
	// Set rifle prefab
	prefab.SetString("prefab","no_craft weapon_sniperrifle marketable")
	// Set weapon mode to 10 (Shooting Star)
	local a1 = attrib.GetKey("lunchbox adds minicrits", true)
	a1.SetString("attribute_class","set_weapon_mode")
	a1.SetInt("value", 10)
	// Add projectile penetration
	local a2 = attrib.GetKey("rifle_projectile_penetration", true)
	a2.SetString("attribute_class","rifle_projectile_penetration")
	a2.SetInt("value", 1)
	// Add does not require ammo description
	local a3 = attrib.GetKey("energy weapon no ammo", true)
	a3.SetString("attribute_class","energy_weapon_no_ammo")
	a3.SetInt("value", 1)
	// Add fires tracers
	local a4 = attrib.GetKey("sniper fires tracer", true)
	a4.SetString("attribute_class","sniper_fires_tracer")
	a4.SetInt("value", 1)
	// Add -50% firing speed
	local a5 = attrib.GetKey("fire rate penalty", true)
	a5.SetString("attribute_class","mult_postfiredelay")
	a5.SetFloat("value", 1.5)
})