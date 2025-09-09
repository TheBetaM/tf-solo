// CTF Helltrain
::Merc <- {}
Merc.MissionID <- 0
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- TF_CLASS_SCOUT
Merc.ForcedTeam <- TF_TEAM_RED
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_red.res"

Merc.Bots <- [
	Merc.Bot(TF_TEAM_RED, 1, "Firefly"),
	Merc.Bot(TF_TEAM_RED, 2, "Boxer"),
	Merc.Bot(TF_TEAM_RED, 1, "Spartan2"),
	Merc.Bot(TF_TEAM_RED, 1, "Sidekick"),
	Merc.Bot(TF_TEAM_RED, 1, "Founding"),
	Merc.Bot(TF_TEAM_RED, 1, "SurgeonGeneral"),
	Merc.Bot(TF_TEAM_RED, 1, "Lonestar"),
	Merc.Bot(TF_TEAM_RED, 1, "Cargo"),
	
	Merc.Bot(TF_TEAM_BLUE, 1, "CurseANature"),
	Merc.Bot(TF_TEAM_BLUE, 0, "Zipperface"),
	Merc.Bot(TF_TEAM_BLUE, 1, "SecondOpinion"),
	Merc.Bot(TF_TEAM_BLUE, 0, "Cranium"),
	Merc.Bot(TF_TEAM_BLUE, 0, "SplitHead"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Defaced"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Headcase"),
	Merc.Bot(TF_TEAM_BLUE, 1, "Facepeeler"),
	Merc.Bot(TF_TEAM_BLUE, 2, "MasterMind"),
]
Merc.ObjectiveText <- LOCM_OBJECTIVE_GENERIC
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Get kills with the Rapid Ranger"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 4

Convars.SetValue("tf_flag_caps_per_round", 5)
Convars.SetValue("tf_ctf_bonus_time", 0)

Merc.Bots[0].WarPaints = [[215,205,0.0,102]]
Merc.Bots[1].BotWpnFlags = 1
Merc.Bots[2].WarPaints = [[206,122,0.2,101]]

Merc.Bots[9].WarPaints = [[228,204,0.0,103]]
Merc.Bots[10].WarPaints = [[211,163,0.2,104]]
Merc.Bots[11].WarPaints = [[424,261,0.4,105]]
Merc.Bots[12].WarPaints = [[208,264,0.2,106]]
Merc.Bots[13].WarPaints = [[1151,297,0.0,107],[207,297,0.0,107]]
Merc.Bots[14].WarPaints = [[203,240,0.2,108]]

Merc.AfterPlayerInv <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() != Merc.ForcedTeam) return
	if (IsPlayerABot(player)) return
	
	local wsize = GetPropArraySize(player, "m_hMyWeapons")
	for (local i = 0; i < wsize; i++)
    {
        local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null || !weapon.IsValid() || weapon.GetClassname() == "tf_weapon_spellbook" || weapon.GetSlot() != 0) continue;
		weapon.Destroy()
        SetPropEntityArray(player, "m_hMyWeapons", null, i)
    }
	
	local waxe = Entities.CreateByClassname("tf_weapon_shotgun_building_rescue")
    SetPropInt(waxe, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 997)
    SetPropBool(waxe, "m_AttributeManager.m_Item.m_bInitialized", true)
    SetPropBool(waxe, "m_bValidatedAttachedEntity", true)
	SetPropEntity(waxe, "m_hOwner", player)
	SetPropEntity(waxe, "m_hOwnerEntity", player)
	
	waxe.SetTeam(player.GetTeam())
	waxe.SetOwner(player)
	
	local flags = GetPropInt(waxe, "m_Collision.m_usSolidFlags")
	SetPropInt(waxe, "m_Collision.m_usSolidFlags", flags | FSOLID_NOT_SOLID)
	flags = GetPropInt(waxe, "m_Collision.m_usSolidFlags")
	SetPropInt(waxe, "m_Collision.m_usSolidFlags", flags & ~(FSOLID_TRIGGER))
	
	Entities.DispatchSpawn(waxe)
	waxe.ValidateScriptScope()
	
	waxe.AcceptInput("SetParent", "!activator", player, player)
	waxe.AddAttribute("killstreak tier", 1.0, -1)
	waxe.AddAttribute("override projectile type", 0.0, -1)
	waxe.AddAttribute("maxammo primary reduced", 1.0, -1)
	waxe.AddAttribute("clip size penalty", 1.0, -1)
	waxe.AddAttribute("sniper no headshots", 1.0, -1)
	
	SetPropEntityArray(player, "m_hMyWeapons", waxe, waxe.GetSlot())
	player.Weapon_Equip(waxe)
	player.Weapon_Switch(waxe)
}

Merc.OnExtraDone <- function() {
	Merc.Delay(4.0, function() {
		Merc.AnnSpeakRaw("vo/killstreak/announcer_ks_18.mp3")
	} )
}

Merc.BeforeRoundStart <- function(params)
{
	Merc.Bots[1].Flags = 1
	Merc.Bots[2].Flags = 1
	Merc.Bots[3].Flags = 1
	Merc.Bots[4].Flags = 1
	Merc.Bots[5].Flags = 1
	Merc.Bots[6].Flags = 1
	Merc.Bots[7].Flags = 1
	Merc.Bots[10].Flags = 1
	Merc.Bots[11].Flags = 1
	Merc.Bots[12].Flags = 1
	Merc.Bots[13].Flags = 1
	Merc.Bots[14].Flags = 1
	Merc.Bots[15].Flags = 1
	Merc.Bots[16].Flags = 1
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid)
		if (params.userid == 0 || !IsPlayerABot(player)) return
		local aplayer = GetPlayerFromUserID(params.attacker)
		if (aplayer == null || IsPlayerABot(aplayer)) return
		if (params.weapon == "tf_projectile_arrow")
		{
			Merc.ExtraGet(1,1,1)
		}
	}
	
	OnGameEvent_ctf_flag_captured = function(params)
	{
		if (params.capping_team_score >= 5) return
		if (params.capping_team == Merc.ForcedTeam)
		{
			Merc.ChatPrint("BLU recieves reinforcements!")
			switch (params.capping_team_score) {
				case 1: {
					Merc.Bots[10].Flags = 0
					Merc.Bots[11].Flags = 0
					Merc.Bots[12].Flags = 0
					break;
				}
				case 2: {
					Merc.Bots[13].Flags = 0
					Merc.Bots[14].Flags = 0
					break;
				}
				case 3: {
					Merc.Bots[15].Flags = 0
					break;
				}
				case 4: {
					Merc.Bots[16].Flags = 0
					break;
				}
				default: { break; }
			}
			Merc.Delay(4.0, function() {
				Merc.AnnSpeakRaw("vo/announcer_security_warning.mp3")
			} )
		}
		else
		{
			Merc.ChatPrint("RED recieves reinforcements!")
			switch (params.capping_team_score) {
				case 1: {
					Merc.Bots[1].Flags = 0
					Merc.Bots[2].Flags = 0
					break;
				}
				case 2: {
					Merc.Bots[3].Flags = 0
					Merc.Bots[4].Flags = 0
					break;
				}
				case 3: {
					Merc.Bots[5].Flags = 0
					Merc.Bots[6].Flags = 0
					break;
				}
				case 4: {
					Merc.Bots[7].Flags = 0
					break;
				}
				default: { break; }
			}
		}
		foreach (i in Merc.Bots)
		{
			i.AddBot()
		}
	}
	
	OnGameEvent_teamplay_round_start = function(params)
	{
		Merc.Delay(0.5, function() { 
			local line = "Fires arrows instead of bullets"
			Merc.DisplayTrMsg("Rapid Ranger",line,10.0)
		} )
		
		Merc.Delay(2.0, function() {
			Merc.AnnSpeakRaw("vo/announcer_capture_intel.mp3")
		} )
	}
	
	OnGameEvent_teamplay_round_win = function(params)
	{
		if (params.team != Merc.ForcedTeam)
		{
			if (RandomInt(0,1) == 0)
			{
				Merc.Delay(3.0, function() {
					MercAnnSpeakRaw("vo/announcer_do_not_fail_again.mp3")
				} )
			}
			else
			{
				Merc.Delay(3.0, function() {
					MercPlayerSpeakResp("TLK_PLAYER_NEGATIVE")
				} )
			}
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])
