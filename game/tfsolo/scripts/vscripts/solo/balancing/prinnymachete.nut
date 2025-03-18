TFSOLO.BalancingFuncs.push(function(kv)
{
	// Prinny Machete
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("30758")
	local attrib = prefab.GetKey("attributes", true)
	// Only usable by Sniper
	local classuse = prefab.GetKey("used_by_classes", true)
	classuse.RemoveSubKey("scout")
	classuse.RemoveSubKey("soldier")
	classuse.RemoveSubKey("demoman")
	classuse.RemoveSubKey("medic")
	classuse.RemoveSubKey("heavy")
	classuse.RemoveSubKey("pyro")
	classuse.RemoveSubKey("spy")
	classuse.RemoveSubKey("engineer")
	
	// Add melee cleave attack
	local a1 = attrib.GetKey("melee_cleave_attack", true)
	a1.SetString("attribute_class","melee_cleave_attack")
	a1.SetInt("value", 1)
	// Add -20% firing speed
	local a2 = attrib.GetKey("fire rate penalty", true)
	a2.SetString("attribute_class","mult_postfiredelay")
	a2.SetFloat("value", 1.2)
})