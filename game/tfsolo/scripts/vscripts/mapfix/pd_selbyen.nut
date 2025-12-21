// PD Selbyen fix - Disable capture zone while seal is out of bounds
MapFixEventTag <- UniqueString()
getroottable()[MapFixEventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "path_track"))
		{
			if (ent.GetName() == "path7")
			{
				EntityOutputs.AddOutput(ent, "OnPass", "cap_area", "Disable", "", 0, -1)
			}
			else if (ent.GetName() == "path1")
			{
				EntityOutputs.AddOutput(ent, "OnTeleport", "cap_area", "Enable", "", 0, -1)
				EntityOutputs.AddOutput(ent, "OnPass", "cap_area", "Enable", "", 0, -1)
			}
		}
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[MapFixEventTag])