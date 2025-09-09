TFSOLO.BalancingFuncs.push(function(kv)
{
	// The Sandman
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("44")
	local attrib = prefab.FindKey("attributes")
	// Remove health penalty
	attrib.RemoveSubKey("max health additive penalty")
	// Add -50% firing speed
	local a1 = attrib.GetKey("fire rate penalty", true)
	a1.SetString("attribute_class","mult_postfiredelay")
	a1.SetFloat("value",1.5)
})