TFSOLO.PlayerData <- {
	
	// Dynamic
	TeamSelected = 0
	Map = ""
	PlayerClass = "any"
	
	// Persistent
	Seed = 0
	
}

TFSOLO.LoadPersistentData <- function()
{
	local kv = Solo.GetSaveData()
	local genericKV = kv.GetKey("Generic", true)
	TFSOLO.PlayerData.Seed = genericKV.GetInt("Solo.Seed")
}

TFSOLO.SavePersistentData <- function()
{
	local kv = Solo.GetSaveData()
	local genericKV = kv.GetKey("Generic", true)
	genericKV.SetInt("Solo.Seed", TFSOLO.PlayerData.Seed)
	
	Solo.WriteSaveData()
}