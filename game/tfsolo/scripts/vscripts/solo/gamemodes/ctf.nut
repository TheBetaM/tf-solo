// Gamemode: Capture the Flag
// Overrides gamemode with stock Capture the Flag mode
// Requires:
// - 2 capturable control points

Convars.SetValue("tf_gamemode_override", 4)

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