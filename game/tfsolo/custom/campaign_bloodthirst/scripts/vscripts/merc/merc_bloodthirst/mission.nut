enum ModeOverride
{
	OFF = 0,
	ON = 1,
}

Merc.Mission <- class {
	ForcedClass = 0
	ForcedTeam = 0
	Map = "koth_viaduct"
	MapName = "Viaduct"
	ModeName = "King of the Hill"
	PlayerClassName = "All-Class"
	Title = "Mission 00"
	BackupMap = ""
	Spell = -1
	MOverride = 0
	
	constructor(title, map, bmap, mapname, modename, pclass, forcedteam = 0, forcedclass = 0, mapspell = -1, modeov = ModeOverride.OFF)
	{
		Title = title
		Map = map
		BackupMap = bmap
		MapName = mapname
		ModeName = modename
		PlayerClassName = pclass
		ForcedTeam = forcedteam
		ForcedClass = forcedclass
		Spell = mapspell
		MOverride = modeov
	}
}

Merc.Missions <- [
	Merc.Mission("Mission A-1","ctf_helltrain_event","","Helltrain","Capture the Flag","Scout",TF_TEAM_RED,TF_CLASS_SCOUT,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Mission B-1","arena_lumberyard_event","","Graveyard","Arena","All-Class",TF_TEAM_RED,0,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Mission A-2","koth_los_muertos","","Los Muertos","King of the Hill","Soldier",TF_TEAM_RED,TF_CLASS_SOLDIER,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Mission B-2","koth_slasher","","Slasher","King of the Hill","All-Class",TF_TEAM_RED,0,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Mission A-3","pl_corruption","","Corruption","Payload","All-Class",TF_TEAM_RED,0,MSpells.Heal,ModeOverride.OFF),
	Merc.Mission("Mission B-3","sd_doomsday_event","","Carnival of Carnage","Special Delivery","All-Class",TF_TEAM_RED,0,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Mission A-4","koth_slime","","Slime","King of the Hill","Engineer",TF_TEAM_RED,TF_CLASS_ENGINEER,MSpells.Mouse,ModeOverride.OFF),
	Merc.Mission("Mission B-4","cp_freaky_fair","","Freaky Fair","Control Points","All-Class",TF_TEAM_RED,0,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Mission A-5","pd_farmageddon","","Farmageddon","Player Destruction","Heavy",TF_TEAM_RED,TF_CLASS_HEAVY,MSpells.Teleport,ModeOverride.OFF),
	Merc.Mission("Mission B-5","pl_terror_event","","Terror","Payload","All-Class",TF_TEAM_RED,0,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Mission A-6","koth_toxic","","Toxic","King of the Hill","All-Class",TF_TEAM_RED,0,MSpells.Pumpkins,ModeOverride.OFF),
	Merc.Mission("Mission B-6","cp_degrootkeep_rats","","Sandcastle","Control Points","All-Class",TF_TEAM_RED,0,MSpells.Any,ModeOverride.OFF),
	
	Merc.Mission("Pact A-1","koth_harvest_event","","Harvest Event","Arena","All-Class",TF_TEAM_BLUE,TF_CLASS_SCOUT,MSpells.Any,ModeOverride.ON),
	Merc.Mission("Pact B-1","koth_lakeside_event","","Ghost Fort","King of the Hill","All-Class",TF_TEAM_BLUE,0,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Pact A-2","arena_perks","","Perks","Arena","All-Class",TF_TEAM_BLUE,0,MSpells.Invis,ModeOverride.OFF),
	Merc.Mission("Pact B-2","zi_devastation_final1","","Devastation","Zombie Infection","A Zombie",TF_TEAM_BLUE,0,-1,ModeOverride.OFF),
	Merc.Mission("Pact A-3","plr_hacksaw_event","","Bonesaw","Payload Race","All-Class",TF_TEAM_BLUE,0,MSpells.Skeletons,ModeOverride.OFF),
	Merc.Mission("Pact B-3","koth_maple_ridge_event","","Maple Ridge Event","King of the Hill","A Ghost",TF_TEAM_BLUE,TF_CLASS_PYRO,-1,ModeOverride.OFF),
	Merc.Mission("Pact A-4","tow_dynamite","","Dynamite","Tug of War","All-Class",TF_TEAM_BLUE,0,MSpells.Jump,ModeOverride.OFF),
	Merc.Mission("Pact B-4","pd_pit_of_death_event","","Pit of Death","Player Destruction","A Skeleton",TF_TEAM_BLUE,TF_CLASS_SPY,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Pact A-5","pl_precipice_event_final","","Precipice","Payload","All-Class",TF_TEAM_BLUE,0,MSpells.Fire,ModeOverride.OFF),
	Merc.Mission("Pact B-5","cp_manor_event","","Mann Manor","Control Points","The HHH",TF_TEAM_BLUE,TF_CLASS_DEMOMAN,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Pact A-6","koth_bagel_event","","Cauldron","King of the Hill","All-Class",TF_TEAM_BLUE,0,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Pact B-6","pl_spineyard","","Spineyard","Payload","MERASMUS",TF_TEAM_BLUE,TF_CLASS_SNIPER,MSpells.Monoculus,ModeOverride.OFF),
	
	Merc.Mission("Final Mission","pd_mannsylvania","","Mannsylvania","Player Destruction","All-Class",TF_TEAM_RED,0,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Final Pact","pl_bloodwater","","Bloodwater","Payload","DRACULA",TF_TEAM_BLUE,TF_CLASS_MEDIC,MSpells.Bats,ModeOverride.OFF),
	Merc.Mission("Bonus Mission","koth_slaughter_event","","Laughter","King of the Hill","All-Class",TF_TEAM_RED,0,-1,ModeOverride.OFF),
	Merc.Mission("Secret Mission","zi_sanitarium","","Sanitarium","Zombie Infection","All-Class",TF_TEAM_RED,0,MSpells.Lightning,ModeOverride.OFF),
	Merc.Mission("Bonus Pact","koth_synthetic_event","","Sinthetic","King of the Hill","All-Class",TF_TEAM_BLUE,0,MSpells.Any,ModeOverride.OFF),
	Merc.Mission("Secret Pact","vsh_outburst","","Outburst","Versus Saxton Hale","Saxton Hale",TF_TEAM_BLUE,TF_CLASS_HEAVY,-1,ModeOverride.OFF),
]