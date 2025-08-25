TFSOLO.StartMission <- function()
{
	local data = TFSOLO.PlayerData
	local mapData = TFSOLO.GetMapEntry(data.Map)
	if (mapData == null)
	{
		printl("[TFSOLO] MAP ENTRY NOT FOUND IN CONFIG: " + data.Map)
	}
	
	ScriptTableToFile(TFSOLO.PlayerData, "mission.cfg")
	
	// Reset server enforced cvars
	SoloPanel.PrepareForLevelLoad()
	
	// Prepare server settings 
	// Preferably only ones that need to be setup before level load, the rest should be in server scripts
	if (data.TeamSelected == 1)
	{
		SendToConsole("mp_humans_must_join_team blue")
		SendToConsole("cl_loadingimage_override ../console/title_blue_widescreen")
	}
	else
	{
		SendToConsole("mp_humans_must_join_team red")
		if (RandomInt(0, 1) == 1)
		{
			SendToConsole("cl_loadingimage_override ../console/background01_widescreen")
		}
		else
		{
			SendToConsole("cl_loadingimage_override ../console/background02_widescreen")
		}
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
	
	local MapFile = data.Map
	if (MapFile.find("workshop_") != null)
	{
		MapFile = "workshop/" + data.Map.slice(9)
	}
	
	// GO!
	SendToConsole("disconnect;wait;wait;maxplayers 33;progress_enable;map " + MapFile)
	
	SoloPanel.ForceClose()
}

TFSOLO.StartMissionTest <- function(map)
{
	TFSOLO.ResetMissionSettings()
	if (map.find("workshop_") == null)
	{
		TFSOLO.PlayerData.Map = map
	}
	else
	{
		TFSOLO.PlayerData.Map = "workshop/" + map.slice(9)
	}
	TFSOLO.PlayerData.TeamSelected = 1
	TFSOLO.StartMission()
}