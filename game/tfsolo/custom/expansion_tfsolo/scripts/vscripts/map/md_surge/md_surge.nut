
::MD_MiniPickup <- function()
{
	AddMadDashMeter(0.1)
}

::MD_RespawnRED <- function()
{
	for (local i = 1; i <= MaxClients().tointeger(); i++)
	{
		local player = PlayerInstanceFromIndex(i)
		if (player && player.GetTeam() == 2)
		{
			player.ForceRegenerateAndRespawn()
		}
	}
}

CollectEventsInScope( {
	OnGameEvent_teamplay_round_active = function(params)
	{
		SendGlobalGameEvent("hide_annotation", {
			id = 11,
		})
		local goal = Entities.FindByName(null, "goal_prop")
		if (goal != null)
		{
			local goalpoint = goal.GetOrigin()
			SendGlobalGameEvent("show_annotation", {
				worldPosX = goalpoint.x,
				worldPosY = goalpoint.y,
				worldPosZ = goalpoint.z + 50,
				id = 11,
				text = "GOAL",
				lifetime = -1,
				show_distance = true,
				follow_entindex = goal.entindex(),
			})
		}
	}
	
	OnGameEvent_player_death= function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (player.GetTeam() == 2 && aplayer != null && aplayer.GetTeam() == 3)
		{
			// todo: drop a pickup instead?
			MD_MiniPickup()
		}
	}
	
	OnGameEvent_teamplay_round_win = function(_)
	{
		SendGlobalGameEvent("hide_annotation", {
			id = 11,
		})
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
} )