TFSOLO.BalancingFuncs.push(function(kv)
{
	// Axtinguisher
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_axtinguisher")
	local attrib = prefab.GetKey("attributes", true)
	local statattrib = prefab.FindKey("static_attrs")
	// Remove current attributes
	statattrib.RemoveSubKey("attack_minicrits_and_consumes_burning")
	statattrib.RemoveSubKey("damage penalty")
	statattrib.RemoveSubKey("single wep holster time increased")
	statattrib.RemoveSubKey("crit mod disabled")
	// Add 100% crit chance on burning players
	local a1 = attrib.GetKey("crit vs burning players", true)
	a1.SetString("attribute_class","or_crit_vs_playercond")
	a1.SetInt("value",1)
	// Add -50% damage vs non-burning players
	local a2 = attrib.GetKey("dmg penalty vs nonburning", true)
	a2.SetString("attribute_class","mult_dmg_vs_nonburning")
	a2.SetFloat("value",0.5)
	// Add no crits vs non-burning players
	local a3 = attrib.GetKey("no crit vs nonburning", true)
	a3.SetString("attribute_class","set_nocrit_vs_nonburning")
	a3.SetInt("value",1)
})