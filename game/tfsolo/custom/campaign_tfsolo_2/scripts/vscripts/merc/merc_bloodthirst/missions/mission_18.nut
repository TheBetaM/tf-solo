// TOW Dynamite
::Merc <- {}
Merc.MissionID <- 18
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.WaitTimeConvar <- 1
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 07"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_ENGINEER, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_DEMOMAN, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_HEAVY, "Bot 12"),
]
Merc.ObjectiveText <- "Win without letting the cart overheat"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get kills while airborne"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 6

::M04_BotHint1 <- null
::M04_BotHint2 <- null
::M04_Cart <- null

::M06Prop <- "models/props_2fort/fire_extinguisher.mdl"
PrecacheModel(M06Prop)
PrecacheScriptSound("Halloween.PumpkinPickup")
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })
PrecacheScriptSound("AmmoPack.Touch")

::M06PropCount <- 20
::M06PropHighCount <- 6
::M06Heat <- 0
::M06CartTeam <- 0

::M06PropSpots <- [
	[2147,2666,233],
	[352,1791,57],
	[742,2569,77],
	[1606,2997,201],
	[2312,2043,245],
	[1223,2159,99],
	[975,2630,325],
	[-517,2071,95],
	[-626,1161,119],
	[-741,568,129],
	[1564,2564,147],
	[548,-13,-79],
	[-551,5,-69],
	[-164,-188,46],
	[164,188,46],
	[-896,-1545,71],
	[-778,-2228,69],
	[924,-1616,75],
	[-299,518,181],
	[-1808,-2606,107],
	[616,-18,121],
	[1131,1227,159],
	[782,550,17],
	[147,2234,69],
	[519,-654,183],
	[-1645,-2323,89],
	[-118,710,89],
	[-1060,-3132,291],
	[1903,2065,149],
	[248,2143,293],
]
::M06PropHighSpots <- [
	[1668,2149,591],
	[1458,2708,524],
	[342,691,375],
	[-342,-691,375],
	[530,1149,403],
	[868,2080,710],
	[-376,480,387],
	[376,-480,387],
	[-40,700,580],
	[-40,-700,580],
	[-550,-1140,423],
]

::M06_HintThink <- function()
{
	local pos = M04_Cart.GetOrigin()
	pos.z = pos.z + 30.0
	M04_BotHint1.SetAbsOrigin(pos)
	M04_BotHint2.SetAbsOrigin(pos)
}

::M06_PropPickup <- function()
{
	M06Heat = M06Heat - 10
	if (M06Heat < 0)
	{
		M06Heat = 0
	}
	Merc.ObjectiveTextAdd = " (HEAT: " + M06Heat + "%)"
	Merc.UpdateHUD()
}

::M06_GetPlacement <- function(list, maxpick)
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

function M06_Clock()
{
	if (Merc.RoundEnded) return
	M06Heat = M06Heat + 1
	if (M06CartTeam == Merc.ForcedTeam)
	{
		//M06Heat = M06Heat + 1
	}
	if (M06Heat < 100)
	{
		Merc.ObjectiveTextAdd = " (HEAT: " + M06Heat + "%)"
	}
	else
	{
		M06Heat = 100
		Merc.ChatPrint("Main objective failed! The cart overheated.")
		Merc.ForceFail()
		Merc.ObjectiveTextAdd = " (HEAT: 100%)"
	}
	Merc.UpdateHUD()
}

function M06_SpawnProp(x, y, z)
{
	local prop = SpawnEntityFromTable("tf_halloween_pickup", {
		origin       = Vector(x,y,z - 15.0),
		angles       = QAngle(0,RandomInt(0, 179),0),
		targetname   = "mercprop",
		model 		 = M06Prop,
		powerup_model = M06Prop,
		pickup_particle = "taunt_headbutt_impact_stars",
		pickup_sound = "Halloween.PumpkinPickup",
		automaterialize = true,
		TeamNum = Merc.ForcedTeam,
		teamnumber = Merc.ForcedTeam,
	})
	prop.SetTeam(Merc.ForcedTeam)
	prop.ValidateScriptScope()
	prop.ConnectOutput("OnBluePickup", "M06_PropPickup")
}

Merc.BeforeRoundStart <- function(params) 
{
	// Bots get stuck in spawn
	foreach (a in Merc.Bots)
	{
		a.Flags = 2
		a.SpawnPos = Vector(-2274,-3168,180)
		if (a.Team == TF_TEAM_BLUE)
		{
			a.SpawnPos = Vector(2274,3168,180)
		}
	}
	
	M04_BotHint1 = SpawnEntityFromTable("item_teamflag", 
	{
		origin = Vector(0, 0, 50),
		TeamNum = 3,
		targetname = "bothint1",
		solid = 0,
	})
	M04_BotHint1.AcceptInput("ForceGlowDisabled","1",null,null)
	M04_BotHint1.AddFlag(FL_DONTTOUCH)
	SetPropFloat(M04_BotHint1,"m_flModelScale",0.0)
	M04_BotHint2 = SpawnEntityFromTable("item_teamflag", 
	{
		origin = Vector(0, 0, 50),
		TeamNum = 2,
		targetname = "bothint2",
		solid = 0,
	})
	M04_BotHint2.AcceptInput("ForceGlowDisabled","1",null,null)
	M04_BotHint2.AddFlag(FL_DONTTOUCH)
	SetPropFloat(M04_BotHint2,"m_flModelScale",0.0)
	M04_Cart = Entities.FindByName(null, "flatcar_dud")
	
	local prop = SpawnEntityFromTable("logic_script", {})
	AddThinkToEnt(prop,"M06_HintThink")
	
	M06Heat = 0
	M06CartTeam = 0
	Merc.ObjectiveTextAdd = " (HEAT: 0%)"
	Merc.Timer(1.0, 0, M06_Clock)
	
	Merc.Delay(0.5, function() {
		local ent = null
		while (ent = Entities.FindByClassname(ent, "tf_logic_koth"))
		{
			ent.AcceptInput("SetBlueTimer", "240", ent, ent)
			ent.AcceptInput("SetRedTimer", "240", ent, ent)
		}
	} )
	
	local places = M06_GetPlacement(M06PropSpots,M06PropCount)
	foreach (a in places)
	{
		M06_SpawnProp(a[0],a[1],a[2])
	}
	places = M06_GetPlacement(M06PropHighSpots,M06PropHighCount)
	foreach (a in places)
	{
		M06_SpawnProp(a[0],a[1],a[2])
	}
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
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0) return
		if (!IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || IsPlayerABot(aplayer)) return
		local check = aplayer.GetFlags() & FL_ONGROUND
		if (check == 0)
		{
			Merc.ExtraGet(1,1,1)
		}
	}
	
	OnGameEvent_player_spawn = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (IsPlayerABot(player)) return
		
		local ent = null
		while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
		{
			if (ent.GetOwner() == player)
			{
				SetPropInt(ent, "m_iSelectedSpellIndex", 2)
				SetPropInt(ent, "m_iSpellCharges", 3)
			}
		}
	}
	
	OnGameEvent_teamplay_point_captured = function(params)
	{
		M06CartTeam = params.team
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

