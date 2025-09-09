// PL Hoodoo
::Merc <- {}
Merc.MissionID <- 23
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 06"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 07"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 08"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 09"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 10"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 11"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 12"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 13"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 14"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 15"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 16"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 17"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 18"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 19"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Spy 20"),
]
Merc.ObjectiveText <- "Kill all cloaked spies across all 3 stages"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 20
Merc.ObjectiveExtraText <- "Collect every ammo pack"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1
Merc.ForceWinOnMainDone <- 1
Merc.AllowRecruits <- 0

Convars.SetValue("mp_disable_respawn_times", 1)

::M23SetupDone <- false
::M23MissionTime <- 200
::M23Time <- M23MissionTime
::M23KillBonusTime <- 20
::M23AmmoBonusTime <- 10
::M23EnemyCount_1 <- 6
::M23EnemyCount_2 <- 7
::M23EnemyCount_3 <- 7
::M23SpawnPoints <- []
::M23ClientCount <- MaxClients().tointeger()
if (M23ClientCount < 20)
{
	Merc.ObjectiveMainMax = M23ClientCount - 1
}

foreach (i, a in Merc.Bots)
{
	Merc.Bots[i].Attribs = [ ["cannot disguise", 1, -1], 
	["set cloak is movement based", 2, -1], ["mult cloak meter regen rate", 1000.0, -1] ]
	Merc.Bots[i].BotAttribs = [ IGNORE_ENEMIES | REMOVE_ON_DEATH ]
	M23SpawnPoints.push([0,0,0,0])
}

::M23DeletePieces <- [
	"round_1_door_block",
	"door_red_spawngate_3",
	"prop_red_spawngate_3",
	"door_blue_spawngate_3",
	"prop_blue_spawngate_3",
	"deadendsign_round_2",
	"deadendsign_round_3"
]

::M23_EnemySpots_1 <- [
	[4424,868,48, 0],
	[5900,1491,39, 0],
	[4114,1583,171, 0],
	[4730,572,236, 0],
	[3462,899,183, 0],
	[3454,1631,183, 0],
	[3106,946,39, 0],
	[3298,435,175, 0],
	[3026,898,183, 0],
	[2585,1023,171, 0],
	[2631,-132,295, 0],
	[3306,-238,175, 0],
	[2694,-391,184, 0],
	[2248,-539,167, 0],
	[2097,91,165, 0],
	[1401,-1368,423, 0],
	[3362,-593,293, 0],
	[3030,-1106,295, 0],
	[2113,-1459,174, 0],
	[2896,-1519,167, 0],
	[1724,-1950,167, 0],
]
::M23_EnemySpots_2 <- [
	[1308,-3648,183, 0],
	[2021,-3647,189, 0],
	[1054,-3003,167, 0],
	[386,-3514,295, 0],
	[-167,-3484,167, 0],
	[-255,-3207,295, 0],
	[389,-2029,167, 0],
	[-704,-2153,295, 0],
	[-363,-1704,295, 0],
	[630,-1395,173, 0],
	[-1251,-1285,231, 0],
	[-953,-1928,295, 0],
	[-1406,-1830,295, 0],
	[-1941,-1671,295, 0],
	[-1453,-2027,487, 0],
	[-1313,-1010,423, 0],
	[-2070,-103,423, 0],
	[-1464,-1316,230, 0],
	[-1831,-728,423, 0],
	[-2116,-1014,237, 0],
	[-3139,-405,237, 0],
]
::M23_EnemySpots_3 <- [
	[-4945,-760,167, 0],
	[-5317,-1275,166, 0],
	[-5852,-1390,175, 0],
	[-6196,-546,359, 0],
	[-5441,-616,391, 0],
	[-5986,-447,177, 0],
	[-6367,306,167, 0],
	[-5749,389,168, 0],
	[-6271,1148,167, 0],
	[-6086,519,359, 0],
	[-6846,517,167, 0],
	[-6629,-414,359, 0],
	[-6752,-872,171, 0],
	[-7525,-915,231, 0],
	[-7660,-1038,204, 0],
	[-8060,-429,179, 0],
	[-8514,-859,167, 0],
	[-8534,-130,167, 0],
	[-8184,-449,-25, 0],
	[-7234,-73,359, 0],
	[-7076,-595,168, 0],
]

::M23_GetPlacement <- function(list, maxpick)
{
	local places = [], full = []
	foreach (a in list) full.push(a)
	for (local i = 0; i < maxpick; i++)
	{
		local a = RandomInt(0, full.len() - 1)
		places.push(full[a])
		full.remove(a)
	}
	return places
}

::M23_TimerAdd <- function(add)
{
	local ent = null
	while(ent = Entities.FindByClassname(ent, "team_round_timer"))
	{
		M23Time = M23Time + add
		local newtime = M23Time
		EntFireByHandle(ent, "SetTime", newtime.tostring(), 0, null, null);
		SendGlobalGameEvent("teamplay_timer_time_added", {
			timer = ent.GetEntityIndex(),
			seconds_added = add,
		})
	}
}

function M23_Clock()
{
	M23Time = M23Time - 1
}

::M23_TimerEnd <- function()
{
	if (!M23SetupDone)
	{
		return
	}
	if (Merc.ObjectiveMainCount < Merc.ObjectiveMainMax)
	{
		Merc.ForceFail()
	}
}

::M23_AmmoPickup <- function(player, ent)
{
	if (IsPlayerABot(player)) return
	ent.Kill()
	Merc.ExtraGet(1,3,3)
	M23_TimerAdd(M23AmmoBonusTime)
}

::MercDeleteByName <- function(name)
{
	local ent = null
	while (ent = Entities.FindByName(ent, name))
	{
		ent.Kill()
	}
}

Merc.BeforeRoundStart <- function(params)
{
	Merc.ObjectiveExtraMax = 0
	M23SetupDone = false
	M23Time = M23MissionTime
	
	local ent = null
	while (ent = Entities.FindByClassname(ent, "item_ammopack_full"))
	{
		ent.ValidateScriptScope()
		ent.GetScriptScope()["M23_Pickup"] <- function(){
			M23_AmmoPickup(activator,caller)
		}
		ent.ConnectOutput("OnPlayerTouch","M23_Pickup")
		ent.SetTeam(Merc.ForcedTeam)
		Merc.ObjectiveExtraMax++
	}
	while (ent = Entities.FindByClassname(ent, "item_ammopack_medium"))
	{
		ent.ValidateScriptScope()
		ent.GetScriptScope()["M23_Pickup"] <- function(){
			M23_AmmoPickup(activator,caller)
		}
		ent.ConnectOutput("OnPlayerTouch","M23_Pickup")
		ent.SetTeam(Merc.ForcedTeam)
		Merc.ObjectiveExtraMax++
	}
	while (ent = Entities.FindByClassname(ent, "item_ammopack_small"))
	{
		ent.ValidateScriptScope()
		ent.GetScriptScope()["M23_Pickup"] <- function(){
			M23_AmmoPickup(activator,caller)
		}
		ent.ConnectOutput("OnPlayerTouch","M23_Pickup")
		ent.SetTeam(Merc.ForcedTeam)
		Merc.ObjectiveExtraMax++
	}
	while (ent = Entities.FindByClassname(ent, "team_round_timer"))
	{
		ent.ValidateScriptScope()
		ent.AcceptInput("SetSetupTime", "5", null, null)
		ent.ConnectOutput("On1SecRemain", "M23_TimerEnd")
	}
	
	foreach (a in M23DeletePieces)
	{
		MercDeleteByName(a)
	}
	while (ent = Entities.FindByClassname(ent, "func_respawnroomvisualizer"))
	{
		ent.Kill()
	}
	while (ent = Entities.FindByName(ent, "cap_area"))
	{
		ent.Kill()
	}
	
	local id = 0
	local places = M23_GetPlacement(M23_EnemySpots_1, M23EnemyCount_1)
	foreach (a in places)
	{
		M23SpawnPoints[id] = a
		id++
	}
	places = M23_GetPlacement(M23_EnemySpots_2, M23EnemyCount_2)
	foreach (a in places)
	{
		M23SpawnPoints[id] = a
		id++
	}
	places = M23_GetPlacement(M23_EnemySpots_3, M23EnemyCount_3)
	foreach (a in places)
	{
		M23SpawnPoints[id] = a
		id++
	}
}

Merc.AfterPlayerSpawn <- function(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() == Merc.ForcedTeam)
	{
		return
	}
	if (!IsPlayerABot(player)) return
	player.AddFlag(FL_FROZEN)
	local name = GetPropString(player, "m_szNetname")
	for (local i = 0; i < Merc.ObjectiveMainMax; i++)
	{
		if (Merc.Bots[i].Name == name || name == Merc.Bots[i].Name + "(1)" || name == Merc.Bots[i].Name + "(2)")
		{
			local p = M23SpawnPoints[i]
			player.Teleport(true, Vector(p[0],p[1],p[2] + 0), true, QAngle(0, p[3], 0), true, Vector(0, 0, 0))
			Merc.Delay(1.5, function() {
				Merc.Bots[i].UpdateResupply(player)
				player.AddCond(TF_COND_STEALTHED)
				player.AddCond(TF_COND_STEALTHED_USER_BUFF)
				player.RemoveCond(TF_COND_DISGUISING)
				player.RemoveCond(TF_COND_DISGUISED)
			} )
			return
		}
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		if (IsPlayerABot(aplayer)) return
		Merc.MainGet(1,3,3)
		M23_TimerAdd(M23KillBonusTime)
	}
	
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		M23SetupDone = true
		Merc.Delay(0.1, function() {
			local ent = null
			while (ent = Entities.FindByClassname(ent, "team_round_timer"))
			{
				local times = M23MissionTime.tostring()
				EntFireByHandle(ent, "SetTime", times, 0, null, null)
			}
		} )
		Merc.Timer(1.0, 0, M23_Clock)
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

