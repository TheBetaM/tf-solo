// KOTH Cauldron
::Merc <- {}
Merc.MissionID <- 22
IncludeScript("merc/merc_bloodthirst/missions/mission_init.nut")
Merc.ForcedClass <- 0
Merc.ForcedTeam <- TF_TEAM_BLUE
Merc.SetupConvars()
Merc.PathHUD <- "resource/ui/solo/mission_twolines_blue.res"

Merc.Bots <- [
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_SCOUT, "Bot 01"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_SOLDIER, "Bot 02"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_PYRO, "Bot 03"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_DEMOMAN, "Bot 04"),
	Merc.BotGeneric(TF_TEAM_RED, 1, TF_CLASS_HEAVY, "Bot 05"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_ENGINEER, "Bot 06"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_MEDIC, "Bot 07"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_SNIPER, "Bot 08"),
	Merc.BotGeneric(TF_TEAM_RED, 2, TF_CLASS_SPY, "Bot 09"),
	
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_PYRO, "Bot 10"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SOLDIER, "Bot 11"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_DEMOMAN, "Bot 12"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_HEAVY, "Bot 13"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_ENGINEER, "Bot 14"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SNIPER, "Bot 15"),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SPY, "Bot 16"),
]
Merc.ObjectiveText <- "Win the round using only spells (ATTACK)"
Merc.ObjectiveMainCount <- 0
Merc.ObjectiveMainMax <- 1
Merc.ObjectiveExtraText <- "Don't let the enemy cap the point"
Merc.ObjectiveExtraCount <- 0
Merc.ObjectiveExtraMax <- 1

::M22_SpellWeapons <- [
	"spellbook_athletic",
	"spellbook_bats",
	"spellbook_blastjump",
	"spellbook_bomb",
	"spellbook_book",
	"spellbook_boss",
	"spellbook_fireball",
	"spellbook_lightning",
	"spellbook_meteor",
	"spellbook_mirv",
	"spellbook_nospell",
	"spellbook_overheal",
	"spellbook_skeleton",
	"spellbook_stealth",
	"spellbook_teleport",
]

::M22_UpdateSpell <- function()
{
	local ent = null
	while (ent = Entities.FindByClassname(ent, "tf_weapon_spellbook"))
	{
		if (!IsPlayerABot(ent.GetOwner()) && GetPropInt(ent, "m_iSpellCharges") <= 0)
		{
			SetPropInt(ent, "m_iSelectedSpellIndex", RandomInt(1,11))
			SetPropInt(ent, "m_iSpellCharges", 1)
			Merc.Delay(0.5, function() { 
				local vm = null
				while (vm = Entities.FindByClassname(vm, "tf_viewmodel"))
				{
					if (!IsPlayerABot(vm.GetOwner()))
					{
						vm.SetSequence(vm.LookupSequence("spell_draw"))
					}
				}
			})
		}
	}
}

function PlayerThink()
{
	M22_UpdateSpell()
	return -1
}

::M22_RollSpells <- function()
{
	foreach (a in GetClients()) 
	{	
		if (!IsPlayerABot(a))
		{
			a.RollRareSpell()
		}
	}
}

Merc.BeforeRoundWin <- function(params) 
{
	if (!Merc.ExtraFailed && params.team == Merc.ForcedTeam)
	{
		Merc.ExtraGet(1,1,1)
	}
	if (params.team == Merc.ForcedTeam)
	{
		Merc.MainGet(1,1,1)
	}
}

Merc.AfterPlayerInv <- function(params) 
{
	local player = GetPlayerFromUserID(params.userid)
	if (player.GetTeam() != Merc.ForcedTeam) return
	if (IsPlayerABot(player)) return
	
	local wsize = GetPropArraySize(player, "m_hMyWeapons")
	local wbook = null
	for (local i = 0; i < wsize; i++)
    {
        local weapon = GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null || !weapon.IsValid()) continue;
        
		if (weapon.GetClassname() == "tf_weapon_spellbook")
		{
			wbook = weapon
			continue
		}
		
		weapon.Destroy()
        SetPropEntityArray(player, "m_hMyWeapons", null, i)
    }
	
	if (wbook != null)
	{
		player.Weapon_Switch(wbook)
	}
	
	AddThinkToEnt(player, "PlayerThink")
}

Merc.EventTag <- UniqueString()
getroottable()[Merc.EventTag] <- {
	OnGameEvent_teamplay_point_captured = function(params)
	{
		if (!Merc.ExtraFailed && params.team != Merc.ForcedTeam)
		{
			Merc.ExtraFail()
			Merc.ChatPrint("Bonus objective failed! The enemy team captured the point.")
		}
	}
}
__CollectGameEventCallbacks(getroottable()[Merc.EventTag])

