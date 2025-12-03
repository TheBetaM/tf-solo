TFSOLO.BotStatsEventTag <- UniqueString()
getroottable()[TFSOLO.BotStatsEventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (params.userid == 0) return
		if (!IsPlayerABot(player) && IsPlayerABot(aplayer))
		{
			local botpreset = aplayer.GetPreset()
			if (botpreset != null && botpreset.len() != 0)
			{
				local msg = {
					target = "BotStatPlayerKilledBy"
					preset = botpreset
				}
				BroadcastTable(msg)
			}
		}
		else if (IsPlayerABot(player) && !IsPlayerABot(aplayer))
		{
			local botpreset = player.GetPreset()
			if (botpreset != null && botpreset.len() != 0)
			{
				local msg = {
					target = "BotStatPlayerKilled"
					preset = botpreset
				}
				BroadcastTable(msg)
			}
		}
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
	}
}
__CollectGameEventCallbacks(getroottable()[TFSOLO.BotStatsEventTag])
