TFSOLO.BalancingFuncs.push(function(kv)
{
	// Eviction Notice
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("426")
	local attrib = prefab.FindKey("attributes")
	// Remove health drain
	local statattr = prefab.GetKey("static_attrs", true)
	statattr.RemoveSubKey("mod_maxhealth_drain_rate")
})