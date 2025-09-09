// VSH Outburst
::Merc <- {}
Merc.MissionID <- 29
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_HEAVY
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(Merc.GetEnemyTeam(), 3, TF_CLASS_SCOUT, "The Devil"),
	Merc.BotGeneric(Merc.GetEnemyTeam(), 3, TF_CLASS_SPY, "Damned Soul"),
]
Merc.ObjectiveText <- "Defeat all Damned Souls before your health drains"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 20
Merc.ObjectiveExtraText <- "Get kills using Stomp or Mighty Slam"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 3
Merc.ObjectiveTextAdd <- ""
Merc.CustomSpawn <- 2
Merc.AllowCustomWeapons <- 0
Merc.AllowRecruits <- 0
Merc.ForceWinOnMainDone <- 1

Merc.Bots[0].BotAttribs = [IGNORE_ENEMIES]
//Merc.Bots[1].Items = ["Duck Billed Hatypus"]

::M29BuildSpots <- [
	[1479,-810,1565, 90, 4],
	[1509,-810,1565, 90, 4],
	[-437,-1413,1629, 90, 4],
	[-433,-1071,1771, 90, 4],
	[-695,-1663,1409, 0, 4],
	[1735,206,1386, 0, 4],
	[233,-700,1361, 0, 4],
	[461,-2111,1669, 0, 4],
	[1011,-171,1385, 0, 4],
	[125,-1953,1453, 90, 4],
	
	[85,-937,1368, 90, 2],
	[891,-1452,1664, 0, 2],
	[-539,-1628,1645, 180, 2],
	[522,316,1401, 180, 1],
	[-604,-759,1785, 135, 1],
	[1402,-421,1420, 90, 1],
	[427,-874,1609, 180, 0],
	[2123,237,1397, 180, 0],
	[295,-1823,1422, 45, 0],
	[589,-1572,1952, 180, 3],
	[478,58,1608, 180, 3],
	[-316,-174,1361, 0, 3],
]
::M29CheckSpots <- [
	[1123,-1342,1423],
	[651,-1699,1985],
	[-223,-1639,1615],
	[189,-644,1346],
	[1977,232,1366],
	[621,9,1578],
	[-792,-355,1351],
	[651,-583,1572],
	[-339,-858,1755],
	[1492,-594,1554],
	[69,-2032,1439],
	[-1032,-1132,1395],
	[2008,-2033,1579],
	[-150,-970,1338],
	[336,623,1385],
	[933,-151,1367],
	[-1292,-1899,1585],
	[1406,-1141,1557],
	[-1043,-510,1391],
	[508,-2054,1654],
	[244,-1456,1391],
]

::M29_HaleWeapons <- [
	"hale_stomp",
	"hale_slam",
	"hale_slam_collateral",
]

::M29_StartHP <- 6000
::M29_CheckHP <- 300
::M29_BuildHP <- 200
::M29_LastCheck <- -1
::M29_LastClass <- -1
::M29_DrainHP <- 20
::M29_DrainHPTime <- 0.5
::M29_CheckGlow <- null
::M29_CheckWait <- 0

::M29_HaleThink <- function()
{
	if (Merc.RoundEnded) return 0.5
	foreach (a in GetClients()) 
	{
		if (!IsPlayerABot(a))
		{
			local hp = a.GetHealth()
			local target = hp - M29_DrainHP
			if (target < 0)
			{
				target = 0
				a.SetHealth(0)
				a.TakeDamage(1.0,8,a)
				Merc.ForceFail()
				return 0.5
			}
			a.SetHealth(target)
		}
	}
	if (M29_CheckWait == 0 && !Merc.Bots[1].Handle.IsAlive())
	{
		M29_RespawnBot()
	}
	return M29_DrainHPTime
}

::M29_HealHale <- function(h)
{
	foreach (a in GetClients()) 
	{
		if (!IsPlayerABot(a))
		{
			local hp = a.GetHealth()
			local target = hp + h
			if (target > M29_StartHP)
			{
				target = M29_StartHP
			}
			a.SetHealth(target)
			SendGlobalGameEvent("player_healonhit", {
				entindex = a.entindex(),
				amount = h
			})
		}
	}
}

::M29_RespawnBot <- function()
{
	::IsRoundSetup <- function() { return true; } // VSH
	local spell = RandomInt(0,19)
	if (spell == 0)
	{
		Merc.Bots[1].SpellType = [2,10.0]
	}
	else if (spell == 1)
	{
		Merc.Bots[1].SpellType = [4,5.0]
	}
	else if (spell == 2)
	{
		Merc.Bots[1].SpellType = [0,5.0]
	}
	else
	{
		Merc.Bots[1].SpellType = [-1,1.0]
	}
	
	local p = M29CheckSpots[M29_LastCheck]
	Merc.Bots[1].Handle.SetPlayerClass(M29_LastClass)
	SetPropInt(Merc.Bots[1].Handle, "m_Shared.m_iDesiredPlayerClass", M29_LastClass)
	Merc.Bots[1].Handle.ForceRespawn()
	Merc.Bots[1].Handle.Teleport(true, Vector(p[0],p[1],p[2]), true, QAngle(0, RandomInt(0,180), 0), true, Vector(0, 0, 0))
	::IsRoundSetup <- function() { return false; } // VSH
	Merc.Delay(0.4, function() {
		Merc.Bots[1].Handle.RemoveCustomAttribute("disable weapon switch")
		Merc.ForceTaunt(Merc.Bots[1].Handle,31288)
		if (Merc.Bots[1].SpellType[0] != -1)
		{
			Merc.Bots[1].SwitchToBook()
			Merc.Bots[1].Handle.AddCustomAttribute("disable weapon switch", 1.0, -1)
		}
	} )
}

::M29_StartCheck <- function()
{
	local full = []
	foreach (i,a in M29CheckSpots)
	{
		if (i != M29_LastCheck)
		{
			full.push(i)
		}
	}
	M29_LastCheck = full[RandomInt(0,full.len()-1)]
	local p = M29CheckSpots[M29_LastCheck]
	
	M29_RespawnBot()
	M29_CheckWait = 0
	
	SendGlobalGameEvent("show_annotation", {
		worldPosX = p[0],
		worldPosY = p[1],
		worldPosZ = p[2] + 50,
		id = 11,
		text = "Next target!",
		lifetime = 10,
		show_distance = true,
		//follow_entindex = Merc.Bots[1].Handle.entindex(),
	})
	SetPropEntity(M29_CheckGlow, "m_hTarget", Merc.Bots[1].Handle)
}
::M29_PassCheck <- function()
{
	if (Merc.RoundEnded) return
	M29_HealHale(M29_CheckHP)
	
	Merc.MainGet(1,1,1)
	SendGlobalGameEvent("hide_annotation", {
		id = 11,
	})
	
	if (Merc.ObjectiveMainCount < Merc.ObjectiveMainMax)
	{
		M29_CheckWait = 1
		
		local fullc = []
		foreach (i,a in [1,2,3,4,5,6,7])
		{
			if (a != M29_LastClass)
			{
				fullc.push(a)
			}
		}
		M29_LastClass = fullc[RandomInt(0,fullc.len()-1)]
		
		Merc.Delay(0.5, function() {
			M29_StartCheck()
		} )
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
			origin = Vector(x,y,z - 30.0),
			angles = QAngle(0.0, rot, 0.0),
			targetname = "worlddispenser",
			TeamNum = Merc.GetEnemyTeam(),
			defaultupgrade = 2,
			SolidToPlayer = 1,
		})
		tempEnt.AcceptInput("SetHealth","1",tempEnt,tempEnt)
		return
	}
	local tempEnt = SpawnEntityFromTable("obj_sentrygun", {
		origin = Vector(x,y,z - 45.0),
		angles = QAngle(0.0, rot, 0.0),
		targetname = "worldsentry",
		TeamNum = Merc.GetEnemyTeam(),
		defaultupgrade = lev,
		SolidToPlayer = 1,
	})
	if (isMini)
	{
		SetPropBool(tempEnt, "m_bMiniBuilding", true)
		tempEnt.SetSkin(tempEnt.GetSkin() + 2)
		tempEnt.SetModelScale(0.75, 0)
	}
	tempEnt.AcceptInput("SetHealth","1",tempEnt,tempEnt)
}

Merc.BeforeRoundStart <- function(params) 
{
	::VSH_TEAM_MERCS <- Merc.GetEnemyTeam() // VSH 2024
	::VSH_TEAM_BOSS <- Merc.ForcedTeam // VSH 2024
	::TF_TEAM_MERCS <- Merc.GetEnemyTeam() // VSH
	::TF_TEAM_BOSS <- Merc.ForcedTeam // VSH
	::UnlockControlPoint <- function() {} // VSH / VSH 2024
	::GetAliveMercCount <- function() { return 20; } // VSH
	::CalcBossMaxHealth <- function(a) { return M29_StartHP; } // VSH
	::IsRoundSetup <- function() { return true; } // VSH
	if ("SetPersistentVar" in getroottable())
	{
		SetPersistentVar("next_boss", 1) // VSH
	}
	
	::M29_LastCheck <- -1
	local prop = SpawnEntityFromTable("logic_script", {})
	AddThinkToEnt(prop,"M29_HaleThink")
	M29_CheckWait = 1
	Merc.Bots[1].SpellType = [-1,1.0]
	
	local fullc = []
	foreach (i,a in [1,2,3,4,5,6,7])
	{
		if (a != M29_LastClass)
		{
			fullc.push(a)
		}
	}
	M29_LastClass = fullc[RandomInt(0,fullc.len()-1)]
	
	foreach (a in M29BuildSpots)
	{
		MercSpawnBuild(a[0],a[1],a[2],a[3],a[4])
	}
	
	local glow = Entities.CreateByClassname("tf_glow")
	glow.KeyValueFromString("GlowColor", "255 255 255 255")
	SetPropInt(glow, "m_iMode", 0)
	SetPropEntity(glow, "m_hTarget", null)
	M29_CheckGlow <- glow
	
	Merc.Delay(0.5, function() {
		foreach (a in GetClients()) 
		{
			if (IsPlayerABot(a))
				a.Teleport(true, Vector(8192,-4400,-7457), true, QAngle(0, 180, 0), true, Vector(0, 0, 0))
			else
			{
				a.Teleport(true, Vector(1976,-421,1592), true, QAngle(0, 180, 0), true, Vector(0, 0, 0))
			}
		}
	} )
}

Merc.AfterPlayerSpawn <- function(params) 
{
	::VSH_TEAM_MERCS <- Merc.GetEnemyTeam() // VSH 2024
	::VSH_TEAM_BOSS <- Merc.ForcedTeam // VSH 2024
	::TF_TEAM_MERCS <- Merc.GetEnemyTeam() // VSH
	::TF_TEAM_BOSS <- Merc.ForcedTeam // VSH
	local player = GetPlayerFromUserID(params.userid)
	if (IsPlayerABot(player))
	{
		//player.Teleport(true, Vector(8192,-4400,-7457), true, QAngle(0, 0, 0), true, Vector(0, 0, 0))
	}
	else
	{
		player.Teleport(true, Vector(1976,-421,1592), true, QAngle(0, 180, 0), true, Vector(0, 0, 0))
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		M29_PassCheck()
		if (Merc.ArrayContains(M29_HaleWeapons, params.weapon) != null)
		{
			Merc.ExtraGet(1,1,1)
		}
	}
	
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		::IsRoundSetup <- function() { return false; } // VSH
		Merc.Delay(0.1, function() {
			local ent = null
			while (ent = Entities.FindByClassname(ent, "team_round_timer"))
			{
				ent.AcceptInput("Pause","",null,null)
			}
			while (ent = Entities.FindByName(ent, "filter_team_boss"))
			{
				ent.SetTeam(TF_TEAM_BLUE)
			}
			while (ent = Entities.FindByName(ent, "filter_team_mercs"))
			{
				ent.SetTeam(TF_TEAM_RED)
			}
		} )
		
		M29_CheckWait = 0
		M29_StartCheck()
	}
	
	OnGameEvent_player_activate = function(params)
	{
		if ("SetPersistentVar" in getroottable())
		{
			SetPersistentVar("next_boss", 1) // VSH
		}
	}
	
	OnGameEvent_object_destroyed = function(params)
	{
		if (params.attacker == 0) return
		local player = GetPlayerFromUserID(params.attacker)
		if (IsPlayerABot(player)) return
		M29_HealHale(M29_BuildHP)
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

