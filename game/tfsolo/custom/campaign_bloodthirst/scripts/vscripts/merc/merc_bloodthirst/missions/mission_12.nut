// KOTH Harvest Event
::Merc <- {}
Merc.MissionID <- 12
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_SCOUT
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"
ToConsole("tf_gamemode_override 1")

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "RED Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "RED Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_SCOUT, "RED Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "RED Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_SCOUT, "RED Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_SCOUT, "RED Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_SCOUT, "RED Bot 07"),
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_SCOUT, "RED Bot 08"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "BLU Bot 01"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "BLU Bot 02"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "BLU Bot 03"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "BLU Bot 04"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SCOUT, "BLU Bot 05"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SCOUT, "BLU Bot 06"),
]
Merc.ObjectiveText <- "Keep playing rounds until all enemies are demoted"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 8
Merc.ObjectiveExtraText <- "Get promoted to Spy"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1
//Merc.WaitTimeConvar <- 1
Merc.AllowRecruits <- 0
Merc.ForceWinOnMainDone <- 1
Merc.ResetMainOnRestart <- 0
Merc.ResetMainOnFail <- 0
Merc.ResetExtraOnRestart <- 0
Merc.ResetExtraOnFail <- 0

Convars.SetValue("tf_arena_override_cap_enable_time", 30)

::M04_SpellWeapons <- [
	"spellbook_athletic",
	"spellbook_bats",
	"spellbook_blastjump",
	"spellbook_bomb",
	"spellbook_book",
	"spellbook_boss",
	"spellbook_fireball",
	"spellbook_lightning",
	"spellbook_meteor",
	"spellbook_mirv",
	"spellbook_nospell",
	"spellbook_overheal",
	"spellbook_skeleton",
	"spellbook_stealth",
	"spellbook_teleport",
]

::M10_ClassOrder <- [
	TF_CLASS_SCOUT,
	TF_CLASS_SCOUT,
	TF_CLASS_SOLDIER,
	TF_CLASS_PYRO,
	TF_CLASS_DEMOMAN,
	TF_CLASS_HEAVY,
	TF_CLASS_ENGINEER,
	TF_CLASS_MEDIC,
	TF_CLASS_SNIPER,
	TF_CLASS_SPY,
]
::M10_ClassNames <- [
	"Scout",
	"Scout",
	"Soldier",
	"Pyro",
	"Demoman",
	"Heavy",
	"Engineer",
	"Medic",
	"Sniper",
	"Spy",
]
::M10_PlayerRank <- 1

::M10_ResetRanks <- function()
{
	Merc.ObjectiveMainCount = 0
	Merc.ObjectiveExtraCount = 0
	M10_PlayerRank = 1
	Merc.ForcedClass = M10_ClassOrder[M10_PlayerRank]
	ToConsole("mp_humans_must_join_class " + Merc.BotClassNames[Merc.ForcedClass])
	Merc.Bots[0].Lives = 5
	Merc.Bots[1].Lives = 7
	Merc.Bots[2].Lives = 8
	Merc.Bots[3].Lives = 9
	Merc.Bots[4].Lives = 6
	Merc.Bots[5].Lives = 4
	Merc.Bots[6].Lives = 3
	Merc.Bots[7].Lives = 1
	
	Merc.Bots[8].Lives = 3
	Merc.Bots[9].Lives = 7
	Merc.Bots[10].Lives = 2
	Merc.Bots[11].Lives = 4
	Merc.Bots[12].Lives = 5
	Merc.Bots[13].Lives = 8
	foreach (a in Merc.Bots) 
	{	
		a.Class = M10_ClassOrder[a.Lives]
		a.Flags = 0
	}
}
M10_ResetRanks()

Merc.BeforeRoundWin <- function(params)
{
	Merc.ChatPrint("Losing team is being demoted!")
	foreach (a in Merc.Bots) 
	{	
		if (a.Team != params.team)
		{
			if (a.Lives > 0)
			{
				a.Lives = a.Lives - 1
				if (a.Lives < 0) a.Lives = 0
			}
			if (a.Lives > 0)
			{
				a.Class = M10_ClassOrder[a.Lives]
			}
			else if (a.Flags == 0)
			{
				if (a.Team != Merc.ForcedTeam)
				{
					Merc.MainGet(1,1,1)
				}
				a.Flags = 1
				a.KickBot()
				Merc.ChatPrint(a.Name + " has been demoted completely!")
			}
		}
	}
	if (params.team != Merc.ForcedTeam)
	{
		if (M10_PlayerRank > 0)
		{
			M10_PlayerRank = M10_PlayerRank - 1
			if (M10_PlayerRank < 0) M10_PlayerRank = 0
		}
		if (M10_PlayerRank > 0)
		{
			Merc.ForcedClass = M10_ClassOrder[M10_PlayerRank]
			ToConsole("mp_humans_must_join_class " + Merc.BotClassNames[Merc.ForcedClass])
			Merc.ChatPrint("Demoted to " + M10_ClassNames[M10_PlayerRank] + " in the next round!");
		}
		else
		{
			Merc.ResetMainOnRestart = 1
			Merc.ResetMainOnFail = 1
			Merc.ResetExtraOnRestart = 1
			Merc.ResetExtraOnFail = 1
			Merc.ChatPrint("Demoted completely!")
		}
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_restart_round = function(params)
	{
		M10_ResetRanks()
		Merc.ResetMainOnRestart = 0
		Merc.ResetMainOnFail = 0
		Merc.ResetExtraOnRestart = 0
		Merc.ResetExtraOnFail = 0
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		local arenalogic = SpawnEntityFromTable("tf_logic_arena", {})
		SetPropEntity(tf_gamerules, "m_hArenaEntity", arenalogic)
		SetPropInt(tf_gamerules, "m_nGameType", 4)
		
		local ent = null
		while (ent = Entities.FindByClassname(ent, "func_regenerate"))
		{
			ent.SetAbsOrigin(Vector(0,0,-8000))
			ent.SetSize(Vector(-0.1,-0.1,-0.1),Vector(0.1,0.1,0.1))
		}
		
		
		if (Merc.ResetMainOnRestart == 1)
		{
			M10_ResetRanks()
		}
		Merc.ResetMainOnRestart = 0
		Merc.ResetMainOnFail = 0
		Merc.ResetExtraOnRestart = 0
		Merc.ResetExtraOnFail = 0

		Merc.Delay(0.5, function() { 
			foreach (a in GetClients()) 
			{	
				if (!IsPlayerABot(a))
				{
					local ent = null
					while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
					{
						if (ent.GetOwner() == a)
						{
							SetPropInt(ent, "m_iSelectedSpellIndex", 4)
							SetPropInt(ent, "m_iSpellCharges", 3)
						}
					}
				}
			}
		} )
	}
	
	OnGameEvent_arena_round_start = function(params)
	{
		local ent = Entities.FindByClassname(null, "tf_logic_holiday")
		SetPropInt(ent,"m_nHolidayType",2)
		ent = Entities.FindByClassname(null, "tf_gamerules")
		SetPropInt(ent, "m_nMapHolidayType", 2)
	}
	
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || params.death_flags & 32) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || aplayer == player) return
		
		if (IsPlayerABot(player))
		{
			foreach (a in Merc.Bots) 
			{	
				if (a.Handle == player)
				{
					if (a.Lives > 1)
					{
						a.Lives--
						a.Class = M10_ClassOrder[a.Lives]
					}
					else if (a.Flags == 0)
					{
						if (player.GetTeam() != Merc.ForcedTeam)
						{
							Merc.MainGet(1,1,1)
						}
						a.Flags = 1
						a.KickBot()
						Merc.ChatPrint(a.Name + " has been demoted completely!")
					}
					break;
				}
			}
		}
		else
		{
			if (M10_PlayerRank > 1)
			{
				M10_PlayerRank--
				Merc.ForcedClass = M10_ClassOrder[M10_PlayerRank]
				ToConsole("mp_humans_must_join_class " + Merc.BotClassNames[Merc.ForcedClass])
				Merc.ChatPrint("Demoted to " + M10_ClassNames[M10_PlayerRank] + " in the next round!")
			}
			else
			{
				Merc.ResetMainOnRestart = 1
				Merc.ResetMainOnFail = 1
				Merc.ResetExtraOnRestart = 1
				Merc.ResetExtraOnFail = 1
				Merc.ForceFail()
				Merc.ChatPrint("Demoted completely!")
			}
		}
		
		if (IsPlayerABot(aplayer))
		{
			foreach (a in Merc.Bots) 
			{	
				if (a.Handle == aplayer)
				{
					if (a.Lives < M10_ClassOrder.len() - 1)
					{
						a.Lives++
						a.Class = M10_ClassOrder[a.Lives]
					}
					break;
				}
			}
		}
		else
		{
			if (M10_PlayerRank < M10_ClassOrder.len() - 1)
			{
				M10_PlayerRank++
				Merc.ForcedClass = M10_ClassOrder[M10_PlayerRank]
				ToConsole("mp_humans_must_join_class " + Merc.BotClassNames[Merc.ForcedClass])
				Merc.ChatPrint("Promoted to " + M10_ClassNames[M10_PlayerRank] + " in the next round!")
				if (M10_PlayerRank >= M10_ClassOrder.len() - 1)
				{
					Merc.ExtraGet(1,1,1)
				}
			}
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

