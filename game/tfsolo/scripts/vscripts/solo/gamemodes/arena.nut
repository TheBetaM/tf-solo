// Gamemode: Arena
// Overrides gamemode with stock Arena mode
// Requires:
// - 1 capturable control point
// TODO: Optional control point, inserting a round timer for stalemates?
// TODO: Symmetrical map with no control points (CTF) <- spawn a control point?
// TODO: Symmetrical map with neutral CTF flag <- replace flag with a control point?

Convars.SetValue("tf_gamemode_override", 2)
Convars.SetValue("tf_arena_override_cap_enable_time", 30)

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

