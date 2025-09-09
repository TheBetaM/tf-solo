TFSOLO.BalancingFuncs.push(function(kv)
{
	// Warrior's Spirit
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("310")
	local attrib = prefab.FindKey("attributes")
	// Remove +30% damage vulnerability
	attrib.RemoveSubKey("dmg taken increased")
	// Remove heal on kill
	attrib.RemoveSubKey("heal on kill")
	// Add +15% movement speed penalty while active
	local a1 = attrib.GetKey("move speed penalty", true)
	a1.SetString("attribute_class","mult_player_movespeed")
	a1.SetFloat("value", 0.85)
})