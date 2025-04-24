TFSOLO.HudScreens.ResultsCredits <- class extends TFSOLO.HudScreen
{
	Name = "ResultsCreditsHUD"
	CreditsBefore = 0
	constructor() 
	{
		CreditsBefore = 0
	}
	
	function OnEnter()
	{
		CreditsBefore = TFSOLO.GetCredits()
	}
	function OnExit()
	{
		
	}
	function OnEvent(key, value)
	{
		
	}
	function OnString(key, value)
	{
		local text1 = SoloHUD.FindPanelRoot("ResultsText")
		if (key == "result_text")
		{
			text1.SetText(value)
		}
	}
}
TFSOLO.HudScreens["resource/ui/solo/results_credits.res"] <- TFSOLO.HudScreens.ResultsCredits()