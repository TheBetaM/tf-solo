TFSOLO.BalancingFuncs.push(function(kv)
{
	// Brass Beast
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_gatling_gun")
	local attrib = prefab.FindKey("attributes")
	// Add can holster while spinning
	local a1 = attrib.GetKey("mod_minigun_can_holster_while_spinning", true)
	a1.SetString("attribute_class","mod_minigun_can_holster_while_spinning")
	a1.SetInt("value", 1)
})