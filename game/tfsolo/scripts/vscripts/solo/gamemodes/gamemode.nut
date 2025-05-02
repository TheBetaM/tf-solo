if (TFSOLO.Settings.gamemode == "arena")
{
	IncludeScript("solo/gamemodes/arena.nut")
}
else if (TFSOLO.Settings.gamemode == "koth")
{
	IncludeScript("solo/gamemodes/koth.nut")
}
else if (TFSOLO.Settings.gamemode == "mvm")
{
	IncludeScript("solo/gamemodes/mvm.nut")
}

if (TFSOLO.Settings.Medieval == 1)
{
	NetProps.SetPropBool(tf_gamerules, "m_bPlayingMedieval", true)
}
else if (TFSOLO.Settings.Medieval == 2)
{
	NetProps.SetPropBool(tf_gamerules, "m_bPlayingMedieval", false)
}