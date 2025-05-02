// Gamemode: King of the Hill
// Overrides gamemode with stock King of the Hill mode
// Requires:
// - 1 capturable control point
//Convars.SetValue("tf_gamemode_override", 1)

// doors are locked, both timers colored blue?, re-capping a point doesn't switch the active timer?

TFSOLO.GamemodeEventTag <- UniqueString()
getroottable()[TFSOLO.GamemodeEventTag] <- {
	OnScriptHook_team_round_activate = function(params)
	{
		local tf_gamerules = Entities.FindByClassname(null, "tf_gamerules")
		NetProps.SetPropInt(tf_gamerules, "m_nGameType", 2)
		
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
				else
				{
					local rules_name = tf_gamerules.GetName()
					if (rules_name == "")
					{
						rules_name = "tf_gamerules"
					}
					EntityOutputs.AddOutput(ent, "OnCapTeam1", rules_name, "SetRedKothClockActive", "", 0, 1)
					EntityOutputs.AddOutput(ent, "OnCapTeam2", rules_name, "SetBlueKothClockActive", "", 0, 1)
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
		else if (PointEnts.len() == 1)
		{
			local ent = null
			while (ent = Entities.FindByClassname(ent, "trigger_capture_area"))
			{
				local rules_name = tf_gamerules.GetName()
				if (rules_name == "")
				{
					rules_name = "tf_gamerules"
				}
				EntityOutputs.AddOutput(ent, "OnCapTeam1", rules_name, "SetRedKothClockActive", "", 0, 1)
				EntityOutputs.AddOutput(ent, "OnCapTeam2", rules_name, "SetBlueKothClockActive", "", 0, 1)
			}
		}
		
		NetProps.SetPropInt(tf_gamerules, "m_nGameType", 2)
		
		local kothlogic = SpawnEntityFromTable("tf_logic_koth", {})
		NetProps.SetPropBool(tf_gamerules, "m_bPlayingKoth", true)
		kothlogic.AcceptInput("RoundSpawn","",null,null)
		tf_gamerules.AcceptInput("SetRedTeamRespawnWaveTime","6",null,null)
		tf_gamerules.AcceptInput("SetBlueTeamRespawnWaveTime","6",null,null)
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "info_player_teamspawn"))
		{
			ent.AcceptInput("Enable","",null,null)
		}
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[TFSOLO.GamemodeEventTag])