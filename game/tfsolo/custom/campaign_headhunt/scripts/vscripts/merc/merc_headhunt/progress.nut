// 0 - locked, 1 - unlocked, 2 - cleared, 3+ - extra cleared
Merc.MissionStatus <- [
	1,1,0,0,0,0,0,0,0,0,0,0,
	1,1,0,0,0,0,0,0,0,0,0,0,
	0,0]
/* Cutscene flags (30)
[0] - RED Intro (M00)
[1] - BLU Intro (M00)
[2] - RED Choice 1 (M03)
[3] - RED Choice 2 (M06)
[4] - RED Choice 3 (M09)
[5] - BLU Choice 1 (M03)
[6] - BLU Choice 2 (M06)
[7] - BLU Choice 3 (M09)
[8] - RED Weapon 1 (B03)
[9] - RED Weapon 2 (B09)
[10] - BLU Weapon 1 (B03)
[11] - BLU Weapon 2 (B09)
[12] - RED Final Mission Available (M10)
[13] - BLU Final Mission Available (M10)
[14] - RED Ending
[15] - BLU Ending
[16] - RED PCorner
[17] - First Mission Selected
[18] - RED 100%
[19] - BLU 100%
*/
Merc.CSFlags <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
/* Reserved flags (30) for any extra persistent functionality
[0] - Equipped MercWeapons ID on RED
[1] - RED MercWeapons property flags
[2] - Equipped MercWeapons ID on BLU
[3] - BLU MercWeapons property flags
[4] - RED Choice 1 (No Recruit/Recruit/Handicap: No Lockers)
[5] - RED Choice 2 (Immune to headshots/Immune to backstabs/Handicap: No Random Crits)
[6] - RED Choice 3 (Speed Boost On Spawn/Always See Teammates/Handicap: No Ammopacks)
[7] - BLU Choice 1 (No Recruit/Recruit/Handicap: No Lockers)
[8] - BLU Choice 2 (Immune to fall damage/Immune to afterburn/Handicap: Crits Become Mini-Crits)
[9] - BLU Choice 3 (Uber On Spawn/Prevent Death Once/Handicap: No Healthkits)
[10] - Friendly Heavy Killed (BLU)
*/
Merc.RSVFlags <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
Merc.LastMissionID <- -1
// New Game Plus
Merc.NGP <- 0

Merc.ResetProgress <- function()
{
	Merc.MissionStatus <- [
		1,1,0,0,0,0,0,0,0,0,0,0,
		1,1,0,0,0,0,0,0,0,0,0,0,
		0,0]
	Merc.CSFlags <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	Merc.RSVFlags <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	Merc.LastMissionID <- -1
	Merc.NGP <- 0
}

Merc.SaveProgress <- function()
{
	local buffer = ""
	buffer += "Merc.SaveVersion<-" + Merc.SaveVersionTarget + "\n"
	buffer += "Merc.LastMissionID<-" + Merc.LastMissionID + "\n"
	buffer += "Merc.NGP<-" + Merc.NGP + "\n"
	buffer += "Merc.MissionStatus<-["
	foreach (i in Merc.MissionStatus) buffer += i + ","
	buffer = buffer.slice(0, buffer.len() - 1)
	buffer += "]\n"
	buffer += "Merc.CSFlags<-["
	foreach (i in Merc.CSFlags) buffer += i + ","
	buffer = buffer.slice(0, buffer.len() - 1)
	buffer += "]\n"
	buffer += "Merc.RSVFlags<-["
	foreach (i in Merc.RSVFlags) buffer += i + ","
	buffer = buffer.slice(0, buffer.len() - 1)
	buffer += "]\n"
	StringToFile("merc/" + Merc.ProjectName + "/savedata.nut", buffer)
	
	Entities.FindByClassname(null,"tf_gamerules").AcceptInput("SoloSaveData","",null,null)
}

Merc.DebugUnlockAll <- function()
{
	Merc.MissionStatus <- [
		2,2,2,2,2,2,2,2,2,2,2,2,
		2,2,2,2,2,2,2,2,2,2,2,2,
		2,2]
	Merc.CSFlags <- [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
	Merc.RSVFlags <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
}

Merc.UpdateProgress <- function()
{
	local MisDoneRED = 0, MisDoneBLU = 0
	for (local i = 0; i < 12; i++)
	{
		if (Merc.MissionStatus[i] >= 2) MisDoneRED++
	}
	for (local i = 12; i < 24; i++)
	{
		if (Merc.MissionStatus[i] >= 2) MisDoneBLU++
	}
	if (Merc.MissionStatus[0]==0) Merc.MissionStatus[0] = 1
	if (Merc.MissionStatus[1]==0) Merc.MissionStatus[1] = 1
	if (Merc.MissionStatus[2]==0 && MisDoneRED >= 1) Merc.MissionStatus[2] = 1
	if (Merc.MissionStatus[3]==0 && MisDoneRED >= 1) Merc.MissionStatus[3] = 1
	if (Merc.MissionStatus[4]==0 && MisDoneRED >= 2) Merc.MissionStatus[4] = 1
	if (Merc.MissionStatus[5]==0 && MisDoneRED >= 2) Merc.MissionStatus[5] = 1
	if (Merc.MissionStatus[6]==0 && MisDoneRED >= 4) Merc.MissionStatus[6] = 1
	if (Merc.MissionStatus[7]==0 && MisDoneRED >= 4) Merc.MissionStatus[7] = 1
	if (Merc.MissionStatus[8]==0 && MisDoneRED >= 6) Merc.MissionStatus[8] = 1
	if (Merc.MissionStatus[9]==0 && MisDoneRED >= 6) Merc.MissionStatus[9] = 1
	if (Merc.MissionStatus[10]==0 && MisDoneRED >= 8) Merc.MissionStatus[10] = 1
	if (Merc.MissionStatus[11]==0 && MisDoneRED >= 8) Merc.MissionStatus[11] = 1
	
	if (Merc.MissionStatus[12]==0) Merc.MissionStatus[12] = 1
	if (Merc.MissionStatus[13]==0) Merc.MissionStatus[13] = 1
	if (Merc.MissionStatus[14]==0 && MisDoneBLU >= 1) Merc.MissionStatus[14] = 1
	if (Merc.MissionStatus[15]==0 && MisDoneBLU >= 1) Merc.MissionStatus[15] = 1
	if (Merc.MissionStatus[16]==0 && MisDoneBLU >= 2) Merc.MissionStatus[16] = 1
	if (Merc.MissionStatus[17]==0 && MisDoneBLU >= 2) Merc.MissionStatus[17] = 1
	if (Merc.MissionStatus[18]==0 && MisDoneBLU >= 4) Merc.MissionStatus[18] = 1
	if (Merc.MissionStatus[19]==0 && MisDoneBLU >= 4) Merc.MissionStatus[19] = 1
	if (Merc.MissionStatus[20]==0 && MisDoneBLU >= 6) Merc.MissionStatus[20] = 1
	if (Merc.MissionStatus[21]==0 && MisDoneBLU >= 6) Merc.MissionStatus[21] = 1
	if (Merc.MissionStatus[22]==0 && MisDoneBLU >= 8) Merc.MissionStatus[22] = 1
	if (Merc.MissionStatus[23]==0 && MisDoneBLU >= 8) Merc.MissionStatus[23] = 1
	
	if (Merc.MissionStatus[24]==0 && MisDoneRED >= 10 && MisDoneBLU >= 10) Merc.MissionStatus[24] = 1
	if (Merc.MissionStatus[25]==0 && MisDoneRED >= 10 && MisDoneBLU >= 10) Merc.MissionStatus[25] = 1
}

Merc.GetProgress <- function(team)
{
	local prog = 0.0, total = 0.0
	for (local i = 0; i < Merc.Missions.len(); i++)
	{
		if (Merc.Missions[i].ForcedTeam == 0 || Merc.Missions[i].ForcedTeam == team)
		{
			total = total + 2.0
			if (Merc.MissionStatus[i] >= 2) prog = prog + 1.0
			if (Merc.MissionStatus[i] > 2) prog = prog + 1.0
		}
	}
	return ceil((prog / total) * 100.0)
}

Merc.GetProgressAll <- function()
{
	local prog = 0.0, total = 0.0
	for (local i = 0; i < Merc.Missions.len(); i++)
	{
		total = total + 2.0
		if (Merc.MissionStatus[i] >= 2) prog = prog + 1.0
		if (Merc.MissionStatus[i] > 2) prog = prog + 1.0
	}
	return ceil((prog / total) * 100.0)
}

Merc.GetWeaponUnlock <- function(id)
{
	local prog_red = 0, prog_blu = 0
	for (local i = 0; i < Merc.Missions.len(); i++)
	{
		if (Merc.MissionStatus[i] > 2)
		{
			if (Merc.Missions[i].ForcedTeam == TF_TEAM_RED)
				prog_red = prog_red + 1
			else
				prog_blu = prog_blu + 1
		}
	}
	if (id == 0 && prog_red >= 3) return true
	else if (id == 1 && prog_red >= 9) return true
	else if (id == 2 && prog_blu >= 3) return true
	else if (id == 3 && prog_blu >= 9) return true
	return false
}

Merc.GetWeaponPerks <- function(id)
{
	local prog_red = 0, prog_blu = 0
	for (local i = 0; i < Merc.Missions.len(); i++)
	{
		if (Merc.MissionStatus[i] > 2)
		{
			if (Merc.Missions[i].ForcedTeam == TF_TEAM_RED)
				prog_red = prog_red + 1
			else
				prog_blu = prog_blu + 1
		}
	}
	if (id == 0)
	{
		if (prog_red >= 7) return 2
		if (prog_red >= 5) return 1
	}
	else if (id == 1)
	{
		if (prog_red >= 13) return 2
		if (prog_red >= 11) return 1
	}
	else if (id == 2)
	{
		if (prog_blu >= 7) return 2
		if (prog_blu >= 5) return 1
	}
	else if (id == 3)
	{
		if (prog_blu >= 13) return 2
		if (prog_blu >= 11) return 1
	}
	return 0
}

Merc.GetProgCount <- function(team, bonus)
{
	local prog = 0
	for (local i = 0; i < Merc.Missions.len(); i++)
	{
		if (Merc.Missions[i].ForcedTeam == 0 || Merc.Missions[i].ForcedTeam == team)
		{
			if (Merc.MissionStatus[i] >= 2 && !bonus) prog = prog + 1
			if (Merc.MissionStatus[i] > 2 && bonus) prog = prog + 1
		}
	}
	return prog
}

