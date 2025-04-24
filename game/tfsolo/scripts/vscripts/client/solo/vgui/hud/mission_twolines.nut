TFSOLO.HudScreens.MissionTwoLines <- class extends TFSOLO.HudScreen
{
	Name = "MissionTwoLinesHUD"
	constructor() {}
	
	function OnEnter()
	{
		
	}
	function OnExit()
	{
		
	}
	function OnEvent(key, value)
	{
		if (key == "obj1done")
		{
			local script1 = @"Animate ObjText1 FgColor	""CreditsGreen""	Linear 0.0 1.0"
			SoloHUD.RunAnimationScript(script1, false)
		}
		else if (key == "obj2done")
		{
			local script1 = @"Animate ObjText2 FgColor	""CreditsGreen""	Linear 0.0 1.0"
			SoloHUD.RunAnimationScript(script1, false)
		}
		else if (key == "obj1fail")
		{
			local script1 = @"Animate ObjText1 FgColor	""RedSolid""	Linear 0.0 1.0"
			SoloHUD.RunAnimationScript(script1, false)
		}
		else if (key == "obj2fail")
		{
			local script1 = @"Animate ObjText2 FgColor	""RedSolid""	Linear 0.0 1.0"
			SoloHUD.RunAnimationScript(script1, false)
		}
	}
	function OnString(key, value)
	{
		// Dialog variables stop working for some reason after changing the res file, this is the workaround for now...
		local text1 = SoloHUD.FindPanelRoot("ObjText1")
		local text1s = SoloHUD.FindPanelRoot("ObjText1Dropshadow")
		local text2 = SoloHUD.FindPanelRoot("ObjText2")
		local text2s = SoloHUD.FindPanelRoot("ObjText2Dropshadow")
		if (key == "objective1")
		{
			text1.SetText(value)
			text1s.SetText(value)
		}
		else if (key == "objective2")
		{
			text2.SetText(value)
			text2s.SetText(value)
		}
	}
}
TFSOLO.HudScreens["resource/ui/solo/mission_twolines.res"] <- TFSOLO.HudScreens.MissionTwoLines()
TFSOLO.HudScreens["resource/ui/solo/mission_twolines_red.res"] <- TFSOLO.HudScreens.MissionTwoLines()
TFSOLO.HudScreens["resource/ui/solo/mission_twolines_blue.res"] <- TFSOLO.HudScreens.MissionTwoLines()