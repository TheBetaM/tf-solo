// KOTH Ghost Fort
::Merc <- {}
Merc.MissionID <- 13
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_SOLDIER, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_DEMOMAN, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_PYRO, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_HEAVY, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_PYRO, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_SNIPER, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_RED, 0, TF_CLASS_HEAVY, "Bot 08"),
]
Merc.ObjectiveText <- "Protect MERASMUS! and win the round"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get kills while affected by the Wheel of Fate"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 6

::M13_WheelActive <- false

::M13_MerasmusWeapons <- [
	"merasmus",
	"merasmus_dancer",
	"tf_weaponbase_merasmus_grenade",
]

function M13_EffectSet(effect)
{
	M13_WheelActive = effect
	if (effect)
	{
		foreach (a in GetClients()) 
		{	
			if (!IsPlayerABot(a))
			{
				a.RollRareSpell()
			}
		}
	}
}

::M13_RollWheel <- function()
{
	EntFire("wheel_of_fortress","Spin")
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
	OnScriptHook_OnTakeDamage = function(params)
	{
		local victim = params.const_entity
		local inf = params.inflictor
		if (inf == null) return;
		if (victim.GetClassname() != "player") return
		if (victim.GetTeam() != Merc.ForcedTeam) return
		if (Merc.ArrayContains(M13_MerasmusWeapons, inf.GetClassname()) == null) 
		{
			return
		}
		params.damage = 0
		params.max_damage = 0
		params.damage_type = 0
		params.damage_stats = 0
		params.damage_force = Vector(0,0,0)
		//params.early_out = true
		victim.ExtinguishPlayerBurning()
		if (victim.GetAbsVelocity().z > 900.0)
		{
			victim.ApplyAbsVelocityImpulse(Vector(0,0,-1000.0))
		}
	}
	
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || IsPlayerABot(aplayer)) return
		if (!M13_WheelActive) return
		Merc.ExtraGet(1,1,1)
	}
	
	OnGameEvent_npc_hurt = function(params)
	{
		local player = GetPlayerFromUserID(params.attacker_player)
		local npc = EntIndexToHScript(params.entindex)
		if (npc.GetClassname() != "merasmus") return
		if (player.GetTeam() == Merc.ForcedTeam)
		{
			npc.SetHealth(params.health + params.damageamount)
			return
		}
		if (!IsPlayerABot(player)) return
		if (params.health - params.damageamount <= 0)
		{
			Merc.ForceFail()
			Merc.ChatPrint("Main objective failed! MERASMUS! has been defeated.")
		}
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		Convars.SetValue("tf_merasmus_health_base", 28000) //32000
		Convars.SetValue("tf_merasmus_health_per_player", 0)
		Convars.SetValue("tf_merasmus_lifetime", 600)
		Convars.SetValue("tf_merasmus_should_disguise_threshold", 2.0)
		Convars.SetValue("tf_merasmus_bomb_head_per_team", 0)
		
		local ent = null
		while (ent = Entities.FindByClassname(ent, "wheel_of_doom"))
		{
			ent.ValidateScriptScope()
			ent.GetScriptScope()["EffectStart"] <- function(){
				M13_EffectSet(true)
			}
			ent.GetScriptScope()["EffectStop"] <- function(){
				M13_EffectSet(false)
			}
			ent.ConnectOutput("OnEffectApplied","EffectStart")
			ent.ConnectOutput("OnEffectExpired","EffectStop")
			//SetPropFloat(ent,"m_flDuration", 20.0)
		}
		ent = null
		while (ent = Entities.FindByName(ent, "boss_enter_relay"))
		{
			ent.Destroy()
		}
		ent = null
		while (ent = Entities.FindByClassname(ent, "tf_logic_koth"))
		{
			ent.AcceptInput("SetBlueTimer", "180", ent, ent)
			ent.AcceptInput("SetRedTimer", "180", ent, ent)
		}
		
		Merc.Delay(2.0, function() {
			local boss = SpawnEntityFromTable("merasmus", {
				origin       = Vector(0,-128,160),
				angles       = QAngle(0,0,0),
			})
			local text = SpawnEntityFromTable("game_text_tf", {
				message = "MERASMUS! has appeared!",
			})
			text.AcceptInput("Display","",null,null)
		} )
		
		Merc.Delay(2.5, function() {
			ent = null
			while (ent = Entities.FindByClassname(ent, "tf_gamerules"))
			{
				SetPropInt(ent,"m_halloweenScenario",0)
				SetPropBool(ent,"m_bTruceActive",false)
				SetPropInt(ent,"m_iRoundState",4)
			}
			ent = null
			while (ent = Entities.FindByName(ent, "cp_koth"))
			{
				EntFireByHandle(ent, "SetLocked", "0", -1, ent, ent)
				EntFireByHandle(ent, "Enable", "", -1, ent, ent)
				//EntFireByHandle(ent, "SetLocked", "1", 0.5, ent, ent)
			}
			ent = null
			while (ent = Entities.FindByName(ent, "zz_red_koth_timer"))
			{
				//EntFireByHandle(ent, "Resume", "", -1, ent, ent)
			}
			
		} )
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

