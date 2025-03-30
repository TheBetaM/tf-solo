TFSOLO.ValidMaps <- []

TFSOLO.InitMapLists <- function()
{
	TFSOLO.ValidMaps.clear()
	
	local bAllowWorkshop = false
	if (GetAppID() == 440)
	{
		bAllowWorkshop = true
	}
	
	local holderkey = TFSOLO.ConfigKV.FindKey("maps")
	local key = holderkey.GetFirstSubKey()
	while (key)
	{
		if (key.GetInt("enabled") == 1)
		{
			if (bAllowWorkshop || key.GetName().find("workshop/") == null)
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
	return null
}

TFSOLO.InitMapLists()
printl("[TFSOLO] Got " + TFSOLO.ValidMaps.len() + " valid maps for solo mode.")