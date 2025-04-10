Merc.Mission <- class {
	ForcedClass = 0
	ForcedTeam = 0
	Map = "koth_viaduct"
	MapName = "Viaduct"
	ModeName = "King of the Hill"
	PlayerClassName = "All-Class"
	IntroFunc = null
	Title = "Mission 00"
	
	constructor(title, map, mapname, modename, pclass, forcedteam = 0, forcedclass = 0)
	{
		Title = title
		Map = map
		MapName = mapname
		ModeName = modename
		PlayerClassName = pclass
		ForcedTeam = forcedteam
		ForcedClass = forcedclass
	}
}

Merc.Missions <- [
	Merc.Mission("Mission 01", "koth_badlands", 	  "Badlands", "King of the Hill",			"All-Class", 	TF_TEAM_RED, 0),
	Merc.Mission("Mission 02", "cp_dustbowl", 		  "Dustbowl", "Control Points"	 			"Demoman", 		TF_TEAM_RED, TF_CLASS_DEMOMAN),
	Merc.Mission("Mission 03", "koth_cachoeira",  	  "Cachoeira","King of the Hill",			"All-Class", 	TF_TEAM_RED, 0),
	Merc.Mission("Mission 04", "pl_swiftwater_final1","Swiftwater", "Payload", 					"All-Class", 	TF_TEAM_RED, 0),
	Merc.Mission("Mission 05", "cp_metalworks", 	  "Metalworks", "Control Points", 			"Soldier", 		TF_TEAM_RED, TF_CLASS_SOLDIER),
	Merc.Mission("Mission 06", "pl_phoenix", 		  "Phoenix", "Payload",						"All-Class", 	TF_TEAM_RED, 0),
	Merc.Mission("Mission 07", "ctf_pelican_peak", 	  "Pelican Peak", "Capture the Flag",	 	"All-Class", 	TF_TEAM_RED, 0),
	Merc.Mission("Mission 08", "cp_gorge", 			  "Gorge", "Control Points", 				"Engineer", 	TF_TEAM_RED, TF_CLASS_ENGINEER),
	Merc.Mission("Mission 09", "pl_badwater", 		  "Badwater Basin", "Payload", 				"All-Class", 	TF_TEAM_RED, 0),
	Merc.Mission("Mission 10", "vsh_distillery", 	  "Distillery", "", 						"Saxton Hale", 	TF_TEAM_RED, 0),
	Merc.Mission("Mission 11", "koth_sharkbay", 	  "Sharkbay", "King of the Hill", 			"Pyro", 		TF_TEAM_RED, TF_CLASS_PYRO),
	Merc.Mission("Mission 12", "pl_goldrush", 		  "Gold Rush", "Payload", 					"All-Class", 	TF_TEAM_RED, 0),
	
	Merc.Mission("Mission 01", "koth_nucleus", 		  "Nucleus", "King of the Hill",			"All-Class", 	TF_TEAM_BLUE, 0),
	Merc.Mission("Mission 02", "cp_mercenarypark", 	  "Mercenary Park", "Control Points",		"Scout", 		TF_TEAM_BLUE, TF_CLASS_SCOUT),
	Merc.Mission("Mission 03", "ctf_landfall", 		  "Landfall", "Capture the Flag",			"All-Class", 	TF_TEAM_BLUE, 0),
	Merc.Mission("Mission 04", "pl_thundermountain",  "Thunder Mountain", "Payload",			"All-Class", 	TF_TEAM_BLUE, 0),
	Merc.Mission("Mission 05", "cp_vanguard", 		  "Vanguard", "Control Points", 			"Heavy", 		TF_TEAM_BLUE, TF_CLASS_HEAVY),
	Merc.Mission("Mission 06", "cp_standin_final", 	  "Standin", "Control Points",				"All-Class", 	TF_TEAM_BLUE, 0),
	Merc.Mission("Mission 07", "ctf_turbine", 	 	  "Turbine", "Capture the Flag",			"All-Class", 	TF_TEAM_BLUE, 0),
	Merc.Mission("Mission 08", "koth_sawmill", 		  "Sawmill", "King of the Hill", 			"Sniper", 		TF_TEAM_BLUE, TF_CLASS_SNIPER),
	Merc.Mission("Mission 09", "pl_upward", 		  "Upward", "Payload", 						"All-Class", 	TF_TEAM_BLUE, 0),
	Merc.Mission("Mission 10", "cp_mossrock", 		  "Mossrock", "Control Points", 			"Spy",		 	TF_TEAM_BLUE, TF_CLASS_SPY),
	Merc.Mission("Mission 11", "koth_rotunda", 		  "Rotunda", "King of the Hill",			"Medic", 		TF_TEAM_BLUE, TF_CLASS_MEDIC),
	Merc.Mission("Mission 12", "pl_hoodoo_final",	  "Hoodoo", "Payload", 						"All-Class", 	TF_TEAM_BLUE, 0),
	
	Merc.Mission("Final Mission", "koth_viaduct", 	  "Viaduct", "King of the Hill", 			"All-Class", 	TF_TEAM_RED,  0),
	Merc.Mission("Final Mission", "koth_viaduct", 	  "Viaduct", "King of the Hill", 			"All-Class", 	TF_TEAM_BLUE, 0),
]