TFSOLO.PreloadItemFuncs.push(function(cache)
{
	// Burnt Bigaxe from plr_hacksaw_event
	if (!("maps/plr_hacksaw_event.bsp" in cache))
	{
		cache["maps/plr_hacksaw_event.bsp"] <- []
	}
	cache["maps/plr_hacksaw_event.bsp"].extend([
		"materials/models/weapons/c_items/pumpkin_axe_burnt.vmt",
		"models/weapons/c_models/c_bigaxe/c_bigaxe_burnt.mdl",
		"models/weapons/c_models/c_bigaxe/c_bigaxe_burnt.phy",
		"models/weapons/c_models/c_bigaxe/c_bigaxe_burnt.vvd",
		"models/weapons/c_models/c_bigaxe/c_bigaxe_burnt.dx80.vtx",
		"models/weapons/c_models/c_bigaxe/c_bigaxe_burnt.dx90.vtx",
		"models/weapons/c_models/c_bigaxe/c_bigaxe_burnt.sw.vtx",
	])
})