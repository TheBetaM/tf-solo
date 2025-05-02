TFSOLO.ValidMaps <- []
TFSOLO.DebugNoWorkshop <- 0

TFSOLO.InitMapLists <- function()
{
	TFSOLO.ValidMaps.clear()
	
	local bAllowWorkshop = false
	if (GetAppID() == 440 && ConnectedOnline())
	{
		bAllowWorkshop = true
	}
	if (TFSOLO.DebugNoWorkshop != 0)
	{
		bAllowWorkshop = false
	}
	
	local holderkey = TFSOLO.ConfigKV.FindKey("maps")
	local key = holderkey.GetFirstSubKey()
	while (key)
	{
		if (key.GetInt("disabled") == 0)
		{
			if (bAllowWorkshop || key.GetName().find("workshop_") == null)
			{
				TFSOLO.ValidMaps.push(key.GetName())
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