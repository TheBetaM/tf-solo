// PL Upward
::Merc <- {}
Merc.MissionID <- 20
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED, 0, "Headhunt_FriendlyHeavy"),
	Merc.Bot(TF_TEAM_RED, 1, "Smoker"),
	Merc.Bot(TF_TEAM_RED, 2, "Partizan"),
	Merc.Bot(TF_TEAM_RED, 1, "Sultan"),
	Merc.Bot(TF_TEAM_RED, 1, "Luchador"),
	Merc.Bot(TF_TEAM_RED, 2, "Sheriff"),
	Merc.Bot(TF_TEAM_RED, 2, "Surgeon"),
	Merc.Bot(TF_TEAM_RED, 2, "Marauder"),
	Merc.Bot(TF_TEAM_RED, 2, "Saharan"),
	
	Merc.Bot(TF_TEAM_BLUE, 1, "Squire"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Spartan"),
	Merc.Bot(TF_TEAM_BLUE, 1, "BlackKnight"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Techhand"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Hooded"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Poacher"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get kills with melee weapons"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 6

Merc.Bots[0].Attribs = [ ["move speed penalty", 0.001, -1] ]
Merc.Bots[0].BotAttribs = [ IGNORE_ENEMIES ]
Merc.Bots[0].Conds = [ TF_COND_FREEZE_INPUT ]

Merc.BeforeRoundStart <- function(params)
{
	if (Merc.RSVFlags[10] != 0)
	{
		Merc.Bots[0].Flags = 1
	}
}

Merc.AfterPlayerSpawn <- function(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (!IsPlayerABot(player)) return
	if (Merc.RSVFlags[10] == 0 && player.entindex() == Merc.Bots[0].Handle.entindex())
	{
		player.Teleport(true, Vector(340,828,143), true, QAngle(0, 45, 0), true, Vector(0, 0, 0))
		return
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || IsPlayerABot(aplayer)) return
		local name = GetPropString(player, "m_szNetname")
		if (Merc.RSVFlags[10] == 0 && player.entindex() == Merc.Bots[0].Handle.entindex())
		{
			Merc.RSVFlags[10] = 1
			Merc.Bots[0].Flags = 1
			Merc.Delay(1.0, function() {
				ToConsole("tf_bot_kick \""+name+"\"")
			} )
		}
		if ((params.damagebits & 128) != 0)
		{
			Merc.ExtraGet(1,1,2)
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

