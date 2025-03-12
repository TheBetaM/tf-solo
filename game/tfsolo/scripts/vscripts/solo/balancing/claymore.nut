TFSOLO.BalancingFuncs.push(function(kv)
{
	// Claidheamh Mor
	local key1 = kv.FindKey("prefabs")
	local prefab = key1.FindKey("weapon_claidheamohmor")
	local attrib = prefab.FindKey("attributes")
	// Raise charge time increase from 0.5s to 0.8s
	local a1 = attrib.GetKey("charge time increased", true)
	a1.SetFloat("value", 0.8)
	// Add attack does not cancel charge
	local a2 = attrib.GetKey("Attack not cancel charge", true)
	a2.SetString("attribute_class","attack_not_cancel_charge")
	a2.SetInt("value", 1)
	
	local key2 = kv.FindKey("attributes")
	local a3 = key2.FindKey("1030")
	a3.RemoveSubKey("is_user_generated")
	a3.SetInt("hidden",0)
	a3.SetString("description_string","#Attrib_AttackNoCancelCharge")
})