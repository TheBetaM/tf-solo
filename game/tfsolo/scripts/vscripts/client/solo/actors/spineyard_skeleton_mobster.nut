TFSOLO.PreloadItemFuncs.push(function(cache)
{
	// Skeleton mobster from pl_spineyard
	if (!("maps/pl_spineyard.bsp" in cache))
	{
		cache["maps/pl_spineyard.bsp"] <- []
	}
	cache["maps/pl_spineyard.bsp"].extend([
		"materials/models/bots/skeleton/cosa_nostra_suit.vmt",
		"materials/models/bots/skeleton/cosa_nostra_suit.vtf",
		"materials/models/bots/skeleton/skeleton_cosa_nostra.vmt",
		"materials/models/bots/skeleton/skeleton_cosa_nostra.vtf",
		"models/bots/vineyard_event/skeleton_sniper_mafia.mdl",
		"models/bots/vineyard_event/skeleton_sniper_mafia.phy",
		"models/bots/vineyard_event/skeleton_sniper_mafia.vvd",
		"models/bots/vineyard_event/skeleton_sniper_mafia.dx80.vtx",
		"models/bots/vineyard_event/skeleton_sniper_mafia.dx90.vtx",
		"models/bots/vineyard_event/skeleton_sniper_mafia.sw.vtx",
	])
})