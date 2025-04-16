::TF_TEAM_UNASSIGNED <- 0
::TF_TEAM_SPECTATOR <- 1
::TF_CLASS_HEAVY <- 6
::MAX_PLAYERS <- MaxClients().tointeger()
::tf_player_manager <- Entities.FindByClassname(null, "tf_player_manager")
::tf_gamerules <- Entities.FindByClassname(null, "tf_gamerules")
tf_gamerules.ValidateScriptScope()

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

::SND_NOFLAGS <- 0
::SND_CHANGE_VOL <- 1
::SND_CHANGE_PITCH <- 2
::SND_STOP <- 4
::SND_SPAWNING <- 8
::SND_DELAY <- 16
::SND_STOP_LOOPING <- 32
::SND_SPEAKER <- 64
::SND_SHOULDPAUSE <- 128
::SND_IGNORE_PHONEMES <- 256
::SND_IGNORE_NAME <- 512
::SND_DO_NOT_OVERWRITE_EXISTING_ON_CHANNEL <- 1024

foreach (k, v in ::NetProps.getclass())
    if (k != "IsValid")
        getroottable()[k] <- ::NetProps[k].bindenv(::NetProps);

foreach (_, cGroup in Constants)
    foreach (k, v in cGroup)
        getroottable()[k] <- v != null ? v : 0;

::safeget <- function(table, field, defValue)
{
    return table && field in table ? table[field] : defValue;
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

::ArrayContains <- function(a, e)
{
	foreach (i,v in a)
	{
		if (v == e) return i
	}
	return null
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

Merc.Delays <- {}
Merc.Timers <- []

// Wait for time before executing
Merc.Delay <- function(time, func, ...)
{
	local scope = func.getinfos().parameters.len() - 1 < vargv.len() ? vargv.pop() : null;

    if (scope == null)
	{
        scope = this
	}
    else if (typeof(scope) == "instance" && scope.IsValid())
    {
        scope.ValidateScriptScope()
        scope = scope.GetScriptScope()
    }

    local tmpEnt = Entities.CreateByClassname("point_template")
    local name = tmpEnt.GetScriptId()
    local code = format("Merc.Delays.%s[0](\"%s\")", name, name)
    Merc.Delays[name] <- [function(name)
    {
		if (!(name in Merc.Delays))
			return
        local entry = delete Merc.Delays[name]
        local scope = entry[3]
        if (!scope || ("self" in scope && (!scope.self || !scope.self.IsValid())))
            return
        entry[1].acall([scope].extend(entry[2]))
    }, func, vargv, scope.weakref()]
    SetPropBool(tmpEnt, "m_bForcePurgeFixedupStrings", true)
    SetPropString(tmpEnt, "m_iName", code)
    EntFireByHandle(Entities.FindByClassname(null, "info_player_teamspawn"), "RunScriptCode", code, time, null, null)
    EntFireByHandle(tmpEnt, "Kill", null, time, null, null)
}

::MercTimerThink <- function()
{
	local time = Time()
    for (local i = Merc.Timers.len() - 1; i >= 0; i --)
    {
        local entry = Merc.Timers[i]
        local scope = entry[2]
        if (!scope || ("self" in scope && (!scope.self || !scope.self.IsValid())))
            Merc.Timers.remove(i)
        else if (time - entry[4] >= entry[5])
        {
            entry[5] += entry[4]
            try { entry[1].acall([scope].extend(entry[3])); } catch (e) { }
        }
    }
	return -1
}

if (Entities.FindByName(null, "MercTimerThinker") != null)
{
	Merc.TimerThinker <- Entities.FindByName(null, "MercTimerThinker")
}
else
{
	Merc.TimerThinker <- SpawnEntityFromTable("commentary_auto", { targetname = "MercTimerThinker" })
}
Merc.TimerThinker.ValidateScriptScope()
AddThinkToEnt(Merc.TimerThinker,"MercTimerThink")

// Execute every time interval
Merc.Timer <- function(interval, order, ...)
{
	local timerFunc = vargv.remove(0)
    local scope = timerFunc.getinfos().parameters.len() - 1 < vargv.len() ? vargv.pop() : null;

    if (scope == null)
        scope = this
    else if (typeof(scope) == "instance" && scope.IsValid())
    {
        scope.ValidateScriptScope()
        scope = scope.GetScriptScope()
    }

    if (interval < 0)
        interval = 0
    local timerEntry = [order, timerFunc, scope.weakref(), vargv, interval, Time()]

    local size = Merc.Timers.len()
    local i = 0;
    for (; i < size; i++)
        if (Merc.Timers[i][0] <= order)
            break;
    Merc.Timers.insert(i, timerEntry)

    return timerEntry
}