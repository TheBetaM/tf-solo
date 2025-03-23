TFSOLO.PreloadItemFuncs.push(function(cache)
{
	// Tommygun from pl_spineyard
	if (!("maps/pl_spineyard.bsp" in cache))
	{
		cache["maps/pl_spineyard.bsp"] <- []
	}
	cache["maps/pl_spineyard.bsp"].extend([
		"materials/models/props_tuscany/tommygun_01.vmt",
		"materials/models/props_tuscany/tommygun_01.vtf",
		"models/props_tuscany/tommygun_01.mdl",
		"models/props_tuscany/tommygun_01.vvd",
		"models/props_tuscany/tommygun_01.dx80.vtx",
		"models/props_tuscany/tommygun_01.dx90.vtx",
		"models/props_tuscany/tommygun_01.sw.vtx",
	])
})