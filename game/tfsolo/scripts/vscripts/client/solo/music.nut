Music <- {}
Music.Track <- ""

Music.Play <- function(track)
{
	if (Music.Track != track)
	{
		Music.Track = track
		EmitMusic(track)
	}
}
Music.Stop <- function()
{
	if (Music.Track != "")
	{
		StopMusic(Music.Track)
		Music.Track = ""
	}
}

TFSOLO.MusicEventTag <- UniqueString()
getroottable()[TFSOLO.MusicEventTag] <- {
	OnGameEvent_mainmenu_stabilized = function(params)
	{
		Music.Play("*#ui/gamestartup1.mp3")
	}
	
	OnScriptHook_LevelInitPreEntity = function(params)
	{
		Music.Track = ""
	}
	
	OnScriptHook_LevelDisconnect = function(params)
	{
		Music.Play("*#ui/gamestartup1.mp3")
	}
}
TFSOLO.MusicEventTable <- getroottable()[TFSOLO.MusicEventTag]
__CollectGameEventCallbacks(TFSOLO.MusicEventTable)
