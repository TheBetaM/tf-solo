TFSOLO.HudScreens.Test <- class extends TFSOLO.HudScreen
{
	Name = "TestHUD"
	constructor() {}
	
	function OnEnter()
	{
		
	}
}
TFSOLO.HudScreens["resource/ui/solo/test.res"] <- TFSOLO.HudScreens.Test()
TFSOLO.HudScreens["resource/ui/solo/test2.res"] <- TFSOLO.HudScreens.Test()