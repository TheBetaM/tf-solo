TFSOLO.Cutscenes.MTT_Medic <- class extends TFSOLO.Cutscene
{
	Name = "MTT_Medic"
	constructor() { }
	
	function CutsceneRun()
	{
		local cs = TFSOLO.Screens.Cutscene
		local actor1 = TFSOLO.Screens.Cutscene.ActorPanel1
		local actor2 = TFSOLO.Screens.Cutscene.ActorPanel2
		actor1.SetVisible(false)
		actor2.SetVisible(false)
		cs.DialogLabel.SetText("PLACEHOLDER: Meet The Medic.")
		::suspend()
		
		TFSOLO.Cutscenes.MTT_Medic.Exit()
		return
	}
}