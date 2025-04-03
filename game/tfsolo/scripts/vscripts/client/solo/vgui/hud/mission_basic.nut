TFSOLO.HudScreens.MissionBasic <- class extends TFSOLO.HudScreen
{
	Name = "MissionBasicHUD"
	constructor() {}
	
	function OnEnter()
	{
		local status = SoloHUD.GetMatchStatusPanel()
		local posX = status.GetXPos()
		local posY = status.GetYPos()
		posY += 50
		status.SetPos(posX, posY)
		
		status = SoloHUD.GetKothTimersPanel()
		posX = status.GetXPos()
		posY = status.GetYPos()
		posY += 50
		status.SetPos(posX, posY)
	}
	function OnExit()
	{
		local status = SoloHUD.GetMatchStatusPanel()
		local posX = status.GetXPos()
		local posY = status.GetYPos()
		posY -= 50
		status.SetPos(posX, posY)
		
		status = SoloHUD.GetKothTimersPanel()
		posX = status.GetXPos()
		posY = status.GetYPos()
		posY -= 50
		status.SetPos(posX, posY)
	}
}
TFSOLO.HudScreens["resource/ui/solo/mission_basic.res"] <- TFSOLO.HudScreens.MissionBasic()