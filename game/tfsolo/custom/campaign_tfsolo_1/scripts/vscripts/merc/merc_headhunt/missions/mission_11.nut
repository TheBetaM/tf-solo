// PL Gold Rush
::Merc <- {}
Merc.MissionID <- 11
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 01"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 02"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 03"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 04"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 05"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 06"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 07"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 12"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 13"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 14"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 15"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 16"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 17"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 18"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 19"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Enemy 20"),
]
Merc.ObjectiveText <- "Kill all enemies across all 3 stages"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 20
Merc.ObjectiveExtraText <- "Collect every health kit"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1
Merc.ForceWinOnMainDone <- 1
Merc.AllowRecruits <- 0

Convars.SetValue("mp_disable_respawn_times", 1)

::M11SetupDone <- false
::M11MissionTime <- 200
::M11Time <- M11MissionTime
::M11KillBonusTime <- 20
::M11HealthBonusTime <- 10
::M11EnemyCount_1 <- 6
::M11EnemyCount_2 <- 7
::M11EnemyCount_3 <- 7
::M11SpawnPoints <- []
::M11ClientCount <- MaxClients().tointeger()
if (M11ClientCount < 20)
{
	Merc.ObjectiveMainMax = M11ClientCount - 1
}

foreach (i, a in Merc.Bots)
{
	Merc.Bots[i].Attribs = [ ["move speed penalty", 0.01, -1] ]
	Merc.Bots[i].BotAttribs = [ REMOVE_ON_DEATH ]
	M11SpawnPoints.push([0,0,0,0,TF_CLASS_SCOUT])
}

::M11DeletePieces <- [
	"stage3_gate_7",
	"stage3_gate_7_prop",
	"stage3_gate_8",
	"stage3_gate_8_prop",
	"stage3_gate_3_prop",
	"stage3_gate_4_prop",
	"stage3_gate_3",
	"stage3_gate_4",
	"stage3_gate_5_prop",
	"stage3_gate_6_prop",
	"stage3_gate_5",
	"stage3_gate_6",
	"cap_2_noforward_barriers",
	"cap_2_noforward_brushes",
	"cap2_noforward_brush",
	"cap2_signs_back_props",
	"stage2_gate_1_prop",
	"stage2_gate_2_prop",
	"stage2_gate_1",
	"stage2_gate_2",
	"stage2_gate_3_prop",
	"stage2_gate_4_prop",
	"stage2_gate_4",
	"stage2_gate_3",
	"stage2_gate_5_prop",
	"stage2_gate_6_prop",
	"stage2_gate_5",
	"stage2_gate_6",
	"stage2_midgate_1_prop",
	"stage2_midgate_2_prop",
	"stage2_midgate_1_door",
	"stage2_midgate_2_door",
	"stage1_midgate_1_prop",
	"stage1_midgate_2_prop",
	"stage1_midgate_1_door",
	"stage1_midgate_2_door",
	"stage1_midgate_3_prop",
	"stage1_midgate_4_prop",
	"stage1_midgate_3_door",
	"stage1_midgate_4_door",
]

::M11_EnemySpots_1 <- [
	[-2612,1761,-89, 270, TF_CLASS_SCOUT],
	[-2793,1060,41, 270, TF_CLASS_SOLDIER],
	[-2500,945,33, 270, TF_CLASS_SNIPER],
	[-2897,-110,39, 270, TF_CLASS_HEAVY],
	[-2892,-79,183, 0, TF_CLASS_DEMOMAN],
	[-2793,-1182,39, 270, TF_CLASS_PYRO],
	[-2605,-1826,39, 90, TF_CLASS_ENGINEER],
	[-3306,-1825,35, 180, TF_CLASS_HEAVY],
	[-3177,-1805,35, 180, TF_CLASS_SCOUT],
	[-3270,-2861,167, 90, TF_CLASS_SNIPER],
	[-2819,-1824,279, 180, TF_CLASS_DEMOMAN],
	[-2980,-2387,39, 180, TF_CLASS_SOLDIER],
	[-3685,-2675,39, 270, TF_CLASS_SOLDIER],
	[-2722,-437,39, 270, TF_CLASS_DEMOMAN],
	[-3080,620,-89, 270, TF_CLASS_ENGINEER],
]
::M11_EnemySpots_2 <- [
	[-4664,-2410,38, 90, TF_CLASS_HEAVY],
	[-6020,-2148,49, 180, TF_CLASS_SOLDIER],
	[-6180,-1690,167, 180, TF_CLASS_SNIPER],
	[-7456,-2100,167, 90, TF_CLASS_DEMOMAN],
	[-7335,-1394,39, 90, TF_CLASS_SCOUT],
	[-7108,-418,39, 180, TF_CLASS_PYRO],
	[-7589,-824,39, 180, TF_CLASS_PYRO],
	[-7168,-35,52, 90, TF_CLASS_ENGINEER],
	[-7550,108,48, 90, TF_CLASS_HEAVY],
	[-7380,600,167, 90, TF_CLASS_DEMOMAN],
	[-7260,1291,39, 0, TF_CLASS_SCOUT],
	[-8169,265,167, 0, TF_CLASS_SOLDIER],
	[-8226,1782,59, 0, TF_CLASS_SOLDIER],
	[-7038,966,167, 90, TF_CLASS_DEMOMAN],
	[-6545,-2126,167, 180, TF_CLASS_HEAVY],
]
::M11_EnemySpots_3 <- [
	[-7649,2395,165, 0, TF_CLASS_SOLDIER],
	[-7015,-2314,7, 0, TF_CLASS_SNIPER],
	[-5830,2047,215, 0, TF_CLASS_SCOUT],
	[-5218,2310,79, 0, TF_CLASS_DEMOMAN],
	[-4632,1878,167, 0, TF_CLASS_PYRO],
	[-4689,1099,295, 180, TF_CLASS_SOLDIER],
	[-5159,1249,168, 0, TF_CLASS_SCOUT],
	[-5873,1352,167, 270, TF_CLASS_SCOUT],
	[-6293,1330,295, 270, TF_CLASS_DEMOMAN],
	[-5958,774,295, 180, TF_CLASS_ENGINEER],
	[-6210,70,168, 0, TF_CLASS_SCOUT],
	[-6131,-434,119, 0, TF_CLASS_SNIPER],
	[-4768,-638,167, 0, TF_CLASS_SCOUT],
	[-4764,-109,167, 0, TF_CLASS_SCOUT],
	[-5400,-562,167, 0, TF_CLASS_MEDIC],
]

::M11_GetPlacement <- function(list, maxpick)
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

::M11_TimerAdd <- function(add)
{
	local ent = null
	while(ent = Entities.FindByClassname(ent, "team_round_timer"))
	{
		M11Time = M11Time + add
		local newtime = M11Time
		EntFireByHandle(ent, "SetTime", newtime.tostring(), 0, null, null);
		SendGlobalGameEvent("teamplay_timer_time_added", {
			timer = ent.GetEntityIndex(),
			seconds_added = add,
		})
	}
}

function M11_Clock()
{
	M11Time = M11Time - 1
}

::M11_TimerEnd <- function()
{
	if (!M11SetupDone)
	{
		return
	}
	if (Merc.ObjectiveMainCount < Merc.ObjectiveMainMax)
	{
		Merc.ForceFail()
	}
}

::M11_HealthPickup <- function(player, ent)
{
	if (IsPlayerABot(player)) return
	ent.Kill()
	Merc.ExtraGet(1,3,3)
	M11_TimerAdd(M11HealthBonusTime)
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
	M11SetupDone = false
	M11Time = M11MissionTime
	
	local ent = null
	while (ent = Entities.FindByClassname(ent, "item_healthkit_full"))
	{
		ent.ValidateScriptScope();
		ent.GetScriptScope()["M11_Pickup"] <- function(){
			M11_HealthPickup(activator,caller);
		}
		ent.ConnectOutput("OnPlayerTouch","M11_Pickup")
		ent.SetTeam(Merc.ForcedTeam)
		Merc.ObjectiveExtraMax++
	}
	while (ent = Entities.FindByClassname(ent, "item_healthkit_medium"))
	{
		ent.ValidateScriptScope()
		ent.GetScriptScope()["M11_Pickup"] <- function(){
			M11_HealthPickup(activator,caller)
		}
		ent.ConnectOutput("OnPlayerTouch","M11_Pickup")
		ent.SetTeam(Merc.ForcedTeam)
		Merc.ObjectiveExtraMax++
	}
	while (ent = Entities.FindByClassname(ent, "item_healthkit_small"))
	{
		ent.ValidateScriptScope()
		ent.GetScriptScope()["M11_Pickup"] <- function(){
			M11_HealthPickup(activator,caller);
		}
		ent.ConnectOutput("OnPlayerTouch","M11_Pickup")
		ent.SetTeam(Merc.ForcedTeam)
		Merc.ObjectiveExtraMax++
	}
	while (ent = Entities.FindByClassname(ent, "team_round_timer"))
	{
		ent.ValidateScriptScope()
		ent.AcceptInput("SetSetupTime", "1", null, null)
		ent.ConnectOutput("On1SecRemain", "M11_TimerEnd")
	}
	
	foreach (a in M11DeletePieces)
	{
		MercDeleteByName(a)
	}
	while (ent = Entities.FindByClassname(ent, "func_respawnroomvisualizer"))
	{
		ent.Kill()
	}
	
	local id = 0
	local places = M11_GetPlacement(M11_EnemySpots_1, M11EnemyCount_1)
	foreach (a in places)
	{
		M11SpawnPoints[id] = a
		id++
	}
	places = M11_GetPlacement(M11_EnemySpots_2, M11EnemyCount_2)
	foreach (a in places)
	{
		M11SpawnPoints[id] = a
		id++
	}
	places = M11_GetPlacement(M11_EnemySpots_3, M11EnemyCount_3)
	foreach (a in places)
	{
		M11SpawnPoints[id] = a
		id++
	}
	for (local i = 0; i < Merc.ObjectiveMainMax; i++)
	{
		local p = M11SpawnPoints[i]
		Merc.Bots[i].Class = p[4]
	}
}

Merc.AfterPlayerSpawn <- function(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() == Merc.ForcedTeam)
	{
		player.Teleport(true, Vector(-4464,-960,-60), true, QAngle(0, 0, 0), true, Vector(0, 0, 0))
		return
	}
	if (!IsPlayerABot(player)) return
	local name = GetPropString(player, "m_szNetname")
	for (local i = 0; i < Merc.ObjectiveMainMax; i++)
	{
		if (Merc.Bots[i].Name == name || name == Merc.Bots[i].Name + "(1)" || name == Merc.Bots[i].Name + "(2)")
		{
			local p = M11SpawnPoints[i]
			player.Teleport(true, Vector(p[0],p[1],p[2] + 0), true, QAngle(0, p[3], 0), true, Vector(0, 0, 0))
			Merc.Delay(0.5, function() {
				Merc.Bots[i].UpdateResupply(player)
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
		if (params.userid == 0 || !IsPlayerABot(player)) return
		Merc.MainGet(1,3,3)
		M11_TimerAdd(M11KillBonusTime)
	}
	
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		M11SetupDone = true
		Merc.Delay(0.1, function() {
			local ent = null
			while (ent = Entities.FindByClassname(ent, "team_round_timer"))
			{
				local times = M11MissionTime.tostring()
				EntFireByHandle(ent, "SetTime", times, 0, null, null)
			}
		})
		Merc.Timer(1.0, 0, M11_Clock)
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

