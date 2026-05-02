TFSOLO.BalancingFuncs.push(function(kv)
{
	// Freedom Staff
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("880")
	local attrib = prefab.GetKey("attributes", true)
	// Only usable by Soldier
	local classuse = prefab.GetKey("used_by_classes", true)
	classuse.RemoveSubKey("scout")
	classuse.RemoveSubKey("sniper")
	classuse.RemoveSubKey("demoman")
	classuse.RemoveSubKey("medic")
	classuse.RemoveSubKey("heavy")
	classuse.RemoveSubKey("pyro")
	
	// TODO: New design
})