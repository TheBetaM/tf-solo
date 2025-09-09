TFSOLO.BalancingFuncs.push(function(kv)
{
	// Overdose
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("412")
	local attrib = prefab.FindKey("attributes")
	// Raise potential movement speed increase to 50%
	local a1 = attrib.GetKey("move speed bonus resource level", true)
	a1.SetFloat("value", 1.5)
	// TODO: item description
})