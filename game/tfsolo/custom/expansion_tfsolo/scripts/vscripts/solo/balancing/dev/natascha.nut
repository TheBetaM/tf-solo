TFSOLO.BalancingFuncs.push(function(kv)
{
	// Natascha
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("41")
	local attrib = prefab.FindKey("attributes")
	// Remove slow on hit
	attrib.RemoveSubKey("slow enemy on hit")
	// Add bleed for 4 seconds on hit
	local a1 = attrib.GetKey("bleeding duration", true)
	a1.SetString("attribute_class","bleeding_duration")
	a1.SetInt("value", 3)
})