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
Music.PlayMainMenu <- function()
{
	Music.Play("*#ui/cyoa_musicteamfortress2.mp3")
}

TFSOLO.MusicEventTag <- UniqueString()
getroottable()[TFSOLO.MusicEventTag] <- {
	OnGameEvent_client_disconnect = function(params)
	{
		Music.Track = ""
	}
	
	OnScriptHook_LevelInitPreEntity = function(params)
	{
		Music.Track = ""
	}
}
TFSOLO.MusicEventTable <- getroottable()[TFSOLO.MusicEventTag]
__CollectGameEventCallbacks(TFSOLO.MusicEventTable)
