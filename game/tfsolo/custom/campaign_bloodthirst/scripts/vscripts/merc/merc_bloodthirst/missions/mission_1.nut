// Arena Graveyard
::Merc <- {}
Merc.MissionID <- 1
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.WaitTimeConvar <- 1
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bone To Pick"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Skull Faced"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Grave Danger"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Missing Skeleton"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Walking Death"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Spine-Chilling Man"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Spiteful Corpse"),
	Merc.BotGeneric(TF_TEAM_BLUE, 0, TF_CLASS_SCOUT, "Rattling Remains"),
	Merc.BotGeneric(TF_TEAM_BLUE, 0, TF_CLASS_SCOUT, "Resting in Pieces"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SCOUT, "Undead Captain"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SCOUT, "Dome of the Dead"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SCOUT, "Mister Bones"),
	
	Merc.Bot(TF_TEAM_RED, 1, "Wraith"),
	Merc.Bot(TF_TEAM_RED, 1, "MonsterJaw"),
	Merc.Bot(TF_TEAM_RED, 1, "WitchDoctor"),
	Merc.Bot(TF_TEAM_RED, 0, "Pith"),
	Merc.Bot(TF_TEAM_RED, 1, "VoodooVizier"),
]
Merc.ObjectiveText <- "Retrieve enough bones within 9 rounds"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 2500
Merc.ObjectiveExtraText <- "Win or survive rounds"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 3
Merc.ForceWinOnMainDone <- 1
Merc.ResetMainOnRestart <- 0
Merc.ResetMainOnFail <- 0
Merc.ResetExtraOnRestart <- 0
Merc.ResetExtraOnFail <- 0

Merc.Bots[0].Items = ["The Horrible Horns"]
Merc.Bots[0].BotWpnFlags = 1
Merc.Bots[1].Items = ["Spine-Chilling Skull 2011 Style 3"]
Merc.Bots[2].Items = ["Spine-Chilling Skull 2011 Style 2"]
Merc.Bots[3].Items = ["Spine-Chilling Skull 2011 Style 1"]
Merc.Bots[4].Items = ["Second-head Headwear"]
Merc.Bots[4].BotWpnFlags = 1
Merc.Bots[5].Items = ["Spine-Chilling Skull"]
Merc.Bots[6].Items = ["Spine-Chilling Skull 2011"]
Merc.Bots[7].Items = ["The Haunted Hat"]
Merc.Bots[8].Items = ["The Skull Island Topper"]
Merc.Bots[9].Items = ["The Mean Captain"]
Merc.Bots[10].Items = ["Demonic Dome"]
Merc.Bots[11].Items = ["Mister Bones"]
for (local a = 0; a < 12; a++)
{
	Merc.Bots[a].Attribs = [["SPELL: Halloween voice modulation",1,-1]]
}

::M15_Scope <- null
::M15_Rounds <- 1
::M15_MaxRounds <- 9
::M15_PickupCount <- 5
::M15_PickupBonus <- 100
::M15_MinEnemies <- 7
::M15_MaxEnemies <- 12

PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })
::M15Prop1 <- "models/props_mvm/mvm_skeleton_arm.mdl"
::M15Prop2 <- "models/props_mvm/mvm_skeleton_leg.mdl"
PrecacheModel(M15Prop1)
PrecacheModel(M15Prop2)
PrecacheScriptSound("Halloween.PumpkinPickup")
PrecacheModel("models/props_graveyard/ghost_healing.mdl")

::PlayerModelFiles <- [
	"scout",
	"scout",
	"sniper",
	"soldier",
	"demo",
	"medic",
	"heavy",
	"pyro",
	"spy",
	"engineer",
	"scout",
]

::M15PropSpots <- [
	[-384,895,36],
	[-495,629,52],
	[-769,1023,36],
	[-830,411,138],
	[-955,-148,165],
	[-445,-987,48],
	[-1718,597,164],
	[-3540,1015,44],
	[-3688,55,58],
	[-3762,-1074,79],
	[-3474,3,25],
	[-2347,-401,105],
	[-1545,-862,154],
	[-1956,-1920,65],
	[-2331,-1109,77],
	[-1311,397,107],
	[-2046,-314,89],
	[-2058,-173,512],
	[-2484,362,110],
	[-1729,137,301],
	[-1538,-481,61],
	[-3155,-1036,37],
	[-3354,-997,39],
	[-2158,-1497,88],
	[-3846,427,34],
];

::M15_BonePickup <- function()
{
	if (Merc.RoundEnded && Merc.ObjectiveMainCount < Merc.ObjectiveMainMax && Merc.ObjectiveMainCount + M15_PickupBonus >= Merc.ObjectiveMainMax) 
	{
		Merc.ObjectiveMainCount = Merc.ObjectiveMainMax - 1
		Merc.UpdateHUD()
		return
	}
	Merc.MainGet(M15_PickupBonus,1,1)
	Merc.ObjectiveTextAdd = " (+" + M15_PickupBonus + ")" + " (Round " + M15_Rounds + ")"
	Merc.UpdateHUD()
}

::M15_GetPlacement <- function(list, maxpick)
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

function M15_SpawnPickup(x, y, z)
{
	local mprop = M15Prop1
	if (RandomInt(0,1) == 1)
	{
		mprop = M15Prop2
	}
	local prop = SpawnEntityFromTable("tf_halloween_pickup", {
		origin       = Vector(x,y,z + 8.0),
		angles       = QAngle(-90,RandomInt(0, 179),0),
		targetname   = "mercduck",
		model 		 = mprop,
		powerup_model = mprop,
		pickup_particle = "taunt_headbutt_impact_stars",
		pickup_sound = "Halloween.PumpkinPickup",
		automaterialize = false,
		TeamNum = Merc.ForcedTeam,
		teamnumber = Merc.ForcedTeam,
	})
	prop.SetTeam(Merc.ForcedTeam)
	prop.ValidateScriptScope()
	prop.ConnectOutput("OnRedPickup", "M15_BonePickup")
}

::M15_SpawnAsSkeleton <- function(player)
{
	if (player.InCond(TF_COND_HALLOWEEN_GHOST_MODE)) return
	local model = PlayerModelFiles[player.GetPlayerClass()]
	player.SetCustomModelWithClassAnimations("models/player/"+model+".mdl")
	
	Merc.Delay(0.5, function() { 
		if (player.InCond(TF_COND_HALLOWEEN_GHOST_MODE)) return
		local group = player.FindBodygroupByName("hat")
		local groupent = player.GetBodygroup(group)
		local body = Entities.CreateByClassname("tf_wearable")
		DoEntFire("!self", "SetParent", "!activator", -1, player, body)
		body.SetModelSimple("models/bots/skeleton_sniper/skeleton_sniper.mdl")
		SetPropEntity(body, "m_hOwnerEntity", player)
		SetPropInt(body, "m_Collision.m_usSolidFlags", Constants.FSolid.FSOLID_NOT_SOLID)
		SetPropInt(body, "m_CollisionGroup", 11)
		SetPropInt(body, "m_bValidatedAttachedEntity", 1)
		SetPropInt(body, "m_iTeamNum", player.GetTeam())
		SetPropInt(body, "m_fEffects", 129)
		SetPropInt(body, "m_AttributeManager.m_Item.m_bInitialized", 1)
		Entities.DispatchSpawn(body)
		SetPropInt(player, "m_nRenderFX", 6)
		body.SetBodygroup(group, groupent)
	} )
}

Merc.BeforeRoundStart <- function(params) 
{
	local eCount = RandomInt(M15_MinEnemies,M15_MaxEnemies)
	for (local a=0;a<12;a++)
	{
		Merc.Bots[a].Class = RandomInt(1,8)
		Merc.Bots[a].Flags = 1
	}
	local enemies = M15_GetPlacement([0,1,2,3,4,5,6,7,8,9,10,11], eCount)
	foreach (a in enemies)
	{
		Merc.Bots[a].Flags = 0
	}
	
	if (M15_Rounds > M15_MaxRounds)
	{
		Merc.ObjectiveMainCount <- 0
		Merc.ObjectiveExtraCount <- 0
		M15_Rounds = 1
	}
	Merc.ObjectiveTextAdd <- " (Round " + M15_Rounds + ")"
	
	local places = M15_GetPlacement(M15PropSpots,M15_PickupCount)
	foreach (a in places)
	{
		M15_SpawnPickup(a[0],a[1],a[2])
	}
	
	local ent = Entities.FindByName(null, "script")
	M15_Scope = ent.GetScriptScope()
	foreach (a in GetClients())
	{	
		a.ValidateScriptScope()
		if(a.GetScriptScope().dispenser_range.IsValid())
		{
			a.GetScriptScope().dispenser_range.Kill()
			a.GetScriptScope().dispenser.Kill()
		}
		M15_Scope["unBecomeGhost"](a)
		a.GetScriptScope().dispenser_range <- { IsValid = @() false }
		a.GetScriptScope().dispenser <- { IsValid = @() false }
	}
}

Merc.BeforeRoundWin <- function(params)
{
	M15_Rounds++
	if (M15_Rounds > M15_MaxRounds)
	{
		if (Merc.ObjectiveMainCount < Merc.ObjectiveMainMax)
		{
			Merc.ChatPrint("Main objective failed! Not enough damage.")
		}
	}
	local ghostcheck = 0
	foreach (a in GetClients())
	{	
		if (!IsPlayerABot(a) && a.InCond(TF_COND_HALLOWEEN_GHOST_MODE))
		{
			ghostcheck++
		}
	}
	if (params.team == Merc.ForcedTeam || ghostcheck == 0)
	{
		Merc.ExtraGet(1,1,1)
	}
}

Merc.AfterPlayerSpawn <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	player.ValidateScriptScope()
	player.GetScriptScope().dispenser_range <- { IsValid = @() false }
	player.GetScriptScope().dispenser <- { IsValid = @() false }
	
	if (player.GetTeam() != Merc.ForcedTeam)
	{
		M15_SpawnAsSkeleton(player)
	}
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_restart_round = function(params)
	{
		Merc.ObjectiveMainCount <- 0
		Merc.ObjectiveExtraCount <- 0
		M15_Rounds = 1
	}
	
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		//player.SetCustomModel("")
		//SetPropInt(player, "m_nRenderFX", 0)
		//player.EnableDraw()
		
		if (params.userid == 0 || !IsPlayerABot(player)) return
		if (player.GetTeam() == Merc.ForcedTeam) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || IsPlayerABot(aplayer)) return
		
		local ent = null
		while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
		{
			if (ent.GetOwner() == aplayer)
			{
				SetPropInt(ent, "m_iSelectedSpellIndex", RandomInt(0,11))
				SetPropInt(ent, "m_iSpellCharges", 1)
			}
		}
	}
	
	OnGameEvent_player_hurt = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer != null && !IsPlayerABot(aplayer))
		{
			local dmg = params.damageamount
			if (dmg > 300) 
			{
				dmg = 300
			}
			if (params.crit)
			{
				dmg = dmg / 3
			}
			if (dmg < 0)
			{
				dmg = 0
			}
			Merc.ObjectiveTextAdd = " (+" + dmg + ")" + " (Round " + M15_Rounds + ")"
			if (Merc.RoundEnded && Merc.ObjectiveMainCount < Merc.ObjectiveMainMax && Merc.ObjectiveMainCount + dmg >= Merc.ObjectiveMainMax) 
			{
				Merc.ObjectiveMainCount = Merc.ObjectiveMainMax - 1
				Merc.UpdateHUD()
				return
			}
			Merc.MainGet(dmg,0,1)
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

