TFSOLO.BalancingFuncs.push(function(kv)
{
	// Loch-n-Load
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_lochnload")
	local attrib = prefab.FindKey("attributes")
	// Replace +20% damage to buildings with +20% damage bonus
	attrib.RemoveSubKey("dmg bonus vs buildings")
	local a1 = attrib.GetKey("damage bonus", true)
	a1.SetString("attribute_class","mult_dmg")
	a1.SetFloat("value", 1.2)
})