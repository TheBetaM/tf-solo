TFSOLO.PreloadItemFuncs.push(function(cache)
{
	// Seal from pd_selbyen
	if (!("maps/pd_selbyen.bsp" in cache))
	{
		cache["maps/pd_selbyen.bsp"] <- []
	}
	cache["maps/pd_selbyen.bsp"].extend([
		"materials/models/props_selbyen/seal.vmt",
		"materials/models/props_selbyen/seal.vtf",
		"materials/models/props_selbyen/seal_eyes.vmt",
		"materials/models/props_selbyen/seal_normal.vtf",
		"materials/models/props_selbyen/seal_skin1.vmt",
		"materials/models/props_selbyen/seal_skin1.vtf",
		"materials/models/props_selbyen/seal_skin2.vmt",
		"materials/models/props_selbyen/seal_skin2.vtf",
		"materials/models/props_selbyen/seal_whiskers.vmt",
		"materials/models/props_selbyen/seal_whiskers.vtf",
		"models/props_selbyen/seal.mdl",
		"models/props_selbyen/seal.vvd",
		"models/props_selbyen/seal.dx80.vtx",
		"models/props_selbyen/seal.dx90.vtx",
		"models/props_selbyen/seal.sw.vtx",
	])
})