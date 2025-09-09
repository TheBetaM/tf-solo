// 0 - locked, 1 - unlocked, 2 - cleared, 3 - bonus cleared, 4 - reverse cleared, 5 - reverse bonus cleared
Merc.MissionStatus <- [
	1,1,1,1,1,1,1,1,1,1,1,1,
	1,1,1,1,1,1,1,1,1,1,1,1,
	1,1,  1,1,1,1]
/* Cutscene flags (30)
[0] - RED Intro (M00)
[1] - BLU Intro (M00)
[2] - RED Choice 1 (M02)
[3] - RED Choice 2 (M04)
[4] - RED Choice 3 (M06)
[5] - BLU Choice 1 (M02)
[6] - BLU Choice 2 (M04)
[7] - BLU Choice 3 (M06)
[8] - RED Bonus (B07)
[9] - RED Spell Shop (B01)
[10] - BLU Bonus (B07)
[11] - BLU Spell Shop (B01)
[12] - RED Final Mission Available (M10)
[13] - BLU Final Mission Available (M10)
[14] - RED Ending
[15] - BLU Ending
[16] - RED Bottles
[17] - First Mission Selected
[18] - RED Invaders 1 (M05)
[19] - RED Invaders 2 (M08)
[20] - BLU Invaders 1 (M05)
[21] - BLU Invaders 2 (M08)
[22] - RED A Plot Complete (M24 Dracula starts with less HP)
[23] - RED B Plot Complete (M24 Dracula is Marked For Death)
[24] - BLU A Plot Complete (M25 Dracula starts with more HP)
[25] - BLU B Plot Complete (M25 Dracula gains On Hit: Marked For Death)
[26] - BLU Secret Pickups
[27] - RED 100% / 200%
[28] - BLU 100% / 200%
*/
Merc.CSFlags <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
/* Reserved flags (30) for any extra persistent functionality
[0] - RED spell credits
[1] - BLU spell credits
[2] - (unused)
[3] - (unused)
[4] - RED Choice 1 (Recruit/No Recruit/Curse of Darkness)
[5] - RED Choice 2 (+25% Clip Size/+50% Ammo/Spawn Marked For Death)
[6] - RED Choice 3 (Taunt For Bullet Resist/Taunt For Overheal/Spawn With Low HP)
[7] - BLU Choice 1 (Recruit/No Recruit/Curse of Darkness)
[8] - BLU Choice 2 (+25% Max HP/+100% Max Overheal/Spawn Mad Milked)
[9] - BLU Choice 3 (Taunt For Blast Resist/Taunt For Fright/Crits Do No Damage)
[10] - Reverse Missions
[11] - BLU Secret Pickup 1 (M20)
[12] - BLU Secret Pickup 2 (M21)
[13] - Spell 0: Fire
[14] - Spell 1: Bats
[15] - Spell 2/14: Heal/KartHeal
[16] - Spell 3: Pumpkins
[17] - Spell 4: Jump
[18] - Spell 5: Invis
[19] - Spell 6: Teleport
[20] - Spell 7: Lightning
[21] - Spell 8: Mouse
[22] - Spell 9: Meteor
[23] - Spell 10: Monoculus
[24] - Spell 11: Skeletons
[25] - Spell 12: KartGlove
*/
Merc.RSVFlags <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
Merc.LastMissionID <- -1
// New Game Plus
Merc.NGP <- 0

Merc.ResetProgress <- function()
{
	Merc.MissionStatus <- [
		1,1,1,1,1,1,1,1,1,1,1,1,
		1,1,1,1,1,1,1,1,1,1,1,1,
		1,1,  1,1,1,1]
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
		2,2,
		2,2,2,2]
	Merc.CSFlags <- [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
	Merc.RSVFlags <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
}

Merc.UpdateProgress <- function()
{
	local MisDoneRED = 0, MisDoneBLU = 0, BDoneRED = 0, BDoneBLU = 0
	for (local i = 0; i < Merc.Missions.len(); i++)
	{
		if (Merc.Missions[i].ForcedTeam == TF_TEAM_RED)
		{
			if (Merc.MissionStatus[i] >= 2)
			{
				MisDoneRED++
			}
			if (Merc.MissionStatus[i] > 2)
			{
				BDoneRED++
			}
		}
		else
		{
			if (Merc.MissionStatus[i] >= 2)
			{
				MisDoneBLU++
			}
			if (Merc.MissionStatus[i] > 2)
			{
				BDoneBLU++
			}
		}
	}
	if (Merc.MissionStatus[0]==0) Merc.MissionStatus[0] = 1
	if (Merc.MissionStatus[2]==0 && Merc.MissionStatus[0] >= 2) Merc.MissionStatus[2] = 1
	if (Merc.MissionStatus[4]==0 && Merc.MissionStatus[2] >= 2) Merc.MissionStatus[4] = 1
	if (Merc.MissionStatus[6]==0 && Merc.MissionStatus[4] >= 2) Merc.MissionStatus[6] = 1
	if (Merc.MissionStatus[8]==0 && Merc.MissionStatus[6] >= 2) Merc.MissionStatus[8] = 1
	if (Merc.MissionStatus[10]==0 && Merc.MissionStatus[8] >= 2) Merc.MissionStatus[10] = 1
	
	if (Merc.MissionStatus[1]==0) Merc.MissionStatus[1] = 1
	if (Merc.MissionStatus[3]==0 && Merc.MissionStatus[1] >= 2) Merc.MissionStatus[3] = 1
	if (Merc.MissionStatus[5]==0 && Merc.MissionStatus[3] >= 2) Merc.MissionStatus[5] = 1
	if (Merc.MissionStatus[7]==0 && Merc.MissionStatus[5] >= 2) Merc.MissionStatus[7] = 1
	if (Merc.MissionStatus[9]==0 && Merc.MissionStatus[7] >= 2) Merc.MissionStatus[9] = 1
	if (Merc.MissionStatus[11]==0 && Merc.MissionStatus[9] >= 2) Merc.MissionStatus[11] = 1
	
	if (Merc.MissionStatus[12]==0) Merc.MissionStatus[12] = 1
	if (Merc.MissionStatus[14]==0 && Merc.MissionStatus[12] >= 2) Merc.MissionStatus[14] = 1
	if (Merc.MissionStatus[16]==0 && Merc.MissionStatus[14] >= 2) Merc.MissionStatus[16] = 1
	if (Merc.MissionStatus[18]==0 && Merc.MissionStatus[16] >= 2) Merc.MissionStatus[18] = 1
	if (Merc.MissionStatus[20]==0 && Merc.MissionStatus[18] >= 2) Merc.MissionStatus[20] = 1
	if (Merc.MissionStatus[22]==0 && Merc.MissionStatus[20] >= 2) Merc.MissionStatus[22] = 1
	
	if (Merc.MissionStatus[13]==0) Merc.MissionStatus[13] = 1
	if (Merc.MissionStatus[15]==0 && Merc.MissionStatus[13] >= 2) Merc.MissionStatus[15] = 1
	if (Merc.MissionStatus[17]==0 && Merc.MissionStatus[15] >= 2) Merc.MissionStatus[17] = 1
	if (Merc.MissionStatus[19]==0 && Merc.MissionStatus[17] >= 2) Merc.MissionStatus[19] = 1
	if (Merc.MissionStatus[21]==0 && Merc.MissionStatus[19] >= 2) Merc.MissionStatus[21] = 1
	if (Merc.MissionStatus[23]==0 && Merc.MissionStatus[21] >= 2) Merc.MissionStatus[23] = 1
	
	if (Merc.MissionStatus[24]==0 && MisDoneRED >= 10 && MisDoneBLU >= 10) Merc.MissionStatus[24] = 1
	if (Merc.MissionStatus[25]==0 && MisDoneRED >= 10 && MisDoneBLU >= 10) Merc.MissionStatus[25] = 1
	
	if (Merc.MissionStatus[26]==0 && BDoneRED >= 7) Merc.MissionStatus[26] = 1
	if (Merc.MissionStatus[27]==0 && Merc.CSFlags[16] != 0) Merc.MissionStatus[27] = 1
	if (Merc.MissionStatus[28]==0 && BDoneBLU >= 7) Merc.MissionStatus[28] = 1
	if (Merc.MissionStatus[29]==0 && Merc.CSFlags[26] != 0) Merc.MissionStatus[29] = 1
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
			if (Merc.MissionStatus[i] > 3) prog = prog + 1.0
			if (Merc.MissionStatus[i] > 4) prog = prog + 1.0
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
		if (Merc.MissionStatus[i] > 3) prog = prog + 1.0
		if (Merc.MissionStatus[i] > 4) prog = prog + 1.0
	}
	return ceil((prog / total) * 100.0)
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

