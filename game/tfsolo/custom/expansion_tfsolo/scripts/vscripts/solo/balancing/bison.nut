TFSOLO.BalancingFuncs.push(function(kv)
{
	// Righteous Bison
	local key1 = kv.FindKey("items")
	local prefab = key1.FindKey("442")
	local attrib = prefab.FindKey("attributes")
	if (IsServer())
	{
		// Allow the projectile to deal damage every tick, instead of every 2 ticks
		Convars.SetValue("tf_bison_tick_time", 0.014)
	}
})