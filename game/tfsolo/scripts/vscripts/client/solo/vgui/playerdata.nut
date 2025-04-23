TFSOLO.PlayerData <- {
	
	// Dynamic
	TeamSelected = 0
	Map = ""
	PlayerClass = "any"
	PopFile = "solo_easy_1"
	CvarGamemodeOverride = 0
	
	// Persistent
	Seed = 0
	
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