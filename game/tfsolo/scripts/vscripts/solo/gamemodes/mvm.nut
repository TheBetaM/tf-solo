// Gamemode: Mann vs Machine
// Overrides gamemode with stock Mann vs Machine mode
// Requires:
// - 1 flag
// - 1 capture zone
Convars.SetValue("tf_gamemode_override", 1)

::TFSOLO.MVMLogic <- SpawnEntityFromTable("tf_logic_mann_vs_machine", {})
NetProps.SetPropBool(tf_gamerules, "m_bPlayingMannVsMachine", true)
NetProps.SetPropInt(tf_gamerules, "m_nGameType", 5)

TFSOLO.GamemodeEventTag <- UniqueString()
getroottable()[TFSOLO.GamemodeEventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[TFSOLO.GamemodeEventTag])