// PL Corruption
::Merc <- {}
Merc.MissionID <- 4
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_ENGINEER, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_MEDIC, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_DEMOMAN, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_HEAVY, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SPY, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SCOUT, "Bot 07"),
]
Merc.ObjectiveText <- "Get kills with critical hits"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 25
Merc.ObjectiveExtraText <- "Take less than 2500 damage"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 2500
Merc.ForceWinOnMainDone <- 1

::M06CrumpkinProp <- "models/props_halloween/pumpkin_loot.mdl"
PrecacheModel(M06CrumpkinProp)
PrecacheScriptSound("Halloween.PumpkinPickup")
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })
PrecacheScriptSound("AmmoPack.Touch")

::M06CrumpkinSpots <- [
	[-4953,790,-431],
	[-4293,806,-370],
	[-3276,381,-82],
	[-3229,-745,-114],
	[-2135,-202,-178],
	[-1886,622,-374],
	[-1270,-189,-163],
	[-2398,12,-302],
	[-672,440,-562],
	[-831,1221,-548],
	[-1203,1502,-434],
	[-558,1497,-370],
	[-44,14,-242],
	[-259,722,-406],
	[48,619,-306],
	[100,-1024,-276],
	[516,-2190,-84],
	[-1300,-2369,-222],
	[-2470,-2239,-154],
	[796,-1055,-30],
	[822,-1965,78],
	[260,-2633,14],
	[-212,-2168,-26],
	[812,-2119,-114],
	[154,-3213,-226],
	[-432,-2016,22],
	[-1621,-2158,142],
	[-1592,-2113,-158],
	[-2624,-2700,-148],
	[-2261,-2771,100],
	[-2271,-2016,14],
	[-2365,-2032,-154],
	[-3127,-2654,90],
	[-454,62,-406],
	[-420,985,-154],
	[-726,214,-270],
	[-4593,-633,-202],
	[-4370,1440,-450],
	[898,-2833,-206],
	[-1125,-3419,164],
]
::M06_CrumpkinCount <- 25

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

::M06_CrumpkinPickupPlayer <- function()
{
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a) && a.GetTeam() == Merc.ForcedTeam)
		{
			a.AddCondEx(TF_COND_CRITBOOSTED_PUMPKIN, 8.0, null)
			a.ClearSpells()
		}
	}
}
::M06_CrumpkinPickupEnemy <- function()
{
	foreach (a in GetClients()) 
	{	
		if (IsPlayerABot(a) && a.GetTeam() != Merc.ForcedTeam)
		{
			a.AddCondEx(TF_COND_CRITBOOSTED_PUMPKIN, 5.0, null)
		}
	}
}
function M06_SpawnCrumpkin(x, y, z)
{
	local prop = SpawnEntityFromTable("tf_halloween_pickup", {
		origin       = Vector(x,y,z - 0.0),
		angles       = QAngle(0,RandomInt(0, 181),0),
		targetname   = "merccrumpkin",
		model 		 = M06CrumpkinProp,
		powerup_model = M06CrumpkinProp,
		pickup_particle = "taunt_headbutt_impact_stars",
		pickup_sound = "Halloween.PumpkinPickup",
		automaterialize = true,
	})
	prop.ValidateScriptScope()
	prop.ConnectOutput("OnRedPickup", "M06_CrumpkinPickupPlayer")
	prop.ConnectOutput("OnBluePickup", "M06_CrumpkinPickupEnemy")
}

Merc.BeforeRoundWin <- function(params)
{
	if (params.team == Merc.ForcedTeam)
	{
		if (Merc.ObjectiveExtraCount <= Merc.ObjectiveExtraMax && !Merc.ExtraFailed)
		{
			Merc.ForceExtraDone(1)
		}
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

		if ((params.damagebits & 1048576) != 0)
		{
			Merc.MainGet(1,1,1)
		}
	}
	
	OnGameEvent_player_hurt = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || IsPlayerABot(player)) return
		if (Merc.RoundEnded || Merc.ExtraFailed) return
		
		local cap = params.damageamount
		if (cap > 300)
		{
			cap = 300
		}
		Merc.ObjectiveExtraCount += cap
		if (Merc.ObjectiveExtraCount >= Merc.ObjectiveExtraMax)
		{
			Merc.ObjectiveExtraCount = 0
			Merc.ExtraFail()
			Merc.ChatPrint("Bonus objective failed! Took too much damage.")
		}
		Merc.UpdateHUD()
	}
	
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		local ent = null
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			ent.Kill()
		}
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		local places = M06_GetPlacement(M06CrumpkinSpots, M06_CrumpkinCount)
		foreach (i in places)
		{
			M06_SpawnCrumpkin(i[0],i[1],i[2])
		}
		
		local ent = null
		while (ent = Entities.FindByName(ent, "cart_pause_relay"))
		{
			ent.Kill()
		}
		ent = null
		while (ent = Entities.FindByName(ent, "cart_resume_relay"))
		{
			ent.Kill()
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

