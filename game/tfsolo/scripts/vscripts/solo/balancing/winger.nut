TFSOLO.BalancingFuncs.push(function(kv)
{
	// Winger
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_winger_pistol")
	local attrib = prefab.FindKey("attributes")
	// Jump height now always increased instead of while active
	attrib.RemoveSubKey("increased jump height from weapon")
	local a1 = attrib.GetKey("increased jump height", true)
	a1.SetString("attribute_class","mod_jump_height")
	a1.SetFloat("value",1.25)
})