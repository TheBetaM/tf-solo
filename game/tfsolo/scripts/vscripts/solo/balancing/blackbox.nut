TFSOLO.BalancingFuncs.push(function(kv)
{
	// Black Box
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_blackbox")
	local attrib = prefab.FindKey("attributes")
	// Remove health on attack
	attrib.RemoveSubKey("health on radius damage")
	// Lower clip size to 1
	local a1 = attrib.GetKey("clip size penalty", true)
	a1.SetString("attribute_class","mult_clipsize")
	a1.SetFloat("value",0.25)
	// Add +30% damage
	local a2 = attrib.GetKey("damage bonus", true)
	a2.SetString("attribute_class","mult_dmg")
	a2.SetFloat("value",1.3)
	// Add +10% explosion radius
	local a3 = attrib.GetKey("Blast radius increased", true)
	a3.SetString("attribute_class","mult_explosion_radius")
	a3.SetFloat("value",1.1)
	// Add -75% reload speed
	local a4 = attrib.GetKey("Reload time increased", true)
	a4.SetString("attribute_class","mult_reload_time")
	a4.SetFloat("value",1.75)
	// Add -30% projectile speed
	local a5 = attrib.GetKey("Projectile speed decreased", true)
	a5.SetString("attribute_class","mult_projectile_speed")
	a5.SetFloat("value",0.7)
})