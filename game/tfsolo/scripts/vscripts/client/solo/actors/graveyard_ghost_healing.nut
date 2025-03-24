TFSOLO.PreloadItemFuncs.push(function(cache)
{
	// Healing ghost from arena_lumberyard_event
	if (!("maps/arena_lumberyard_event.bsp" in cache))
	{
		cache["maps/arena_lumberyard_event.bsp"] <- []
	}
	cache["maps/arena_lumberyard_event.bsp"].extend([
		"materials/models/props_graveyard/healing_ghost.vmt",
		"materials/models/props_graveyard/healing_ghost.vtf",
		"materials/models/props_graveyard/healing_ghost_eyeglow.vmt",
		"materials/models/props_graveyard/healing_ghost_eyeglow.vtf",
		"materials/models/props_graveyard/healing_ghost_red.vmt",
		"models/props_graveyard/ghost_healing.mdl",
		"models/props_graveyard/ghost_healing.vvd",
		"models/props_graveyard/ghost_healing.dx80.vtx",
		"models/props_graveyard/ghost_healing.dx90.vtx",
		"models/props_graveyard/ghost_healing.sw.vtx",
		"models/props_graveyard/ghost_healing_red.mdl",
		"models/props_graveyard/ghost_healing_red.vvd",
		"models/props_graveyard/ghost_healing_red.dx80.vtx",
		"models/props_graveyard/ghost_healing_red.dx90.vtx",
		"models/props_graveyard/ghost_healing_red.sw.vtx",
	])
})