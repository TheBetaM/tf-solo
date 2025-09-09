TFSOLO.BalancingFuncs.push(function(kv)
{
	// Hot Hand
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("1181")
	local attrib = prefab.FindKey("attributes")
	// Add +40% damage to burning enemies
	local a1 = attrib.GetKey("damage bonus vs burning", true)
	a1.SetString("attribute_class","mult_dmg_vs_burning")
	a1.SetFloat("value", 1.4)
})