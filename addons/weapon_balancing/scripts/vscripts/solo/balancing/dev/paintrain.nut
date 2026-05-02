TFSOLO.BalancingFuncs.push(function(kv)
{
	// Pain Train
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("154")
	local attrib = prefab.FindKey("attributes")
	// Only usable by Soldier
	local classuse = prefab.GetKey("used_by_classes", true)
	classuse.RemoveSubKey("demoman")
})