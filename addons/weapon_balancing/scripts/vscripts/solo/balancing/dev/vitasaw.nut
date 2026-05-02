TFSOLO.BalancingFuncs.push(function(kv)
{
	// Vita-Saw
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("173")
	local attrib = prefab.FindKey("attributes")
	// Remove organ harvesting
	attrib.RemoveSubKey("ubercharge_preserved_on_spawn_max")
	// Add up to 50% charge retained upon death
	local a1 = attrib.GetKey("preserve ubercharge", true)
	a1.SetString("attribute_class","preserve_ubercharge")
	a1.SetFloat("value", 0.5)
	// TODO: Description
})