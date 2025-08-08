TFSOLO.BalancingFuncs.push(function(kv)
{
	// Ullapool Caber
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("307")
	local attrib = prefab.FindKey("attributes")
	// Remove penalties
	attrib.RemoveSubKey("fire rate penalty")
	attrib.RemoveSubKey("single wep deploy time increased")
	// Add 45% damage penalty
	local a1 = attrib.GetKey("damage penalty" true)
	a1.SetString("attribute_class","mult_dmg")
	a1.SetFloat("value", 0.55)
})