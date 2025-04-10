// KOTH Sawmill
::Merc <- {}
Merc.MissionID <- 19
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_SNIPER
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- []
Merc.ObjectiveText <- "Break all the targets"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveExtraText <- "Reach the target score"
Merc.ObjectiveExtraCount <- 0
Merc.IgnoreExtraCap <- 1
Merc.AllowRecruits <- 0

Convars.SetValue("mp_disable_respawn_times", 1)

::M19PropPickCount <- 30
Merc.ObjectiveMainMax <- M19PropPickCount
Merc.ObjectiveExtraMax <- 200
::M19StartScore <- 50
::M19PropAddScore <- 10
::M19TimeFalloff <- 1
::M19Score <- M19StartScore
::M19GlowOn <- 0

PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "doublejump_smoke" })
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "hit_text" })

::M19Props <- [
	"models/props_gameplay/orange_cone001.mdl",
	"models/props_training/target_scout.mdl",
	"models/props_training/target_soldier.mdl",
	"models/props_training/target_pyro.mdl",
	"models/props_training/target_demoman.mdl",
	"models/props_training/target_heavy.mdl",
	"models/props_training/target_engineer.mdl",
	"models/props_training/target_medic.mdl",
	"models/props_training/target_sniper.mdl",
	"models/props_training/target_spy.mdl",
	"models/props_mining/fence001_reference.mdl",
];
foreach (i in M19Props)
{
	PrecacheModel(i)
}

::M19BlockerSpots <- [
	[10, 184,567,142, 0,270,0],
	[10, 840,-567,142, 0,90,0],
	[10, 512,567,362, 0,270,0],
	[10, 512,-567,362, 0,90,0],
	[10, 1416,146,162, 0,180,0],
	[10, 1416,16,162, 0,180,0],
	[10, 1416,-106,162, 0,180,0],
	[10, 1416,-234,162, 0,180,0],
	[10, 1416,146,234, 0,180,0],
	[10, 1416,16,234, 0,180,0],
	[10, 1416,-106,234, 0,180,0],
	[10, 1416,-234,234, 0,180,0],
	[10, -391,-166,148, 0,0,0],
	[10, -391,-38,148, 0,0,0],
	[10, -391,86,148, 0,0,0],
	[10, -391,212,148, 0,0,0],
	[10, -391,-166,228, 0,0,0],
	[10, -391,-38,228, 0,0,0],
	[10, -391,86,228, 0,0,0],
	[10, -391,212,228, 0,0,0],
]
::M19FakeBlockerSpots <- [
	[0, 488,576,318, 0,0,0],
	[0, 539,576,318, 0,0,0],
	[0, 539,-576,318, 0,0,0],
	[0, 488,-576,318, 0,0,0],
	[0, -410,-156,98, 0,0,0],
	[0, -408,-56,102, 0,0,0],
	[0, -405,38,106, 0,0,0],
	[0, -412,148,151, 0,0,0],
	[0, 1439,146,104, 0,0,0],
	[0, 1440,41,103, 0,0,0],
	[0, 1445,-92,100, 0,0,0],
	[0, 1444,-188,101, 0,0,0],
	[0, 838,-600,102, 0,0,0],
	[0, 188,600,102, 0,0,0],
]
::M19AmmoPacks <- [
	[1, 512,0,120],
	[0, -66,520,110],
	[0, 1099,-520,110],
	[0, 1080,484,180],
	[0, -52,-484,180],
]
::M19PropSpots <- [
	[6, 462,-361,120, 0,90,0],
	[6, 538,-496,120, 0,0,0],
	[6, 320,517,336, 0,0,0],
	[6, 712,-532,336, 0,180,0],
	[6, 509,437,120, 0,90,0],
	[6, 400,383,120, 0,180,0],
	[6, 1271,-7,128, 0,180,0],
	[6, -277,-7,128, 0,0,0],
	[6, -113,325,120, 0,0,0],
	[6, 1138,-356,120, 0,180,0],
	
	[6, -661,-11,206, 0,340,0],
	[6, -1132,74,146, 0,0,0],
	[6, -827,-484,71, 0,90,0],
	[6, -1690,987,-40, 0,330,0],
	[6, -425,259,119, 0,270,0],
	[6, -724,508,42, 0,270,0],
	[6, -958,719,-80, 0,315,0],
	[6, -671,-263,97, 0,0,0],
	[6, -1190,994,312, 0,330,0],
	[6, -1053,1232,312, 0,330,0],
	
	[6, 1589,113,116, 0,150,0],
	[6, 2135,0,85, 0,180,0],
	[6, 2275,-708,-39, 0,140,0],
	[6, 1525,472,73, 0,270,0],
	[6, 2054,355,84, 0,180,0],
	[6, 1528,-585,-22, 0,60,0],
	[6, 1811,-1428,-86, 0,90,0],
	[6, 2458,-8,344, 0,180,0],
	[6, 2458,-272,344, 0,180,0],
	[6, 2548,-424,22, 0,180,0],
	
	[6, 227,-1017,-43, 0,0,0],
	[6, 833,-990,-54, 0,90,0],
	[6, 82,-1678,-76, 0,45,0],
	[6, 1313,-821,-48, 0,145,0],
	[6, 634,-988,-12, 0,90,0],
	[6, 1237,-1317,-56, 0,90,0],
	[6, 590,-1343,-69, 0,90,0],
	[6, 907,-1332,-56, 0,90,0],
	[6, 290,-1886,104, 0,90,0],
	[6, 217,-892,196, 0,0,0],
	
	[6, 369,980,-3, 0,245,0],
	[6, -161,982,-10, 0,330,0],
	[6, 709,1150,-54, 0,190,0],
	[6, 821,1826,-84, 0,245,0],
	[6, -93,1331,-56, 0,270,0],
	[6, 314,1332,-56, 0,270,0],
	[6, 644,866,-28, 0,180,0],
	[6, 725,1221,59, 0,190,0],
	[6, 717,1977,-13, 0,270,0],
	[6, 1109,1918,-96, 0,215,0],
	
	[6, 363,-625,343, 0,0,0],
	[6, 44,-1101,376, 0,0,0],
	[6, 726,-1991,206, 0,90,0],
	[6, 1079,-1069,304, 0,90,0],
	[6, 684,-1172,216, 0,90,0],
	[6, 2222,-1626,155, 0,180,0],
	[6, 735,-2235,638, 0,90,0],
	[6, 1023,-1462,496, 0,135,0],
	[6, 1880,-1950,581, 0,135,0],
	[6, 1987,-1778,391, 0,135,0],
	
	[6, 713,847,294, 0,215,0],
	[6, 30,1369,274, 0,270,0],
	[6, -118,1200,348, 0,330,0],
	[6, -199,831,152, 0,0,0],
	[6, 1456,1507,272, 0,215,0],
	[6, 1683,1266,272, 0,200,0],
	[6, 193,1624,498, 0,270,0],
	[6, 656,1058,286, 0,270,0],
	[6, 391,1450,132, 0,270,0],
	[6, 512,676,343, 0,270,0],
]

::M19_GlowAll <- function()
{
	if (M19GlowOn != 0) return
	M19GlowOn = 1
	local ent = null
	while (ent = Entities.FindByClassname(ent, "prop_dynamic"))
	{
		ent.ValidateScriptScope()
		local scope = ent.GetScriptScope()
		if ("M19PropState" in scope)
		{
			local glow = Entities.CreateByClassname("tf_glow")
			glow.KeyValueFromString("GlowColor", "255 255 255 255")
			SetPropInt(glow, "m_iMode", 0)
			SetPropEntity(glow, "m_hTarget", ent)
		}
	}
}

::M19_GetPropPlacement <- function(id, list)
{
	local places = [], full = []
	local maxpick = M19PropPickCount
	foreach (a in list) full.push(a)
	for (local i = 0; i < maxpick; i++)
	{
		local a = RandomInt(0, full.len() - 1)
		places.push(full[a])
		full.remove(a)
	}
	return places
}

::M19_PropDestroyed <- function()
{
	Merc.MainGet(1, 4, 1)
	M19Score = M19Score + M19PropAddScore
	if (Merc.ObjectiveMainCount >= Merc.ObjectiveMainMax - 1)
	{
		M19_GlowAll()
	}
	Merc.ObjectiveExtraCount = M19Score;
	if (Merc.ObjectiveMainCount >= Merc.ObjectiveMainMax)
	{
		if (Merc.ObjectiveExtraCount >= Merc.ObjectiveExtraMax)
			Merc.ExtraGet(0, 0, 2)
		Merc.ForceWin()
	}
	Merc.ObjectiveExtraAdd = " +" + M19PropAddScore;
}

function M19_SpawnProp(modelname, x, y, z, rotx, roty, rotz, ptype)
{
	local offset = 20.0
	local petype = "prop_dynamic"
	local mname = modelname
	if (ptype == 0) 
	{
		offset = 40.0
		mname = M19Props[RandomInt(1, 9)]
	}
	else if (ptype == 1) offset = 36.0
	else petype = "prop_dynamic_override"
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
		prop.SetTeam(TF_TEAM_RED)
		prop.ValidateScriptScope()
		prop.GetScriptScope()["M19PropState"] <- 0
		prop.GetScriptScope()["M19PropDestroy"] <- function(){
			if (M19PropState != 0) return
			M19PropState = 1
			M19_PropDestroyed()
			DispatchParticleEffect("hit_text", Vector(x,y,z), Vector(0,0,0));
			DispatchParticleEffect("doublejump_smoke", Vector(x,y,z), Vector(0,0,0));
			if (self != null)
				self.AcceptInput("Break","",self,self)
		}
		prop.ConnectOutput("OnTakeDamage", "M19PropDestroy")
	}
	else if (ptype == 1)
	{
		prop.DisableDraw()
		//prop.SetCollisionGroup(0)
		prop.SetCollisionGroup(25)
	}
	else
	{
		//prop.SetSolid(0)
	}
	
	return prop
}
function M19_SpawnAmmo(t, x, y, z)
{
	local tstr = "item_ammopack_medium"
	if (t == 0) tstr = "item_ammopack_small"
	else if (t == 2) tstr = "item_ammopack_full"
	local prop = SpawnEntityFromTable(tstr, {
		origin       = Vector(x,y,z - 24.0),
		angles       = QAngle(0,0,0),
		targetname   = "mercammo",
	})
	return prop
}
function M19_Clock()
{
	if (Merc.ExtraDone || Merc.RoundEnded || Merc.MainDone) return
	if (M19Score <= 0)
	{
		M19_GlowAll()
		M19PropAddScore = 9
		return;
	}
	M19Score = M19Score - M19TimeFalloff
	if (M19Score < 0)
	{
		M19Score = 0
	}
	Merc.ObjectiveExtraCount = M19Score
	Merc.ObjectiveExtraAdd = ""
	Merc.UpdateHUD()
}

Merc.BeforeRoundStart <- function(params)
{
	M19Score = M19StartScore
	M19GlowOn = 0
	M19PropAddScore = 10
	Merc.Timer(1.0, 0, M19_Clock)
	local ent = null
	while (ent = Entities.FindByName(ent, "master_control_point"))
	{
		ent.DisableDraw()
		ent.AcceptInput("Disable", "", null, null)
	}
	while (ent = Entities.FindByName(ent, "prop_cap_1"))
	{
		ent.Kill()
	}
	while (ent = Entities.FindByName(ent, "control_point_1"))
	{
		ent.DisableDraw()
		ent.AcceptInput("Disable", "", null, null)
	}
	while (ent = Entities.FindByName(ent, "capture_area_1"))
	{
		ent.AcceptInput("SetTeamCanCap", "3 0", null, null)
		ent.DisableDraw()
		ent.AcceptInput("Disable", "", null, null)
	}
	while (ent = Entities.FindByClassname(ent, "ambient_generic"))
	{
		local name = GetPropString(ent, "m_sSourceEntName")
		if (name == "sawblade01" || name == "sawblade02")
		{
			ent.AcceptInput("Volume", "1", null, null)
		}
	}
	
	local places = M19_GetPropPlacement(0, M19PropSpots)
	foreach (a in places)
	{
		M19_SpawnProp(M19Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 0)
	}
	foreach (a in M19BlockerSpots)
	{
		M19_SpawnProp(M19Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 1)
	}
	foreach (a in M19FakeBlockerSpots)
	{
		M19_SpawnProp(M19Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 2)
	}
	foreach (a in M19AmmoPacks)
	{
		M19_SpawnAmmo(a[0], a[1], a[2], a[3])
	}
	foreach (a in GetClients()) 
	{
		a.Teleport(true, Vector(508,272,140), true, QAngle(0, 270, 0), true, Vector(0, 0, 0))
	}
}

Merc.BeforePlayerSpawn <- function(params)
{
	local player = GetPlayerFromUserID(params.userid)
	player.Teleport(true, Vector(508,272,140), true, QAngle(0, 270, 0), true, Vector(0, 0, 0))
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		if (Merc.RoundEnded) return
		Merc.ForceFail()
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])


