TFSOLO.InitSaveData <- function()
{
	local kv = Solo.GetSaveData()
	kv.SetInt("Credits",10000)
	local itemsKV = kv.GetKey("UnlockedItems", true)
	local armoryKV = kv.GetKey("Armory", true)
	local botpresetsKV = kv.GetKey("BotPresets", true)
	local campaignsKV = kv.GetKey("Campaigns", true)
	local mapsKV = kv.GetKey("Maps", true)
	local genericKV = kv.GetKey("Generic", true)
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

TFSOLO.UnlockItem <- function(item)
{
	Solo.UnlockItem(item)
	if (Solo.ItemDefExists(item))
	{
		local kv = Solo.GetSaveData()
		local itemsKV = kv.GetKey("UnlockedItems", true)
		itemsKV.SetInt(item,1)
	}
}

TFSOLO.UnlockItemID <- function(item)
{
	Solo.UnlockItemID(item)
	if (Solo.ItemDefIDExists(item))
	{
		local kv = Solo.GetSaveData()
		local itemsKV = kv.GetKey("UnlockedItems", true)
		itemsKV.SetInt(Solo.ItemDefName(item),1)
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
		TFSOLO.UnlockItem(params.item)
	}
	
	OnGameEvent_solo_unlock_itemid = function(params)
	{
		TFSOLO.UnlockItem(params.item)
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
}
TFSOLO.SaveEventTable <- getroottable()[TFSOLO.SaveEventTag]
__CollectGameEventCallbacks(TFSOLO.SaveEventTable)

TFSOLO.InitSaveData()