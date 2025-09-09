// PL Swiftwater
::Merc <- {}
Merc.MissionID <- 3
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Cart Pusher 01"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Cart Pusher 02"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Cart Pusher 03"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Cart Pusher 04"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Cart Pusher 05"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Cart Pusher 06"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Cart Pusher 07"),
	
	Merc.Bot(TF_TEAM_BLUE, 1, "Camo"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Diver"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Plaid"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Outback"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Fedora"),

	Merc.Bot(TF_TEAM_RED, 1, "Patriot"),
	Merc.Bot(TF_TEAM_RED, 1, "Golfer"),
	Merc.Bot(TF_TEAM_RED, 1, "Birdman"),
	Merc.Bot(TF_TEAM_RED, 1, "Vitals"),
]
Merc.ObjectiveText <- "Get kills before the cart reaches the end"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 15
Merc.ObjectiveExtraText <- "Block the cart before the third checkpoint"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 4
Merc.ForceWinOnMainDone <- 1

Merc.Bots[0].BotAttribs = [ IGNORE_ENEMIES ]
Merc.Bots[1].BotAttribs = [ IGNORE_ENEMIES ]
Merc.Bots[2].BotAttribs = [ IGNORE_ENEMIES ]
Merc.Bots[3].BotAttribs = [ IGNORE_ENEMIES ]
Merc.Bots[4].BotAttribs = [ IGNORE_ENEMIES ]
Merc.Bots[5].BotAttribs = [ IGNORE_ENEMIES ]
Merc.Bots[6].BotAttribs = [ IGNORE_ENEMIES ]

::M03_CheckCounter <- 0

::M03_RecedeFix <- function()
{
	local ent = null
	while (ent = Entities.FindByClassname(ent, "team_train_watcher"))
	{
		ent.AcceptInput("SetNumTrainCappers","1",ent,ent)
		ent.AcceptInput("SetNumTrainCappers","0",ent,ent)
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_round_selected = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "path_track"))
		{
			SetPropInt(ent, "m_spawnflags", 64)
		}
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "path_track"))
		{
			SetPropInt(ent, "m_spawnflags", 64)
		}
		while (ent = Entities.FindByClassname(ent, "team_train_watcher"))
		{
			ent.ValidateScriptScope()
			ent.ConnectOutput("OnTrainStartRecede", "M03_RecedeFix")
		}
		M03_CheckCounter <- 0
	}
	
	OnGameEvent_player_death = function(params)
	{
		if (Merc.RoundEnded) return
		local player = GetPlayerFromUserID(params.userid)
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (params.attacker == 0) return
		if (!IsPlayerABot(player)) return
		if (IsPlayerABot(aplayer)) return
		Merc.MainGet(1, 1, 1)
	}
	
	OnGameEvent_teamplay_point_captured = function(params)
	{
		M03_CheckCounter++
		if (M03_CheckCounter == 3 && !Merc.ExtraFailed && !Merc.ExtraDone)
		{
			Merc.ExtraFail()
			Merc.ChatPrint("Bonus objective failed! The cart passed 3 checkpoints.");
		}
	}
	
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		M03_RecedeFix()
	}
	
	OnGameEvent_teamplay_capture_blocked = function(params)
	{
		if (Merc.ExtraFailed) return
		if (params.blocker == 0) return
		local player = EntIndexToHScript(params.blocker)
		if (IsPlayerABot(player)) return
		Merc.ExtraGet(1, 1, 1)
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

