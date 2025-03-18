TFSOLO.BalancingFuncs.push(function(kv)
{
	// Ham Shank
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("1013")
	local attrib = prefab.GetKey("attributes", true)
	// Only usable by Sniper
	local classuse = prefab.GetKey("used_by_classes", true)
	classuse.RemoveSubKey("scout")
	classuse.RemoveSubKey("soldier")
	classuse.RemoveSubKey("demoman")
	classuse.RemoveSubKey("medic")
	classuse.RemoveSubKey("heavy")
	classuse.RemoveSubKey("pyro")
	
	// TODO: New design
})