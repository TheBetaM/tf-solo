// CP Mercenary Park
::Merc <- {}
Merc.MissionID <- 13
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_SCOUT
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED, 0, "Cheetah"),
	Merc.Bot(TF_TEAM_RED, 0, "Racc"),
	Merc.Bot(TF_TEAM_RED, 0, "Canine"),
	Merc.Bot(TF_TEAM_RED, 0, "Fox"),
	Merc.Bot(TF_TEAM_RED, 0, "Yeti"),
	Merc.Bot(TF_TEAM_RED, 0, "Spider"),
	Merc.Bot(TF_TEAM_RED, 0, "Crocodile"),
	Merc.Bot(TF_TEAM_RED, 0, "Bear"),
]
Merc.ObjectiveText <- "Find and capture all points"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 3
Merc.ObjectiveExtraText <- "Collect ducks to gain time"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 20

Convars.SetValue("mp_disable_respawn_times", 1)

Merc.Bots[0].BotAttribs = [ IGNORE_ENEMIES ]
Merc.Bots[0].BotWpnFlags = 1
Merc.Bots[0].Attribs = [ ["max health additive penalty",-100,-1], ["overheal penalty",0.01,-1] ]

Merc.Bots[1].BotAttribs = [ IGNORE_ENEMIES ]
Merc.Bots[1].BotWpnFlags = 1
Merc.Bots[1].Attribs = [ ["max health additive penalty",-100,-1], ["overheal penalty",0.01,-1] ]

Merc.Bots[2].BotWpnFlags = 1
Merc.Bots[2].Attribs = [ ["max health additive penalty",-100,-1], ["overheal penalty",0.01,-1] ]

Merc.Bots[3].BotAttribs = [ IGNORE_ENEMIES ]
Merc.Bots[3].BotWpnFlags = 1
Merc.Bots[3].Attribs = [ ["max health additive penalty",-100,-1], ["overheal penalty",0.01,-1] ]

Merc.Bots[4].BotWpnFlags = 1
Merc.Bots[4].Attribs = [ ["max health additive penalty",-150,-1], ["overheal penalty",0.01,-1] ]

Merc.Bots[5].BotAttribs = [ IGNORE_ENEMIES ]
Merc.Bots[5].BotWpnFlags = 1
Merc.Bots[5].Attribs = [ ["max health additive penalty",-100,-1], ["overheal penalty",0.01,-1] ]

Merc.Bots[6].BotAttribs = [ IGNORE_ENEMIES ]
Merc.Bots[6].BotWpnFlags = 1
Merc.Bots[6].Attribs = [ ["max health additive penalty",-100,-1], ["overheal penalty",0.01,-1] ]

Merc.Bots[7].BotWpnFlags = 1
Merc.Bots[7].Attribs = [ ["max health additive penalty",-150,-1], ["overheal penalty",0.01,-1] ]

::M13DuckCount <- 40;
::M13DuckBonusTime <- 8;
::M13PointBonusTime <- 30;
::M13MissionTime <- 121
::M13Time <- M13MissionTime
::M13DuckSpots <- [
	[-1536,-459,79],
	[-1047,-135,79],
	[-1495,-1764,15],
	[-1041,-1765,15],
	[-2166,-1255,175],
	[-2112,119,186],
	[-2520,63,47],
	[-2780,-907,-1],
	[-2546,-428,31],
	[-1826,-1794,111],
	[-2603,-1227,143],
	[-3115,-2221,-33],
	[-2958,-1383,31],
	[-2883,-1876,287],
	[-3578,-1823,303],
	[-2919,-1219,303],
	[-2690,97,287],
	[-2957,303,287],
	[-3399,117,127],
	[-3240,-961,111],
	[-2659,250,127],
	[-3255,-1838,111],
	[-3537,-1726,31],
	[-3981,-1913,47],
	[-3997,39,47],
	[-4432,-1365,191],
	[-4445,-1632,47],
	[-4944,-733,111],
	[-4892,-1655,132],
	[-3730,-1869,303],
	[-3751,-537,303],
	[-4430,-1200,303],
	[-4439,-587,303],
	[-4674,-896,315],
	[-5425,-1445,255],
	[-5073,-7,47],
	[-4395,-384,47],
	[-5530,-472,255],
	[-5570,-56,127],
	[-5554,-1594,47],
	[-6153,-792,131],
	[-6128,-1667,31],
	[-6637,-1712,47],
	[-5468,-896,255],
	[-5710,-892,255],
	[-5797,-96,207],
	[-6529,35,255],
	[-6739,-129,255],
	[-6805,-1176,255],
	[-6790,-646,255],
	[-6772,-502,47],
	[-6380,-38,68],
	[-6063,394,-17],
	[-7688,-130,-17],
	[-7504,-556,64],
	[-7761,-1391,-17],
	[-7200,-1391,47],
	[-8157,-900,191],
	[-6742,420,-17],
	[-8169,-1203,271],
	[-8366,-936,31],
	[-8749,-68,-33],
	[-8271,-939,-17],
	[-7488,-895,223],
	[-8724,-250,-129],
	[-9062,-64,-129],
	[-9400,181,-129],
	[-9449,128,15],
	[-9042,130,143],
	[-8451,89,175],
	[-8560,-320,111],
	[-9243,-941,207],
	[-8676,-1216,143],
	[-9072,-1872,159],
	[-8224,-606,111],
	[-8540,-1588,-17],
	[-8833,-655,-49],
	[-9243,-901,-129],
	[-7328,-914,-17],
	[-9395,-1517,173],
	[-9816,-1887,111],
	[-9616,-1228,63],
	[-10130,-1307,31],
	[-9756,-1758,107],
	[-10172,-851,47],
	[-9591,-361,-44],
	[-9375,-1293,-129],
	[-9926,-310,-129],
	[-10074,-604,94],
	[-10129,-324,130],
	[-9599,-435,111],
	[-9963,-590,-52],
	[-10734,-1591,47],
	[-10301,-1915,63],
	[-10462,-1157,63],
	[-9324,-1740,-129],
	[-10148,-769,-113],
	[-9467,-2087,-113],
	[-9744,-1565,-97],
	[-10144,-1595,-129],
	[-10336,-352,-97],
	[-9680,-896,15],
	[-1188,-974,-97],
];
::M13PointSpots <- [
	[-5494,-892,4],
	[-6269,-1634,4],
	[-6882,-396,212],
	[-7700,-903,-60],
	[-7785,-909,148],
	[-8591,-912,-172],
	[-9673,-1516,4],
	[-8383,-241,-60],
	[-3248,-895,260],
	[-9060,-569,100],
	[-10401,-1431,4],
	[-5407,-1440,212],
	[-5866,-896,212],
	
	[-9680,-894,-172],
	[-6954,-910,-62],
	[-4432,-894,20],
];
//[-7540,103,-60],
//[-8740,-1311,-60],
//[-6382,206,-60],
//[-10439,-405,4],
::M13DuckProp <- "models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl"
PrecacheModel(M13DuckProp)
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })

::M13_GetPlacement <- function(list, maxpick)
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
::M13_TimerAdd <- function(add)
{
	local ent = null
	while(ent = Entities.FindByClassname(ent, "team_round_timer"))
	{
		M13Time = M13Time + add
		local newtime = M13Time
		EntFireByHandle(ent, "SetTime", newtime.tostring(), 0, null, null);
		SendGlobalGameEvent("teamplay_timer_time_added", {
			timer = ent.GetEntityIndex(),
			seconds_added = add,
		})
	}
}
::M13_DuckPickup <- function()
{
	Merc.ExtraGet(1, 4, 1)
	M13_TimerAdd(M13DuckBonusTime)
}

function M13_SpawnDuck(x, y, z)
{
	local prop = SpawnEntityFromTable("tf_halloween_pickup", {
		origin       = Vector(x,y,z - 18.0),
		angles       = QAngle(0,RandomInt(0, 181),0),
		targetname   = "mercduck",
		model 		 = M13DuckProp,
		powerup_model = M13DuckProp,
		pickup_particle = "taunt_headbutt_impact_stars",
		automaterialize = false,
		TeamNum = Merc.ForcedTeam,
		teamnumber = Merc.ForcedTeam,
	})
	prop.SetTeam(Merc.ForcedTeam)
	prop.ValidateScriptScope()
	prop.ConnectOutput("OnBluePickup", "M13_DuckPickup")
}

function M13_Clock()
{
	M13Time = M13Time - 1
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_point_captured = function(params)
	{
		if (params.team != Merc.ForcedTeam) return
		Merc.MainGet(1,1,1)
		local ent = null
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			M13Time = M13Time + M13PointBonusTime
			EntFireByHandle(ent, "SetTime", M13Time.tostring(), 0.1, null, null)
			SendGlobalGameEvent("teamplay_timer_time_added", {
				timer = ent.GetEntityIndex(),
				seconds_added = M13PointBonusTime,
			})
		}
	}
	
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			local times = M13MissionTime.tostring()
			EntFireByHandle(ent, "SetTime", times, 0, null, null)
		}
		M13Time = M13MissionTime
		Merc.Timer(1.0, 0, M13_Clock)
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		if (params.full_reset)
		{
			local area = null
			while (area = Entities.FindByClassname(area, "trigger_capture_area"))
			{
				local capName = GetPropString(area, "m_iszCapPointName")
				SetPropFloat(area, "m_flCapTime", 3)
				area.AcceptInput("SetControlPoint", capName, null, null)
			}
		}
		
		local places = M13_GetPlacement(M13DuckSpots, M13DuckCount)
		foreach (a in places)
		{
			M13_SpawnDuck(a[0], a[1], a[2])
		}
		
		local ent = null
		while (ent = Entities.FindByName(ent, "brush_blocker_finalarea"))
		{
			ent.Kill()
		}
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			ent.AcceptInput("SetSetupTime", "5", null, null)
		}
		ent = null
		local places = M13_GetPlacement(M13PointSpots, 3)
		local place = places[0]
		ent = Entities.FindByName(null, "capture_area_1")
		ent.AcceptInput("SetParent","control_point_1",ent,ent)
		ent = Entities.FindByName(null, "control_point_1")
		ent.SetAbsOrigin(Vector(place[0],place[1],place[2]))
		ent = Entities.FindByName(null, "prop_cap_2")
		ent.SetAbsOrigin(Vector(place[0],place[1],place[2]))
		place = places[1]
		ent = Entities.FindByName(null, "capture_area_2")
		ent.AcceptInput("SetParent","control_point_2",ent,ent)
		ent = Entities.FindByName(null, "control_point_2")
		ent.SetAbsOrigin(Vector(place[0],place[1],place[2]))
		ent = Entities.FindByName(null, "prop_cap_3")
		ent.SetAbsOrigin(Vector(place[0],place[1],place[2]))
		place = places[2]
		ent = Entities.FindByName(null, "capture_area_3")
		ent.AcceptInput("SetParent","control_point_3",ent,ent)
		ent = Entities.FindByName(null, "control_point_3")
		ent.SetAbsOrigin(Vector(place[0],place[1],place[2]))
		ent = Entities.FindByName(null, "prop_cap_4")
		ent.SetAbsOrigin(Vector(place[0],place[1],place[2]))
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

