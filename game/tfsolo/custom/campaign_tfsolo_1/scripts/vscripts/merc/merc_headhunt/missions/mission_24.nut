// KOTH Viaduct RED
::Merc <- {}
Merc.MissionID <- 24
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED,  2, "Headhunt_HandlerRED"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Headhunt_HandlerBLU"),
	
	Merc.Bot(TF_TEAM_BLUE, 2, "Warmup"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Stomper"),
	Merc.Bot(TF_TEAM_BLUE, 2, "SubZero"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Breeze"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Heating"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Lawnmaker"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Mantel"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Cold"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Frostbite"),
	
	Merc.Bot(TF_TEAM_RED, 2, "Snowboarder"),
	Merc.Bot(TF_TEAM_RED, 2, "Polar"),
	Merc.Bot(TF_TEAM_RED, 2, "Skier"),
	Merc.Bot(TF_TEAM_RED, 2, "Winter"),
	Merc.Bot(TF_TEAM_RED, 2, "Ushanka"),
	Merc.Bot(TF_TEAM_RED, 2, "Insulated"),
	Merc.Bot(TF_TEAM_RED, 2, "Coldfront"),
	Merc.Bot(TF_TEAM_RED, 2, "Tundra"),
	Merc.Bot(TF_TEAM_RED, 2, "Covert"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "(Team) Destroy buildings"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 40

Merc.Bots[0].Conds = [ TF_COND_REGENONDAMAGEBUFF ]
Merc.Bots[1].Conds = [ TF_COND_REGENONDAMAGEBUFF ]

::M24SentrySpots <- [
	[-1503,2177,108, 90, 1],
	[-800,2211,77, 90, 0],
	[-2030,2151,173, 90, 0],
	[-1704,1916,45, 0, 2],
	[-685,1178,432, 90, 2],
	[-1352,1205,205, 90, 2],
	[-2502,1040,172, 90, 2],
	[-1734,953,277, 0, 0],
	[-1710,855,277, 270, 0],
	[-2030,602,301, 315, 0],
	[-1305,858,429, 0, 0],
	[-1665,1191,109, 90, 2],
	[-977,443,434, 90, 0],
	[-1056,-4,285, 180, 2],
	[-2183,57,301, 90, 1],
	[-1965,-263,301, 90, 2],
	[-1707,-866,277, 90, 0],
	[-969,-455,433, 180, 0],
	[-1230,-875,205, 90, 2],
	[-1743,-951,277, 0, 0],
	[-1695,-1193,109, 270, 2],
	[-1379,-1689,46, 90, 2],
	[-435,-1640,173, 90, 2],
	[-2399,-1662,173, 90, 2],
	[-1778,-1939,45, 90, 2],
	[-1045,-2822,109, 90, 0],
	[-1855,-2833,109, 90, 0],
	[-846,-3184,109, 90, 0],
	[-1307,-2515,45, 90, 0],
	[-2014,-851,277, 270, 0],
];
::M24DispSpots <- [
	[-822,3188,93, 0],
	[-1900,2945,93, 0],
	[-1356,2049,96, 0],
	[-2128,2478,38, 0],
	[-1969,1838,157, 0],
	[-616,1996,61, 0],
	[-1341,1363,49, 90],
	[-1522,826,189, 90],
	[-2011,843,261, 90],
	[-2361,121,285, 90],
	[-1949,-467,285, 90],
	[-1046,120,269, 90],
	[-1041,-130,269, 90],
	[-2215,-292,285, 90],
	[-2529,-616,285, 90],
	[-1532,-509,185, 90],
	[-984,-545,250, 90],
	[-1434,148,255, 90],
	[-1651,-138,249, 90],
	[-969,-3091,93, 90],
];

function MercSpawnSentry(x,y,z,rot,lev)
{
	local isMini = false
	if (lev > 2)
	{
		isMini = true
		lev = 0
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
		SetPropBool(tempEnt, "m_bMiniBuilding", true)
		tempEnt.SetSkin(tempEnt.GetSkin() + 2)
		tempEnt.SetModelScale(0.75, 0)
	}
}
function MercSpawnDispenser(x,y,z,rot)
{
	local tempEnt = SpawnEntityFromTable("obj_dispenser", {
		origin       = Vector(x,y,z - 30.0),
		angles       = QAngle(0.0, rot, 0.0),
		targetname = "worlddispenser",
		TeamNum = TF_TEAM_BLUE,
		defaultupgrade = 2,
		SolidToPlayer = 1,
	})
}

Merc.BeforeRoundStart <- function(params)
{
	SetSkyboxTexture("sky_nightfall_01")
	local ent = null
	PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "env_snow_stormfront_001" })
	while (ent = Entities.FindByName(ent, "particle_snow_01"))
	{
		ent.AcceptInput("Stop", "", null, null);
		local tempEnt = SpawnEntityFromTable("info_particle_system", {
			origin       = ent.GetOrigin(),
			angles       = ent.EyeAngles(),
			effect_name = "env_snow_stormfront_001",
			start_active = true,
		})
		tempEnt.AcceptInput("Start", "", null, null)
	}
	while( ent = Entities.FindByClassname(ent, "env_fog_controller") )
	{
		ent.AcceptInput("SetColor", "0 0 0", null, null)
		ent.AcceptInput("SetColorSecondary", "0 0 0", null, null)
		ent.AcceptInput("SetEndDist", "1200", null, null)
	}
	while( ent = Entities.FindByClassname(ent, "tf_logic_koth") )
	{
		ent.AcceptInput("SetBlueTimer", "600", ent, ent)
		ent.AcceptInput("SetRedTimer", "300", ent, ent)
	}
	local ent2 = SpawnEntityFromTable("color_correction", {
		minfalloff = -1,
		maxfalloff = -1,
		filename = "tfhallway.raw",
	})
	
	foreach (i in M24SentrySpots)
	{
		MercSpawnSentry(i[0],i[1],i[2],i[3],i[4])
	}
	foreach (i in M24DispSpots)
	{
		MercSpawnDispenser(i[0],i[1],i[2],i[3])
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

