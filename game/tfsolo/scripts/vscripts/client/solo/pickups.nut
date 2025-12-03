
TFSOLO.PickupModels <- [
"models/items/currencypack_small.mdl",
]


TFSOLO.SpawnPickups <- function()
{
	local map = Convars.GetStr("tfsolo_mapentry")
	if (map == null || map.len() == 0)
		return
	local mapKV = TFSOLO.GetMapEntry(map)
	if (mapKV == null)
		return
	
	local pickupKV = mapKV.GetKey("pickups", false)
	if (pickupKV == null)
		return
	
	local saveKV = Solo.GetSaveData()
	local savemapsKV = saveKV.GetKey("Maps", true)
	local savemapKV = savemapsKV.GetKey(map, true)
	
	local key = pickupKV.GetFirstSubKey()
	while (key)
	{
		local name = key.GetName()
		local t = key.GetInt("type")
		local pos = key.GetString("pos")
		local modelin = key.GetString("model")
		local model = TFSOLO.PickupModels[t]
		if (modelin != null && modelin.len() != 0)
		{
			model = modelin
		}
		if (savemapKV.GetInt(name) == 0)
		{
			Solo.CreateClientPickup(name, pos, t, model)
		}
		key = key.GetNextKey()
	}
}


TFSOLO.PickupsEventTag <- UniqueString()
getroottable()[TFSOLO.PickupsEventTag] <- {
	OnScriptHook_LevelInitPostEntity = function(params)
	{
		TFSOLO.SpawnPickups()
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		
	}
	
	OnScriptHook_GenericItemPickupCollect = function(params)
	{
		local map = Convars.GetStr("tfsolo_mapentry")
		if (map == null || map.len() == 0)
			return
		local kv = Solo.GetSaveData()
		local mapsKV = kv.GetKey("Maps", true)
		local mapKV = mapsKV.GetKey(map, true)
		local pickupCount = mapKV.GetInt(params.name)
		mapKV.SetInt(params.name, pickupCount + 1)
		
		if (params.pickuptype == 0)
		{
			TFSOLO.AddCredits(50)
			Solo.WriteSaveData()
			EmitSound("MVM.MoneyPickup")
			AwardAchievement(161, 1) // TFSOLO_GENERAL_COLLECT_CREDITS
		}
	}
}
TFSOLO.PickupsEventTable <- getroottable()[TFSOLO.PickupsEventTag]
__CollectGameEventCallbacks(TFSOLO.PickupsEventTable)