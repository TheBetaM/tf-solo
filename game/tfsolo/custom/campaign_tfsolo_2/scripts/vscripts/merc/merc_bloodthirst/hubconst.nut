Merc.SceneFiles_Yes <- [
	"scenes/Player/Demoman/low/1037.vcd",
	"scenes/Player/Demoman/low/1038.vcd",
	"scenes/Player/Demoman/low/1039.vcd",
	"scenes/Player/Engineer/low/187.vcd",
	"scenes/Player/Engineer/low/188.vcd",
	"scenes/Player/Engineer/low/189.vcd",
	"scenes/Player/Heavy/low/350.vcd",
	"scenes/Player/Heavy/low/351.vcd",
	"scenes/Player/Heavy/low/352.vcd",
	"scenes/Player/Medic/low/689.vcd",
	"scenes/Player/Medic/low/690.vcd",
	"scenes/Player/Medic/low/691.vcd",
	"scenes/Player/Pyro/low/1558.vcd",
	"scenes/Player/Scout/low/516.vcd",
	"scenes/Player/Scout/low/517.vcd",
	"scenes/Player/Scout/low/518.vcd",
	"scenes/Player/Sniper/low/1767.vcd",
	"scenes/Player/Sniper/low/1768.vcd",
	"scenes/Player/Sniper/low/1769.vcd",
	"scenes/Player/Soldier/low/1350.vcd",
	"scenes/Player/Soldier/low/1220.vcd",
	"scenes/Player/Soldier/low/1221.vcd",
	"scenes/Player/Soldier/low/1219.vcd",
	"scenes/Player/Spy/low/857.vcd",
	"scenes/Player/Spy/low/858.vcd",
	"scenes/Player/Spy/low/859.vcd",
]
Merc.SceneFiles_No <- [
	"scenes/Player/Demoman/low/977.vcd",
	"scenes/Player/Demoman/low/978.vcd",
	"scenes/Player/Demoman/low/979.vcd",
	"scenes/Player/Engineer/low/127.vcd",
	"scenes/Player/Engineer/low/128.vcd",
	"scenes/Player/Engineer/low/129.vcd",
	"scenes/Player/Heavy/low/291.vcd",
	"scenes/Player/Heavy/low/292.vcd",
	"scenes/Player/Heavy/low/293.vcd",
	"scenes/Player/Medic/low/627.vcd",
	"scenes/Player/Medic/low/628.vcd",
	"scenes/Player/Medic/low/629.vcd",
	"scenes/Player/Pyro/low/1507.vcd",
	"scenes/Player/Scout/low/455.vcd",
	"scenes/Player/Scout/low/456.vcd",
	"scenes/Player/Scout/low/457.vcd",
	"scenes/Player/Sniper/low/1694.vcd",
	"scenes/Player/Sniper/low/1695.vcd",
	"scenes/Player/Sniper/low/1696.vcd",
	"scenes/Player/Sniper/low/1782.vcd",
	"scenes/Player/Soldier/low/1159.vcd",
	"scenes/Player/Soldier/low/1161.vcd",
	"scenes/Player/Soldier/low/1160.vcd",
	"scenes/Player/Spy/low/797.vcd",
	"scenes/Player/Spy/low/798.vcd",
	"scenes/Player/Spy/low/799.vcd",
]
Merc.SceneFiles_Left <- [
	"scenes/Player/Demoman/low/917.vcd",
	"scenes/Player/Demoman/low/918.vcd",
	"scenes/Player/Demoman/low/919.vcd",
	"scenes/Player/Engineer/low/73.vcd",
	"scenes/Player/Engineer/low/75.vcd",
	"scenes/Player/Heavy/low/237.vcd",
	"scenes/Player/Heavy/low/238.vcd",
	"scenes/Player/Heavy/low/239.vcd",
	"scenes/Player/Heavy/low/2276.vcd",
	"scenes/Player/Medic/low/571.vcd",
	"scenes/Player/Medic/low/572.vcd",
	"scenes/Player/Medic/low/573.vcd",
	"scenes/Player/Pyro/low/1457.vcd",
	"scenes/Player/Scout/low/398.vcd",
	"scenes/Player/Scout/low/399.vcd",
	"scenes/Player/Scout/low/400.vcd",
	"scenes/Player/Sniper/low/1644.vcd",
	"scenes/Player/Sniper/low/1645.vcd",
	"scenes/Player/Sniper/low/1646.vcd",
	"scenes/Player/Soldier/low/1098.vcd",
	"scenes/Player/Soldier/low/1100.vcd",
	"scenes/Player/Soldier/low/1099.vcd",
	"scenes/Player/Spy/low/746.vcd",
	"scenes/Player/Spy/low/747.vcd",
	"scenes/Player/Spy/low/748.vcd",
]
Merc.SceneFiles_Right <- [
	"scenes/Player/Demoman/low/920.vcd",
	"scenes/Player/Demoman/low/921.vcd",
	"scenes/Player/Demoman/low/922.vcd",
	"scenes/Player/Engineer/low/76.vcd",
	"scenes/Player/Engineer/low/77.vcd",
	"scenes/Player/Engineer/low/78.vcd",
	"scenes/Player/Heavy/low/240.vcd",
	"scenes/Player/Heavy/low/241.vcd",
	"scenes/Player/Heavy/low/242.vcd",
	"scenes/Player/Heavy/low/2275.vcd",
	"scenes/Player/Medic/low/574.vcd",
	"scenes/Player/Medic/low/575.vcd",
	"scenes/Player/Medic/low/576.vcd",
	"scenes/Player/Pyro/low/1460.vcd",
	"scenes/Player/Scout/low/401.vcd",
	"scenes/Player/Scout/low/402.vcd",
	"scenes/Player/Scout/low/403.vcd",
	"scenes/Player/Sniper/low/1647.vcd",
	"scenes/Player/Sniper/low/1648.vcd",
	"scenes/Player/Sniper/low/1649.vcd",
	"scenes/Player/Soldier/low/1103.vcd",
	"scenes/Player/Soldier/low/1101.vcd",
	"scenes/Player/Soldier/low/1102.vcd",
	"scenes/Player/Spy/low/749.vcd",
	"scenes/Player/Spy/low/750.vcd",
	"scenes/Player/Spy/low/751.vcd",
]

enum MercHubTrig
{
	RED_Enter,
	BLU_Enter,
	BLU_SecretPickups,
}

::AttrConv <- function(i)
{
	local b = blob(4)
	b.writen(i,105)
	b.seek(0)
	local v = b.readn(102)
	b.flush()
	return v
}

Merc.Bot <- class {
	Name = "Bot"
	Skill = TFBOT_MEDIUM
	Team = TF_TEAM_RED
	Class = TF_CLASS_SCOUT
	Handle = null
	Items = []
	Conds = []
	Attribs = []
	BotAttribs = []
	// 1 - don't spawn
	// 2 - custom spawn
	// 4 - limited lives (mission only)
	// 8 - join unassigned team
	Flags = 0
	BotWpnFlags = 0
	Preset = "NoPresetGiven"
	SpawnPos = Vector(0,0,0)
	SpawnRot = 0
	AltSpawnPos = Vector(0,0,0)
	AltSpawnRot = 0
	
	Lives = 0
	OrigName = "notset"
	BotAdded = 0
	/*
	[0] - Weapon item ID
	[1] - War Paint ID (int)
	[2] - Wear (0.0-1.0)
	[3] - Seed Low (int)
	[4] - Seed High (int)
	*/
	WarPaints = []
	/*
	[0] - Weapon item ID
	[1] - Item Style
	[2] - 1 to festivize
	[3] - 1 to australium
	[4] - Paint RGB
	[5] - Unusual effect ID
	[6] - Killstreak tier (1-3)
	[7] - Killstreak sheen (1-7)
	[8] - Killstreak effect (2002-2008)
	[9] - Strange count (int)
	*/
	Styles = []
	// Spell ID / Spell cooldown
	SpellType = [-1,1.0]
	
	constructor (bteam, bskill, pname)
	{
		Preset = pname
		Team = bteam
		Skill = bskill
		Handle = null
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
		AltSpawnPos = Vector(0,0,0)
		AltSpawnRot = 0
	}
	
	function Start()
	{
		if (OrigName == "notset")
		{
			OrigName = Name
		}
		AddBot()
	}
	
	function AddBot()
	{
		if (Flags & 1)
		{
			return
		}
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
		if (Flags & 2)
		{
			player.Teleport(true, AltSpawnPos, true, QAngle(0, AltSpawnRot, 0), true, Vector(0, 0, 0))
		}
		else
		{
			player.Teleport(true, SpawnPos, true, QAngle(0, SpawnRot, 0), true, Vector(0, 0, 0))
		}
		player.AddFlag(FL_FROZEN)
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
		foreach (i in Conds)
		{
			player.AddCond(i)
		}
		foreach (i in BotAttribs)
		{
			player.AddBotAttribute(i)
		}
		if (BotWpnFlags != 0)
		{
			player.AddWeaponRestriction(BotWpnFlags)
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
					wbook = weapon;
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
	
	function Kick()
	{
		ToConsole("tf_bot_kick \""+Name+"\"")
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
				local charges = GetPropInt(wbook,"m_iSpellCharges")
				if (charges != 0 && charges != 9)
				{
					SetPropFloat(Handle,"m_flNextAttack",Time() + SpellType[1])
					SetPropInt(wbook,"m_iSpellCharges",9)
				}
			}
		}
	}
	
	function BotThink()
	{
		
	}
}
Merc.BotGeneric <- class extends Merc.Bot 
{
	constructor (bteam, bskill, bclass, bname)
	{
		Preset = ""
		Name = bname
		Team = bteam
		Skill = bskill
		Class = bclass
	}
	
	function Start()
	{
		if (Flags == 1) return
		if (Team == TF_TEAM_RED)
			ToConsole("tf_bot_add 1 "+Merc.BotClassNames[Class]+" red "+TFBOT_SKILLS[Skill]+" \""+Name+"\" noquota")
		else
			ToConsole("tf_bot_add 1 "+Merc.BotClassNames[Class]+" blue "+TFBOT_SKILLS[Skill]+" \""+Name+"\" noquota")
	}
}

Merc.HubBots <- [
	Merc.BotGeneric(TF_TEAM_RED,  2, TF_CLASS_ENGINEER, Merc.HandlerRED_Name),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_MEDIC, Merc.HandlerBLU_Name),
	Merc.Bot(TF_TEAM_RED,  2, "Bloodthirst_RecruitRED"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Bloodthirst_RecruitBLU"),
	
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Invader 01"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Invader 02"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Invader 03"),
	Merc.BotGeneric(TF_TEAM_BLUE, 1, TF_CLASS_SCOUT, "Invader 04"),
]

::MercBotThink <- function() {
	foreach (i in Merc.HubBots){
		i.BotThink()
	}
}
Merc.HubBots[0].Conds = [TF_COND_FREEZE_INPUT]
Merc.HubBots[0].BotAttribs = [IGNORE_ENEMIES]
//Merc.HubBots[0].SpawnPos = Vector(-142,628,150)
Merc.HubBots[0].SpawnPos = Vector(-420,0,150)

Merc.HubBots[1].Conds = [TF_COND_FREEZE_INPUT]
Merc.HubBots[1].BotAttribs = [IGNORE_ENEMIES]
//Merc.HubBots[1].SpawnPos = Vector(-126,-621,150)
Merc.HubBots[1].SpawnPos = Vector(-910,0,150)

Merc.HubBots[2].Conds = [TF_COND_FREEZE_INPUT,TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED]
Merc.HubBots[2].BotAttribs = [IGNORE_ENEMIES]
Merc.HubBots[2].Flags = 1
Merc.HubBots[2].WarPaints = [[1151,285,0.0]]
Merc.HubBots[2].SpawnPos = Vector(729,652,110)
Merc.HubBots[2].SpawnRot = 270
Merc.HubBots[2].AltSpawnPos = Vector(989,622,110)
Merc.HubBots[2].AltSpawnRot = 180

Merc.HubBots[3].Conds = [TF_COND_FREEZE_INPUT,TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED]
Merc.HubBots[3].BotAttribs = [IGNORE_ENEMIES]
Merc.HubBots[3].Flags = 1
Merc.HubBots[3].WarPaints = [[208,416,0.0]]
Merc.HubBots[3].SpawnPos = Vector(1029,-255,110)
Merc.HubBots[3].SpawnRot = 180
Merc.HubBots[3].AltSpawnPos = Vector(989,-634,110)
Merc.HubBots[3].AltSpawnRot = 180

Merc.HubBots[4].Flags = 1
Merc.HubBots[4].BotAttribs = [ REMOVE_ON_DEATH ]
Merc.HubBots[5].Flags = 1
Merc.HubBots[5].BotAttribs = [ REMOVE_ON_DEATH ]
Merc.HubBots[6].Flags = 1
Merc.HubBots[6].BotAttribs = [ REMOVE_ON_DEATH ]
Merc.HubBots[7].Flags = 1
Merc.HubBots[7].BotAttribs = [ REMOVE_ON_DEATH ]

::LOCM_MISSION_STARTING <- "You're heading to"
::LOCM_MISSION_OPEN <- "Hit this\nto select!"
::LOCM_MISSION_CLEARED <- "CLEARED"
::LOCM_MISSION_COMPLETED <- "100%"
::LOCM_MISSION_LOCKED <- "LOCKED"
::LOCM_MISSION_FINAL_LOCKED <- "Complete 10\nmissions for\nRED and BLU\nto unlock!"
::LOCM_MISSION_SELECT_RED <- "Select a mission!"
::LOCM_MISSION_SELECT_BLU <- "Select a pact!"
::LOCM_MISSION_COMPLETION <- "Completion"
::LOCM_MISSION_LOCKED_BONUS <- "LOCKED\nCOMPLETE MORE\nBONUS OBJECTIVES\nTO UNLOCK!"
::LOCM_MISSION_SECRET_RED <- "Thirsty?"
::LOCM_MISSION_SECRET_RED2 <- "BREAK ALL\nBOTTLES\nIN THIS ROOM"
::LOCM_MISSION_SECRET_BLU <- "Free The Souls!"
::LOCM_MISSION_SECRET_BLU2 <- "FIND BOTH\nSOULS ON\nTHE POSTER"
::LOCM_NGP_TITLE <- "The Strongmann"
::LOCM_NGP_WARNING <- "This will RESET all mission progress, but keep unlocks and choices!"

