// KOTH Toxic
::Merc <- {}
Merc.MissionID <- 10
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.WaitTimeConvar <- 1
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SOLDIER, "King"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Medic 1"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Medic 2"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Medic 3"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Medic 4"),
]
Merc.ObjectiveText <- "Win before The King reaches full health"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "TBD"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1

::M11_HealthBar <- null
::M11_KingMaxHealth <- 10000
::M11_KingHealth <- 1

//Merc.Bots[0].Conds = [ TF_COND_SPEED_BOOST, ];
//Merc.Bots[0].Attribs = [ ["max health additive", 5000.0, -1], ]

Merc.Bots[1].Items = ["The Kritzkrieg"]
Merc.Bots[2].Items = ["The Kritzkrieg"]
Merc.Bots[3].Items = ["The Kritzkrieg"]
Merc.Bots[4].Items = ["The Kritzkrieg"]

::M11_UpdateHealthBar <- function()
{
	if (Merc.RoundEnded) return
	if (Merc.Bots[0].Handle != null)
	{
		M11_KingHealth = Merc.Bots[0].Handle.GetHealth()
	}
	local hp = (M11_KingHealth / M11_KingMaxHealth.tofloat()) * 255.0
	if (hp < 1.0)
	{
		hp = 1.0
	}
	local hpbar = hp.tointeger()
	SetPropInt(M11_HealthBar, "m_iBossHealthPercentageByte", hpbar)
	if (M11_KingHealth >= M11_KingMaxHealth - 1)
	{
		Merc.ForceFail()
		Merc.ChatPrint("Main objective failed! The King reached full health.")
	}
}

Merc.BeforeRoundWin <- function(params)
{
	if (params.team == Merc.ForcedTeam)
	{
		if (!Merc.ExtraFailed)
		{
			Merc.ExtraGet(1,1,1)
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
		if (IsPlayerABot(player)) return
		if (params.death_flags & 32) return
		if (Merc.ExtraFailed) return
		if (params.weapon != "tf_pumpkin_bomb") return
		
		Merc.ExtraFail()
		Merc.ChatPrint("Bonus objective failed! Died to a pumpkin bomb.")
	}
	
	OnGameEvent_post_inventory_application = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (player.GetTeam() == Merc.ForcedTeam) return
		if (!IsPlayerABot(player) || Merc.RoundEnded) return
		
		local name = GetPropString(player, "m_szNetname")
		if (name == Merc.Bots[0].Name || name == Merc.Bots[0].Name + "(1)" || name == Merc.Bots[0].Name + "(2)")
		{
			Merc.Delay(1.0, function() {
				player.SetHealth(1)
				player.AddCustomAttribute("hidden maxhealth non buffed", 10000.0, -1)
				M11_UpdateHealthBar()
			} )
		}
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		M11_KingHealth = 1
	
		local ent = null
		while (ent = Entities.FindByClassname(ent, "func_regenerate"))
		{
			local team = ent.GetTeam()
			if (team != Merc.ForcedTeam)
			{
				ent.SetAbsOrigin(Vector(0,0,-9000))
				ent.SetSize(Vector(-0.1,-0.1,-0.1),Vector(0.1,0.1,0.1))
			}
		}
		ent = null
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
		
		if (Entities.FindByClassname(null, "monster_resource") != null)
		{
			M11_HealthBar = Entities.FindByClassname(null, "monster_resource")
		}
		else
		{
			M11_HealthBar = SpawnEntityFromTable("monster_resource", { })
		}
		SetPropInt(M11_HealthBar, "m_iBossState", 0)
		SetPropInt(M11_HealthBar, "m_iBossHealthPercentageByte", 1)
		//M11_UpdateHealthBar()
		
		Merc.Timer(0.5, 0, function() {
			M11_UpdateHealthBar()
		} )
		
		Merc.Delay(0.5, function() { 
			foreach (a in GetClients()) 
			{	
				if (!IsPlayerABot(a))
				{
					local ent = null
					while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
					{
						if (ent.GetOwner() == a)
						{
							SetPropInt(ent, "m_iSelectedSpellIndex", 3)
							SetPropInt(ent, "m_iSpellCharges", 5)
						}
					}
				}
			}
		} )
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

