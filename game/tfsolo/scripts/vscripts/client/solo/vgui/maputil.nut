TFSOLO.ValidMaps <- []
TFSOLO.DebugNoWorkshop <- 0

TFSOLO.InitMapLists <- function()
{
	TFSOLO.ValidMaps.clear()
	
	local WorkshopKV = FileToKeyValues("workshop_localcache.txt")
	
	local bAllowWorkshop = true
	if (GetAppID() == 440 && !ConnectedOnline())
	{
		bAllowWorkshop = false
	}
	if (TFSOLO.DebugNoWorkshop != 0 || WorkshopKV == null)
	{
		bAllowWorkshop = false
	}
	
	local holderkey = TFSOLO.ConfigKV.FindKey("maps")
	local key = holderkey.GetFirstSubKey()
	while (key)
	{
		if (key.GetInt("disabled") == 0)
		{
			local name = key.GetName()
			if (name.find("workshop_") == null)
			{
				TFSOLO.ValidMaps.push(name)
			}
			else if (bAllowWorkshop)
			{
				if (WorkshopKV.FindKey(name.slice(9)) != null)
				{
					TFSOLO.ValidMaps.push(name)
				}
			}
		}
		
		key = key.GetNextKey()
	}
	
}

TFSOLO.GetMapEntry <- function(map)
{
	local holderkey = TFSOLO.ConfigKV.FindKey("maps")
	if (holderkey.FindKey(map) != null)
	{
		return holderkey.FindKey(map)
	}
	printl("FAILED TO FIND MAP: " + map)
	return null
}

TFSOLO.InitMapLists()
printl("[TFSOLO] Got " + TFSOLO.ValidMaps.len() + " valid maps for solo mode.")