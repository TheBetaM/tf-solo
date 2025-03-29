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
	
	constructor() { }
	function _tostring() return this.Name
}

IncludeScript("client/solo/vgui/cutscenes/test.nut")