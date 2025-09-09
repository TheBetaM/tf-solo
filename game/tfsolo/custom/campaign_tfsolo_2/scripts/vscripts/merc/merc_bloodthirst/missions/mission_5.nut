// SD Carnival of Carnage
::Merc <- {}
Merc.MissionID <- 5
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_DEMOMAN, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SOLDIER, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_ENGINEER, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SNIPER, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_MEDIC, "Bot 08"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Bot 09"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SOLDIER, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_MEDIC, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_HEAVY, "Bot 12"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_PYRO, "Bot 13"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_DEMOMAN, "Bot 14"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SNIPER, "Bot 15"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SPY, "Bot 16"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_ENGINEER, "Bot 17"),
]
Merc.ObjectiveText <- "Get enough carnival points in time"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 9000
Merc.ObjectiveExtraText <- "Get kills with different types of weapons"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 9
Merc.IgnoreMainCap <- 1

Convars.SetValue("tf_flag_caps_per_round", 999)

::M09MissionTime <- (10 * 60) + 6
::M09Time <- M09MissionTime
::M09TimeAdd <- " (0:00)"
::M09ScoreAdd <- ""
::M09_WeaponArray <- []
::M09DuckCount <- 10

::M09Prop <- "models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl"
PrecacheModel(M09Prop)
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "taunt_headbutt_impact_stars" })

::M09DuckSpots <- [
	[-2811,1946,94],
	[-3693,1550,70],
	[-2906,2396,79],
	[-3220,1401,27],
	[-2768,3500,246],
	[-1655,1259,-131],
	[-1687,884,-111],
	[-1975,360,318],
	[-1300,899,399],
	[-744,838,399],
	[-74,364,322],
	[984,1070,-28],
	[-46,2230,69],
	[-391,1270,-126],
	[-347,873,-100],
	[202,2358,94],
	[-793,2091,21],
	[-1247,2096,16],
	[-974,186,322],
	[-1079,195,322],
	[-1266,3190,10],
	[-771,3181,13],
	[19,3554,214],
	[-167,4306,194],
	[-1024,4631,-157],
	[-1532,4399,186],
	[-1298,3237,206],
	[-752,3243,210],
	[-1497,2725,128],
	[-554,2747,107],
]

function M09_Clock()
{
	if (Merc.RoundEnded) return
	if (M09Time > 0)
	{
		M09Time = M09Time - 1
		local minutes = M09Time / 60
		local seconds = M09Time - (minutes * 60)
		if (seconds > 9)
			M09TimeAdd = " ("+minutes+":"+seconds+")"
		else
			M09TimeAdd = " ("+minutes+":0"+seconds+")"
	}
	else
	{
		if (Merc.ObjectiveMainCount >= Merc.ObjectiveMainMax)
		{
			Merc.MainGet(0,1,1)
			Merc.ForceWin()
		}
		else
		{
			Merc.ChatPrint("Main objective failed! Not enough carnival points.")
			Merc.ForceFail()
		}
		M09TimeAdd = " (0:00)"
	}
	Merc.ObjectiveTextAdd = M09TimeAdd
	Merc.UpdateHUD()
}

function M09Score(name,count)
{
	Merc.ObjectiveMainCount += count
	if (Merc.ObjectiveMainCount < 0)
	{
		Merc.ObjectiveMainCount = 0
	}
	if (count > 0)
		M09ScoreAdd = "" + name + " +" + count
	else
		M09ScoreAdd = "" + name + " " + count
	Merc.ChatPrint(M09ScoreAdd)
	Merc.UpdateHUD()
}

::M09_GetPlacement <- function(list, maxpick)
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

function M09_SpawnDuck(x, y, z)
{
	local mprop = M09Prop
	local prop = SpawnEntityFromTable("tf_halloween_pickup", {
		origin       = Vector(x,y,z - 18.0),
		angles       = QAngle(0,RandomInt(0, 179),0),
		targetname   = "mercduck",
		model 		 = mprop,
		powerup_model = mprop,
		pickup_particle = "taunt_headbutt_impact_stars",
		automaterialize = false,
		TeamNum = Merc.ForcedTeam,
		teamnumber = Merc.ForcedTeam,
	})
	prop.SetTeam(Merc.ForcedTeam)
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0) return
		if (!IsPlayerABot(player)) 
		{
			if ((params.damagebits & 128) != 0)
			{
				//M09Score("Feign Death",50)
				//return
			}
			M09Score("Death",-50)
			return
		}
		if (player.GetTeam() == Merc.ForcedTeam) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null) return
		if (IsPlayerABot(aplayer))
		{
			if (params.assister <= 0) return
			local asplayer = GetPlayerFromUserID(params.assister)
			if (asplayer == null || IsPlayerABot(asplayer)) return
			if (asplayer.GetPlayerClass() == TF_CLASS_MEDIC)
			{
				M09Score("Medic Assist",160)
			}
			else
			{
				M09Score("Assist",80)
			}
			return
		}
		if (Merc.ArrayContains(M09_WeaponArray,params.weapon) == null)
		{
			Merc.ExtraGet(1,1,1)
			M09_WeaponArray.push(params.weapon)
			M09Score("Unique Kill",200)
		}
		else
		{
			M09Score("Normal Kill",100)
		}
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		M09_WeaponArray <- []
	
		M09Time = M09MissionTime
		Merc.Timer(1.0, 0, M09_Clock)
		local minutes = M09Time / 60
		local seconds = M09Time - (minutes * 60)
		if (seconds > 9)
			M09TimeAdd = " ("+minutes+":"+seconds+")"
		else
			M09TimeAdd = " ("+minutes+":0"+seconds+")"
		M09ScoreAdd = ""
		Merc.ObjectiveTextAdd = M09TimeAdd
		
		local ent = null
		while (ent = Entities.FindByClassname(ent, "func_capturezone"))
		{
			EntityOutputs.RemoveOutput(ent, "OnCapTeam1", "halloween_logic_2014", "SetAdvantageTeam", "red")
			EntityOutputs.RemoveOutput(ent, "OnCapTeam2", "halloween_logic_2014", "SetAdvantageTeam", "blue")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "game_timer", "Disable", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "button_touch_trigger", "Disable", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "bell_ringer_relay", "Enable", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "bell_ticket_case", "Enable", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "tickets_captured_sound", "PlaySound", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "button_touch_trigger", "Disable", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "elevator_australium_zone", "Kill", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "merasmus_fortune_booth", "DisableFortuneTelling", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "fortune_music_track", "StopSound", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "hammer_smash_trigger_relay", "CancelPending", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "fortune_music_track", "Kill", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "bell_chain_lock_fx", "Start", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "sound_chain_explode", "PlaySound", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "bell_ticket_case", "Kill", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "bell_chain_lock", "Kill", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "tickets_captured_sound", "Kill", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "hammer_souls_rising", "Start", "")
			EntityOutputs.RemoveOutput(ent, "OnCapture", "hammer_souls_rising", "Stop", "")
		}
		ent = null
		while (ent = Entities.FindByName(ent, "australium"))
		{
			EntityOutputs.RemoveOutput(ent, "OnCapture", "australium", "Kill", "")
		}
		
		local places = M09_GetPlacement(M09DuckSpots, M09DuckCount)
		foreach (a in places)
		{
			M09_SpawnDuck(a[0], a[1], a[2])
		}
	}
	
	OnGameEvent_halloween_duck_collected = function(params)
	{
		local player = GetPlayerFromUserID(params.collector)
		if (IsPlayerABot(player)) return
		M09Score("Bonus Duck",500)
	}
	
	OnGameEvent_halloween_pumpkin_grab = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (IsPlayerABot(player)) return
		M09Score("Pumpkin Grab",150)
	}
	
	OnGameEvent_halloween_soul_collected = function(params)
	{
		local player = GetPlayerFromUserID(params.collecting_player)
		if (IsPlayerABot(player)) return
		Merc.ObjectiveMainCount += params.soul_count
	}
	
	OnGameEvent_ctf_flag_captured = function(params)
	{
		if (params.capping_team == Merc.ForcedTeam)
		{
			if (params.capping_team_score > 1)
				M09Score("Ticket Re-delivery",750)
			else
				M09Score("Ticket Delivery",3000)
			
			foreach (a in GetClients()) 
			{	
				if (!IsPlayerABot(a))
				{
					a.RollRareSpell()
				}
			}
		}
		else
		{
			M09Score("Enemy Delivery",-2000)
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

