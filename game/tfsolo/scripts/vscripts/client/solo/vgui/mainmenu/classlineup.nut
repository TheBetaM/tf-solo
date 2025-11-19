
SoloMainMenu.ActorPanels <- [null,null,null,null,null,null,null,null,null,null,null]

SoloMainMenu.ClassLineupNames <-
[
	"civilian",
	
    "scout",
    "sniper",
    "soldier",
    "demoman",
    "medic",
    "heavy",
    "pyro",
    "spy",
    "engineer",
	
    "civilian"
]

SoloMainMenu.ClassLineupOffsetX <-
[
	"-135",
	
	"+60",
	"",
	"+120",
	"+220",
	"+320",
	"-90",
	"-320",
	"-180",
	"-240",
	
	/*
	"-320",
	"-240",
	"-180",
	"-90",
	"",
	"+90",
	"+180",
	"+280",
	"+320",
	*/
	
	"-135",
]

SoloMainMenu.ClassLineupOffsetZ <-
[
	"-98",
	
	"-97",
	"-98",
	"-98",
	"-97",
	"-98",
	"-97",
	"-97",
	"-98",
	"-98",
	
	"-98",
]

SoloMainMenu.ClassLineupSlots <-
[
	0,
	0
	0,
	0,
	0
	1
	0,
	0,
	2,
	2,
	2,
]

SoloMainMenu.ClassLineupKV <- function(i)
{
	local kvActorPanel = {
		ControlName=	"CTFPlayerModelPanel"
		fieldName=		"ActorPanel1"
		
		xpos=			"cs-0.5" + SoloMainMenu.ClassLineupOffsetX[i]
		ypos=			"cs-0.5+20"
		zpos=			SoloMainMenu.ClassLineupOffsetZ[i]		
		wide=			"270"
		tall=			"340"
		autoResize=	"0"
		pinCorner=		"0"
		visible=		"1"
		enabled=		"1"
		
		render_texture=	"0"
		fov=			"30"
		allow_rot=		"0"
				
		model=
		{
			force_pos=	"1"

			angles_x= "0"
			angles_y= "190"
			angles_z= "0"
			origin_x= "190"
			origin_y= "0"
			origin_z= "-48"
			frame_origin_x=	"0"
			frame_origin_y=	"0"
			frame_origin_z=	"0"
			spotlight= "1"
		
			modelname=		""
		}
	}
	return kvActorPanel;
}



SoloMainMenu.InitClassLineup <- function()
{
	local team = 2
	if (RandomInt(0,1) == 0)
	{
		team = 3
	}
	for (local i = 1; i < 10; i++)
	{
		SoloMainMenu.ActorPanels[i] = MainMenu.CreatePanelRoot(SoloMainMenu.ClassLineupKV(i))
		SoloMainMenu.ActorPanels[i].SetToPlayerClass(i, true, null)
		SoloMainMenu.ActorPanels[i].SetTeam(team)
		SoloMainMenu.ActorPanels[i].SetDisableSpeak(true)
		//SoloMainMenu.ActorPanels[i].SetFreezeScene(true)
		local bAnim = SoloMainMenu.ActorPanels[i].AutoAddPlayerCarriedItems(i)
		if (bAnim)
		{
			SoloMainMenu.ActorPanels[i].PlayVCD("scenes/player/" + SoloMainMenu.ClassLineupNames[i] + "/low/class_select.vcd", null, true, false)
		}
		else
		{
			SoloMainMenu.ActorPanels[i].PlayVCD("scenes/player/" + SoloMainMenu.ClassLineupNames[i] + "/low/idle.vcd", null, true, false)
		}
		SoloMainMenu.ActorPanels[i].HoldItemInSlot(SoloMainMenu.ClassLineupSlots[i])
	}
}

SoloMainMenu.UpdateClassLineup <- function()
{
	for (local i = 1; i < 10; i++)
	{
		SoloMainMenu.ActorPanels[i].ClearCarriedItems()
		local bAnim = SoloMainMenu.ActorPanels[i].AutoAddPlayerCarriedItems(i)
		if (bAnim)
		{
			SoloMainMenu.ActorPanels[i].PlayVCD("scenes/player/" + SoloMainMenu.ClassLineupNames[i] + "/low/class_select.vcd", null, true, false)
		}
		else
		{
			SoloMainMenu.ActorPanels[i].PlayVCD("scenes/player/" + SoloMainMenu.ClassLineupNames[i] + "/low/idle.vcd", null, true, false)
		}
		SoloMainMenu.ActorPanels[i].HoldItemInSlot(SoloMainMenu.ClassLineupSlots[i])
	}
}