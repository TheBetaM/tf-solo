// CP Sandcastle
::Merc <- {}
Merc.MissionID <- 11
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_HEAVY, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_DEMOMAN, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 05"),
	
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 09"),
]
Merc.ObjectiveText <- "Make MONOCULUS destroy all targets"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 10
Merc.ObjectiveExtraText <- "Get kills with critical hits"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 5
Merc.ForceWinOnMainDone <- 1

::M10Props <- [
	"models/props_gameplay/orange_cone001.mdl",
	"models/props_medieval/target/target.mdl",
	"models/props_training/target_scout.mdl",
];
foreach (i in M10Props)
{
	PrecacheModel(i)
}

::M10PropCount <- 10;
::M10PropSpots <- [
	[1, -240,1560,26, 0,45,0],
	[1, 349,1746,379, 0,180,0],
	[1, -455,2435,379, 0,90,0],
	[1, -27,2433,379, 0,90,0],
	//[1, -530,1537,379, 0,90,0],
	[1, 349,1879,214, 0,180,0],
	[1, -373,2058,-32, 0,345,0],
	[1, -467,1747,214, 0,0,0],
	[1, -467,1958,214, 0,0,0],
	[1, -1415,1818,-102, 0,0,0],
	[1, -1167,1648,-40, 0,45,0],
	[1, -443,3474,150, 15,270,0],
	[1, 939,3699,210, 0,270,0],
	[1, 95,4222,-169, -15,270,0],
	[1, -525,4906,-224, 0,240,0],
	[1, -1255,4131,-150, 0,0,0],
	[1, -361,2475,-58, 0,90,0],
	[1, 1025,2822,18, 0,180,0],
	[1, 901,2275,-42, 0,270,0],
	[1, 1170,1678,-42, 0,120,0],
];
::M10EyeSpots <- [
	[-601,2842,94],
	[-68,1848,152],
	[-68,1848,344],
	[1096,1881,138],
	[-844,1664,110],
	[472,2839,98],
	[-734,4667,-72],
	[161,3942,106],
	[645,3592,228],
	[-66,2815,436],
];
::M10PurgSpots <- [
	[-512,2016,360],
	[415,2261,360],
	[-652,2975,30],
	[242,2916,-66],
];

::M10_GetPlacement <- function(list, maxpick)
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

function M10_SpawnProp(modelname, x, y, z, rotx, roty, rotz, ptype)
{
	local offset = 60.0
	local petype = "prop_dynamic_override"
	local mname = modelname
	if (ptype == 1) 
	{
		offset = 22.0
	}
	local prop = SpawnEntityFromTable(petype, {
		origin       = Vector(x,y,z - offset),
		angles       = QAngle(rotx, roty, rotz),
		model 		 = mname,
		targetname   = "mercprop",
		max_health   = 1000,
		health 		 = 1000,
		solid		 = 6,
		skin		 = 1,
	})
	if (ptype == 1)
	{
		prop.SetTeam(TF_TEAM_BLUE)
		prop.ValidateScriptScope()
		prop.GetScriptScope()["M10PropState"] <- 0
		prop.GetScriptScope()["M10PropDestroy"] <- function(){
			if (activator.GetTeam() == 2 || activator.GetTeam() == 3) return
			if (M10PropState != 0) return
			M10PropState = 1
			Merc.MainGet(1,1,1)
			DispatchParticleEffect("hit_text", Vector(x,y,z), Vector(0,0,0))
			DispatchParticleEffect("doublejump_smoke", Vector(x,y,z), Vector(0,0,0))
			if (self != null)
				self.AcceptInput("Break","",self,self)
		}
		prop.ConnectOutput("OnTakeDamage", "M10PropDestroy")
	}
	
	return prop
}


Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_npc_hurt = function(params)
	{
		local player = GetPlayerFromUserID(params.attacker_player)
		local npc = EntIndexToHScript(params.entindex)
		if (npc.GetClassname() != "eyeball_boss") return
		if (params.attacker_player == null) return
		npc.SetHealth(params.health + params.damageamount)
		Merc.Delay(0.1, function() { 
			local ent = null
			while (ent = Entities.FindByName(ent, "monster_resource"))
			{
				SetPropInt(ent, "m_iBossHealthPercentageByte", 0)
			}
		} )
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		foreach (a in Merc.Bots)
		{
			a.BotWpnFlags = 1
		}
		
		Convars.SetValue("tf_eyeball_boss_lifetime", 9000)
		Convars.SetValue("tf_eyeball_boss_health_base", 9000)
		Convars.SetValue("tf_eyeball_boss_health_per_level", 0)
		Convars.SetValue("tf_eyeball_boss_health_per_player", 0)
		Convars.SetValue("tf_eyeball_boss_health_at_level_2", 9000)
		Convars.SetValue("tf_eyeball_boss_hover_height", 50)
		
		foreach (a in M10EyeSpots)
		{
			local targetalt = SpawnEntityFromTable("info_target", {
				origin = Vector(a[0],a[1],a[2]),
				targetname = "spawn_boss_alt"
			})
		}
		foreach (a in M10PurgSpots)
		{
			local target1 = SpawnEntityFromTable("info_target", {
				origin = Vector(a[0],a[1],a[2]),
				targetname = "spawn_loot"
			})
			local target2 = SpawnEntityFromTable("info_target", {
				origin = Vector(a[0],a[1],a[2]),
				targetname = "spawn_purgatory"
			})
		}
		
		local ent = null
		while (ent = Entities.FindByName(ent, "keep_door"))
		{
			ent.Destroy()
			//ent.SetAbsOrigin(Vector(-64,2396,-2000))
		}
		
		local places = M10_GetPlacement(M10PropSpots,M10PropCount)
		foreach (a in places)
		{
			M10_SpawnProp(M10Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 1)
		}
	}
	
	OnGameEvent_teamplay_setup_finished = function(params)
	{
		local boss1 = SpawnEntityFromTable("eyeball_boss", {
			origin = Vector(-576,2848,16),
			TeamNum = 5,
		})
		boss1.AddFlag(FL_NOTARGET)
		local text = SpawnEntityFromTable("game_text_tf", {
			message = "MONOCULUS has appeared!",
		})
		text.AcceptInput("Display","",null,null)
		
		local ent = null
		while (ent = Entities.FindByClassname(ent, "team_round_timer"))
		{
			EntFireByHandle(ent,"Pause","",0,ent,ent)
		}
		ent = null
		while (ent = Entities.FindByName(ent, "monster_resource"))
		{
			SetPropInt(ent, "m_iBossHealthPercentageByte", 0)
		}
	}
	
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		if (params.death_flags & 32) return
		if (player.GetTeam() == Merc.ForcedTeam) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || IsPlayerABot(aplayer)) return
		if ((params.damagebits & 1048576) != 0)
		{
			Merc.ExtraGet(1,1,1)
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

