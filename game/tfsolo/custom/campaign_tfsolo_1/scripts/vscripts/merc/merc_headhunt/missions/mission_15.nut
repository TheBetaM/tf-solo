// PL Thunder Mountain
::Merc <- {}
Merc.MissionID <- 15
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED, 1, "Builder"),
	Merc.Bot(TF_TEAM_RED, 2, "Torcher"),
	Merc.Bot(TF_TEAM_RED, 1, "Pathfinder"),
	Merc.Bot(TF_TEAM_RED, 1, "Blast"),
	Merc.Bot(TF_TEAM_RED, 2, "Brute"),
	Merc.Bot(TF_TEAM_RED, 1, "Tacticals"),
	
	Merc.Bot(TF_TEAM_BLUE, 1, "Charmer"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Hound"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Freeman"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Afro"),
]
Merc.ObjectiveText <- "Push the cart along the new path and win"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get exactly 1 kill only"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1

SetRoundToPlayNext("round_b")

::M15Props <- [
	"models/props_mining/track_straight_256.mdl",
	"models/props_mining/track_straight_64.mdl",
	"models/props_mining/track_arc_90degree_128.mdl",
	"models/props_mining/track_arc_45degree.mdl",
	"models/props_mining/track_straight_128.mdl",
	"models/props_mining/track_straight_32.mdl",
];
foreach (i in M15Props)
{
	PrecacheModel(i)
}

::M15PropSpots <- [
	[0, -4604,2447,451, 0,345,0],
	[0, -4669,2202,451, 0,345,0],
	[3, -4693,2075,451, 0,30,0],
	[0, -4629,1894,445, 0,30,3],
	[0, -4502,1673,441, 0,30,-1.5],
	[0, -4375,1454,448, 0,30,-1.5],
	[0, -4248,1234,452, 0,30,-0.5],
	[3, -4180.5,1135,453.25, 0,75,0],
	[0, -4000,1078,455, 0,90,-1],
	[0, -3755,1078,484.5, 0,90,-12],
	[0, -3503,1078,521, 0,90,-5],
	[2, -3314,1116,533, 0,180,0],
	[4, -3276,1242,537, 0,0,4],
	[2, -3239,1367,541.25, 0,0,0],
	[4, -3112,1404,535.25, 0,90,5],
	[0, -2924.25,1402.5,503.5, 0,90,12],
	[3, -2804,1419,477, 0,135,0],
	[4, -2685,1474,464, 0,132.75,12],
	[1, -2614,1539,451, 0,132,0],
	[3, -2599,1560,451, 0,180,0],
	[4, -2561,1695,451, 0,0,0],
	
	[2, -1832,2661,452, 0,180,0],
	[4, -1795,2788,452, 0,0,0],
	[2, -1757,2914,452, 0,0,0],
	[4, -1631,2952,452, 0,270,0],
	[5, -1551,2952,452, 0,180,0],
	[5, -1535,2952,452, 0,180,0],
	[0, -1405,2952,394, 0,90,27],
	[4, -1236,2952,307, 0,90,27],
	[5, -1165,2952,271, -27,180,0],
	[0, -1023,2952,259, 0,90,0],
	[4, -832,2952,259, 0,90,0],
	[2, -705,2915,259, 0,270,0],
	[0, -668,2725,259, 0,0,0],
	[4, -668,2535,259, 0,0,0],
	[2, -631,2413,259, 0,90,0],
	[5, -552,2376,259, 0,180,0],
	[5, -537,2376,259, 0,180,0],
	[0, -272,2376,259, 0,270,0],
	[4, -463,2376,259, 0,270,0],
	[2, -82,2339,259, 0,270,0],
	[2, -6,2215,259, 0,90,0],
]
::M15Tracks <- [
	["001",0, -4581,2532,504],
	["002",0, -4704,2067,504],
	["003",0, -4698,2016,504],
	["004",0, -4171,1106,504],
	["50",0, -4126,1078,504],
	["51",1, -3883,1078,504],
	["52",1, -3630,1078,550],
	["53",1, -3376,1078,590],
	["54",0, -3325,1092,590],
	["55",0, -3290,1126,589],
	["56",0, -3276,1178,589],
	["57",0, -3276,1305,589],
	["58",0, -3257,1361,589],
	["59",0, -3226,1390,589],
	["60",0, -3176,1404,589],
	["61",0, -3049,1403,576],
	["62",0, -2800,1404,527],
	["63",0, -2760,1412,527],
	["64",0, -2730,1432,527],
	["65",0, -2638,1518,504],
	["66",0, -2591,1560,504],
	["67",0, -2574,1581,504],
	["68",0, -2565,1603,504],
	["69",0, -2562,1627,504],
	["70",0, -2561,1649,504],
	["70_1",0, -2561,1676,504],
	["70_2",0, -2561,1701,504],
	["70_3",0, -2561,1730,504],
	
	["71",0, -1882,2623,504],
	["72",0, -1795,2738,504],
	["73",0, -1795,2864,504],
	["74",0, -1706,2952,504],
	["75",2, -1471,2952,504],
	["76",2, -1110,2952,312],
	["77",0, -748,2952,312],
	["78",0, -667,2862,312],
	["79",0, -667,2476,312],
	["80",0, -567,2376,312],
	["82",0, -142,2376,312],
	["83",0, -74,2345,312],
	["88",0, -44,2252,312],
	["89",0, 43,2176,312],
]

function M15_SpawnProp(modelname, x, y, z, rotx, roty, rotz, ptype)
{
	local prop = SpawnEntityFromTable("prop_dynamic", {
		origin       = Vector(x,y,z - 0.0),
		angles       = QAngle(rotx, roty, rotz),
		model 		 = modelname,
		targetname   = "mercprop",
		solid		 = 6,
	})
	if (ptype == 0)
	{
		prop.SetSolid(0)
	}
}
function M15_MoveTrack(sname, t, x, y, z)
{
	local name = "cart_path_" + sname
	local ent = null
	local flag = 0
	if (t == 1) flag = 32
	if (t == 2) flag = 64
	while (ent = Entities.FindByName(ent, name))
	{
		ent.SetAbsOrigin(Vector(x,y,z - 0.0))
		SetPropInt(ent, "m_spawnflags", flag)
		break
	}
}

Merc.BeforeRoundWin <- function(params)
{
	if (params.team != Merc.ForcedTeam) return
	Merc.MainGet(1,1,1)
	if (!Merc.ExtraFailed)
	{
		if (Merc.ObjectiveExtraCount != Merc.ObjectiveExtraMax)
		{
			Merc.ExtraFail()
			Merc.ChatPrint("Bonus objective failed! Not enough kills.")
		}
		else
		{
			Merc.ExtraGet(1,2,2)
		}
	}
}


Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_round_selected = function(params)
	{
		SetRoundToPlayNext("round_b")
	}
	
	OnGameEvent_teamplay_restart_round = function(params)
	{
		SetRoundToPlayNext("round_b")
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		SetRoundToPlayNext("round_b")
		foreach (a in M15PropSpots)
		{
			M15_SpawnProp(M15Props[a[0]],a[1],a[2],a[3], a[4],a[5],a[6], 0)
		}
		foreach (a in M15Tracks)
		{
			M15_MoveTrack(a[0],a[1],a[2],a[3],a[4])
		}
		local ent = null
		while (ent = Entities.FindByName(ent, "cart_path_001"))
		{
			ent.SetAbsAngles(QAngle(0,255,0))
			break
		}
	}

	OnGameEvent_player_death = function(params)
	{
		if (Merc.RoundEnded || Merc.ExtraFailed) return
		local player = GetPlayerFromUserID(params.userid)
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		if (IsPlayerABot(aplayer)) return
		
		Merc.ObjectiveExtraCount = Merc.ObjectiveExtraCount + 1
		Merc.UpdateHUD()
		if (Merc.ObjectiveExtraCount > Merc.ObjectiveExtraMax)
		{
			Merc.ExtraFail()
			Merc.ObjectiveExtraCount = 0
			Merc.ChatPrint("Bonus objective failed! Too many kills.")
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

