// CP Mossrock
::Merc <- {}
Merc.MissionID <- 21
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_SPY
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED, 1, "Fool"),
	Merc.Bot(TF_TEAM_RED, 1, "Jester"),
	Merc.Bot(TF_TEAM_RED, 1, "Control"),
	Merc.Bot(TF_TEAM_RED, 1, "Guard2"),
	Merc.Bot(TF_TEAM_RED, 1, "Prince"),
	Merc.Bot(TF_TEAM_RED, 1, "King"),
	Merc.Bot(TF_TEAM_RED, 1, "Lifter"),
	Merc.Bot(TF_TEAM_RED, 1, "Rough"),
	Merc.Bot(TF_TEAM_RED, 1, "Baron"),
	Merc.Bot(TF_TEAM_RED, 1, "Monarch"),
	Merc.Bot(TF_TEAM_RED, 1, "Woodsman"),
	Merc.Bot(TF_TEAM_RED, 1, "Camouflage"),
]
Merc.ObjectiveText <- "Capture the point"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Destroy all dispensers"
Merc.ObjectiveExtraCount <- 0
M21_DispCount <- 16
Merc.ObjectiveExtraMax <- M21_DispCount

foreach (i, a in Merc.Bots)
{
	Merc.Bots[i].BotAttribs = [ REMOVE_ON_DEATH ]
}

::M21_DispPlaces <- [
	[-2129,-625,-115, 0],
	[-3225,-2407,-241, 0],
	[-1821,-1694,-188, 0],
	[-1698,-1274,-51, 0],
	[-1505,-241,-51, 0],
	[-746,-2098,5, 0],
	[-1379,-810,-51, 0],
	[287,-67,-267, 0],
	[546,562,-275, 0],
	[-84,-1610,117, 0],
	[-312,1008,-340, 0],
	[-531,-855,-115, 0],
	[567,-1621,-78, 0],
	//[1064,-66,-147, 90],
	[1573,-777,-99, 0],
	[199,-91,-51, 0],
	[1625,10,-144, 0],
	[1327,784,63, 0],
	[1367,396,157, 0],
	[1840,-669,175, 0],
	[1817,15,93, 0],
	[2335,781,93, 0],
	[2929,353,93, 0],
	[1990,-351,-83, 90],
	[1842,328,-139, 90],
	[2252,-253,-144, 0],
	[1379,-515,-99, 0],
	[1999,-886,-115, 0],
	[3665,-1035,-232, 0],
	[3793,-370,61, 0],
	[4170,432,5, 0],
	[3949,-35,-240, 0],
	[3494,-635,-51, 90],
	[3509,-161,-51, 90],
	[3511,-471,-275, 0],
	[3844,665,-50, 90],
	[3081,271,21, 90],
	[-481,-1077,33, 0],
	[-3423,-837,-283, 0],
	[-2502,-1341,-285, 0],
	[-672,372,-3, 0],
	
	[1411,-531,-210, 0],
	[1891,607,210, 0],
	[-2296,-1833,-31, 0],
	[-1538,-991,-172, 0],
	[-207,1043,-2, 0],
	[-368,-1639,66, 0],
	[-358,-1169,41, 0],
	[1259,705,-118, 0],
	[3744,-282,323, 0],
	[3744,-505,323, 0],
]
::M21_SentryPlaces <- [
	[-2016,-1024,-92, 215, 2],
	[-1939,-1963,-35, 180, 2],
	[-1199,-924,-35, 0, 1],
	[211,-1099,-35, 180, 1],
	[44,652,-35, 180, 1],
	[1375,-920,-83, 180, 1],
	[1581,578,-35, 180, 1],
	[3846,-816,77, 180, 1],
	[3333,-607,-35, 180, 0],
	[3333,-185,-35, 0, 0],
	[3475,157,37, 270, 0],
	[3863,239,21, 180, 0],
	[2848,-288,-3, 0, 0],
	[3760,-394,340, 180, 1],
	[2040,87,109, 0, 1],
]

::M21_GetPropPlacement <- function(list)
{
	local places = [], full = []
	local maxpick = M21_DispCount
	foreach (a in list) full.push(a)
	for (local i = 0; i < maxpick; i++)
	{
		local a = RandomInt(0, full.len() - 1)
		places.push(full[a])
		full.remove(a)
	}
	return places
}

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
		TeamNum = TF_TEAM_RED,
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
		TeamNum = TF_TEAM_RED,
		defaultupgrade = 2,
		SolidToPlayer = 1,
	})
}

Merc.BeforeRoundWin <- function(params)
{
	if (params.team == Merc.ForcedTeam)
	{
		Merc.MainGet(1,1,1)
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		local ent = null
		while (ent = Entities.FindByName(ent, "cp_1A"))
		{
			EntFireByHandle(ent, "SetOwner", "3", -1, ent, ent)
		}
		while (ent = Entities.FindByName(ent, "cp_1B"))
		{
			EntFireByHandle(ent, "SetLocked", "0", -1, ent, ent)
			ent.KeyValueFromInt("area_time_to_cap", 3)
		}
		while (ent = Entities.FindByName(ent, "cp_1A"))
		{
			EntFireByHandle(ent, "SetLocked", "0", -1, ent, ent)
		}
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			EntFireByHandle(ent, "SetTime", "600", 0, null, null)
		}
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
		
		local ent = null
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			ent.AcceptInput("SetSetupTime", "30", null, null);
		}
		while (ent = Entities.FindByName(ent, "cp_1B"))
		{
			SetPropString(ent, "team_previouspoint_3_0", "")
			SetPropInt(ent, "m_iDefaultOwner", 2)
		}
		
		local places = M21_GetPropPlacement(M21_DispPlaces)
		foreach (a in places)
		{
			MercSpawnDispenser(a[0],a[1],a[2],a[3])
		}
		foreach (a in M21_SentryPlaces)
		{
			MercSpawnSentry(a[0],a[1],a[2],a[3],a[4])
		}
	}
	
	OnGameEvent_teamplay_point_captured = function(params)
	{
		if (params.team != Merc.ForcedTeam) return
		Merc.ForceWin()
	}
	
	OnGameEvent_object_destroyed = function(params)
	{
		local player = GetPlayerFromUserID(params.attacker)
		if (params.attacker == 0 || player.GetTeam() != Merc.ForcedTeam) return
		if (params.objecttype != 0) return
		Merc.ExtraGet(1,4,2)
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

