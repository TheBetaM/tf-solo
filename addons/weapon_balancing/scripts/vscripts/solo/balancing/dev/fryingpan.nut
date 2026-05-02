TFSOLO.BalancingFuncs.push(function(kv)
{
	// Frying Pan / Golden Frying Pan
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("264")
	local attrib = prefab.FindKey("attributes")
	// Add +25% damage to the same class
	local a1 = attrib.GetKey("mult_dmg_vs_same_class", true)
	a1.SetString("attribute_class","mult_dmg_vs_same_class")
	a1.SetFloat("value", 1.25)
	// Add -50% crit resistance
	local a2 = attrib.GetKey("dmg taken from crit increased", true)
	a2.SetString("attribute_class","mult_dmgtaken_from_crit")
	a2.SetFloat("value", 1.5)
	
	// Repeat for the other item
	prefab = key1.FindKey("1071")
	attrib = prefab.FindKey("attributes")
	a1 = attrib.GetKey("mult_dmg_vs_same_class", true)
	a1.SetString("attribute_class","mult_dmg_vs_same_class")
	a1.SetFloat("value", 1.25)
	a2 = attrib.GetKey("dmg taken from crit increased", true)
	a2.SetString("attribute_class","mult_dmgtaken_from_crit")
	a2.SetFloat("value", 1.5)
})