TFSOLO.Cutscenes.MTT_Scout <- class extends TFSOLO.Cutscene
{
	Name = "MTT_Scout"
	constructor() { }
	
	function CutsceneRun()
	{
		local cs = TFSOLO.Screens.Cutscene
		local actor1 = TFSOLO.Screens.Cutscene.ActorPanel1
		local actor2 = TFSOLO.Screens.Cutscene.ActorPanel2
		actor1.SetVisible(false)
		actor2.SetVisible(false)
		actor1.SetToPlayerClass(1, true, null)
		actor1.HoldItemInSlot(2)
		actor2.SetToPlayerClass(8, true, null)
		actor2.HoldItemInSlot(1)
		cs.DialogLabel.SetText("PLACEHOLDER: Meet The Scout.")
		::suspend()
		
		TFSOLO.Cutscenes.MTT_Scout.Exit()
		return
	}
}