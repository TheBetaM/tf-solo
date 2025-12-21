// PD Watergate fix - Remove unused out of bounds capture zones
MapFixEventTag <- UniqueString()
getroottable()[MapFixEventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "func_capturezone"))
		{
			if (ent.GetName() != null && ent.GetName().len() < 1)
			{
				ent.Kill()
			}
		}
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[MapFixEventTag])