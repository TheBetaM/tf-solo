TFSOLO.BalancingFuncs.push(function(kv)
{
	// Saxxy
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("423")
	local attrib = prefab.FindKey("attributes")
	// Only usable by Spy
	local classuse = prefab.GetKey("used_by_classes", true)
	classuse.RemoveSubKey("scout")
	classuse.RemoveSubKey("sniper")
	classuse.RemoveSubKey("soldier")
	classuse.RemoveSubKey("demoman")
	classuse.RemoveSubKey("medic")
	classuse.RemoveSubKey("heavy")
	classuse.RemoveSubKey("engineer")
	classuse.RemoveSubKey("pyro")
	// Add +200% damage bonus
	local a1 = attrib.GetKey("damage bonus", true)
	a1.SetString("attribute_class","mult_dmg")
	a1.SetFloat("value", 3.0)
	// Add no backstabs
	local a2 = attrib.GetKey("knife_no_backstab", true)
	a2.SetString("attribute_class","knife_no_backstab")
	a2.SetInt("value", 1)
	// Add -10% movement speed while active
	local a3 = attrib.GetKey("move speed penalty", true)
	a3.SetString("attribute_class","mult_player_movespeed")
	a3.SetFloat("value", 0.9)
})