IncludeScript("solo/mission/mission_util.nut")

Convars.SetValue("mp_tournament", 0)
Convars.SetValue("mp_winlimit", 0)
Convars.SetValue("mp_forceautoteam", 0)
Convars.SetValue("mp_autoteambalance", 0)
Convars.SetValue("mp_allowspectators", 0)
Convars.SetValue("mp_bonusroundtime", 15)
Convars.SetValue("tf_bot_quota_mode", 0)
Convars.SetValue("tf_bot_quota", 0)
Convars.SetValue("tf_bot_count", 0)
Convars.SetValue("tf_bot_reevaluate_class_in_spawnroom", 0)
Convars.SetValue("tf_bot_keep_class_after_death", 1)
Convars.SetValue("mp_teams_unbalance_limit", 0)
Convars.SetValue("mp_waitingforplayers_time", 0)
Convars.SetValue("tf_arena_use_queue", 0)
Convars.SetValue("mp_maxrounds", 0)
Convars.SetValue("tf_bot_quota_use_presets", 1)

TFSOLO.MissionBots <- []

TFSOLO.MissionBot <- class {
	Name = "Bot"
	Skill = TFBOT_MEDIUM
	Team = TF_TEAM_RED
	Class = TF_CLASS_SCOUT
	Handle = null
	Items = []
	Conds = []
	Attribs = []
	BotAttribs = []
	Flags = 0
	BotWpnFlags = 0
	Preset = "NoPresetGiven"
	Lives = 0
	OrigName = "notset"
	BotAdded = 0
	WarPaints = []
	Styles = []
	SpellType = [-1,1.0]
	SpawnPos = Vector(0,0,0)
	SpawnRot = 0
	ExtraData = []
	
	constructor (bteam, bskill, pname)
	{
		Preset = pname
		Team = bteam
		Skill = bskill
		Items = []
		Conds = []
		Attribs = []
		BotAttribs = []
		Flags = 0
		BotWpnFlags = 0
		Lives = 0
		OrigName = "notset"
		BotAdded = 0
		WarPaints = []
		Styles = []
		SpellType = [-1,1.0]
		SpawnPos = Vector(0,0,0)
		SpawnRot = 0
		ExtraData = []
	}
	
	function Start()
	{
		BotAdded = 0
		if (OrigName == "notset")
		{
			OrigName = Name
		}
		AddBot()
	}
	
	function AddBot()
	{
		if (Flags == 1) return
		if (BotAdded != 0) return
		BotAdded = 1
		if (Team == TF_TEAM_RED)
			ToConsole("tf_bot_add preset "+Preset+" red "+TFBOT_SKILLS[Skill]+"")
		else
			ToConsole("tf_bot_add preset "+Preset+" blue "+TFBOT_SKILLS[Skill]+"")
	}
	function KickBot()
	{
		if (BotAdded == 0) return
		ToConsole("tf_bot_kick \""+Name+"\"")
	}
	
	function OnSpawn(player)
	{
		Handle = player
		foreach (i in Conds)
		{
			player.AddCond(i)
		}
		if (Flags & 2)
		{
			player.Teleport(true, SpawnPos, true, QAngle(0, SpawnRot, 0), true, Vector(0, 0, 0))
		}
	}
	function OnItems(player)
	{
		Handle = player
		foreach (i in Items)
		{
			player.GenerateAndWearItem(i)
		}
	}
	
	function UpdateResupply(player)
	{
		Handle = player
		
		foreach (i in BotAttribs)
		{
			player.AddBotAttribute(i)
		}
		if (BotWpnFlags != 0)
		{
			player.AddWeaponRestriction(BotWpnFlags)
		}
		if (Attribs.len() != 0)
		{
			foreach (i in Attribs)
			{
				player.RemoveCustomAttribute(i[0])
				player.AddCustomAttribute(i[0], i[1], i[2])
			}
		}
		if (SpellType[0] != -1)
		{
			local wsize = GetPropArraySize(player, "m_hMyWeapons")
			local wbook = null
			for (local i = 0; i < wsize; i++)
			{
				local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
				if (weapon == null || !weapon.IsValid()) continue;
				if (weapon.GetClassname() == "tf_weapon_spellbook")
				{
					wbook = weapon
				}
			}
			if (wbook != null)
			{
				SetPropInt(wbook,"m_iSelectedSpellIndex",SpellType[0])
				SetPropInt(wbook,"m_iSpellCharges",9)
				player.Weapon_Switch(wbook)
				SetPropEntity(player,"m_hActiveWeapon",wbook)
				player.AddCustomAttribute("disable weapon switch", 1.0, -1)
				SetPropEntity(player,"m_hActiveWeapon",wbook)
			}
		}
		if (WarPaints.len() != 0 || Styles.len() != 0)
		{
			local wsize = GetPropArraySize(player, "m_hMyWeapons")
			for (local i = 0; i < wsize; i++)
			{
				local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
				local item = GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")
				if (weapon == null || !weapon.IsValid()) continue;
				foreach (i in WarPaints)
				{
					if (i[0] == item)
					{
						weapon.AddAttribute("paintkit_proto_def_index", AttrConv(i[1]), -1)
						if (i.len() > 2)
						{
							weapon.AddAttribute("set_item_texture_wear", i[2], -1)
						}
						else
						{
							weapon.AddAttribute("set_item_texture_wear", 0.0, -1)
						}
						if (i.len() > 3)
						{
							weapon.AddAttribute("custom_paintkit_seed_lo", AttrConv(i[3]), -1)
							if (i.len() > 4)
							{
								weapon.AddAttribute("custom_paintkit_seed_hi", AttrConv(i[4]), -1)
							}
							else
							{
								weapon.AddAttribute("custom_paintkit_seed_hi", 0, -1)
							}
						}
					}
				}
				foreach (i in Styles)
				{
					if (i[0] == item)
					{
						if (i[1] != -1)
						{
							weapon.AddAttribute("item style override", i[1], -1)
						}
						if (i.len() > 2 && i[2] != -1)
						{
							weapon.AddAttribute("is_festivized", 1, -1)
						}
						if (i.len() > 3 && i[3] != -1)
						{
							weapon.AddAttribute("is australium item", 1, -1)
						}
						if (i.len() > 4 && i[4] != -1)
						{
							weapon.AddAttribute("set item tint RGB", i[4], -1)
						}
						if (i.len() > 5 && i[5] != -1)
						{
							weapon.AddAttribute("attach particle effect", i[5], -1)
						}
						if (i.len() > 6 && i[6] != -1)
						{
							weapon.AddAttribute("killstreak tier", i[6], -1)
						}
						if (i.len() > 7 && i[7] != -1)
						{
							weapon.AddAttribute("killstreak idleeffect", i[7], -1)
						}
						if (i.len() > 8 && i[8] != -1)
						{
							weapon.AddAttribute("killstreak effect", i[8], -1)
						}
						if (i.len() > 9 && i[9] != -1)
						{
							weapon.AddAttribute("kill eater", AttrConv(i[9]), -1)
						}
						if (i.len() > 10 && i[10] != -1)
						{
							weapon.AddAttribute("weapon_uses_stattrak_module", 1, -1)
						}
						if (i.len() > 11 && i[11] != -1)
						{
							weapon.AddAttribute("paintkit_proto_def_index", AttrConv(i[11]), -1)
						}
					}
				}
			}
		}
	}
	
	function OnDeath(player)
	{
		Handle = player
		if (Flags & 4)
		{
			if (Lives > 1)
			{
				Lives--
				Name = OrigName + " (" + Lives + "x)"
				SetFakeClientConVarValue(player, "name", Name)
				TFSOLO.BotOnLifeLost(this)
			}
			else
			{
				local name = GetPropString(player, "m_szNetname")
				ToConsole("tf_bot_kick \""+name+"\"")
				TFSOLO.BotOnLivesDepleted(this)
			}
		}
		
	}
	
	function SwitchToBook()
	{
		try 
		{
			if (Handle == null) 
			{
				return -1
			}
		}
		catch (e)
		{
			return -1
		}
		local player = Handle
		local wsize = GetPropArraySize(player, "m_hMyWeapons")
		local wbook = null
		for (local i = 0; i < wsize; i++)
		{
			local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
			if (weapon == null || !weapon.IsValid()) continue;
			if (weapon.GetClassname() == "tf_weapon_spellbook")
			{
				wbook = weapon
			}
		}
		if (wbook != null)
		{
			SetPropInt(wbook,"m_iSelectedSpellIndex",SpellType[0])
			SetPropInt(wbook,"m_iSpellCharges",9)
			player.Weapon_Switch(wbook)
			SetPropEntity(player,"m_hActiveWeapon",wbook)
			player.AddCustomAttribute("disable weapon switch", 1.0, -1)
			SetPropEntity(player,"m_hActiveWeapon",wbook)
		}
	}
	
	function BotThink()
	{
		try 
		{
			if (Handle == null) 
			{
				return -1
			}
		}
		catch (e)
		{
			return -1
		}
		if (SpellType[0] != -1)
		{
			local wsize = GetPropArraySize(Handle, "m_hMyWeapons")
			local wbook = null
			for (local i = 0; i < wsize; i++)
			{
				local weapon = GetPropEntityArray(Handle, "m_hMyWeapons", i)
				if (weapon == null || !weapon.IsValid()) continue;
				if (weapon.GetClassname() == "tf_weapon_spellbook")
				{
					wbook = weapon
				}
			}
			if (wbook != null)
			{
				if (wbook != Handle.GetActiveWeapon())
				{
					Handle.Weapon_Switch(wbook)
					SetPropEntity(Handle,"m_hActiveWeapon",wbook)
					Handle.AddCustomAttribute("disable weapon switch", 1.0, -1)
					SetPropEntity(Handle,"m_hActiveWeapon",wbook)
				}
				local charges = GetPropInt(wbook,"m_iSpellCharges")
				if (charges != 0 && charges != 9)
				{
					SetPropFloat(Handle,"m_flNextAttack",Time() + SpellType[1])
					SetPropInt(wbook,"m_iSpellCharges",9)
					TFSOLO.BotOnSpell(this,wbook)
				}
			}
		}
	}
	
	
}
TFSOLO.MissionBotGeneric <- class extends TFSOLO.MissionBot 
{
	constructor (bteam, bskill, bclass, bname)
	{
		Preset = ""
		Name = bname
		Team = bteam
		Skill = bskill
		Class = bclass
		Items = []
		Conds = []
		Attribs = []
		BotAttribs = []
		Flags = 0
		BotWpnFlags = 0
		Lives = 0
		OrigName = "notset"
		BotAdded = 0
		WarPaints = []
		Styles = []
		SpellType = [-1,1.0]
		SpawnPos = Vector(0,0,0)
		SpawnRot = 0
		ExtraData = []
	}
	
	function Start()
	{
		BotAdded = 0
		if (OrigName == "notset")
		{
			OrigName = Name
		}
		AddBot()
	}
	
	function AddBot()
	{
		if (Flags & 1) return
		if (Flags & 4)
		{
			Name = OrigName + " (" + Lives + "x)"
		}
		if (BotAdded != 0) return
		BotAdded = 1
		if (Team == TF_TEAM_RED)
			ToConsole("tf_bot_add 1 "+TFSOLO.BotClassNames[Class]+" red "+TFBOT_SKILLS[Skill]+" \""+Name+"\" noquota")
		else
			ToConsole("tf_bot_add 1 "+TFSOLO.BotClassNames[Class]+" blue "+TFBOT_SKILLS[Skill]+" \""+Name+"\" noquota")
	}
}

TFSOLO.BotOnSpell <- function(a,book) { }
TFSOLO.BotOnLifeLost <- function(a) { }
TFSOLO.BotOnLivesDepleted <- function(a) { }

::TFSOLOBotThink <- function() {
	foreach (i in TFSOLO.MissionBots){
		i.BotThink()
	}
}


TFSOLO.MissionCommonEventTag <- UniqueString()
getroottable()[TFSOLO.MissionCommonEventTag] <- {
	OnGameEvent_teamplay_round_start = function(params)
	{
		ToConsole("tf_bot_kick all")
		
		local bt = SpawnEntityFromTable("logic_script", {})
		AddThinkToEnt(bt,"TFSOLOBotThink")
		
		foreach (b in TFSOLO.MissionBots) b.Start()

	}
	
	OnGameEvent_teamplay_round_win = function(params)
	{
		local team = Convars.GetStr("mp_humans_must_join_team") == "red" ? 2 : 3
		if (params.team == team && params.full_round == 1)
		{
			Convars.SetValue("mp_maxrounds", 1)
		}
	}
	
	OnGameEvent_mvm_mission_complete = function(params)
	{
		
	}
	
	OnGameEvent_scorestats_accumulated_update = function(_)
	{
		TFSOLO.Delays <- {}
		TFSOLO.Timers <- []
		ToConsole("tf_bot_kick all")
	}
}
__CollectGameEventCallbacks(getroottable()[TFSOLO.MissionCommonEventTag])