TFSOLO.Cutscenes.MTT_Engineer <- class extends TFSOLO.Cutscene
{
	Name = "MTT_Engineer"
	constructor() { }
	
	function CutsceneRun()
	{
		local cs = TFSOLO.Screens.Cutscene
		local actor1 = TFSOLO.Screens.Cutscene.ActorPanel1
		local actor2 = TFSOLO.Screens.Cutscene.ActorPanel2
		actor1.SetVisible(false)
		actor2.SetVisible(false)
		cs.DialogLabel.SetText("PLACEHOLDER: Meet The Engineer.")
		::suspend()
		
		TFSOLO.Cutscenes.MTT_Engineer.Exit()
		return
	}
}