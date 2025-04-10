// PL Phoenix
::Merc <- {}
Merc.MissionID <- 5
IncludeScript("merc/merc_headhunt/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_BLUE, 1, "Medieval"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Pardner"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Centurion"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Roman"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Olympic"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Headhunter"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Legion"),
	
	Merc.Bot(TF_TEAM_RED, 1, "Builder2"),
	Merc.Bot(TF_TEAM_RED, 1, "Hazmat"),
	Merc.Bot(TF_TEAM_RED, 0, "Master"),
	Merc.Bot(TF_TEAM_RED, 1, "Hazard"),
	Merc.Bot(TF_TEAM_RED, 1, "Brigade"),
]
Merc.ObjectiveText <- "Destroy the cart"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Destroy the hidden explosives"
Merc.ObjectiveExtraCount <- 0
::M05PropCount <- 5
Merc.ObjectiveExtraMax <- M05PropCount
Merc.ForceWinOnMainDone <- 1

::M05Props <- [
	"models/props_lakeside_event/bomb_temp.mdl",
	"models/props_trainyard/bomb_cart.mdl",
]
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "asplode_hoodoo" })
PrecacheSound("items/pumpkin_explode2.wav")
foreach (i in M05Props)
{
	PrecacheModel(i)
}

::M05PropSpots <- [
	[0, 4891,1311,-42, 0,0,0],
	[0, 1766,2857,-63, 0,0,0],
	[0, 686,-72,159, 0,0,0],
	[0, 1171,-168,277, 0,0,0],
	[0, 1121,-1895,163, 0,0,0],
	[0, -576,-1300,-107, 0,0,0],
	[0, -1089,-1012,149, 0,0,0],
	[0, -1378,-2587,-299, 0,0,0],
	[0, -3569,1074,-107, 0,0,0],
	[0, -1973,230,-235, 0,0,0],
]

::M05SetupDone <- false
::M05_HealthBar <- null
::M05_Cart <- null
::M05_RealCart <- null
::M05_CartMaxHealth <- 10000
::M05_CartHealth <- M05_CartMaxHealth

::M05_TimerEnd <- function()
{
	if (!M05SetupDone)
	{
		return;
	}
	if (Merc.ObjectiveMainCount < Merc.ObjectiveMainMax)
	{
		Merc.ForceFail()
	}
}
::M05_SetupEnd <- function()
{
	M05SetupDone = true
}

::M05_GetPropPlacement <- function(list)
{
	local places = [], full = []
	local maxpick = M05PropCount
	foreach (a in list) full.push(a)
	for (local i = 0; i < maxpick; i++)
	{
		local a = RandomInt(0, full.len() - 1)
		places.push(full[a])
		full.remove(a)
	}
	return places
}

::M05_PropDestroyed <- function()
{
	Merc.ExtraGet(1, 1, 1)
}

::M05_UpdateHealthBar <- function()
{
	local hp = (M05_CartHealth / M05_CartMaxHealth) * 255;
	SetPropInt(M05_HealthBar, "m_iBossHealthPercentageByte", hp);
}

::M05_CartDamage <- function(params)
{
	if (Merc.RoundEnded) return
	local victim = params.const_entity
	if (victim.GetName() != "mcartprop") return
	local inf = params.attacker
	if (inf == null) return
	if (inf.GetTeam() != Merc.ForcedTeam) return
	if (inf.GetClassname() == "player" && inf.GetPlayerClass() == TF_CLASS_HEAVY)
	{
		M05_CartHealth = M05_CartHealth - (params.damage * 0.8);
	}
	else
	{
		M05_CartHealth = M05_CartHealth - params.damage;
	}
	if (M05_CartHealth < 0)
	{
		M05_CartHealth = 0
		Merc.MainGet(1, 1, 1)
		M05_RealCart.DisableDraw()
		DispatchParticleEffect("asplode_hoodoo", victim.GetOrigin(), Vector(0,0,0));
		EmitSoundEx({ sound_name = "items/pumpkin_explode2.wav",
			origin = victim.GetOrigin(),
		})
		M05_Cart.Kill()
		M05_UpdateHealthBar()
		return
	}
	M05_UpdateHealthBar()
	local userid = inf.GetUserID()
	SendGlobalGameEvent("npc_hurt", {
		entindex = victim.entindex(),
		health = M05_CartHealth,
		attacker_player = userid,
		damageamount = params.damage,
	})
}

function M05_SpawnProp(modelname, x, y, z, rotx, roty, rotz, ptype)
{
	if (ptype == 0)
	{
		local prop = SpawnEntityFromTable("prop_dynamic", {
			origin       = Vector(x,y,z - 10.0),
			angles       = QAngle(rotx, roty, rotz),
			model 		 = modelname,
			targetname   = "mtargetprop",
			max_health   = 1000,
			health 		 = 1000,
			solid		 = 6,
		})
		prop.SetTeam(TF_TEAM_BLUE)
		prop.ValidateScriptScope()
		prop.GetScriptScope()["M05PropState"] <- 0
		prop.GetScriptScope()["M05PropDestroy"] <- function(){
			if (M05PropState != 0) return
			M05PropState = 1
			M05_PropDestroyed()
			DispatchParticleEffect("taunt_headbutt_impact_stars", Vector(x,y,z), Vector(0,0,0))
			self.Kill()
		}
		prop.ConnectOutput("OnTakeDamage", "M05PropDestroy")
	}
	else
	{
		local prop = SpawnEntityFromTable("prop_dynamic_override", {
			origin       = Vector(-1107,-5121,24),
			angles       = QAngle(0, 90, 0),
			model 		 = modelname,
			targetname   = "mcartprop",
			max_health   = 1000,
			health 		 = 1000,
			solid		 = 6,
			spawnflags 	 = 1024,
		})
		SetPropInt(prop, "m_nRenderMode", Constants.ERenderMode.kRenderTransColor)
		SetPropInt(prop, "m_clrRender", 0)
		prop.SetTeam(TF_TEAM_BLUE)
		prop.ValidateScriptScope()
		prop.GetScriptScope()["OnScriptHook_OnTakeDamage"] <- function(params){
			M05_CartDamage(params)
		}
		__CollectGameEventCallbacks(prop.GetScriptScope())
		M05_Cart = prop
	}
}

::M05_TrainThink <- function()
{
	if (Merc.RoundEnded) return -1
	local pos = M05_RealCart.GetOrigin()
	local ang = M05_RealCart.GetAbsAngles()
	M05_Cart.SetAbsOrigin(pos)
	M05_Cart.SetAbsAngles(ang)
	return -1
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		M05SetupDone = false
	
		M05_CartHealth = M05_CartMaxHealth
		if (Entities.FindByClassname(null, "monster_resource") != null)
		{
			M05_HealthBar = Entities.FindByClassname(null, "monster_resource")
		}
		else
		{
			M05_HealthBar = SpawnEntityFromTable("monster_resource", { })
		}
		SetPropInt(M05_HealthBar, "m_iBossState", 0)
		SetPropInt(M05_HealthBar, "m_iBossHealthPercentageByte", 255)
		M05_UpdateHealthBar()
		
		local ent = null
		while (ent = Entities.FindByName(ent, "sspl_train"))
		{
			ent.SetSolid(0)
		}
		while (ent = Entities.FindByName(ent, "sspl_cart"))
		{
			local pos = ent.GetCenter()
			local rot = ent.GetAbsAngles()
			M05_SpawnProp(M05Props[1], pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, 1)
			M05_RealCart = ent
		}
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			ent.ValidateScriptScope()
			ent.AcceptInput("SetSetupTime", "1", null, null)
			ent.ConnectOutput("OnSetupFinished", "M05_SetupEnd")
			ent.ConnectOutput("On1SecRemain", "M05_TimerEnd")
		}
		local thinker = SpawnEntityFromTable("logic_script", {})
		thinker.ValidateScriptScope()
		AddThinkToEnt(thinker,"M05_TrainThink")
		
		local places = M05_GetPropPlacement(M05PropSpots)
		foreach (a in places)
		{
			M05_SpawnProp(M05Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 0)
		}
	}
	
	OnGameEvent_teamplay_round_win = function(params)
	{
		if (params.team != Merc.ForcedTeam)
		{
			M05_Cart.Kill()
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

