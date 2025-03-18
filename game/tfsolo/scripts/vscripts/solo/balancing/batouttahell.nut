TFSOLO.BalancingFuncs.push(function(kv)
{
	// Bat Outta Hell
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("939")
	local attrib = prefab.GetKey("attributes", true)
	// Only usable by Medic
	local classuse = prefab.GetKey("used_by_classes", true)
	classuse.RemoveSubKey("scout")
	classuse.RemoveSubKey("sniper")
	classuse.RemoveSubKey("soldier")
	classuse.RemoveSubKey("demoman")
	classuse.RemoveSubKey("heavy")
	classuse.RemoveSubKey("pyro")
	
	// TODO: New design
})