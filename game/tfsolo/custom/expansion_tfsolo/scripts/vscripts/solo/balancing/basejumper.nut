TFSOLO.BalancingFuncs.push(function(kv)
{
	// B.A.S.E. Jumper
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("1101")
	local attrib = prefab.FindKey("attributes")
	// Only usable by Soldier
	local classuse = prefab.GetKey("used_by_classes", true)
	classuse.RemoveSubKey("demoman")
	if (IsServer())
	{
		// Enable re-deploy
		Convars.SetValue("tf_parachute_deploy_toggle_allowed", 1)
		// Revert 50% air control decrease
		Convars.SetValue("tf_parachute_aircontrol", 5.0)
	}
})