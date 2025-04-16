// PL Precipice
::Merc <- {}
Merc.MissionID <- 20
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 3, TF_CLASS_PYRO, "Fire Wizard"),
	Merc.BotGeneric(TF_TEAM_RED, 3, TF_CLASS_SPY, "Bats Wizard"),
	Merc.BotGeneric(TF_TEAM_RED, 3, TF_CLASS_MEDIC, "Healing Wizard"),
	Merc.BotGeneric(TF_TEAM_RED, 3, TF_CLASS_DEMOMAN, "Pumpkin Wizard"),
	Merc.BotGeneric(TF_TEAM_RED, 3, TF_CLASS_SCOUT, "Blink Wizard"),
	Merc.BotGeneric(TF_TEAM_RED, 3, TF_CLASS_SNIPER, "Lightning Wizard"),
	Merc.BotGeneric(TF_TEAM_RED, 3, TF_CLASS_SOLDIER, "Meteor Wizard"),
	Merc.BotGeneric(TF_TEAM_RED, 3, TF_CLASS_HEAVY, "Monoculus Wizard"),
	Merc.BotGeneric(TF_TEAM_RED, 3, TF_CLASS_ENGINEER, "Skeleton Wizard"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SOLDIER, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SNIPER, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_DEMOMAN, "Bot 04"),
]
Merc.ObjectiveText <- "Win without letting the cart recede"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get at least 1 kill every life"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1

Convars.SetValue("tf_escort_recede_time", 45)
Convars.SetValue("tf_escort_recede_time_overtime", 20)

::SecretPickupProp <- "models/props_halloween/gargoyle_ghost.mdl"
PrecacheModel(SecretPickupProp)
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })
PrecacheScriptSound("Halloween.Haunted")

::GotKill <- false
::M18_LastPoint <- 0

Merc.Bots[0].SpellType = [0,3.0]
Merc.Bots[1].SpellType = [1,10.0]
Merc.Bots[2].SpellType = [2,5.0]
Merc.Bots[3].SpellType = [3,10.0]
Merc.Bots[4].SpellType = [6,0.2]
Merc.Bots[5].SpellType = [7,10.0]
Merc.Bots[6].SpellType = [9,20.0]
Merc.Bots[7].SpellType = [10,40.0]
Merc.Bots[8].SpellType = [11,60.0]

::SecretPickupGet <- function()
{
	Merc.RSVFlags[11] = 1
}
function SpawnSecretPickup(x, y, z)
{
	local prop = SpawnEntityFromTable("tf_halloween_pickup", {
		origin       = Vector(x,y,z - 18.0),
		angles       = QAngle(0,RandomInt(0, 181),0),
		targetname   = "mercduck",
		model 		 = SecretPickupProp,
		powerup_model = SecretPickupProp,
		pickup_particle = "taunt_headbutt_impact_stars",
		pickup_sound = "Halloween.Haunted",
		automaterialize = false,
		TeamNum = Merc.ForcedTeam,
		teamnumber = Merc.ForcedTeam,
	})
	prop.SetTeam(Merc.ForcedTeam)
	prop.ValidateScriptScope()
	prop.ConnectOutput("OnBluePickup", "SecretPickupGet")
}

Merc.BeforeRoundStart <- function(params)
{
	::M18_LastPoint <- 0
	GotKill <- false
	Merc.ObjectiveExtraAdd = " (WAITING)"
	
	local ent = null
	while (ent = Entities.FindByClassname(ent, "team_train_watcher"))
	{
		ent.ValidateScriptScope()
		ent.GetScriptScope()["StartRecede"] <- function(){
			if (!Merc.RoundEnded)
			{
				Merc.ChatPrint("Main objective failed! The cart started receding.");
				Merc.ForceFail()
			}
		}
		ent.ConnectOutput("OnTrainStartRecede","StartRecede")
	}
	while (ent = Entities.FindByClassname(ent, "team_round_timer"))
	{
		ent.AcceptInput("SetSetupTime","25",null,null)
	}
	
	if (Merc.RSVFlags[11] == 0)
	{
		SpawnSecretPickup(-3344,7305,793)
	}
}
Merc.AfterPlayerSpawn <- function(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (M18_LastPoint == 1 && IsPlayerABot(player) && player.GetTeam() == Merc.ForcedTeam) 
	{
		player.Teleport(true, Vector(-3747,3005,235), true, QAngle(0, RandomInt(0,360), 0), true, Vector(0, 0, 0))
		return
	}
	if (player.GetTeam() != Merc.ForcedTeam) return
	if (IsPlayerABot(player)) return
	if (Merc.RoundEnded || Merc.ExtraFailed) return
	
	GotKill <- false
	Merc.ObjectiveExtraAdd = " (WAITING)"
	Merc.UpdateHUD()
}
Merc.BeforeRoundWin <- function(params)
{
	::M18_LastPoint <- 0
	if (params.team == Merc.ForcedTeam)
	{
		if (!Merc.ExtraFailed)
		{
			Merc.ExtraGet(1,0,0)
		}
		Merc.MainGet(1,1,1)
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0) return
		if (!IsPlayerABot(player))
		{
			if (Merc.RoundEnded) return
			
			if (!Merc.ExtraFailed)
			{
				if (!GotKill)
				{
					Merc.ChatPrint("Bonus objective failed! Failed to get a kill.")
					Merc.ObjectiveExtraAdd = ""
					Merc.ExtraFail()
				}
			}
			
			return
		}
		if (player.GetTeam() == Merc.ForcedTeam) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || IsPlayerABot(aplayer)) return
		if (Merc.RoundEnded || Merc.ExtraFailed) return
		
		GotKill <- true
		Merc.ObjectiveExtraAdd = " (OK)"
		Merc.UpdateHUD()
	}
	
	OnGameEvent_teamplay_point_captured = function(params)
	{
		if (params.cp == 2)
		{
			M18_LastPoint = 1
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

