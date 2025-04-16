// PL Terror
::Merc <- {}
Merc.MissionID <- 9
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [ Merc.Bot(TF_TEAM_BLUE, 0, "Bloodthirst_Merasmus"),]
Merc.ObjectiveText <- "Reach the cart without dying"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Break all the targets"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 10
Merc.AllowRecruits <- 0

Merc.Bots[0].Conds = [TF_COND_FREEZE_INPUT]
Merc.Bots[0].BotAttribs = [IGNORE_ENEMIES]
Merc.Bots[0].BotWpnFlags = 1

PrecacheModel("models/bots/merasmus/merasmus.mdl")

::M01SetupDone <- false
::M01Props <- [
	"models/props_gameplay/orange_cone001.mdl",
	"models/props_gameplay/security_fence_section01.mdl",
	"models/props_training/target_scout.mdl",
]
foreach (i in M01Props)
{
	PrecacheModel(i)
}

::M01_TimerEnd <- function()
{
	if (!M01SetupDone)
	{
		return
	}
	if (!Merc.RoundEnded)
	{
		Merc.ForceFail()
		M01SetupDone = false
	}
}
::M01_SetupEnd <- function()
{
	M01SetupDone = true
}

::M01PropSpots <- [
	[1, -1825,7183,311, 0,90,0],
	[1, -2503,6246,240, 0,0,0],
	[1, -1812,5571,176, 0,0,0],
	[1, -958,5563,207, 0,0,0],
	[1, -1210,5563,207, 0,0,0],
	[1, -271,6142,304, 0,90,0],
	[1, -414,4717,266, 0,0,0],
	[1, -1126,4714,295, 0,0,0],
	[1, -1492,4691,48, 0,0,0],
	[1, -430,4715,2, 0,0,0],
	[1, -977,2768,184, 0,0,0],
	[1, -1805,3751,152, 0,90,0],
	[1, -1410,1957,112, 0,0,0],
	[1, -153,2103,288, 0,90,0],
	[1, -1053,765,256, 0,0,0],
	[1, -375,842,263, 0,0,0],
	[1, 335,793,154, 0,0,0],
	[1, 584,555,328, 0,0,0],
	[1, -656,513,263, 0,0,0],
]
::M01TargetSpots <- [
	[2, -2236,5865,41, 0,180,0],
	[2, -149,5671,341, 0,270,0],
	[2, -1942,5451,153, 0,0,0],
	[2, 140,3868,89, 0,270,0],
	[2, -839,3319,237, 0,180,0],
	[2, -1917,2320,33, 0,180,0],
	[2, -807,2653,161, 0,0,0],
	[2, 561,1371,113, 0,180,0],
	[2, -641,-147,121, 0,90,0],
	[2, -1171,1652,161, 0,0,0],
]

::M01SkeletonSpots <- [
	[-1615,6695,21],
	//[-290,4298,-16],
	[-1760,2593,29],
	[475,1008,109],
	[-114,38,112],
]
::M01MeteorSpots <- [
	[-691,6625,87],
	[-1969,4550,191],
	[-407,3492,57],
	[-964,2103,79],
	[-342,1197,197],
]
::M01FireballSpots <- [
	[-770,5837,180, 0,0,0],
	[-1224,4859,297, 0,0,0],
	[-1467,2941,71, 0,0,0],
	[-1461,3045,82, 0,0,0],
	[-206,2109,184, 0,180,0],
	[-476,707,310, 0,0,0],
	[-1139,605,265, 0,0,0],
]

::M01_PropDestroyed <- function()
{
	Merc.ExtraGet(1,1,1)
}

function M01_SpawnProp(modelname, x, y, z, rotx, roty, rotz, ptype)
{
	local offset = 60.0
	local petype = "prop_dynamic_override"
	local mname = modelname
	if (ptype == 1) 
	{
		offset = 40.0
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
		prop.GetScriptScope()["M01PropState"] <- 0
		prop.GetScriptScope()["M01PropDestroy"] <- function(){
			if (M01PropState != 0) return
			M01PropState = 1
			M01_PropDestroyed()
			DispatchParticleEffect("hit_text", Vector(x,y,z), Vector(0,0,0))
			DispatchParticleEffect("doublejump_smoke", Vector(x,y,z), Vector(0,0,0))
			if (self != null)
				self.AcceptInput("Break","",self,self)
		}
		prop.ConnectOutput("OnTakeDamage", "M01PropDestroy")
	}
	if (ptype == 2)
	{
		//prop.DisableDraw()
		//prop.SetCollisionGroup(25)
	}
	
	return prop
}
function M01_SpawnHazard(htype, x, y, z, rotx, roty, rotz)
{
	local offset = 20.0
	if (htype == 0) 
	{ 
		local prop = SpawnEntityFromTable("tf_zombie_spawner", {
			origin = Vector(x,y,z - offset),
			angles = QAngle(rotx, roty, rotz),
			zombie_lifetime = 0,
			max_zombies = 1,
			infinite_zombies = false,
			zombie_type = 0,
			TeamNum = TF_TEAM_BLUE,
			teamnumber = TF_TEAM_BLUE,
		})
		prop.AcceptInput("Enable", "", null, null)
	}
	else if (htype == 1)
	{
		local prop = SpawnEntityFromTable("tf_projectile_spellmeteorshower", {
			basevelocity = QAngle(rotx, roty, rotz).Forward()*200,
			origin = Vector(x,y,z - offset),
			angles = QAngle(rotx, roty, rotz),
			TeamNum = TF_TEAM_BLUE,
			teamnumber = TF_TEAM_BLUE,
		})
		prop.SetOwner(Merc.Bots[0].Handle)
	}
	else
	{
		local prop = SpawnEntityFromTable("tf_projectile_spellfireball", {
			basevelocity = QAngle(rotx, roty, rotz).Forward()*200,
			origin = Vector(x,y,z - offset),
			angles = QAngle(rotx, roty, rotz),
			TeamNum = TF_TEAM_BLUE,
			teamnumber = TF_TEAM_BLUE,
		})
		prop.SetOwner(Merc.Bots[0].Handle)
	}
}

Merc.BeforeRoundStart <- function(params) 
{
	M01SetupDone <- false
	
	foreach (a in M01PropSpots)
	{
		M01_SpawnProp(M01Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 0)
	}
	foreach (a in M01TargetSpots)
	{
		M01_SpawnProp(M01Props[a[0]], a[1], a[2], a[3], a[4], a[5], a[6], 1)
	}
	foreach (a in M01SkeletonSpots)
	{
		M01_SpawnHazard(0, a[0], a[1], a[2], 0, 0, 0)
	}
	Merc.Timer(25.0, 0, function() {
		foreach (a in M01MeteorSpots)
		{
			M01_SpawnHazard(1, a[0], a[1], a[2], 90, 0, 0)
		}
	} )
	Merc.Timer(15.0, 0, function() {
		foreach (a in M01FireballSpots)
		{
			M01_SpawnHazard(2, a[0], a[1], a[2], a[3], a[4], a[5])
		}
	} )
	
	local ent = null
	while (ent = Entities.FindByClassname(ent, "team_round_timer"))
	{
		ent.ValidateScriptScope()
		ent.AcceptInput("SetSetupTime", "1", null, null)
		ent.ConnectOutput("OnSetupFinished", "M01_SetupEnd")
		ent.ConnectOutput("On1SecRemain", "M01_TimerEnd")
	}
	ent = null
	while (ent = Entities.FindByName(ent, "portti_x_oikea"))
	{
		ent.Destroy()
	}
	ent = null
	while (ent = Entities.FindByName(ent, "portti_x_vasen"))
	{
		ent.Destroy()
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_controlpoint_starttouch = function(params)
	{
		local player = EntIndexToHScript(params.player)
		if (player.GetTeam() != Merc.ForcedTeam) return
		if (IsPlayerABot(player)) return
		if (Merc.RoundEnded) return
		Merc.MainGet(1,1,1)
		Merc.ForceWin()
	}
	
	OnGameEvent_player_spawn = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (IsPlayerABot(player)) 
		{
			//player.SetCustomModelWithClassAnimations("models/bots/merasmus/merasmus.mdl")
			player.SetSkin(0)
			return
		}
		if (player.GetTeam() == Merc.ForcedTeam)
		{
			player.Teleport(true, Vector(-2761,7157,233), true, QAngle(0, 315, 0), true, Vector(0, 0, 0))
			
			local ent = null
			while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
			{
				if (ent.GetOwner() == player)
				{
					SetPropInt(ent, "m_iSelectedSpellIndex", 2)
					SetPropInt(ent, "m_iSpellCharges", 1)
				}
			}
		}
	}
	
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (IsPlayerABot(player)) return
		if (Merc.RoundEnded) return
		Merc.ForceFail()
		M01SetupDone = false
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

