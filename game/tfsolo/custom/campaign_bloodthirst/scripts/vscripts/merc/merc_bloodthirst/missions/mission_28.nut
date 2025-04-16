// KOTH Sinthetic
::Merc <- {}
Merc.MissionID <- 28
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SPY, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 07"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_ENGINEER, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_HEAVY, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_DEMOMAN, "Bot 12"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get kills while in a bumper car"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 3

::M18_CarTeam <- TF_TEAM_RED

PrecacheModel("models/player/items/taunts/bumpercar/parts/bumpercar.mdl")
PrecacheModel("models/props_halloween/bumpercar_cage.mdl")
PrecacheScriptSound("BumperCar.Jump")
PrecacheScriptSound("BumperCar.HitBall")
PrecacheScriptSound("BumperCar.Bump")
PrecacheScriptSound("BumperCar.BumpHard")
PrecacheScriptSound("BumperCar.JumpLand")
PrecacheScriptSound("BumperCar.Spawn")
PrecacheScriptSound("BumperCar.Accelerate")
PrecacheScriptSound("BumperCar.GoLoop")
PrecacheScriptSound("BumperCar.Decelerate")
PrecacheScriptSound("BumperCar.DecelerateQuick")
PrecacheScriptSound("BumperCar.SpeedBoostStart")
PrecacheScriptSound("BumperCar.SpeedBoostStop")
PrecacheScriptSound("BumperCar.Screech")
PrecacheScriptSound("BumperCar.BumpIntoAir")
PrecacheScriptSound("BumperCar.HitGhost")

Merc.BeforeRoundStart <- function(params) 
{
	M18_CarTeam = TF_TEAM_RED
}

Merc.AfterRoundStart <- function(params) 
{
	M18_CarTeam = TF_TEAM_RED
	
	local ent = null
	while (ent = Entities.FindByClassname(ent, "tf_logic_koth"))
	{
		ent.AcceptInput("SetBlueTimer", "300", ent, ent)
		ent.AcceptInput("SetRedTimer", "300", ent, ent)
	}
	
	foreach (a in GetClients()) 
	{	
		if (a.GetTeam() == M18_CarTeam)
		{
			a.AddCond(TF_COND_HALLOWEEN_KART)
		}
		else
		{
			a.RemoveCond(TF_COND_HALLOWEEN_KART)
		}
	}
}

Merc.AfterPlayerSpawn <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() != M18_CarTeam) return
	player.AddCond(TF_COND_HALLOWEEN_KART)
	
	if (IsPlayerABot(player)) return
	local ent = null
	while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
	{
		if (ent.GetOwner() == player)
		{
			SetPropInt(ent, "m_iSelectedSpellIndex", 12)
			SetPropInt(ent, "m_iSpellCharges", 3)
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
		if (aplayer.InCond(TF_COND_HALLOWEEN_KART))
		{
			Merc.ExtraGet(1,1,1)
		}
	}
	
	OnGameEvent_teamplay_point_captured = function(params)
	{
		if (params.team == 0)
		{
			foreach (a in GetClients()) 
			{	
				a.RemoveCond(TF_COND_HALLOWEEN_KART)
			}
		}
		else
		{
			M18_CarTeam = params.team
			foreach (a in GetClients()) 
			{	
				if (a.GetTeam() == M18_CarTeam)
				{
					a.AddCond(TF_COND_HALLOWEEN_KART)
					if (!IsPlayerABot(a))
					{
						local ent = null
						while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
						{
							if (ent.GetOwner() == a)
							{
								SetPropInt(ent, "m_iSelectedSpellIndex", 12)
								SetPropInt(ent, "m_iSpellCharges", 3)
							}
						}
					}
				}
				else
				{
					a.RemoveCond(TF_COND_HALLOWEEN_KART)
				}
			}
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

