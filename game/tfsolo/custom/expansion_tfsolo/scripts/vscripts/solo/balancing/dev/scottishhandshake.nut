TFSOLO.BalancingFuncs.push(function(kv)
{
	// Scottish Handshake
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("609")
	local attrib = prefab.FindKey("attributes")
	// Add air jump on attack in mid-air
	local a1 = attrib.GetKey("air jump on attack", true)
	a1.SetString("attribute_class","air_jump_on_attack")
	a1.SetInt("value", 1)
	// Add -30% damage penalty
	local a2 = attrib.GetKey("damage penalty", true)
	a2.SetString("attribute_class","mult_dmg")
	a2.SetFloat("value", 0.7)
	
	local key2 = kv.FindKey("attributes")
	local a3 = key2.FindKey("634")
	a3.SetInt("hidden",0)
})