TFSOLO.Cutscenes <- {}
TFSOLO.Cutscenes.Active <- null

TFSOLO.Cutscene <- class
{
	function Enter()
	{
		TFSOLO.Cutscenes.Active = this
		Coroutine = ::newthread(CutsceneRun)
		TFSOLO.Screens.Cutscene.Enter()
		OnEnter()
	}
	function OnEnter()
	{
		Coroutine.call()
	}
	function Exit()
	{
		TFSOLO.Cutscenes.Active = null
		TFSOLO.PlayTransitionScreenEffects()
		OnExit()
	}
	function OnExit()
	{
		if (TFSOLO.WorldMaps.Active != null && TFSOLO.WorldMaps.Active.SelectedNode != null)
		{
			TFSOLO.WorldMaps.Active.SelectedNode.OnSelect()
			TFSOLO.WorldMaps.Active.Enter()
		}
	}
	function Skip()
	{
		OnSkip()
	}
	function OnSkip()
	{
		Exit()
	}
	function Progress()
	{
		OnProgress()
	}
	function OnProgress()
	{
		Coroutine.wakeup()
	}
	function CutsceneRun()
	{
		local ret = ::suspend()
		Exit()
		return
	}
	
	Name = "BaseCutscene"
	Coroutine = null
	
	constructor() {
		Coroutine = null
	}
	function _tostring() return this.Name
}

IncludeScript("client/solo/vgui/cutscenes/test.nut")
IncludeScript("client/solo/vgui/cutscenes/mtt/scout.nut")
IncludeScript("client/solo/vgui/cutscenes/mtt/soldier.nut")
IncludeScript("client/solo/vgui/cutscenes/mtt/pyro.nut")
IncludeScript("client/solo/vgui/cutscenes/mtt/demoman.nut")
IncludeScript("client/solo/vgui/cutscenes/mtt/heavy.nut")
IncludeScript("client/solo/vgui/cutscenes/mtt/engineer.nut")
IncludeScript("client/solo/vgui/cutscenes/mtt/medic.nut")
IncludeScript("client/solo/vgui/cutscenes/mtt/sniper.nut")
IncludeScript("client/solo/vgui/cutscenes/mtt/spy.nut")