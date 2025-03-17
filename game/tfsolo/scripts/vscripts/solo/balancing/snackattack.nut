TFSOLO.BalancingFuncs.push(function(kv)
{
	// Snack Attack
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("1102")
	local attrib = prefab.GetKey("attributes", true)
	// Add sapping players
	local a1 = attrib.GetKey("sapper_on_players", true)
	a1.SetString("attribute_class","sapper_on_players")
	a1.SetInt("value", 1)
	// Add no sapping buildings
	local a2 = attrib.GetKey("sapper_no_buildings", true)
	a2.SetString("attribute_class","sapper_no_buildings")
	a2.SetInt("value", 1)
	// Add destructible sapper (doesn't work on players yet)
	//local a3 = attrib.GetKey("sapper_destructible", true)
	//a3.SetString("attribute_class","sapper_destructible")
	//a3.SetInt("value", 1)
	// Add recharge time
	local a4 = attrib.GetKey("sapper_recharge_time", true)
	a4.SetString("attribute_class","sapper_recharge_time")
	a4.SetInt("value", 15)
})