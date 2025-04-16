// PD Mannsylvania
::Merc <- {}
Merc.MissionID <- 24
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.WaitTimeConvar <- 1
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"
//ToConsole("tf_gamemode_override 1")

Merc.Bots <- [
	Merc.Bot(TF_TEAM_BLUE, 3, "Bloodthirst_HandlerBLU"),
	Merc.Bot(TF_TEAM_RED, 2, "Bloodthirst_HandlerRED"),
	
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_SOLDIER, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_PYRO, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_DEMOMAN, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_HEAVY, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_ENGINEER, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_MEDIC, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_SNIPER, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_SPY, "Bot 09"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SCOUT, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SOLDIER, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_PYRO, "Bot 12"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_DEMOMAN, "Bot 13"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_HEAVY, "Bot 14"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_ENGINEER, "Bot 15"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_MEDIC, "Bot 16"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SNIPER, "Bot 17"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SPY, "Bot 18"),
]
Merc.ObjectiveText <- "Defeat DRACULA!"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "TBD"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1
Merc.ForceWinOnMainDone <- 1

Merc.Bots[0].BotWpnFlags = 2
Merc.Bots[0].BotAttribs = [ AGGRESSIVE ]

::M24_HealthBar <- null
::M24_KingMaxHealth <- 10000
::M24_KingHealth <- 10000

::M24_UpdateHealthBar <- function()
{
	if (Merc.RoundEnded) return
	if (Merc.Bots[0].Handle != null)
	{
		M24_KingHealth = Merc.Bots[0].Handle.GetHealth()
	}
	local hp = (M24_KingHealth / M24_KingMaxHealth.tofloat()) * 255.0
	if (hp < 1.0)
	{
		hp = 1.0
	}
	if (hp > 255.0)
	{
		hp = 255.0
	}
	local hpbar = hp.tointeger()
	SetPropInt(M24_HealthBar, "m_iBossHealthPercentageByte", hpbar)
}

Merc.BeforeRoundStart <- function(params)
{
	M24_KingHealth = M24_KingMaxHealth
	if (Merc.MissionStatus[10] >= 2)
	{
		M24_KingHealth -= 1000
	}
	
	if (Entities.FindByClassname(null, "monster_resource") != null)
	{
		M24_HealthBar = Entities.FindByClassname(null, "monster_resource")
	}
	else
	{
		M24_HealthBar = SpawnEntityFromTable("monster_resource", { })
	}
	SetPropInt(M24_HealthBar, "m_iBossState", 0)
	SetPropInt(M24_HealthBar, "m_iBossHealthPercentageByte", 255)
	M24_UpdateHealthBar()
	
	Merc.Timer(0.25, 0, function() {
		M24_UpdateHealthBar()
	} )
	
	local ent = null
	while (ent = Entities.FindByClassname(ent, "item_healthkit_full"))
	{
		ent.SetTeam(Merc.ForcedTeam)
	}
	ent = null
	while (ent = Entities.FindByClassname(ent, "item_healthkit_medium"))
	{
		ent.SetTeam(Merc.ForcedTeam)
	}
	ent = null
	while (ent = Entities.FindByClassname(ent, "item_healthkit_small"))
	{
		ent.SetTeam(Merc.ForcedTeam)
	}
	ent = null
	while (ent = Entities.FindByClassname(ent, "func_regenerate"))
	{
		local team = ent.GetTeam()
		if (team != Merc.ForcedTeam)
		{
			ent.SetAbsOrigin(Vector(0,0,-8000))
			ent.SetSize(Vector(-0.1,-0.1,-0.1),Vector(0.1,0.1,0.1))
		}
	}
	
	Merc.Delay(2.5, function() { 
		local tperks = "Completion Bonus: "
		local hasperks = false
		if (Merc.MissionStatus[10] >= 2)
		{
			tperks += "[+1000 HP headstart] "
			hasperks = true
		}
		if (Merc.MissionStatus[11] >= 2)
		{
			tperks += "[+DRACULA is Marked For Death]"
			hasperks = true
		}
		if (hasperks) Merc.ChatPrint(tperks)
	} )
}
Merc.AfterPlayerInv <- function(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() == Merc.ForcedTeam) return
	if (!IsPlayerABot(player)) return
	if (Merc.RoundEnded) return
	
	local preset = player.GetPreset()
	if (preset == Merc.Bots[0].Preset)
	{
		Merc.Delay(1.0, function() {
			player.SetHealth(10000)
			if (Merc.MissionStatus[10] >= 2)
			{
				player.SetHealth(9000)
			}
			if (Merc.MissionStatus[11] >= 2)
			{
				player.AddCond(TF_COND_MARKEDFORDEATH)
			}
			player.AddCustomAttribute("hidden maxhealth non buffed", 10000.0, -1)
			player.AddCustomAttribute("maxammo primary increased", 90.0, -1)
			player.AddCustomAttribute("ammo regen", 90.0, -1)
			player.AddCustomAttribute("cancel falling damage", 1.0, -1)
			player.AddCustomAttribute("cannot be backstabbed", 1.0, -1)
			player.AddCustomAttribute("gesture speed increase", 50.0, -1)
			player.Teleport(true, Vector(0,2576,230), true, QAngle(0, 0, 0), true, Vector(0, 0, 0))
			M24_UpdateHealthBar()
		} )
		player.Teleport(true, Vector(0,2576,230), true, QAngle(0, 0, 0), true, Vector(0, 0, 0))
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0) return
		if (!IsPlayerABot(player)) return
		local preset = player.GetPreset()
		if (preset == Merc.Bots[0].Preset)
		{
			Merc.MainGet(1,1,1)
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

