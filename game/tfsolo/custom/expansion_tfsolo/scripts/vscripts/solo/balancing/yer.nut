TFSOLO.BalancingFuncs.push(function(kv)
{
	// Your Eternal Reward
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_eternal_reward")
	local attrib = prefab.FindKey("attributes")
	// Remove cloak drain penalty
	attrib.RemoveSubKey("mult cloak meter consume rate")
})