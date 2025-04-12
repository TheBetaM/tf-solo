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
	
	constructor(title, map, bmap, mapname, modename, pclass, forcedteam = 0, forcedclass = 0, mapspell = -1)
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
	}
}

Merc.Missions <- [
	Merc.Mission("Mission A-1","ctf_helltrain_event","","Helltrain","Capture the Flag","Scout",TF_TEAM_RED,TF_CLASS_SCOUT,MSpells.Any),
	Merc.Mission("Mission B-1","arena_lumberyard_event","","Graveyard","Arena","All-Class",TF_TEAM_RED,0,MSpells.Any),
	Merc.Mission("Mission A-2","workshop/1150874564","cp_standin_event","Demesne Event","Control Points","Soldier",TF_TEAM_RED,TF_CLASS_SOLDIER,MSpells.Any),
	Merc.Mission("Mission B-2","workshop/3350846941","pass_skulltown_v2","SkullTown","PASS Time","All-Class",TF_TEAM_RED,0,MSpells.Any),
	Merc.Mission("Mission A-3","workshop/2576870721","pl_abaddon_event","Abaddon","Payload","All-Class",TF_TEAM_RED,0,MSpells.Heal),
	Merc.Mission("Mission B-3","sd_doomsday_event","","Carnival of Carnage","Special Delivery","All-Class",TF_TEAM_RED,0,MSpells.Any),
	Merc.Mission("Mission A-4","workshop/3025150214","pd_infestation_b9","Infestation","Player Destruction","Engineer",TF_TEAM_RED,TF_CLASS_ENGINEER,MSpells.Mouse),
	Merc.Mission("Mission B-4","cp_freaky_fair","","Freaky Fair","Control Points","All-Class",TF_TEAM_RED,0,MSpells.Any),
	Merc.Mission("Mission A-5","workshop/3329421443","koth_sewer_b3","Sewer","King of the Hill","Heavy",TF_TEAM_RED,TF_CLASS_HEAVY,MSpells.Teleport),
	Merc.Mission("Mission B-5","pl_terror_event","","Terror","Payload","All-Class",TF_TEAM_RED,0,MSpells.Any),
	Merc.Mission("Mission A-6","koth_toxic","","Toxic","King of the Hill","All-Class",TF_TEAM_RED,0,MSpells.Pumpkins),
	Merc.Mission("Mission B-6","cp_degrootkeep_rats","","Sandcastle","Control Points","All-Class",TF_TEAM_RED,0,MSpells.Any),
	
	Merc.Mission("Pact A-1","workshop/1598716865","arena_staple_event_b6","Pharoah","Arena","All-Class",TF_TEAM_BLUE,TF_CLASS_SCOUT,MSpells.Any),
	Merc.Mission("Pact B-1","koth_lakeside_event","","Ghost Fort","King of the Hill","All-Class",TF_TEAM_BLUE,0,MSpells.Any),
	Merc.Mission("Pact A-2","workshop/3028406009","rd_crypt_rc1b","Crypt","Robot Destruction","All-Class",TF_TEAM_BLUE,0,MSpells.Invis),
	Merc.Mission("Pact B-2","zi_devastation_final1","","Devastation","Zombie Infection","A Zombie",TF_TEAM_BLUE,0,-1),
	Merc.Mission("Pact A-3","plr_hacksaw_event","","Bonesaw","Payload Race","All-Class",TF_TEAM_BLUE,0,MSpells.Skeletons),
	Merc.Mission("Pact B-3","workshop/3332394265","koth_hollow_b2c","Hollow","King of the Hill","A Ghost",TF_TEAM_BLUE,TF_CLASS_PYRO,-1),
	Merc.Mission("Pact A-4","tow_dynamite","","Dynamite","Tug of War","All-Class",TF_TEAM_BLUE,0,MSpells.Jump),
	Merc.Mission("Pact B-4","pd_pit_of_death_event","","Pit of Death","Player Destruction","A Skeleton",TF_TEAM_BLUE,TF_CLASS_SPY,MSpells.Any),
	Merc.Mission("Pact A-5","pl_precipice_event_final","","Precipice","Payload","All-Class",TF_TEAM_BLUE,0,MSpells.Fire),
	Merc.Mission("Pact B-5","cp_manor_event","","Mann Manor","Control Points","The HHH",TF_TEAM_BLUE,TF_CLASS_DEMOMAN,MSpells.Any),
	Merc.Mission("Pact A-6","koth_bagel_event","","Cauldron","King of the Hill","All-Class",TF_TEAM_BLUE,0,MSpells.Any),
	Merc.Mission("Pact B-6","pl_spineyard","","Spineyard","Payload","MERASMUS",TF_TEAM_BLUE,TF_CLASS_SNIPER,MSpells.Monoculus),
	
	Merc.Mission("Final Mission","workshop/3028289051","cp_holyhell_rc1","Holy Hell","Control Points","All-Class",TF_TEAM_RED,0,MSpells.Any),
	Merc.Mission("Final Pact","workshop/3028289051","cp_holyhell_rc1","Holy Hell","Control Points","DRACULA",TF_TEAM_BLUE,TF_CLASS_MEDIC,MSpells.Bats),
	Merc.Mission("Bonus Mission","koth_slaughter_event","","Laughter","King of the Hill","All-Class",TF_TEAM_RED,0,-1),
	Merc.Mission("Secret Mission","zi_sanitarium","","Sanitarium","Zombie Infection","All-Class",TF_TEAM_RED,0,MSpells.Lightning),
	Merc.Mission("Bonus Pact","koth_synthetic_event","","Sinthetic","King of the Hill","All-Class",TF_TEAM_BLUE,0,MSpells.Any),
	Merc.Mission("Secret Pact","vsh_outburst","","Outburst","Versus Saxton Hale","Saxton Hale",TF_TEAM_BLUE,TF_CLASS_HEAVY,-1),
]