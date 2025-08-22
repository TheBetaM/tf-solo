TFSOLO.Cutscenes.MTT_Soldier <- class extends TFSOLO.Cutscene
{
	Name = "MTT_Soldier"
	constructor() { }
	
	function CutsceneRun()
	{
		local cs = TFSOLO.Screens.Cutscene
		local actor1 = TFSOLO.Screens.Cutscene.ActorPanel1
		local actor2 = TFSOLO.Screens.Cutscene.ActorPanel2
		actor1.SetVisible(false)
		actor2.SetVisible(false)
		cs.DialogLabel.SetText("PLACEHOLDER: Meet The Soldier.")
		::suspend()
		
		TFSOLO.Cutscenes.MTT_Soldier.Exit()
		return
	}
}