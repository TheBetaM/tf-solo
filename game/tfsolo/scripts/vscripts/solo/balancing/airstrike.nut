TFSOLO.BalancingFuncs.push(function(kv)
{
	// Air Strike
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_atom_launcher")
	local attrib = prefab.FindKey("attributes")
	// Reduce damage penalty from 15% to 10%
	local a1 = attrib.GetKey("damage penalty", true)
	a1.SetFloat("value", 0.9)
})