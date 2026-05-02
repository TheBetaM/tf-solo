TFSOLO.BalancingFuncs.push(function(kv)
{
	// Reserve Shooter
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_reserve_shooter")
	local attrib = prefab.FindKey("attributes")
	// Only usable by Soldier
	local classuse = prefab.GetKey("used_by_classes", true)
	classuse.RemoveSubKey("pyro")
})