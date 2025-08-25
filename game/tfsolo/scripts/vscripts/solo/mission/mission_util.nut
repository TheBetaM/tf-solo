::MAX_PLAYERS <- MaxClients().tointeger()
::tf_player_manager <- Entities.FindByClassname(null, "tf_player_manager")
::tf_gamerules <- Entities.FindByClassname(null, "tf_gamerules")
if (tf_gamerules != null)
{
	tf_gamerules.ValidateScriptScope()
}

::TF_CLASS_NAMES <- [
    "civilian",
    "scout",
    "sniper",
    "soldier",
    "demoman",
    "medic",
    "heavyweapons",
    "pyro",
    "spy",
    "engineer",
    "civilian"
]

::TFBOT_EASY <- 0
::TFBOT_MEDIUM <- 1
::TFBOT_HARD <- 2
::TFBOT_EXPERT <- 3

::TFBOT_SKILLS <- [
	"easy",
	"medium",
	"hard",
	"expert"
]

TFSOLO.BotClassNames <- [
    "generic",
    "scout",
    "sniper",
    "soldier",
    "demoman",
    "medic",
    "heavyweapons",
    "pyro",
    "spy",
    "engineer",
    "civilian"
]

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

::IsValidClient <- function(player)
{
    try
    {
        return player && player.IsValid() && player.IsPlayer()
    }
    catch (e)
    {
        return false
    }
}

::IsValidPlayer <- function(player)
{
    try
    {
        return player && player.IsValid() && player.IsPlayer() && player.GetTeam() > 1;
    }
    catch(e)
    {
        return false
    }
}

::ToConsole <- function(t)
{
	if (IsDedicatedServer())
		SendToServerConsole(t)
	else
		SendToConsole(t)
}

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

foreach (k, v in ::NetProps.getclass())
    if (k != "IsValid")
        getroottable()[k] <- ::NetProps[k].bindenv(::NetProps);

foreach (_, cGroup in Constants)
    foreach (k, v in cGroup)
        getroottable()[k] <- v != null ? v : 0;