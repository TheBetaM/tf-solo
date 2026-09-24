// PLR Helltower - Spell island enter hint
MapFixEventTag <- UniqueString()
getroottable()[MapFixEventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		local trigger = SpawnEntityFromTable("trigger_bot_tag",
		{
			origin = Vector(7200,7577,200),
			angles = QAngle(0, 0, 0)
			spawnflags = 1,
			StartDisabled = true,
			add = 1,
			tags = "InPurg",
			targetname = "MapFixTrig",
			exitremove = true,
		})
		trigger.SetSize(Vector(-7000,-7000,-2000), Vector(7000,7000,2000))
		trigger.SetSolid(3)

		local ent = null
		while (ent = Entities.FindByClassname(ent, "logic_relay"))
		{
			if (ent.GetName() == "island_event_reset_relay")
			{
				EntityOutputs.AddOutput(ent, "OnTrigger", "MapFixTrig", "Disable", "", 0, -1)
			}
			else if (ent.GetName() == "island_event_relay")
			{
				EntityOutputs.AddOutput(ent, "OnTrigger", "MapFixTrig", "Enable", "", 0, -1)
			}
			else if (ent.GetName() == "clean_upper_world")
			{
                EntityOutputs.AddOutput(ent, "OnTrigger", "MapFixTrig", "Disable", "", 0, -1)
				EntityOutputs.AddOutput(ent, "OnTrigger", "MapFixTrig", "Kill", "", 0, -1)
			}
		}
		ent = null
		while (ent = Entities.FindByClassname(ent, "func_capturezone"))
		{
			NetProps.SetPropBool(ent, "m_bBotIgnore", true)
		}
	}

	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[MapFixEventTag])
