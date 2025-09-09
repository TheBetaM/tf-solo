TFSOLO.BalancingFuncs.push(function(kv)
{
	// Necro Smasher
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("1123")
	local attrib = prefab.GetKey("attributes", true)
	// Only usable by Engineer
	local classuse = prefab.GetKey("used_by_classes", true)
	classuse.RemoveSubKey("scout")
	classuse.RemoveSubKey("sniper")
	classuse.RemoveSubKey("soldier")
	classuse.RemoveSubKey("demoman")
	classuse.RemoveSubKey("medic")
	classuse.RemoveSubKey("heavy")
	classuse.RemoveSubKey("pyro")
	
	// TODO: New design
})