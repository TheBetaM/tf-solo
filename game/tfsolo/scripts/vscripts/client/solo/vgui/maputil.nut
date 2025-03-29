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

TFSOLO.InitMapLists()
printl("[TFSOLO] Got " + TFSOLO.ValidMaps.len() + " valid maps for solo mode.")