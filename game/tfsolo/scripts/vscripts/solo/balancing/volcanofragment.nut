TFSOLO.BalancingFuncs.push(function(kv)
{
	// Sharpened Volcano Fragment
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("348")
	local attrib = prefab.FindKey("attributes")
	// Add +100% afterburn damage passive
	local a1 = attrib.GetKey("player burn dmg increased", true)
	a1.SetString("attribute_class","mult_wpn_burndmg")
	a1.SetFloat("value", 2.0)
})