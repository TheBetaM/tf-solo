printl("[TFSOLO] Game Client Init")
TFSOLO <- {}

DoIncludeScript("client/util.nut", this)
ClearGameEventCallbacks()
IncludeScript("solo/util.nut")
IncludeScript("client/savedata.nut")
IncludeScript("solo/itemschema.nut")
IncludeScript("client/solo/preload_items.nut")
IncludeScript("client/solo/vgui/init.nut")

TFSOLO.CoreEventTag <- UniqueString()
getroottable()[TFSOLO.CoreEventTag] <- {
	OnGameEvent_player_death = function(params)
	{
	}
	
	OnGameEvent_localplayer_changeteam = function(params)
	{
	}
}
TFSOLO.CoreEventTable <- getroottable()[TFSOLO.CoreEventTag]
__CollectGameEventCallbacks(TFSOLO.CoreEventTable)

::TestPreloadSingle <- function()
{
	local cache = {
		["maps/pd_selbyen.bsp"] = "models/props_selbyen/seal.mdl",
	}
	
	BSP_CacheStartSingle(cache)
}
::TestPreloadBatch <- function()
{
	local cache = {
		["maps/pd_selbyen.bsp"] = [
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
		]
	}
	
	BSP_CacheStartArray(cache)
}
::TestPreloadRemap <- function()
{
	local cache = {
		["maps/pd_selbyen.bsp"] = {
		["materials/models/props_selbyen/seal.vmt"] = "materials/models/props_selbyen/seal.vmt",
		["materials/models/props_selbyen/seal.vtf"] = "materials/models/props_selbyen/seal.vtf",
		["materials/models/props_selbyen/seal_eyes.vmt"] = "materials/models/props_selbyen/seal_eyes.vmt",
		["materials/models/props_selbyen/seal_normal.vtf"] = "materials/models/props_selbyen/seal_normal.vtf",
		["materials/models/props_selbyen/seal_skin1.vmt"] = "materials/models/props_selbyen/seal_skin1.vmt",
		["materials/models/props_selbyen/seal_skin1.vtf"] = "materials/models/props_selbyen/seal_skin1.vtf",
		["materials/models/props_selbyen/seal_skin2.vmt"] = "materials/models/props_selbyen/seal_skin2.vmt",
		["materials/models/props_selbyen/seal_skin2.vtf"] = "materials/models/props_selbyen/seal_skin2.vtf",
		["materials/models/props_selbyen/seal_whiskers.vmt"] = "materials/models/props_selbyen/seal_whiskers.vmt",
		["materials/models/props_selbyen/seal_whiskers.vtf"] = "materials/models/props_selbyen/seal_whiskers.vtf",
		["models/props_selbyen/seal.mdl"] = "models/props_selbyen/sealremap.mdl",
		["models/props_selbyen/seal.vvd"] = "models/props_selbyen/sealremap.vvd",
		["models/props_selbyen/seal.dx80.vtx"] = "models/props_selbyen/sealremap.dx80.vtx",
		["models/props_selbyen/seal.dx90.vtx"] = "models/props_selbyen/sealremap.dx90.vtx",
		["models/props_selbyen/seal.sw.vtx"] = "models/props_selbyen/sealremap.sw.vtx",
		}
	}
	
	BSP_CacheStartRemap(cache)
}