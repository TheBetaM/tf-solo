// CP Dustbowl
::Merc <- {}
Merc.MissionID <- 1
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_DEMOMAN
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- []
Merc.ObjectiveText <- "Destroy bags before time runs out"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 40
Merc.ObjectiveExtraText <- "Break the target on the last point"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1
Merc.AllowRecruits <- 0

PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })

::M01Props <- [
	"models/props_soho/trashbag001.mdl",
	"models/props_training/target_scout.mdl",
]
foreach (i in M01Props)
{
	PrecacheModel(i)
}

Convars.SetValue("mp_disable_respawn_times", 1)

::M01SetupDone <- false
::M01MissionTime <- 30
::M01PropAddTime <- 2
::M01StageAddTime <- 30
::M01StageAddTime2 <- 15
::M01StageCount1 <- 16
::M01StageCount2 <- 30
::M01PropSpots <- [
	[0, -1854,2956,-230, 0,0,0],
	[0, -2022,2752,-41, 0,0,0],
	[0, -2148,1976,-138, 0,0,0],
	[0, -1251,3182,-232, 0,0,0],
	[0, -1159,2581,-392, 0,0,0],
	[0, -976,1972,-232, 0,0,0],
	[0, -583,2603,-177, 0,0,0],
	[0, -492,2682,-224, 0,0,0],
	[0, -49,2895,-176, 0,0,0],
	[0, 35,2915,-230, 0,0,0],
	[0, -1606,2216,-415, 0,0,0],
	[0, -205,1856,-386, 0,0,0],
	[0, 906,2649,-232, 0,0,0],
	[0, 796,2058,-232, 0,0,0],
	[0, 1304,1964,-232, 0,0,0],
	[0, 1040,2779,-189, 0,0,0],
	[0, 892,2153,-232, 0,0,0],
	[0, 742,1552,-160, 0,0,0],
	[0, 1181,1643,44, 0,0,0],
	[0, 1080,1928,-40, 0,0,0],
	[0, 1039,1932,-40, 0,0,0],
	[0, 1061,1971,-40, 0,0,0],
	[0, -312,2466,-118, 0,0,0],
	[0, 752,3092,-40, 0,0,0],
	[0, 1128,3206,-40, 0,0,0],
	[0, 1177,3206,-40, 0,0,0],
	[0, 1662,3198,-40, 0,0,0],
	[0, 1483,2572,16, 0,0,0],
	[0, 1688,2135,-171, 0,0,0],
	[0, 2082,2531,-162, 0,0,0],
	[0, 1962,2792,-168, 0,0,0],
	[0, 2158,2202,-120, 0,0,0],
	[0, 2484,1908,-169, 0,0,0],
	[0, 2526,1944,-168, 0,0,0],
	[0, 2526,1876,-168, 0,0,0],
	[0, 1666,1409,-154, 0,0,0],
	[0, 2241,1506,24, 0,0,0],
	[0, 2658,1519,24, 0,0,0],
	[0, 2628,1017,24, 0,0,0],
	[0, 2241,1021,24, 0,0,0],
	[0, 1606,1435,24, 0,0,0],
	[0, 1459,730,-100, 0,0,0],
	[0, 2811,857,-168, 0,0,0],
	[0, 2770,838,-168, 0,0,0],
	[0, 2807,810,-168, 0,0,0],
	[0, 954,2606,-39, 0,0,0],
	[0, 1377,1906,-222, 0,0,0],
	[0, 1312,2345,-38, 0,0,0],
	[0, 2395,2744,-48, 0,0,0],
	[0, 226,2499,-70, 0,0,0],
]
::M01PropRandSpots <- [
	[0, -1310,1818,-121, 30,0,0],
	[0, -2130,1862,26, 0,0,0],
	[0, -382,2569,58, 0,0,30],
	[0, 639,1406,-196, 0,0,0],
	[0, 2131,2476,99, -30,0,0],
	[0, 2138,2235,105, -30,0,0],
	[0, 2655,2302,-125, 0,0,0],
]
::M01PropSpotsStage2 <- [
	[0, 2748,611,-299, 0,0,0],
	[0, 3051,294,-298, 0,0,0],
	[0, 2235,340,-310, 0,0,0],
	[0, 1887,-464,-101, 0,0,0],
	[0, 1571,-213,-168, 0,0,0],
	[0, 1734,-582,-168, 0,0,0],
	[0, 2378,-737,-104, 0,0,0],
	[0, 2321,-825,-104, 0,0,0],
	[0, 2718,-1053,-24, 0,0,0],
	[0, 2428,-927,24, 0,0,0],
	[0, 2439,-885,24, 0,0,0],
	[0, 2394,-890,24, 0,0,0],
	[0, 2294,-1561,-104, 0,0,0],
	[0, 1779,-1395,-103, 0,0,0],
	[0, 1680,-2195,-104, 0,0,0],
	[0, 1881,-1896,-104, 0,0,0],
	[0, 1186,-2145,-104, 0,0,0],
	[0, 1014,-1453,-102, 0,0,0],
	[0, 1015,-2795,-90, 0,0,0],
	[0, 523,-2601,-95, 0,0,0],
	[0, 193,-1593,92, 0,0,0],
	[0, 198,-1796,92, 0,0,0],
	[0, 208,-2031,92, 0,0,0],
	[0, 315,-1378,-104, 0,0,0],
	[0, 506,-2215,-103, 0,0,0],
	[0, -119,-1092,-100, 0,0,0],
	[0, -480,-1277,2, 0,0,0],
	[0, -395,-2229,24, 0,0,0],
	[0, -1078,-2524,-54, 0,0,0],
	[0, -1693,-2163,-22, 0,0,0],
	[0, -1567,-1444,-104, 0,0,0],
	[0, -598,-1603,24, 0,0,0],
	[0, -1066,-2217,24, 0,0,0],
	[0, -2473,-1644,-104, 0,0,0],
	[0, -2511,-1694,-104, 0,0,0],
	[0, -2511,-1592,-104, 0,0,0],
	[0, 1824,-206,31, 0,0,0],
	[0, 1638,-203,31, 0,0,0],
	[0, -268,-1860,-136, 0,0,0],
]
::M01PropRandSpotsStage2 <- [
	[0, 2264,-603,138, 0,0,-30],
	[0, 1550,-1882,96, 0,0,-30],
	[0, -781,-1995,80, 0,0,0],
	[0, -1774,-2007,96, 0,0,0],
	[0, -2604,-1647,24, 0,0,0],
	[0, -1097,-2635,100, 0,0,0],
	[0, -1822,-2401,-40, 0,0,0],
]
::M01PropSpotsStage3 <- [
	[0, -2048,-1206,-168, 0,0,0],
	[0, -2081,-1170,-168, 0,0,0],
	[0, -2009,-1167,-168, 0,0,0],
	[0, -2116,-1093,44, 0,0,0],
	[0, -2387,-551,-40, 0,0,0],
	[0, -1347,-478,-40, 0,0,0],
	[0, -1814,-228,72, 0,0,0],
	[0, -1963,539,24, 0,0,0],
	[0, -1763,543,24, 0,0,0],
	[0, -750,408,27, 0,0,0],
	[0, -638,-59,152, 0,0,0],
	[0, -1010,21,152, 0,0,0],
	[0, -923,-864,216, 0,0,0],
	[0, -665,-875,24, 0,0,0],
	[0, 287,-880,152, 0,0,0],
	[0, -414,-581,152, 0,0,0],
	[0, -734,-884,-233, 0,0,0],
	[0, -858,513,-233, 0,0,0],
	[0, -483,1348,-223, 0,0,0],
	[0, 696,-768,-24, 0,0,0],
	[0, 743,-436,166, 0,0,0],
	[0, 112,-279,152, 0,0,0],
	[0, -146,-116,152, 0,0,0],
	[0, 845,-90,24, 0,0,0],
	[0, 257,418,24, 0,0,0],
	[0, 847,425,24, 0,0,0],
	[0, 1215,-300,168, 0,0,0],
	[0, 498,130,-238, 0,0,0],
	[0, 1040,133,-232, 0,0,0],
	[0, -2283,632,-40, 0,0,0],
	[0, -1436,-987,-40, 0,0,0],
]
::M01PropRandSpotsStage3 <- [
	[0, -1071,482,136, 0,0,0],
	[0, -1000,482,136, 0,0,0],
	[0, -1815,-498,238, 15,0,0],
	[0, -650,-644,296, 0,0,30],
]
::M01ExtPropSpots <- [
	[1, 544,708,29, 0,270,0],
]

::M01Time <- M01MissionTime
::M01PropsOut <- 0

::M01Stage2Blocks <- [
	"gate_2nd_spawn",
	"cap1_fence_block",
	"gate_3a",
	"gate_3b",
	"gate_3c",
]
::M01Stage3Blocks <- [
	"gate_5a",
	"gate_5a_bottom",
	"gate_5a_top",
	"gate_5b_bottom",
	"gate_5b_top",
	"gate_5c_top",
	"gate_5c_bottom",
]

::M01DestroyByName <- function(name)
{
	local ent = null
	while (ent = Entities.FindByName(ent, name))
	{
		ent.Kill()
	}
}

::M01_GetPropPlacement <- function(id, list, rlist)
{
	local places = [], full = []
	local maxpick = 15
	foreach (a in list) full.push(a)
	if (id == 0)
	{
		places.push(list[0])
		full.remove(0)
	}
	else if (id == 1)
		maxpick = 10
	else
		maxpick = 5
	for (local i = 0; i < maxpick; i++)
	{
		local a = RandomInt(0, full.len() - 1)
		places.push(full[a])
		full.remove(a)
	}
	foreach (a in rlist) full.push(a)
	for (local i = 0; i < maxpick; i++)
	{
		local a = RandomInt(0, full.len() - 1)
		places.push(full[a])
		full.remove(a)
	}
	return places
}

::M01_TimerAdd <- function(add)
{
	local ent = null
	while (ent = Entities.FindByClassname(ent, "team_round_timer"))
	{
		M01Time = M01Time + add
		local newtime = M01Time
		EntFireByHandle(ent, "SetTime", newtime.tostring(), 0, null, null)
		SendGlobalGameEvent("teamplay_timer_time_added", {
			timer = ent.GetEntityIndex(),
			seconds_added = add,
		})
	}
}
::M01_PropDestroyed <- function()
{
	Merc.MainGet(1, 4, 1)
	M01_TimerAdd(M01PropAddTime)
	SendGlobalGameEvent("hide_annotation", {
		id = 10,
	})
	M01PropsOut++
	if (M01PropsOut == M01StageCount1)
	{
		M01_OpenStage2()
	}
	if (M01PropsOut == M01StageCount2)
	{
		M01_OpenStage3()
	}
	if (Merc.ObjectiveMainCount >= Merc.ObjectiveMainMax && Merc.ObjectiveExtraCount >= Merc.ObjectiveExtraMax)
	{
		Merc.ForceWin()
	}
}
::M01_ExtPropDestroyed <- function()
{
	Merc.ExtraGet(1, 1, 1)
	if (Merc.ObjectiveMainCount >= Merc.ObjectiveMainMax && Merc.ObjectiveExtraCount >= Merc.ObjectiveExtraMax)
	{
		Merc.ForceWin()
	}
}
::M01_TimerEnd <- function()
{
	if (!M01SetupDone)
	{
		return
	}
	if (Merc.ObjectiveMainCount < Merc.ObjectiveMainMax)
	{
		Merc.ForceFail()
		M01SetupDone = false
	}
}
::M01_SetupEnd <- function()
{
	M01SetupDone = true
}
::M01_OpenStage2 <- function()
{
	M01_TimerAdd(M01StageAddTime)
	local places = M01_GetPropPlacement(1, M01PropSpotsStage2, M01PropRandSpotsStage2)
	foreach (a in places)
	{
		M01_SpawnProp(M01Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 0)
	}
	foreach (a in M01Stage2Blocks)
	{
		M01DestroyByName(a)
	}
	SendGlobalGameEvent("show_annotation", {
		worldPosX = 1956,
		worldPosY = 527,
		worldPosZ = -200,
		id = 11,
		text = "Stage 2 is now open!",
		lifetime = 10,
	})
	Merc.ChatPrint("Stage 2 is now open!")
}
::M01_OpenStage3 <- function()
{
	M01_TimerAdd(M01StageAddTime2)
	local places = M01_GetPropPlacement(2, M01PropSpotsStage3, M01PropRandSpotsStage3)
	foreach (a in places)
	{
		M01_SpawnProp(M01Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 0)
	}
	foreach (a in M01ExtPropSpots)
	{
		M01_SpawnProp(M01Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 1)
	}
	foreach (a in M01Stage3Blocks)
	{
		M01DestroyByName(a)
	}
	SendGlobalGameEvent("show_annotation", {
		worldPosX = -2041,
		worldPosY = -1620,
		worldPosZ = -131,
		id = 12,
		text = "Stage 3 is now open!",
		lifetime = 7,
	})
	Merc.ChatPrint("Stage 3 is now open!")
}


function M01_SpawnProp(modelname, x, y, z, rotx, roty, rotz, ptype)
{
	local yrot = roty
	if (rotx == 0 && rotz == 0 && ptype == 0)
	{
		yrot = RandomInt(0,360)
	}
	local prop = SpawnEntityFromTable("prop_dynamic", {
		origin       = Vector(x,y,z - 24.0),
		angles       = QAngle(rotx, yrot, rotz),
		model 		 = modelname,
		targetname   = "mtargetprop",
		max_health   = 1000,
		health 		 = 1000,
		solid		 = 6,
	})
	prop.SetTeam(TF_TEAM_BLUE)
	prop.ValidateScriptScope()
	if (ptype == 0)
	{
		prop.GetScriptScope()["M01PropState"] <- 0
		prop.GetScriptScope()["M01PropDestroy"] <- function(){
			if (M01PropState != 0) return
			M01PropState = 1
			M01_PropDestroyed()
			DispatchParticleEffect("taunt_headbutt_impact_stars", Vector(x,y,z), Vector(0,0,0))
			self.Kill()
		}
		prop.ConnectOutput("OnTakeDamage", "M01PropDestroy")
	}
	else
	{
		prop.GetScriptScope()["M01PropState"] <- 0
		prop.GetScriptScope()["M01EPropDestroy"] <- function(){
			if (M01PropState != 0) return
			M01PropState = 1
			M01_ExtPropDestroyed()
			DispatchParticleEffect("taunt_headbutt_impact_stars", Vector(x,y,z), Vector(0,0,0))
			self.Kill()
		}
		prop.ConnectOutput("OnTakeDamage", "M01EPropDestroy")
		prop.SetSkin(1)
	}
	return prop
}
function M01_Clock()
{
	M01Time = M01Time - 1
}

Merc.BeforeRoundStart <- function(params) 
{
	M01Time = M01MissionTime
	M01SetupDone <- false
	M01PropsOut = 0
	local ent = null
	while (ent = Entities.FindByClassname(ent, "team_round_timer"))
	{
		ent.ValidateScriptScope()
		SetPropInt(ent, "m_bAutoCountdown", 0)
		ent.AcceptInput("SetSetupTime", "1", null, null)
		EntFireByHandle(ent, "SetTime", "30", 1.1, null, null)
		ent.ConnectOutput("OnSetupFinished", "M01_SetupEnd")
		ent.ConnectOutput("On1SecRemain", "M01_TimerEnd")
	}
	Merc.Timer(1.0, 0, M01_Clock)
	local places = M01_GetPropPlacement(0, M01PropSpots, M01PropRandSpots)
	foreach (a in places)
	{
		M01_SpawnProp(M01Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 0)
	}
	foreach (a in GetClients()) 
	{
		a.Teleport(true, Vector(-2057, 2959, -200), true, QAngle(0, 0, 0), true, Vector(0, 0, 0))
	}
	Merc.Delay(1.0, function() { 
		local prop = M01PropSpots[0]
		SendGlobalGameEvent("show_annotation", {
			worldPosX = prop[1],
			worldPosY = prop[2],
			worldPosZ = prop[3] + 16.0,
			id = 10,
			text = "Demolish bags like this one!",
			lifetime = -1,
		})
	})
}

Merc.AfterPlayerSpawn <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	player.Teleport(true, Vector(-2057, 2959, -200), true, QAngle(0, 0, 0), true, Vector(0, 0, 0))
}

