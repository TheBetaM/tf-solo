TFSOLO.HudScreen <- class
{
	Name = "BaseHudScreen"
	
	constructor()
	{

	}
	
	function Enter()
	{
		TFSOLO.HudScreens.Active = this
		OnEnter()
	}
	function OnEnter()
	{
		
	}
	function Exit()
	{
		OnExit()
	}
	function OnExit()
	{
		
	}
	function OnEvent(key, value)
	{
		
	}
	function OnThink()
	{
		
	}
	function OnString(key, value)
	{
		
	}
	function _tostring() return this.Name
}

IncludeScript("client/solo/vgui/hud/test.nut")
IncludeScript("client/solo/vgui/hud/mission_basic.nut")
IncludeScript("client/solo/vgui/hud/mission_twolines.nut")
IncludeScript("client/solo/vgui/hud/results_credits.nut")