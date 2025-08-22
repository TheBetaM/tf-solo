TFSOLO.Cutscenes.MTT_Pyro <- class extends TFSOLO.Cutscene
{
	Name = "MTT_Pyro"
	constructor() { }
	
	function CutsceneRun()
	{
		local cs = TFSOLO.Screens.Cutscene
		local actor1 = TFSOLO.Screens.Cutscene.ActorPanel1
		local actor2 = TFSOLO.Screens.Cutscene.ActorPanel2
		actor1.SetVisible(false)
		actor2.SetVisible(false)
		cs.DialogLabel.SetText("PLACEHOLDER: Meet The Pyro.")
		::suspend()
		
		TFSOLO.Cutscenes.MTT_Pyro.Exit()
		return
	}
}