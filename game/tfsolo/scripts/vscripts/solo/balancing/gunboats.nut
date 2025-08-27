TFSOLO.BalancingFuncs.push(function(kv)
{
	// Gunboats
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("133")
	local attrib = prefab.GetKey("attributes", true)
	// Add usable by Demoman
	local usable = prefab.GetKey("used_by_classes", true)
	usable.SetString("demoman","primary")
	// Add stick to walls
	local a1 = attrib.GetKey("stick_to_walls", true)
	a1.SetString("attribute_class","stick_to_walls")
	a1.SetInt("value", 1)
	// Replace rocket jump attribute with generic blast dmg
	attrib.RemoveSubKey("rocket jump damage reduction")
	local a2 = attrib.GetKey("blast dmg to self reduced", true)
	a2.SetString("attribute_class","blast_dmg_to_self")
	a2.SetFloat("value", 0.4)
	// Repeat for prefab
	key1 = kv.FindKey("prefabs")
	prefab = key1.FindKey("weapon_gunboats")
	attrib = prefab.FindKey("attributes")
	usable = prefab.GetKey("used_by_classes", true)
	usable.SetString("demoman","primary")
	a1 = attrib.GetKey("stick_to_walls", true)
	a1.SetString("attribute_class","stick_to_walls")
	a1.SetInt("value", 1)
	attrib.RemoveSubKey("rocket jump damage reduction")
	a2 = attrib.GetKey("blast dmg to self reduced", true)
	a2.SetString("attribute_class","blast_dmg_to_self")
	a2.SetFloat("value", 0.4)
})