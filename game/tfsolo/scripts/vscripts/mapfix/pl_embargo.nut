// PL Embargo fix - Update nav mesh with payload progress
MapFixEventTag <- UniqueString()
getroottable()[MapFixEventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "path_track"))
		{
			if (ent.GetName() == "sspl_path_cp_one3") // point A
			{
				EntityOutputs.AddOutput(ent, "OnPass", "tf_gamerules", "RunScriptCode", "NavMesh.RecomputeBlockersWithCapture(5, 0)", 0, -1)
			}
			else if (ent.GetName() == "sspl_path_B_21") // tanks exit interior
			{
				EntityOutputs.AddOutput(ent, "OnPass", "tf_gamerules", "RunScriptCode", "NavMesh.RecomputeBlockersWithCapture(5, 1)", 0, -1)
			}
			else if (ent.GetName() == "sspl_path_B_30") // point B
			{
				EntityOutputs.AddOutput(ent, "OnPass", "tf_gamerules", "RunScriptCode", "NavMesh.RecomputeBlockersWithCapture(5, 2)", 0, -1)
			}
			else if (ent.GetName() == "sspl_path_C_17") // before door
			{
				EntityOutputs.AddOutput(ent, "OnPass", "tf_gamerules", "RunScriptCode", "NavMesh.RecomputeBlockersWithCapture(5, 4)", 0, -1)
			}
			else if (ent.GetName() == "sspl_path_C_9") // after door
			{
				EntityOutputs.AddOutput(ent, "OnPass", "tf_gamerules", "RunScriptCode", "NavMesh.RecomputeBlockersWithCapture(5, 2)", 0, -1)
			}
			else if (ent.GetName() == "sspl_path_cp_three3") // point C
			{
				EntityOutputs.AddOutput(ent, "OnPass", "tf_gamerules", "RunScriptCode", "NavMesh.RecomputeBlockersWithCapture(5, 3)", 0, -1)
			}
		}
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[MapFixEventTag])

// Please let this be the last time this function gets overriden...
::ClearGameEventCallbacks <- function()
{
	local root = getroottable()
	foreach (callbacks in [GameEventCallbacks, ScriptEventCallbacks, ScriptHookCallbacks])
	{
		foreach (event_name, scopes in callbacks)
		{
			for (local i = scopes.len() - 1; i >= 0; i--)
			{
				local scope = scopes[i]
				if (scope == null || scope == root || "__vrefs" in scope)
					scopes.remove(i)
			}
		}
	}
}
