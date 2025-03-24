TFSOLO.PreloadItemFuncs.push(function(cache)
{
	// Television Head from zi_murky
	if (!("maps/zi_murky.bsp" in cache))
	{
		cache["maps/zi_murky.bsp"] <- []
	}
	cache["maps/zi_murky.bsp"].extend([
		"materials/models/workshop/player/items/pyro/television_head/television_head.vmt",
		"materials/models/workshop/player/items/pyro/television_head/television_head_1.vmt",
		"materials/models/workshop/player/items/pyro/television_head/television_head_1_color.vtf",
		"materials/models/workshop/player/items/pyro/television_head/television_head_1_illum.vtf",
		"materials/models/workshop/player/items/pyro/television_head/television_head_1_normal.vtf",
		"materials/models/workshop/player/items/pyro/television_head/television_head_1_phongexponent.vtf",
		"materials/models/workshop/player/items/pyro/television_head/television_head_color.vtf",
		"materials/models/workshop/player/items/pyro/television_head/television_head_illum.vtf",
		"materials/models/workshop/player/items/pyro/television_head/television_head_normal.vtf",
		"materials/models/workshop/player/items/pyro/television_head/television_head_phongexponent.vtf",
		"models/workshop/player/items/pyro/television_head/television_head.mdl",
		"models/workshop/player/items/pyro/television_head/television_head.vvd",
		"models/workshop/player/items/pyro/television_head/television_head.dx80.vtx",
		"models/workshop/player/items/pyro/television_head/television_head.dx90.vtx",
		"models/workshop/player/items/pyro/television_head/television_head.sw.vtx",
	])
})