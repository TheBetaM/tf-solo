::tf_player_manager <- Entities.FindByClassname(null, "tf_player_manager")
::tf_gamerules <- Entities.FindByClassname(null, "tf_gamerules")
::MAX_PLAYERS <- MaxClients().tointeger()

::ToConsole <- function(t)
{
	if (IsDedicatedServer())
		SendToServerConsole(t)
	else
		SendToConsole(t)
}

::CTFPlayer.GetUserID <- function()
{
    return GetPropIntArray(tf_player_manager, "m_iUserID", this.entindex())
}
::CTFBot.GetUserID <- CTFPlayer.GetUserID

::GetClients <- function()
{
    local allPlayers = []
    for (local i = 1; i <= MAX_PLAYERS; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player)
            allPlayers.push(player)
    }
    return allPlayers
}
::GetHumans <- function()
{
    local allPlayers = []
    for (local i = 1; i <= MAX_PLAYERS; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player && !IsPlayerABot(player))
            allPlayers.push(player)
    }
    return allPlayers
}
