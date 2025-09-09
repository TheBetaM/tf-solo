// CP Gorge
::Merc <- {}
Merc.MissionID <- 7
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_ENGINEER
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_BLUE, 1, "Frenchman"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Flak"),
	Merc.Bot(TF_TEAM_BLUE, 0, "Campus"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Pyromancer"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Trashman"),
]
Merc.ObjectiveText <- "Defend the point until time runs out"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Upgrade all dispensers to level 3"
Merc.ObjectiveExtraCount <- 0
::M07_DispCount <- 7
Merc.ObjectiveExtraMax <- M07_DispCount

::M07_DispPlaces <- [
	[-6025,1928,-67, 90],
	[-6421,1709,-67, 135],
	[-5607,1716,-67, 45],
	[-5465,1133,-67, 0],
	[-6567,1146,-67, 180],
	[-6164,1928,-67, 90],
	[-5882,1928,-67, 90],
	[-5459,1503,-67, 0],
	[-6562,1503,-67, 180],
	[-6017,1732,-67, 90],
	
	[-6661,1769,125, 90],
	[-6439,850,189, 45],
	[-5454,773,125, 90],
	[-5007,399,189, 90],
	//[-5471,1984,125, 90],
	[-6009,119,189, 90],
]
::M07_SentryPlaces <- [
	[-5572,1420,149, 90, 1],
	[-6464,1437,141, 90, 1],
	[-6100,1772,-51, 270, 0],
	[-5935,1772,-51, 270, 0],
	[-5294,1226,333, 90, 2],
	[-6015,648,205, 90, 0],
	[-6462,1348,-51, 0, 0],
	[-5577,1317,-51, 180, 0],
	[-6885,1901,141, 0, 2],
]

::M07_GetPropPlacement <- function(list)
{
	local places = [], full = []
	local maxpick = M07_DispCount 
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
	local isMini = false;
	if (lev > 2)
	{
		isMini = true;
		lev = 0;
	}
	local tempEnt = SpawnEntityFromTable("obj_sentrygun", {
		origin       = Vector(x,y,z - 45.0),
		angles       = QAngle(0.0, rot, 0.0),
		targetname = "worldsentry",
		TeamNum = Merc.ForcedTeam,
		defaultupgrade = lev,
		SolidToPlayer = 1,
	})
	if (isMini)
	{
		SetPropBool(tempEnt, "m_bMiniBuilding", true);
		tempEnt.SetSkin(tempEnt.GetSkin() + 2);
		tempEnt.SetModelScale(0.75, 0)
	}
}
function MercSpawnDispenser(x,y,z,rot)
{
	local tempEnt = SpawnEntityFromTable("obj_dispenser", {
		origin       = Vector(x,y,z - 30.0),
		angles       = QAngle(0.0, rot, 0.0),
		targetname = "worlddispenser",
		TeamNum = Merc.ForcedTeam,
		defaultupgrade = 1,
		SolidToPlayer = 1,
	})
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_round_win = function(params)
	{
		if (params.team == Merc.ForcedTeam)
		{
			Merc.MainGet(1,1,1)
			Merc.CheckObjectives()
		}
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			ent.AcceptInput("SetSetupTime", "30", null, null)
		}
		EntFire("spawns_blue_stage2_cap1", "Enable", null)
		EntFire("spawns_blue_stage1_cap1", "Disable", null)
		
		local places = M07_GetPropPlacement(M07_DispPlaces)
		foreach (a in places)
		{
			MercSpawnDispenser(a[0],a[1],a[2],a[3])
		}
		foreach (a in M07_SentryPlaces)
		{
			MercSpawnSentry(a[0],a[1],a[2],a[3],a[4])
		}
	}
	
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		EntFire("trigger_door_respawnroom_stage2_blue1", "Enable", null)
		local ent = null
		while (ent = Entities.FindByName(ent, "control_point_2"))
		{
			EntFireByHandle(ent, "SetOwner", "3", -1, ent, ent)
			EntFireByHandle(ent, "SetLocked", "1", -1, ent, ent)
		}
		while (ent = Entities.FindByName(ent, "control_point_3"))
		{
			EntFireByHandle(ent, "SetLocked", "0", -1, ent, ent)
		}
		while (ent = Entities.FindByName(ent, "brush_stage2_sneakyroutedoor1"))
		{
			ent.Kill()
		}
	}
	
	OnGameEvent_player_upgradedobject = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || IsPlayerABot(player)) return
		if (params.isbuilder || params.object != 0) return
		Merc.ExtraGet(1,2,2)
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

