// KOTH Laughter
::Merc <- {}
Merc.MissionID <- 26
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_SCOUT
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [ ]
Merc.ObjectiveText <- "Capture the point in time"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Collect all bonus ducks"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 5
Merc.AllowRecruits <- 0

::M08MissionTime <- 120
::M08Time <- M08MissionTime
::M08TimerPaused <- false

PrecacheModel("models/player/items/taunts/bumpercar/parts/bumpercar.mdl")
PrecacheModel("models/props_halloween/bumpercar_cage.mdl")
PrecacheScriptSound("BumperCar.Jump")
PrecacheScriptSound("BumperCar.HitBall")
PrecacheScriptSound("BumperCar.Bump")
PrecacheScriptSound("BumperCar.BumpHard")
PrecacheScriptSound("BumperCar.JumpLand")
PrecacheScriptSound("BumperCar.Spawn")
PrecacheScriptSound("BumperCar.Accelerate")
PrecacheScriptSound("BumperCar.GoLoop")
PrecacheScriptSound("BumperCar.Decelerate")
PrecacheScriptSound("BumperCar.DecelerateQuick")
PrecacheScriptSound("BumperCar.SpeedBoostStart")
PrecacheScriptSound("BumperCar.SpeedBoostStop")
PrecacheScriptSound("BumperCar.Screech")
PrecacheScriptSound("BumperCar.BumpIntoAir")
PrecacheScriptSound("BumperCar.HitGhost")
PrecacheScriptSound("Halloween.Quack")
::M08Props <- [
	"models/props_gameplay/orange_cone001.mdl",
	"models/props_mining/fence001_reference.mdl",
]
foreach (i in M08Props)
{
	PrecacheModel(i)
}
::M08DuckProp <- "models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl"
PrecacheModel(M08DuckProp)
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })

::M08BlockerSpots <- [
	[1, -1836,-285,146, 0,0,0],
	[1, -1836,-412,146, 0,0,0],
	[1, -1836,-543,146, 0,0,0],
	[1, -1801,-653,165, 0,225,0],
	[1, -1636,-770,84, 0,0,0],
	[1, -1636,-847,84, 0,0,0],
	[1, -897,-1263,17, 0,270,0],
	[1, -918,-1263,77, 0,270,0],
	[1, -790,-1263,77, 0,270,0],
	[1, -672,-1263,77, 0,270,0],
	[1, -546,-1263,77, 0,270,0],
	[1, 563,-609,18, 0,180,0],
	[1, 563,-490,18, 0,180,0],
	[1, 199,-549,80, 0,0,0],
	[1, 199,-433,80, 0,0,0],
	[1, 199,-309,80, 0,0,0],
	[1, 242,-340,26, 0,300,0],
	[1, 340,-286,26, 0,300,0],
	[1, 383,-194,31, 0,180,0],
	[1, 379,-100,73, 0,180,0],
	[1, 381,115,73, 0,180,0],
	[1, 844,-164,77, 0,180,0],
	[1, 844,-80,77, 0,180,0],
	[1, 756,19,111, 0,75,0],
	[1, 755,16,62, 0,255,0],
	[1, 676,72,62, 0,225,0],
	[1, 805,21,1, 0,270,0],
	[1, 714,37,16, 0,225,0],
	[1, 623,119,15, 0,240,0],
	[1, 519,149,12, 0,270,0],
	[1, 407,143,14, 0,270,0],
	[1, -438,180,1, 0,45,0],
	[1, -525,268,1, 0,45,0],
	[1, -566,310,1, 0,45,0],
	[1, -566,310,60, 0,45,0],
	[1, -434,-150,25, 0,270,0],
	[1, -550,-150,25, 0,270,0],
	[1, -672,-150,25, 0,270,0],
	[1, -788,-127,25, 0,255,0],
	[1, -788,-127,88, 0,255,0],
	[1, -1474,86,308, 0,0,0],
	[1, -1462,184,308, 0,0,0],
	[1, -1399,248,308, 0,270,0],
	[1, -668,466,87, 0,90,0],
	[1, -732,522,87, 0,0,0],
	[1, -732,619,87, 0,0,0],
	[1, -735,617,148, 0,0,0],
	[1, -80,763,333, 0,270,0],
	[1, 80,763,333, 0,270,0],
	[1, -298,-108,96, 0,270,0],
	[1, -189,-126,96, 0,255,0],
	[1, 1788,754,94, 0,315,0],
	[1, 1862,851,94, 0,330,0],
	[1, 1906,952,94, 0,345,0],
	[1, 1929,1054,94, 0,0,0],
	[1, 546,634,254, 0,270,0],
	[1, 546,634,192, 0,270,0],
	[1, 667,634,219, 0,270,0],
	[1, 796,634,219, 0,270,0],
	[1, 938,634,219, 0,270,0],
	[1, 732,634,148, 0,270,0],
	[1, 865,634,148, 0,270,0],
	[1, 997,634,122, 0,270,0],
	[1, 832,634,77, 0,270,0],
	[1, 961,634,57, 0,270,0],
	[1, 832,634,10, 0,270,0],
	[1, 953,634,1, 0,270,0],
	[1, 1048,634,1, 0,270,0],
	[1, 544,1163,316, 0,90,0],
	[1, 673,1163,316, 0,90,0],
	[1, 638,1163,248, 0,90,0],
	[1, 553,1219,181, 0,90,0],
	[1, 679,1219,181, 0,90,0],
	[1, 811,1219,181, 0,90,0],
	[1, 919,1219,112, 0,90,0],
	[1, 562,1219,98, 0,90,0],
	[1, 679,1219,98, 0,90,0],
	[1, 790,1219,87, 0,90,0],
	[1, 873,1219,28, 0,90,0],
	[1, 985,1219,28, 0,90,0],
	[1, 915,1265,124, 0,270,0],
	[1, 915,1265,46, 0,270,0],
	[1, 796,1265,84, 0,270,0],
	[1, 666,1265,84, 0,270,0],
	[1, 552,1265,84, 0,270,0],
	[1, -656,-142,92, 0,270,0],
	[1, -531,-146,92, 0,270,0],
	[1, -405,-142,91, 0,270,0],
	[1, -483,217,66, 0,45,0],
	[1, -409,144,66, 0,45,0],
	[1, -1263,254,309, 0,270,0],
	[1, -1148,253,309, 0,270,0],
	[1, -736,497,148, 0,0,0],
	[1,-1638,-774,165, 0,0,0],
	[1,-1638,-901,165, 0,0,0],
	[1,-1638,-774,241, 0,0,0],
	[1,-1638,-901,241, 0,0,0],
	[1,-1638,-774,304, 0,0,0],
	[1,-1638,-901,304, 0,0,0],
	[1,-1638,-774,364, 0,0,0],
	[1,-1638,-901,364, 0,0,0],
	[1,-1638,-774,414, 0,0,0],
	[1,-1638,-901,414, 0,0,0],
	[1,-1839,-541,229, 0,0,0],
	[1,-1839,-397,229, 0,0,0],
	[1,-1839,-253,229, 0,0,0],
	[1,-1839,-110,229, 0,0,0],
	[1,-1839,-541,289, 0,0,0],
	[1,-1839,-397,289, 0,0,0],
	[1,-1839,-253,289, 0,0,0],
	[1,-1839,-110,289, 0,0,0],
	[1,-1839,-541,349, 0,0,0],
	[1,-1839,-397,349, 0,0,0],
	[1,-1839,-253,349, 0,0,0],
	[1,-1839,-110,349, 0,0,0],
	[1, 444,141,98, 0,270,0],
	[1, 565,135,98, 0,255,0],
	[1, 444,141,158, 0,270,0],
	[1, 565,135,158, 0,255,0],
	[1, 444,141,218, 0,270,0],
	[1, 565,135,218, 0,255,0],
	[1, 444,141,278, 0,270,0],
	[1, 565,135,278, 0,255,0],
	[1, 679,71,128, 0,225,0],
	[1, 679,71,188, 0,225,0],
	[1, 679,71,248, 0,225,0],
	[1, 679,71,308, 0,225,0],
	[1, 6758,14,177, 0,75,0],
	[1, 6758,14,237, 0,75,0],
	[1, 6758,14,297, 0,75,0],
	[1, 554,638,320, -15,270,0],
	[1, 554,638,380, -15,270,0],
	[1, 669,638,285, -15,270,0],
	[1, 669,638,345, -15,270,0],
	[1, 801,638,285, -15,270,0],
	[1, 801,638,345, -15,270,0],
	[1, 940,638,285, -15,270,0],
	[1, 940,638,345, -15,270,0],
	[1, 1032,638,285, -15,270,0],
	[1, 1032,638,345, -15,270,0],
	[1, 1032,638,225, 0,270,0],
	[1, 1032,638,165, 0,270,0],
	[1, 1056,627,67, 0,270,0],
	[1, 948,1210,178, 0,90,0],
	[1, 553,1161,382, 0,90,0],
	[1, 679,1161,382, 0,90,0],
	[1, 776,1206,246, 0,90,0],
	[1, 909,1206,246, 0,90,0],
	[1, 776,1206,306, 0,90,0],
	[1, 909,1206,306, 0,90,0],
	[1, 776,1206,366, 0,90,0],
	[1, 909,1206,366, 0,90,0],
	[1, 776,1206,416, 0,90,0],
	[1, 909,1206,416, 0,90,0],
	[1, -916,-1263,143, 0,270,0],
	[1, -787,-1263,143, 0,270,0],
	[1, -665,-1263,143, 0,270,0],
	[1, -545,-1263,143, 0,270,0],
	[1, -916,-1263,203, 0,270,0],
	[1, -787,-1263,203, 0,270,0],
	[1, -665,-1263,203, 0,270,0],
	[1, -545,-1263,203, 0,270,0],
	[1, 583,69,90, -90,180,0],
	[1, 583,-60,90, -90,180,0],
	[1, -558,57,90, -90,180,0],
	[1, -558,-72,90, -90,180,0],
	[1, -631,-65,107, 45,0,0],
	[1, -631,61,107, 45,0,0],
	[1, 606,56,97, 0,0,0],
	[1, 606,-72,97, 0,0,0],
	[1, 542,1151,447, -90,90,0],
	[1, 671,1151,447, -90,90,0],
	[1, 733,1120,349, 0,0,0],
]
::M08FakeBlockerSpots <- [
	[0, -1829,-313,117, 0,0,0],
	[0, -1829,-440,117, 0,0,0],
	[0, -1829,-560,117, 0,0,0],
	[0, -1620,-769,53, 0,0,0],
	[0, -1620,-830,53, 0,0,0],
	[0, -942,-1227,-11, 0,0,0],
	[0, -884,-1227,-11, 0,0,0],
	[0, -826,-1227,-11, 0,0,0],
	[0, -760,-1238,53, 0,0,0],
	[0, -683,-1238,53, 0,0,0],
	[0, -597,-1238,53, 0,0,0],
	[0, -530,-1238,53, 0,0,0],
	[0, 573,-612,-11, 0,0,0],
	[0, 573,-527,-11, 0,0,0],
	[0, 180,-503,69, 0,0,0],
	[0, 180,-435,69, 0,0,0],
	[0, 180,-365,69, 0,0,0],
	[0, 222,-318,-11, 0,0,0],
	[0, 288,-286,-11, 0,0,0],
	[0, 356,-263,-11, 0,0,0],
	[0, 860,-135,53, 0,0,0],
	[0, 860,-70,53, 0,0,0],
	[0, 758,25,-11, 0,0,0],
	[0, 699,87,-11, 0,0,0],
	[0, 619,144,-11, 0,0,0],
	[0, 504,167,-11, 0,0,0],
	[0, 392,164,-11, 0,0,0],
	[0, -409,184,-11, 0,0,0],
	[0, -445,237,-11, 0,0,0],
	[0, -500,291,-11, 0,0,0],
	[0, -545,328,-11, 0,0,0],
	[0, -440,-174,-11, 0,0,0],
	[0, -504,-172,-11, 0,0,0],
	[0, -575,-175,-11, 0,0,0],
	[0, -649,-167,-11, 0,0,0],
	[0, -720,-162,-11, 0,0,0],
	[0, -784,-150,-11, 0,0,0],
	[0, -1444,179,261, 0,0,0],
	[0, -1444,91,261, 0,0,0],
	[0, -650,465,53, 0,0,0],
	[0, -717,525,53, 0,0,0],
	[0, -720,577,53, 0,0,0],
	[0, -718,631,53, 0,0,0],
	[0, -82,748,293, 0,0,0],
	[0, 82,748,293, 0,0,0],
	[0, 538,619,157, 0,0,0],
	[0, 612,619,157, 0,0,0],
	[0, 813,600,-11, 0,0,0],
	[0, 896,600,-11, 0,0,0],
	[0, 977,600,-11, 0,0,0],
	[0, 1043,600,-11, 0,0,0],
	[0, 545,1237,53, 0,0,0],
	[0, 593,1237,53, 0,0,0],
	[0, 652,1237,53, 0,0,0],
	[0, 708,1237,53, 0,0,0],
	[0, 771,1237,53, 0,0,0],
	[0, 832,1228,-11, 0,0,0],
	[0, 885,1228,-11, 0,0,0],
	[0, 953,1228,-11, 0,0,0],
	[0, 1797,720,53, 0,0,0],
	[0, 1842,776,53, 0,0,0],
	[0, 1877,829,53, 0,0,0],
	[0, 1908,903,53, 0,0,0],
	[0, 1933,963,53, 0,0,0],
	[0, 1945,1017,53, 0,0,0],
	[0, 1950,1070,53, 0,0,0],
	[0, -310,-127,61, 0,0,0],
	[0, -242,-133,61, 0,0,0],
]
::M08DuckSpots <- [
	[-1834,-1509,52],
	[-24,174,-177],
	[-1490,-314,111],
	[329,629,255],
	[1227,849,47],
	//[1478,1285,84],
	//[-609,257,-11],
	//[-1718,-667,116],
	//[-1989,139,260],
	//[-1312,561,64],
	//[-596,816,275],
	//[-279,-39,77],
	//[-2474,-859,63],
	//[-628,570,34],
	//[805,-102,49],
]

::M08_GetPlacement <- function(list, maxpick)
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

function M08_SpawnProp(modelname, x, y, z, rotx, roty, rotz, ptype)
{
	local offset = 20.0
	local petype = "prop_dynamic_override"
	local mname = modelname
	local prop = SpawnEntityFromTable(petype, {
		origin       = Vector(x,y,z - offset),
		angles       = QAngle(rotx, roty, rotz),
		model 		 = mname,
		targetname   = "mercprop",
		max_health   = 1000,
		health 		 = 1000,
		solid		 = 6,
	})
	if (ptype == 0)
	{
		prop.DisableDraw()
		prop.SetCollisionGroup(25)
	}
	
	return prop
}
::M08_DuckPickup <- function()
{
	Merc.ExtraGet(1,1,1)
}
function M08_SpawnDuck(x, y, z)
{
	local prop = SpawnEntityFromTable("tf_halloween_pickup", {
		origin       = Vector(x,y,z - 18.0),
		angles       = QAngle(0,RandomInt(0, 181),0),
		targetname   = "mercduck",
		model 		 = M08DuckProp,
		powerup_model = M08DuckProp,
		pickup_particle = "taunt_headbutt_impact_stars",
		automaterialize = false,
		TeamNum = Merc.ForcedTeam,
		teamnumber = Merc.ForcedTeam,
	})
	prop.SetTeam(Merc.ForcedTeam)
	prop.ValidateScriptScope()
	prop.ConnectOutput("OnRedPickup", "M08_DuckPickup")
}

function M08_Clock()
{
	if (Merc.RoundEnded) return
	if (M08TimerPaused) return
	if (M08Time > 0)
	{
		M08Time = M08Time - 1
		local minutes = M08Time / 60
		local seconds = M08Time - (minutes * 60)
		if (seconds > 9)
			Merc.ObjectiveTextAdd = " ("+minutes+":"+seconds+")"
		else
			Merc.ObjectiveTextAdd = " ("+minutes+":0"+seconds+")"
	}
	else
	{
		Merc.ChatPrint("Main objective failed! Ran out of time.")
		Merc.ForceFail()
		Merc.ObjectiveTextAdd = " (0:00)"
	}
	Merc.UpdateHUD()
}

Merc.AfterPlayerSpawn <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	if (IsPlayerABot(player)) return
	if (player.GetTeam() != Merc.ForcedTeam) return
	player.Teleport(true, Vector(-3585,-256,210), true, QAngle(0, 0, 0), true, Vector(0, 0, 0))
	player.AddCond(TF_COND_HALLOWEEN_KART)
	player.AddCond(TF_COND_FREEZE_INPUT)
}

Merc.BeforeRoundStart <- function(params) 
{
	if (params.full_reset)
	{
		local area = null
		while (area = Entities.FindByClassname(area, "trigger_capture_area"))
		{
			local capName = GetPropString(area, "m_iszCapPointName")
			SetPropFloat(area, "m_flCapTime", 1)
			area.AcceptInput("SetControlPoint", capName, null, null)
		}
	}
	//Convars.SetValue("tf_halloween_kart_cam_dist", 80) // def 225
	//Convars.SetValue("tf_halloween_kart_stationary_turn_speed", 100) // def 50
	//Convars.SetValue("tf_halloween_kart_slow_turn_speed", 150) // def 100
	//Convars.SetValue("tf_halloween_kart_slow_turn_accel_speed", 250) // def 200
	//Convars.SetValue("tf_halloween_kart_fast_turn_speed", 90) // def 60
	//Convars.SetValue("tf_halloween_kart_fast_turn_accel_speed", 600) // def 400
	//Convars.SetValue("tf_halloween_kart_turning_curve_peak_position", 0.5) // def 0.5
	
	M08TimerPaused <- true
	M08Time <- M08MissionTime
	Merc.ObjectiveTextAdd = ""
	Merc.ObjectiveExtraAdd = ""
	Merc.Timer(1.0, 0, M08_Clock)
	local minutes = M08Time / 60
	local seconds = M08Time - (minutes * 60);
	if (seconds > 9)
		Merc.ObjectiveTextAdd = " ("+minutes+":"+seconds+")"
	else
		Merc.ObjectiveTextAdd = " ("+minutes+":0"+seconds+")"
	
	Merc.Delay(1.0, function() {
		Merc.ChatPrint("READY")
	} )
	Merc.Delay(2.0, function() {
		Merc.ChatPrint("READY.")
	} )
	Merc.Delay(3.0, function() {
		Merc.ChatPrint("READY..")
	} )
	Merc.Delay(4.0, function() {
		Merc.ChatPrint("READY...")
	} )
	Merc.Delay(5.0, function() {
		M08TimerPaused <- false
		Merc.ChatPrint("GO!")
		foreach (a in GetClients()) 
		{	
			if (!IsPlayerABot(a))
			{
				a.RemoveCond(TF_COND_FREEZE_INPUT)
			}
		}
		local ent = null
		while (ent = Entities.FindByName(ent, "cp_koth1"))
		{
			EntFireByHandle(ent, "SetLocked", "0", -1, ent, ent)
			EntFireByHandle(ent, "Enable", "", -1, ent, ent)
		}
	} )
	
	foreach (a in M08BlockerSpots)
	{
		M08_SpawnProp(M08Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 0)
	}
	foreach (a in M08FakeBlockerSpots)
	{
		M08_SpawnProp(M08Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 1)
	}
	//local places = M08_GetPlacement(M08DuckSpots, MercObjectiveExtraMax)
	foreach (a in M08DuckSpots)
	{
		M08_SpawnDuck(a[0], a[1], a[2])
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (IsPlayerABot(player)) return
		if (Merc.RoundEnded) return
		Merc.ForceFail()
	}
	
	OnGameEvent_teamplay_point_captured = function(params)
	{
		Merc.MainGet(1,1,1)
		Merc.ForceWin()
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

