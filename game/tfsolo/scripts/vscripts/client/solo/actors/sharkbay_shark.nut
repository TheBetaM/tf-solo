TFSOLO.PreloadItemFuncs.push(function(cache)
{
	// Shark from koth_sharkbay
	if (!("maps/koth_sharkbay.bsp" in cache))
	{
		cache["maps/koth_sharkbay.bsp"] <- []
	}
	cache["maps/koth_sharkbay.bsp"].extend([
		"materials/models/props_gunn/shark/shark_beige.vmt",
		"materials/models/props_gunn/shark/shark_beige.vtf",
		"materials/models/props_gunn/shark/shark_blue.vmt",
		"materials/models/props_gunn/shark/shark_blue.vtf",
		"materials/models/props_gunn/shark/shark_exponent.vtf",
		"materials/models/props_gunn/shark/shark_stripeless_beige.vmt",
		"materials/models/props_gunn/shark/shark_stripeless_beige.vtf",
		"materials/models/props_gunn/shark/shark_stripeless_blue.vmt",
		"materials/models/props_gunn/shark/shark_stripeless_blue.vtf",
		"materials/models/props_gunn/shark/shark_stripeless_exponent.vtf",
		"materials/models/props_gunn/shark/shark_stripeless_white.vmt",
		"materials/models/props_gunn/shark/shark_stripeless_white.vtf",
		"materials/models/props_gunn/shark/shark_white.vmt",
		"materials/models/props_gunn/shark/shark_white.vtf",
		"models/props_gunn/shark/shark.mdl",
		"models/props_gunn/shark/shark.vvd",
		"models/props_gunn/shark/shark.dx80.vtx",
		"models/props_gunn/shark/shark.dx90.vtx",
		"models/props_gunn/shark/shark.sw.vtx",
	])
})