// Gamemode: Arena
// Overrides gamemode with stock Arena mode
// Requires:
// - 1 capturable control point
// TODO: Optional control point, inserting a round timer for stalemates?
Convars.SetValue("tf_gamemode_override", 1)
Convars.SetValue("tf_arena_override_cap_enable_time", 30)

// canaveral can't cap?

TFSOLO.GamemodeEventTag <- UniqueString()
getroottable()[TFSOLO.GamemodeEventTag] <- {
	OnScriptHook_team_round_activate = function(params)
	{
		local tf_gamerules = Entities.FindByClassname(null, "tf_gamerules")
		NetProps.SetPropInt(tf_gamerules, "m_nGameType", 4)
		local ent = null
		local PointEnts = []
		local CenterPoint = 0.0
		local CenterPointName = ""
		while (ent = Entities.FindByClassname(ent, "team_control_point"))
		{
			PointEnts.push([ent, NetProps.GetPropInt(ent,"m_iPointIndex")])
		}
		
		// TODO: Symmetrical map with no control points (CTF)
		// TODO: Symmetrical map with neutral CTF flag
		
		if (PointEnts.len() > 1)
		{
			PointEnts.sort(@(a,b) a[1] <=> b[1])
			CenterPoint = floor(PointEnts.len() / 2.0)
			CenterPoint = CenterPoint.tointeger()
			CenterPointName = PointEnts[CenterPoint][0].GetName()
			
			foreach (i, a in PointEnts)
			{
				if (i != CenterPoint)
				{
					a[0].AddEFlags(1)
					a[0].DisableDraw()
				}
			}
			
			ent = null
			while (ent = Entities.FindByClassname(ent, "trigger_capture_area"))
			{
				if (NetProps.GetPropString(ent, "m_iszCapPointName") != CenterPointName)
				{
					ent.Destroy()
				}
			}
			
			// Using forward spawns if available
			ent = null
			while (ent = Entities.FindByClassname(ent, "info_player_teamspawn"))
			{
				local point = NetProps.GetPropString(ent, "m_iszControlPointName")
				if (point == "")
				{
					
				}
				else if (point == CenterPointName)
				{
					//NetProps.SetPropString(ent, "m_iszControlPointName", "nonexistant")
					//ent.AcceptInput("RoundSpawn","",null,null)
					//ent.AcceptInput("Enable","",null,null)
					local spawn = SpawnEntityFromTable("info_player_teamspawn", {
						origin = ent.GetOrigin(),
						angles = ent.GetAbsAngles(),
						TeamNum = ent.GetTeam(),
					})
					ent.Destroy()
				}
				else
				{
					ent.Destroy()
				}
			}
			
			ent = null
			while (ent = Entities.FindByClassname(ent, "team_control_point_master"))
			{
				ent.AcceptInput("RoundSpawn","",null,null)
			}
			
			foreach (i, a in PointEnts)
			{
				if (i != CenterPoint)
				{
					a[0].RemoveEFlags(1)
				}
			}
		}
	
		local arenalogic = SpawnEntityFromTable("tf_logic_arena", {})
		NetProps.SetPropEntity(tf_gamerules, "m_hArenaEntity", arenalogic)
		NetProps.SetPropInt(tf_gamerules, "m_nGameType", 4)
		
		local ent = null
		while (ent = Entities.FindByClassname(ent, "func_regenerate"))
		{
			ent.SetAbsOrigin(Vector(0,0,-8000))
			ent.SetSize(Vector(-0.1,-0.1,-0.1),Vector(0.1,0.1,0.1))
		}
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[TFSOLO.GamemodeEventTag])

