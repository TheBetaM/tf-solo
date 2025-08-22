TFSOLO.PlayerData <- {
	
	// Dynamic mission settings
	TeamSelected = 0
	Map = ""
	PlayerClass = "any"
	PopFile = "solo_easy_1"
	CvarGamemodeOverride = 0
	GameMode = "standard"
	MapMode = "standard"
	BotMode = "standard"
	Medieval = 0
	MissionScript = ""
	
	// Persistent data
	Seed = 0
	
}

TFSOLO.ResetMissionSettings <- function()
{
	TFSOLO.PlayerData.TeamSelected = 0
	TFSOLO.PlayerData.Map = ""
	TFSOLO.PlayerData.PlayerClass = "any"
	TFSOLO.PlayerData.PopFile = "solo_easy_1"
	TFSOLO.PlayerData.CvarGamemodeOverride = 0
	TFSOLO.PlayerData.GameMode = "standard"
	TFSOLO.PlayerData.MapMode = "standard"
	TFSOLO.PlayerData.BotMode = "standard"
	TFSOLO.PlayerData.Medieval = 0
	TFSOLO.PlayerData.MissionScript = ""
}

TFSOLO.LoadPersistentData <- function()
{
	local kv = Solo.GetSaveData()
	local genericKV = kv.GetKey("Solo", true)
	TFSOLO.PlayerData.Seed = genericKV.GetInt("Seed")
}

TFSOLO.SavePersistentData <- function()
{
	local kv = Solo.GetSaveData()
	local genericKV = kv.GetKey("Solo", true)
	genericKV.SetInt("Seed", TFSOLO.PlayerData.Seed)
	
	Solo.WriteSaveData()
}