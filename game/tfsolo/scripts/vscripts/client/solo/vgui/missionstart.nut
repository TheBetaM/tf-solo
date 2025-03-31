TFSOLO.StartMission <- function()
{
	local data = TFSOLO.PlayerData
	local mapData = TFSOLO.GetMapEntry(data.Map)
	if (mapData == null)
	{
		printl("[TFSOLO] MAP ENTRY NOT FOUND IN CONFIG: " + data.Map)
	}
	
	// Reset server enforced cvars
	SoloPanel.PrepareForLevelLoad()
	
	// Prepare server settings 
	// Preferably only ones that need to be setup before level load, the rest should be in server scripts
	if (data.TeamSelected == 1)
	{
		SendToConsole("mp_humans_must_join_team blue")
	}
	else
	{
		SendToConsole("mp_humans_must_join_team red")
	}
	SendToConsole("mp_humans_must_join_class " + data.PlayerClass)
	SendToConsole("nav_generate_auto 1")
	if (mapData != null)
	{
		if (mapData.GetInt("navViewDistance") != 0)
		{
			SendToConsole("nav_generate_auto_view_distance " + mapData.GetInt("navViewDistance"))
		}
		else
		{
			SendToConsole("nav_generate_auto_view_distance 2500")
		}
	}
	SendToConsole("tf_gamemode_override " + data.CvarGamemodeOverride)
	SendToConsole("tf_mvm_popfile_requested " + data.PopFile)
	
	// GO!
	SendToConsole("disconnect;wait;wait;maxplayers 32;progress_enable;map " + data.Map)
	
	SoloPanel.ForceClose()
}