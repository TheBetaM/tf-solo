// Gamemode: Player Destruction
// Overrides gamemode with stock Player Destruction mode
// Requires:
// - 1 capturable control point

Convars.SetValue("tf_gamemode_override", 5)

TFSOLO.GamemodeEventTag <- UniqueString()
getroottable()[TFSOLO.GamemodeEventTag] <- {
	OnScriptHook_team_round_activate = function(params)
	{
		
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[TFSOLO.GamemodeEventTag])