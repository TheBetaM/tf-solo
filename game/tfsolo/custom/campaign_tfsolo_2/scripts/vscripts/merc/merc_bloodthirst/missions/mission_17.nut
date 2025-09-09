// KOTH Maple Ridge Event
::Merc <- {}
Merc.MissionID <- 17
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_PYRO
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 06"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SPY, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_HEAVY, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_DEMOMAN, "Bot 10"),
]
Merc.ObjectiveText <- "Win the round by scaring enemies to death (CROUCH)"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Avoid scaring teammates"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1
Merc.AllowBuffs <- 0

Convars.SetValue("mp_friendlyfire", 1)

::BooActive <- false
::M15_HauntArray <- {}

PrecacheModel("models/props_halloween/ghost_no_hat.mdl")
PrecacheScriptSound("Halloween.Haunted")
PrecacheScriptSound("Halloween.GhostMoan")
PrecacheScriptSound("Halloween.GhostBoo")
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "ghost_appearation" })

function BooAction()
{
	if (BooActive) return;
	BooActive = true
	local player = EntIndexToHScript(1)
	
	local ghost = SpawnEntityFromTable("ghost", {
		origin       = player.GetOrigin(),
		angles       = player.GetAbsAngles(),
		rendermode	 = kRenderNone,
	})
	
	Merc.Delay(0.5, function() {
		ghost.Kill()
		player.RemoveCond(TF_COND_STUNNED)
	} )
	Merc.Delay(3.0, function() {
		BooActive = false
	} )
}

::M15_UpdateHaunt <- function()
{
	foreach (a in GetClients()) 
	{	
		if (IsPlayerABot(a) && a.IsSnared())
		{
			if (M15_HauntArray[a.entindex()] == 0)
			{
				local bot = a
				M15_HauntArray[a.entindex()] <- 1
				Merc.Delay(1.0, function() {
					local player = EntIndexToHScript(1)
					bot.TakeDamage(1000.0, 0, player)
					if (bot.GetTeam() != Merc.ForcedTeam)
					{
						//Merc.ObjectiveMainCount++
					}
					else if (!Merc.ExtraFailed)
					{
						Merc.ExtraFail()
						Merc.ChatPrint("Bonus objective failed! Scared a teammate.")
					}
				} )
			}
		}
	}
}

::M17_PlayerThink <- function()
{
	local buttons = GetPropInt(self, "m_nButtons")
	if (buttons & IN_DUCK)
	{
		BooAction()
	}
	
	M15_UpdateHaunt()
	
	return -1
}

Merc.BeforeRoundWin <- function(params) 
{
	if (params.team == Merc.ForcedTeam)
	{
		Merc.MainGet(1,1,1)
		if (!Merc.ExtraFailed)
		{
			Merc.ExtraGet(1,1,1)
		}
	}
}

Merc.AfterPlayerSpawn <- function(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (IsPlayerABot(player))
	{
		M15_HauntArray[player.entindex()] <- 0
		return
	}
	
	player.Teleport(true, Vector(-1724,2344,560), true, QAngle(0, 270, 0), true, Vector(0, 0, 0))
	player.AddCond(TF_COND_HALLOWEEN_GHOST_MODE)
	AddThinkToEnt(player, "M17_PlayerThink")
}

