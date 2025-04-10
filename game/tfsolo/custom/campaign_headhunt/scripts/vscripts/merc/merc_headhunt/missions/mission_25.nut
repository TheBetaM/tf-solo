// KOTH Viaduct BLU
::Merc <- {}
Merc.MissionID <- 25
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED,  2, "Headhunt_HandlerRED"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Headhunt_HandlerBLU"),
	
	Merc.Bot(TF_TEAM_RED, 2, "Snowboarder"),
	Merc.Bot(TF_TEAM_RED, 2, "Polar"),
	Merc.Bot(TF_TEAM_RED, 2, "Skier"),
	Merc.Bot(TF_TEAM_RED, 2, "Winter"),
	Merc.Bot(TF_TEAM_RED, 2, "Ushanka"),
	Merc.Bot(TF_TEAM_RED, 2, "Insulated"),
	Merc.Bot(TF_TEAM_RED, 2, "Coldfront"),
	Merc.Bot(TF_TEAM_RED, 2, "Tundra"),
	Merc.Bot(TF_TEAM_RED, 2, "Covert"),
	
	Merc.Bot(TF_TEAM_BLUE, 2, "Warmup"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Stomper"),
	Merc.Bot(TF_TEAM_BLUE, 2, "SubZero"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Breeze"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Heating"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Lawnmaker"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Mantel"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Cold"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Frostbite"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "(Team) Destroy buildings"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 50

Merc.Bots[0].Conds = [ TF_COND_REGENONDAMAGEBUFF ]
Merc.Bots[1].Conds = [ TF_COND_REGENONDAMAGEBUFF ]

::M25SentrySpots <- [
	[-1753,-2330,84, 0,270,0, 0],
	[-1883,-2959,84, 0,90,0, 0],
	[-931,-2867,167, 0,180,0, 0],
	[-1410,-2727,84, 0,270,0, 0],
	[-827,-3212,84, 0,90,0, 0],
	[-1721,-2154,84, 0,270,0, 0],
	[-1169,-2387,62, 0,270,0, 0],
	[-797,-2165,52, 0,270,0, 0],
	[-1943,-2282,148, 0,270,0, 0],
	[-1104,-1943,20, 0,270,0, 0],
	
	[-1950,-1836,148, 0,180,0, 0],
	[-1574,-2017,20, 0,90,0, 0],
	[-2217,-1577,229, 0,90,0, 0],
	[-458,-1942,148, 0,90,0, 0],
	[-1884,-1638,20, 0,90,0, 0],
	[-1394,-1629,15, 0,90,0, 0],
	[-1662,-1207,84, 0,270,0, 0],
	[-1230,-1194,180, 0,270,0, 0],
	[-270,-1762,157, 0,90,0, 0],
	[-1615,-1227,340, 0,270,0, 0],
	[-2015,-850,252, 0,270,0, 0],
	[-1908,-850,252, 0,270,0, 0],
	[-1830,-850,252, 0,270,0, 0],
	[-1706,-865,252, 0,90,0, 0],
	[-1424,-1202,180, 0,270,0, 0],
	[-1575,-850,180, 0,270,0, 0],
	[-969,-449,407, 0,270,0, 0],
	[-1303,-860,404, 0,270,0, 0],
	[-1302,-1227,404, 0,270,0, 0],
	[-837,-932,489, 0,0,0, 0],
	[-833,-643,389, 0,270,0, 0],
	[-2509,-1177,146, 0,270,0, 0],
	[-2501,-611,276, 0,270,0, 0],
	[-2293,-960,146, 0,270,0, 0],
	[-2727,-1061,160, 0,0,0, 0],
	[-2248,-161,276, 0,270,0, 0],
	[-2032,-605,276, 0,35,0, 0],
	[-2390,-28,356, 0,270,0, 0],
	[-1485,-777,156, 0,90,0, 0],
	[-1977,-97,276, 0,270,0, 0],
	[-1064,-202,260, 0,270,0, 0],
	[-1064,-101,260, 0,270,0, 0],
	[-1064,-1,260, 0,270,0, 0],
	[-1064,94,260, 0,270,0, 0],
	[-1064,177,260, 0,270,0, 0],
	[-993,-53,260, 0,270,0, 0],
	[-993,69,260, 0,270,0, 0],
	[-1346,-3,245, 0,270,0, 0],
	[-1716,-5,247, 0,270,0, 0],
	[-1536,141,245, 0,270,0, 0],
	[-1946,-649,153, 0,90,0, 0],
	[-817,-1043,155, 0,180,0, 0],
	[-2026,598,276, 0,270,0, 0],
	[-1986,83,276, 0,0,0, 0],
	[-1937,655,165, 0,270,0, 0],
	[-981,422,410, 0,180,0, 0],
	[-1390,286,266, 0,0,0, 0],
	[-1364,-277,265, 0,270,0, 0],
	[-1708,861,252, 0,270,0, 0],
	[-1230,870,180, 0,270,0, 0],
	[-2099,344,276, 0,270,0, 0],
	[-1414,1591,13, 0,270,0, 0],
	[-2458,1475,148, 0,270,0, 0],
	[-332,1666,153, 0,270,0, 0],
	[-2015,841,252, 0,90,0, 0],
	[-1847,2850,84, 0,270,0, 0],
	[-1028,2813,84, 0,270,0, 0],
	[-1346,2711,84, 0,270,0, 0],
	[-1939,-405,276, 0,270,0, 0],
	[-1290,873,404, 0,270,0, 0],
	
	//[-1544,-1897,181, 90,180,0, 0], //
	//[-2293,-1792,340, 90,90,0, 0],//
	//[-1534,-808,349, 90,270,0, 0],//
	//[-1534,-798,349, 90,90,0, 0], //
	//[-2029,-9,433, 90,0,0, 0], //
];

function MercSpawnSentry(x,y,z,rotx,roty,rotz,lev)
{
	local tempEnt = SpawnEntityFromTable("obj_sentrygun", {
		origin       = Vector(x,y,z - 20.0),
		angles       = QAngle(rotx, roty, rotz),
		targetname = "worldsentry",
		TeamNum = TF_TEAM_RED,
		defaultupgrade = lev,
		SolidToPlayer = 1,
	})
	SetPropBool(tempEnt, "m_bMiniBuilding", true)
	tempEnt.SetSkin(tempEnt.GetSkin() + 2)
	tempEnt.SetModelScale(0.75, 0)
}

Merc.BeforeRoundStart <- function(params)
{
	SetSkyboxTexture("sky_nightfall_01")
	local ent = null
	PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "env_snow_stormfront_001" })
	while (ent = Entities.FindByName(ent, "particle_snow_01"))
	{
		ent.AcceptInput("Stop", "", null, null)
		local tempEnt = SpawnEntityFromTable("info_particle_system", {
			origin       = ent.GetOrigin(),
			angles       = ent.EyeAngles(),
			effect_name = "env_snow_stormfront_001",
			start_active = true,
		})
		tempEnt.AcceptInput("Start", "", null, null)
	}
	while (ent = Entities.FindByClassname(ent, "env_fog_controller"))
	{
		ent.AcceptInput("SetColor", "0 0 0", null, null)
		ent.AcceptInput("SetColorSecondary", "0 0 0", null, null)
		ent.AcceptInput("SetEndDist", "1200", null, null)
	}
	while (ent = Entities.FindByClassname(ent, "tf_logic_koth"))
	{
		ent.AcceptInput("SetRedTimer", "600", ent, ent)
		ent.AcceptInput("SetBlueTimer", "300", ent, ent)
	}
	local ent2 = SpawnEntityFromTable("color_correction", {
		minfalloff = -1,
		maxfalloff = -1,
		filename = "tfhallway.raw",
	})
	
	foreach (i in M25SentrySpots)
	{
		MercSpawnSentry(i[0],i[1],i[2],i[3],i[4],i[5],i[6])
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_object_destroyed = function(params)
	{
		if (params.attacker == 0) return
		local player = GetPlayerFromUserID(params.attacker)
		if (player.GetTeam() != Merc.ForcedTeam) return
		Merc.ExtraGet(1,3,3)
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

