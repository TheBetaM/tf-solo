TFSOLO.InitSaveData <- function()
{
	local kv = Solo.GetSaveData()
	local itemsKV = kv.GetKey("UnlockedItems", true)
	local armoryKV = kv.GetKey("Armory", true)
	local botpresetsKV = kv.GetKey("BotPresets", true)
	local campaignsKV = kv.GetKey("Campaigns", true)
	local mapsKV = kv.GetKey("Maps", true)
	local genericKV = kv.GetKey("Generic", true)
	
	// Start with 100 credits.
	kv.SetInt("Credits", 100)
	// Start without base game weapons. Unlock the ability to equip them in the Armory.
	genericKV.SetInt("BaseGameWeapons", 0)
	genericKV.SetInt("BaseGameTaunts", 1)
	genericKV.SetInt("BaseGameCosmetics", 1)
}

TFSOLO.AddCredits <- function(amount)
{
	local kv = Solo.GetSaveData()
	local credits = kv.GetInt("Credits")
	if (amount < 0 && credits < abs(amount))
	{
		kv.SetInt("Credits",0)
	}
	else
	{
		kv.SetInt("Credits",credits + amount)
	}
}

TFSOLO.GetCredits <- function()
{
	return Solo.GetSaveData().GetInt("Credits");
}

TFSOLO.OnItemUnlock <- function(item, itemid)
{
	switch (item)
	{
		case "Solo BaseGameUnlock Weapons":
		{
			local kv = Solo.GetSaveData()
			local genericKV = kv.GetKey("Generic", true)
			genericKV.SetInt("BaseGameWeapons", 1)
			break;
		}
		case "Solo BaseGameUnlock Taunts":
		{
			local kv = Solo.GetSaveData()
			local genericKV = kv.GetKey("Generic", true)
			genericKV.SetInt("BaseGameTaunts", 1)
			break;
		}
		case "Solo BaseGameUnlock Cosmetics":
		{
			local kv = Solo.GetSaveData()
			local genericKV = kv.GetKey("Generic", true)
			genericKV.SetInt("BaseGameCosmetics", 1)
			break;
		}
		case "Solo BaseGameUnlock All":
		{
			local kv = Solo.GetSaveData()
			local genericKV = kv.GetKey("Generic", true)
			genericKV.SetInt("BaseGameWeapons", 1)
			genericKV.SetInt("BaseGameTaunts", 1)
			genericKV.SetInt("BaseGameCosmetics", 1)
			break;
		}
		default:
		{
			break;
		}
	}
	
	Solo.UnlockItem(item)
	if (Solo.ItemDefExists(item))
	{
		local kv = Solo.GetSaveData()
		local itemsKV = kv.GetKey("UnlockedItems", true)
		itemsKV.SetInt(item,1)
	}
}

TFSOLO.UnlockItem <- function(item)
{
	TFSOLO.OnItemUnlock(item, Solo.ItemDefID(item))
}

TFSOLO.UnlockItemID <- function(item)
{
	TFSOLO.OnItemUnlock(Solo.ItemDefName(item), item)
}

TFSOLO.UpdateMapVisits <- function(map)
{
	local kv = Solo.GetSaveData()
	local mapsKV = kv.GetKey("Maps", true)
	local mapKV = mapsKV.GetKey(map, true)
	local mapVisits = mapKV.GetInt("Visits")
	mapKV.SetInt("Visits", mapVisits + 1)
	
	Solo.WriteSaveData()
}

TFSOLO.UpdateBotStats <- function(params)
{
	local kv = Solo.GetSaveData()
	local botsKV = kv.GetKey("Bots", true)
	local botKV = botsKV.GetKey(params.preset, true)
	if (params.target == "BotStatPlayerKilledBy")
	{
		local stat = botKV.GetInt("KilledBy")
		botKV.SetInt("KilledBy", stat + 1)
	}
	else if (params.target == "BotStatPlayerKilled")
	{
		local stat = botKV.GetInt("Killed")
		botKV.SetInt("Killed", stat + 1)
	}
}

TFSOLO.SaveEventTag <- UniqueString()
getroottable()[TFSOLO.SaveEventTag] <- {
	OnGameEvent_solo_add_credits = function(params)
	{
		TFSOLO.AddCredits(params.amount)
	}
	
	OnGameEvent_solo_save_data = function(params)
	{
		Solo.WriteSaveData()
	}
	
	OnGameEvent_solo_unlock_item = function(params)
	{
		TFSOLO.OnItemUnlock(params.item, Solo.ItemDefID(params.item))
	}
	
	OnGameEvent_solo_unlock_itemid = function(params)
	{
		TFSOLO.OnItemUnlock(Solo.ItemDefName(params.item), params.item)
	}
	
	OnGameEvent_solo_armory_flag = function(params)
	{
		local kv = Solo.GetSaveData()
		local targetKey = kv.GetKey("Armory", true);
		if (params.setflag)
		{
			targetKey.SetInt(params.flag, params.count);
		}
		else
		{
			local target = targetKey.GetInt(params.flag);
			targetKey.SetInt(params.flag, target + params.count);
		}
	}
	
	OnGameEvent_solo_campaign_flag = function(params)
	{
		local kv = Solo.GetSaveData()
		local holderKey = kv.GetKey("Campaigns", true);
		local targetKey = holderKey.GetKey(params.campaign, true);
		if (params.setflag)
		{
			targetKey.SetInt(params.flag, params.count);
		}
		else
		{
			local target = targetKey.GetInt(params.flag);
			targetKey.SetInt(params.flag, target + params.count);
		}
	}
	
	OnGameEvent_solo_botpreset_flag = function(params)
	{
		local kv = Solo.GetSaveData()
		local holderKey = kv.GetKey("BotPresets", true);
		local targetKey = holderKey.GetKey(params.preset, true);
		if (params.setflag)
		{
			targetKey.SetInt(params.flag, params.count);
		}
		else
		{
			local target = targetKey.GetInt(params.flag);
			targetKey.SetInt(params.flag, target + params.count);
		}
	}
	
	OnGameEvent_solo_generic_flag = function(params)
	{
		local kv = Solo.GetSaveData()
		local targetKey = kv.GetKey("Generic", true);
		if (params.setflag)
		{
			targetKey.SetInt(params.flag, params.count);
		}
		else
		{
			local target = targetKey.GetInt(params.flag);
			targetKey.SetInt(params.flag, target + params.count);
		}
	}
	
	OnGameEvent_solo_client_armory_unlocked = function(params)
	{
		TFSOLO.OnItemUnlock(params.item, params.itemid)
		Solo.WriteSaveData()
	}
	
	OnScriptHook_solo_save_reset = function(params)
	{
		// Resets campaign save data
		StringToFile("merc/merc_headhunt/savedata.nut","printl(0)")
		StringToFile("merc/merc_bloodthirst/savedata.nut","printl(0)")
	}
	
	OnScriptHook_OnServerScriptTable = function(params)
	{
		if ("target" in params)
		{
			if (params.target == "SaveMapVisit" && "map" in params)
			{
				TFSOLO.UpdateMapVisits(params.map)
			}
			else if (params.target == "BotStatPlayerKilledBy" && "preset" in params)
			{
				TFSOLO.UpdateBotStats(params)
			}
			else if (params.target == "BotStatPlayerKilled" && "preset" in params)
			{
				TFSOLO.UpdateBotStats(params)
			}
		}
	}
	
	OnScriptHook_LevelDisconnect = function(params)
	{
		Solo.WriteSaveData()
	}
}
TFSOLO.SaveEventTable <- getroottable()[TFSOLO.SaveEventTag]
__CollectGameEventCallbacks(TFSOLO.SaveEventTable)

TFSOLO.InitSaveData()