TFSOLO.BalancingFuncs.push(function(kv)
{
	// Sydney Sleeper
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("230")
	local attrib = prefab.FindKey("attributes")
	// Remove existing attributes
	attrib.RemoveSubKey("jarate duration")
	// Add Jarate on hit for 8 seconds
	local a1 = attrib.GetKey("rifle_jarate_on_hit", true)
	a1.SetString("attribute_class","rifle_jarate_on_hit")
	a1.SetInt("value", 8)
})