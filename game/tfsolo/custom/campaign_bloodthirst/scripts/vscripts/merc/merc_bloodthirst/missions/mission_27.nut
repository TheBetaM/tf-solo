// ZI Sanitarium
::Merc <- {}
Merc.MissionID <- 27
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 12"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 13"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 14"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 15"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 16"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 17"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Bot 18"),
]
Merc.ObjectiveText <- "Stash beer bottles in the truck";
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 20
Merc.ObjectiveExtraText <- "(Team) Kill zombies"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 60
Merc.AllowTeamChange <- 1
Merc.ForceWinOnMainDone <- 1
Merc.CustomSpawnBLU <- 1

::M03PickupProp <- "models/props_gameplay/bottle001.mdl"
::M03EscapeProp <- "models/props_vehicles/pickup03.mdl"
PrecacheModel(M03PickupProp)
PrecacheModel(M03EscapeProp)
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })
PrecacheScriptSound("GlassBottle.ImpactHard")
PrecacheScriptSound("AmmoPack.Touch")

::M03PickupSpots <- [
	[-1525,758,12],
	[-1936,695,12],
	[-1473,-359,219],
	[-433,-574,12],
	[526,450,203],
	[-1767,328,219],
	[-673,-182,57],
	[-911,-585,11],
	[543,-190,11],
	[-1517,-1021,57],
	[603,-1550,236],
	[-56,311,11],
	[471,1173,254],
	[-2196,-123,218],
	[814,-203,218],
	[474,820,427],
	[-1941,519,11],
	[616,897,11],
	[-1514,-439,11],
	[114,1050,219],
	[91,2,219],
	[-352,344,259],
	[-2073,171,219],
	[-1230,401,219],
	[-1165,-478,427],
	[343,-126,468],
	[110,1053,427],
	[-156,380,427],
	[-543,225,427],
	[-834,222,427],
	[-2064,909,427],
	[-1102,241,472],
	[-567,-703,635],
	[-110,-338,731],
	[486,177,635],
	[119,1048,635],
	[-470,-166,635],
	[-2075,-6,635],
	[-1805,807,635],
	[-1140,-452,635],
	[-688,660,795],
	[-210,128,219],
	[662,50,219],
	[-692,-709,219],
	[-690,-705,427],
	[-1920,-349,622],
	[-1790,365,427],
	[-2067,172,427],
	[660,46,427],
	[423,375,11],
]

::M04_BotHint1 <- null
::M04_BotHint2 <- null

::M10_GoalGlow <- null
::M10_DepositCount <- 0
::M10_HoldingBeer <- 0
::M10_MaxBeer <- 4
::M10_ZombieStartCount <- 9
::M03PickupCount <- 30
::M03Setup <- 0

::M10_BeerPickup <- function()
{
	SendGlobalGameEvent("hide_annotation", {
		id = 12,
	})
	if (M10_DepositCount == 0)
	{
		SendGlobalGameEvent("show_annotation", {
			worldPosX = -75,
			worldPosY = 1642,
			worldPosZ = 0,
			id = 11,
			text = "Stash them back at the truck!",
			lifetime = -1,
		})
	}
	M10_HoldingBeer++
	Merc.ObjectiveExtraAdd = " Beer: " + M10_HoldingBeer
	if (M10_HoldingBeer >= M10_MaxBeer)
	{
		Merc.ObjectiveExtraAdd = " Beer: " + M10_HoldingBeer + " (MAX)"
		local ent = null
		while (ent = Entities.FindByName(ent, "mercb*"))
		{
			ent.SetSolid(0)
		}
	}
	Merc.UpdateHUD()
	EntFireByHandle(M10_GoalGlow, "Enable", "", -1, M10_GoalGlow, M10_GoalGlow)
	activator.GetScriptScope()["mercglow"].Destroy()
}
function M10_SpawnBeer(x, y, z, id)
{
	local prop = SpawnEntityFromTable("tf_halloween_pickup", {
		origin       = Vector(x,y,z - 0.0),
		angles       = QAngle(0,RandomInt(0, 179),0),
		targetname   = "mercb" + id.tostring(),
		model 		 = M03PickupProp,
		powerup_model = M03PickupProp,
		pickup_particle = "taunt_headbutt_impact_stars",
		pickup_sound = "GlassBottle.ImpactHard",
		automaterialize = false,
		TeamNum = Merc.ForcedTeam,
		teamnumber = Merc.ForcedTeam,
	})
	prop.SetTeam(Merc.ForcedTeam)
	prop.ValidateScriptScope()
	prop.ConnectOutput("OnRedPickup", "M10_BeerPickup")
	
	local glow = Entities.CreateByClassname("tf_glow")
	glow.KeyValueFromString("GlowColor", "255 255 255 255")
	SetPropInt(glow, "m_iMode", 0)
	SetPropEntity(glow, "m_hTarget", prop)
	prop.GetScriptScope()["mercglow"] <- glow
}

::M03_DepositBeer <- function()
{
	if (activator.GetClassname() != "player") return
	if (IsPlayerABot(activator) || !activator.IsAlive() || activator.GetTeam() != TF_TEAM_RED) return
	if (M10_HoldingBeer <= 0) return;
	
	Merc.MainGet(M10_HoldingBeer,1,1)
	M10_HoldingBeer = 0
	EntFireByHandle(M10_GoalGlow, "Disable", "", -1, M10_GoalGlow, M10_GoalGlow)
	Merc.ObjectiveExtraAdd = ""
	M10_DepositCount++
	SendGlobalGameEvent("hide_annotation", {
		id = 11,
	})
	Merc.UpdateHUD()
	
	local ent = null
	while (ent = Entities.FindByName(ent, "mercb*"))
	{
		ent.SetSolid(6)
	}
}

::M15_GetPlacement <- function(list, maxpick)
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


::M06_HintThink <- function()
{
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a) && a.IsAlive() && a.GetTeam() == TF_TEAM_RED)
		{
			local pos1 = a.GetOrigin()
			pos1.z = pos1.z
			M04_BotHint1.SetAbsOrigin(pos1)
			M04_BotHint2.SetAbsOrigin(pos1)
		}
	}
	
}

// ZI Override
::GetRandomPlayers <- function(count = 1)
{
    local players = []
    foreach (a in GetClients())
    {
        if (a == null) continue;
		local name = GetPropString(a, "m_szNetname")
        if (IsPlayerABot(a) && name != Merc.RecruitRED_Name && name != Merc.RecruitBLU_Name)
		{
			players.append(a)
		}
    }
    count = M10_ZombieStartCount
    local list = []
    for (local i = 0; i < count;i++)
    {
        local rnd = RandomInt(0, players.len() - 1)
        list.append(players[rnd])
        players.remove(rnd)
    }
    return list
}

Merc.BeforeRoundStart <- function(params) 
{
	M10_HoldingBeer <- 0
	M10_DepositCount <- 0
	Merc.ObjectiveExtraAdd = ""
	
	M04_BotHint1 = SpawnEntityFromTable("item_teamflag", 
	{
		origin = Vector(1028, -16, -100),
		TeamNum = 2,
	})
	M04_BotHint1.AcceptInput("ForceGlowDisabled","1",null,null)
	M04_BotHint1.AddFlag(FL_DONTTOUCH)
	SetPropFloat(M04_BotHint1,"m_flModelScale",0.0)
	M04_BotHint2 = SpawnEntityFromTable("item_teamflag", 
	{
		origin = Vector(1028, -16, -100),
		TeamNum = 3,
	})
	M04_BotHint2.AcceptInput("ForceGlowDisabled","1",null,null)
	M04_BotHint2.AddFlag(FL_DONTTOUCH)
	SetPropFloat(M04_BotHint2,"m_flModelScale",0.0)
	
	local tprop = SpawnEntityFromTable("logic_script", {})
	AddThinkToEnt(tprop,"M06_HintThink")
	
	
	local prop = SpawnEntityFromTable("prop_dynamic_override", {
		//origin       = Vector(-704,1600,-153.0),
		//angles       = QAngle(0, 180, 0),
		origin       = Vector(-75,1642,-153.0),
		angles       = QAngle(0, 209.5, 0),
		model 		 = M03EscapeProp,
		targetname   = "mercescape",
		max_health   = 1000,
		health 		 = 1000,
		solid		 = 6,
	})
	//SetPropInt(prop, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
	//SetPropInt(prop, "m_clrRender", 0)
	M10_GoalGlow <- Entities.CreateByClassname("tf_glow")
	M10_GoalGlow.KeyValueFromString("GlowColor", "189 59 59 255")
	SetPropInt(M10_GoalGlow, "m_iMode", 0)
	SetPropEntity(M10_GoalGlow, "m_hTarget",  prop)
	EntFireByHandle(M10_GoalGlow, "Disable", "", -1, M10_GoalGlow, M10_GoalGlow)
	local trigger = SpawnEntityFromTable("trigger_multiple", 
	{
		//origin = Vector(-677,1595,-154),
		origin = Vector(-75,1642,-154),
		angles     = QAngle(0, 209.5, 0)
		spawnflags = 1,
	})
	trigger.SetSize(Vector(-224,-90,0), Vector(128,90,128))
	trigger.SetSolid(3)
	trigger.ValidateScriptScope()
	trigger.ConnectOutput("OnStartTouch", "M03_DepositBeer")
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		local places = M15_GetPlacement(M03PickupSpots,M03PickupCount)
		foreach (i,a in places)
		{
			M10_SpawnBeer(a[0],a[1],a[2],i)
		}
		
		local ent = null
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			EntFireByHandle(ent,"Pause","",0,ent,ent)
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
				SetPropInt(ent, "m_iSelectedSpellIndex", RandomInt(0,11))
				SetPropInt(ent, "m_iSpellCharges", 1)
			}
		}
	}
	
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid != 0 && IsPlayerABot(player))
		{
			if (params.death_flags & 32 || player.GetTeam() == TF_TEAM_RED) return
			local aplayer = GetPlayerFromUserID(params.attacker)
			if (aplayer == null) return
			Merc.ExtraGet(1,1,1)
			return
		}
		
		local count = 0
		foreach (a in GetClients()) 
		{	
			if (!IsPlayerABot(a) && a.IsAlive() && a.GetTeam() == TF_TEAM_RED && a != player)
			{
				count++
			}
		}
		if (count == 0)
		{
			Merc.ForceFail()
		}
		
		if (params.userid == 0 || IsPlayerABot(player) || M10_HoldingBeer == 0 || player.GetTeam() != Merc.ForcedTeam || params.death_flags & 32) return;
		
		Merc.ChatPrint("Dropped " + M10_HoldingBeer + " beer!")
		local deathpos = player.GetOrigin()
		local beerdrop = M10_HoldingBeer + 0
		Merc.Delay(1.0, function() {
			for (local i = 0; i < beerdrop; i++)
			{
				M10_SpawnBeer(deathpos.x, deathpos.y, deathpos.z + 60.0, 101)
			}
		} )
		M10_HoldingBeer = 0
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

