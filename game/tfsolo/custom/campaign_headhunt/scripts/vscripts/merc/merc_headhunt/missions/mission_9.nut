// VSH Distillery
::Merc <- {}
Merc.MissionID <- 9
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_HEAVY
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Innocent Bystander"),
]
Merc.ObjectiveText <- "Collect enough ducks before time runs out"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveExtraText <- "Destroy all buildings"
Merc.ObjectiveExtraCount <- 0
Merc.CustomSpawn <- 1
Merc.AllowCustomWeapons <- 0
Merc.AllowRecruits <- 0

PrecacheSound("ui/quest_status_tick_novice.wav")

Merc.Bots[0].BotAttribs = [ IGNORE_ENEMIES ]

::M09SetupDone <- false
::M09DuckCount <- 70
::M09BuildCount <- 20
::M09DuckScore <- 5
::M09MissionTime <- 211
Merc.ObjectiveMainMax <- 40
Merc.ObjectiveExtraMax <- M09BuildCount
::M09Time <- M09MissionTime
::M09DuckSpots <- [
	[1365,-169,326],
	[1365,-318,203],
	[1068,-45,117],
	[1333,226,181],
	[1397,409,136],
	[1009,897,149],
	[1599,32,333],
	[1116,551,112],
	[961,144,202],
	[1964,721,151],
	[2287,978,133],
	[1553,795,116],
	[1353,1435,123],
	[1338,1926,123],
	[1607,2115,123],
	[182,1541,161],
	[191,2098,114],
	[1027,1805,123],
	[981,-758,241],
	[1556,-520,95],
	[2000,-174,115],
	[2135,385,111],
	[2365,-372,245],
	[3072,52,250],
	[2435,498,-13],
	[2784,330,-4],
	[2765,1280,-291],
	[1771,2079,-134],
	[2245,1491,-319],
	[2931,872,-190],
	[2030,1961,-220],
	[705,1377,-199],
	[2244,960,506],
	[2176,818,392],
	[447,1804,-166],
	[326,2011,-73],
	[1576,316,336],
	[3073,402,243],
	[2243,-1781,275],
	[2282,-1292,215],
	[1794,-916,221],
	[1665,-1474,221],
	[1903,-1247,104],
	[1272,-821,115],
	[1076,-1254,116],
	[655,-1070,108],
	[1541,-1807,319],
	[1016,1120,408],
	[449,547,107],
	[437,808,119],
	[225,1066,116],
	[-34,496,128],
	[213,-49,128],
	[-414,-65,131],
	[-515,-479,160],
	[-57,-708,121],
	[459,-673,229],
	[418,-459,312],
	[747,-642,410],
	[1018,-47,472],
	[460,-47,472],
	[447,601,481],
	[2294,-365,482],
	[493,-241,729],
	[506,133,729],
	[-599,-1123,144],
	[-318,857,256],
	[-145,1039,408],
	[-567,1133,469],
	[-754,623,675],
	[-1207,620,677],
	[-449,419,481],
	[-1078,641,471],
	[-800,281,366],
	[-1063,287,214],
	[-859,19,207],
	[-701,-522,216],
	[-1173,-941,208],
	[-1090,-710,521],
	[-679,-696,521],
	[-918,-258,521],
	[-615,-1268,348],
	[-282,-1486,259],
	[9,-1703,315],
	[394,-1453,255],
	[-469,-1952,245],
	[91,-2032,482],
	[679,-2316,632],
	[-154,-2200,590],
	[-49,-2035,880],
	[744,-1859,884],
	[694,-2108,857],
	[848,-2113,475],
	[788,-2347,475],
	[788,-1880,575],
	[2184,-2201,572],
	[1904,-1915,459],
	[1943,-2091,120],
	[1454,-2125,304],
	[1826,-2487,435],
	[1964,-2344,274],
	[2302,-1967,242],
	[1655,-1896,186],
	[894,-2450,571],
	[2329,-2471,211],
	[932,-1788,805],
	[998,-1461,600],
	[1318,-1510,600],
	[1522,-1806,480],
	[2284,-1806,480],
	[1359,-1312,323],
	[1183,-1662,323],
	[628,-1747,331],
	[-1257,85,455],
	[1106,-2040,1110],
	[1683,-2040,1110],
	[2114,-2040,1110],
	[1225,-2463,1110],
	[1367,-2207,1110],
	[2640,-1284,1022],
	[2640,-915,1022],
	[2640,-1639,1022],
	[2826,-1064,1022],
	[2826,-1545,1022],
	[2346,-1801,1130],
	[1459,-1814,1138],
	[858,-1816,1257],
	[2470,55,963],
	[3055,51,956],
	[1490,1641,-357],
	
	[775,-51,974],
	[1955,-1479,975],
	[1635,807,530],
	[-104,-616,601],
	[-395,-2024,889],
	[464,1768,178],
	[712,-1439,823],
	[1434,-904,450],
	[-965,632,928],
	[487,1324,516],
]
::M09BuildSpots <- [
	[1381,162,317, 0, 0],
	[594,-762,397, 0, 1],
	[930,1290,397, 0, 1],
	[327,-52,461, 0, 1],
	[2205,-649,237, 180, 0],
	[2889,76,-19, 90, 2],
	[2055,1793,-211, 270, 1],
	[428,1628,-163, 0, 2],
	[777,1007,109, 270, 1],
	[2172,-2367,109, 90, 2],
	[-147,-1883,461, 0, 1],
	[-619,-2071,237, 45, 1],
	[-756,-938,205, 0, 2],
	[2259,-2130,1093, 90, 1],
	[2838,-1291,997, 180, 0],
	
	[1786,-353,301, 0, 4],
	[1359,-55,301, 0, 4],
	[995,-53,93, 0, 4],
	[1876,-192,93, 0, 4],
	[1890,-921,93, 0, 4],
	[2344,951,125, 0, 4],
	[2279,718,125, 0, 4],
	[1218,1005,93, 0, 4],
	[1929,1042,93, 0, 4],
	[940,-1316,93, 0, 4],
	[1214,-1316,93, 0, 4],
	[843,-48,445, 0, 4],
	[894,-462,381, 0, 4],
	[376,901,445, 0, 4],
	[1169,970,381, 0, 4],
	[951,-1482,301, 0, 4],
	[698,-1245,221, 0, 4],
	[-221,-1231,222, 0, 4],
	[374,-2218,445, 0, 4],
	[-161,-2326,594, 0, 4],
	[2203,-1899,445, 0, 4],
	[1331,-2075,269, 0, 4],
	[2332,-1076,93, 0, 4],
	[-1153,-106,189, 0, 4],
	[-683,1162,445, 0, 4],
	[304,-47,95, 0, 4],
	[1491,-2482,1077, 0, 4],
	[962,-2475,1077, 0, 4],
	[2839,-832,981, 0, 4],
	[2839,-1748,981, 0, 4],
	[2331,650,381, 0, 4],
	[2305,2073,-227, 0, 4],
	[394,1244,-237, 0, 4],
	[178,1728,93, 0, 4],
	[-364,662,127, 0, 4],
]
::M09DuckProp <- "models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl"
PrecacheModel(M09DuckProp)
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })

::M09_TimerEnd <- function()
{
	if (!M09SetupDone) return
	if (Merc.ObjectiveMainCount < Merc.ObjectiveMainMax)
	{
		Merc.ForceFail()
	}
	else
	{
		Merc.ForceWin()
	}
}

function MercSpawnBuild(x,y,z,rot,lev)
{
	local isMini = false
	if (lev == 3)
	{
		isMini = true
		lev = 0
	}
	else if (lev == 4)
	{
		local tempEnt = SpawnEntityFromTable("obj_dispenser", {
			origin       = Vector(x,y,z - 30.0),
			angles       = QAngle(0.0, rot, 0.0),
			targetname = "worlddispenser",
			TeamNum = TF_TEAM_BLUE,
			defaultupgrade = 2,
			SolidToPlayer = 1,
		})
		tempEnt.AcceptInput("SetHealth","1",tempEnt,tempEnt)
		return;
	}
	local tempEnt = SpawnEntityFromTable("obj_sentrygun", {
		origin       = Vector(x,y,z - 45.0),
		angles       = QAngle(0.0, rot, 0.0),
		targetname = "worldsentry",
		TeamNum = TF_TEAM_BLUE,
		defaultupgrade = lev,
		SolidToPlayer = 1,
	})
	if (isMini)
	{
		SetPropBool(tempEnt, "m_bMiniBuilding", true);
		tempEnt.SetSkin(tempEnt.GetSkin() + 2);
		tempEnt.SetModelScale(0.75, 0)
	}
	tempEnt.AcceptInput("SetHealth","1",tempEnt,tempEnt)
}

::M09_GetPlacement <- function(list, maxpick)
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
::M09_TimerAdd <- function(add)
{
	local ent = null
	while(ent = Entities.FindByClassname(ent, "team_round_timer"))
	{
		M09Time = M09Time + add
		local newtime = M09Time
		EntFireByHandle(ent, "SetTime", newtime.tostring(), 0, null, null);
		SendGlobalGameEvent("teamplay_timer_time_added", {
			timer = ent.GetEntityIndex(),
			seconds_added = add,
		})
	}
}
::M09_DuckPickup <- function()
{
	Merc.ObjectiveMainCount = Merc.ObjectiveMainCount + 1
	EmitSoundEx({ sound_name = "ui/quest_status_tick_novice.wav", volume = 0.3 })
	Merc.UpdateHUD()
}

function M09_SpawnDuck(x, y, z)
{
	local prop = SpawnEntityFromTable("tf_halloween_pickup", {
		origin       = Vector(x,y,z - 18.0),
		angles       = QAngle(0,RandomInt(0, 181),0),
		targetname   = "mercduck",
		model 		 = M09DuckProp,
		powerup_model = M09DuckProp,
		pickup_particle = "taunt_headbutt_impact_stars",
		automaterialize = false,
		TeamNum = Merc.ForcedTeam,
		teamnumber = Merc.ForcedTeam,
	})
	prop.SetTeam(Merc.ForcedTeam)
	prop.ValidateScriptScope()
	prop.ConnectOutput("OnRedPickup", "M09_DuckPickup")
}

function M09_Clock()
{
	M09Time = M09Time - 1
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		M09SetupDone = true
		Merc.Delay(0.1, function() {
			local ent = null
			while (ent = Entities.FindByClassname(ent, "team_round_timer"))
			{
				local times = M09MissionTime.tostring()
				EntFireByHandle(ent, "SetTime", times, 0, null, null)
			}
		} )
		M09Time = M09MissionTime
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		::VSH_TEAM_MERCS <- TF_TEAM_BLUE // VSH 2024
		::VSH_TEAM_BOSS <- TF_TEAM_RED // VSH 2024
		::TF_TEAM_MERCS <- TF_TEAM_BLUE // VSH
		::TF_TEAM_BOSS <- TF_TEAM_RED // VSH
		::UnlockControlPoint <- function() {} // VSH / VSH 2024
		::GetAliveMercCount <- function() { return 20; } // VSH
		local haleHP = 5000
		if (Merc.RSVFlags[4] == 2) haleHP -= 500
		if (Merc.RSVFlags[5] == 3) haleHP -= 500
		if (Merc.RSVFlags[6] == 3) haleHP -= 1000
		::CalcBossMaxHealth <- function(a) { return haleHP; } // VSH
		if ("SetPersistentVar" in getroottable())
		{
			SetPersistentVar("next_boss", 1); // VSH
		}
		if ("VSH_API_DEF_VALUES" in getroottable())
		{
			if ("setup_lines" in VSH_API_DEF_VALUES)
			{
				VSH_API_DEF_VALUES.setup_lines = false // VSH
			}
			if ("long_setup_lines" in VSH_API_DEF_VALUES)
			{
				VSH_API_DEF_VALUES.long_setup_lines = false // VSH
			}
		}
		
		M09SetupDone = false
		
		local places = M09_GetPlacement(M09DuckSpots, M09DuckCount)
		foreach (a in places)
		{
			M09_SpawnDuck(a[0], a[1], a[2])
		}
		places = M09_GetPlacement(M09BuildSpots, M09BuildCount)
		foreach (a in places)
		{
			MercSpawnBuild(a[0],a[1],a[2],a[3],a[4])
		}
		
		Merc.Delay(0.5, function() {
			local ent = null
			while (ent = Entities.FindByClassname(ent, "team_round_timer"))
			{
				ent.ValidateScriptScope()
				ent.ConnectOutput("On1SecRemain", "M09_TimerEnd")
			}
			
			foreach (a in GetClients()) 
			{
				if (IsPlayerABot(a))
					a.Teleport(true, Vector(-1483, 1629, 498), true, QAngle(0, 0, 0), true, Vector(0, 0, 0))
				else
				{
					a.Teleport(true, Vector(2512, -368, 900), true, QAngle(0, 180, 0), true, Vector(0, 0, 0))
				}
			}
		} )
	}
	
	OnGameEvent_player_activate = function(params)
	{
		if ("SetPersistentVar" in getroottable())
		{
			SetPersistentVar("next_boss", 1) // VSH
		}
	}
	
	OnGameEvent_player_spawn = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (IsPlayerABot(player))
			player.Teleport(true, Vector(-1483, 1629, 498), true, QAngle(0, 0, 0), true, Vector(0, 0, 0))
		else
			player.Teleport(true, Vector(2512, -368, 900), true, QAngle(0, 180, 0), true, Vector(0, 0, 0))
	}
	
	OnGameEvent_object_destroyed = function(params)
	{
		local player = GetPlayerFromUserID(params.attacker)
		if (params.attacker == 0) return
		if (IsPlayerABot(player)) return
		
		Merc.ExtraGet(1,2,2)
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])


