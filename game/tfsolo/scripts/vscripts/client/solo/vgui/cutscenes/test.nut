TFSOLO.Cutscenes.Test <- class extends TFSOLO.Cutscene
{
	function CutsceneRun()
	{
		local cs = TFSOLO.Screens.Cutscene
		local actor1 = TFSOLO.Screens.Cutscene.ActorPanel1
		local actor2 = TFSOLO.Screens.Cutscene.ActorPanel2
		cs.ActorPanel1.SetVisible(false)
		cs.ActorPanel2.SetVisible(false)
		cs.DialogSpeakerLabel.SetText("")
		cs.DialogLabel.SetText("The Scout wakes up in a hospital room.")
		::suspend()
		
		cs.ActorPanel2.SetVisible(true)
		cs.DialogSpeakerLabel.SetText("Scout")
		cs.DialogLabel.SetText("...")
		actor2.PlayVCD("scenes/workshop/player/scout/low/taunt_the_scaredycat.vcd", null, false, false)
		actor2.HoldItemInSlot(1)
		::suspend()
		
		cs.DialogLabel.SetText("What the hell just happened?")
		::suspend()
		
		cs.ActorPanel1.SetVisible(true)
		local script1 = @"Animate ActorPanel1 xpos 200 Linear 0.1 1.0"
		SoloPanel.RunAnimationScript(script1, false)
		cs.DialogSpeakerLabel.SetText("")
		cs.DialogLabel.SetText("The Medic walks up to him.")
		::suspend()
		
		cs.DialogSpeakerLabel.SetText("Medic")
		cs.DialogLabel.SetText("Ah, you are finally awake.")
		actor1.PlayVCD("scenes/player/medic/low/taunt_xray.vcd", null, false, false)
		actor1.HoldItemInSlot(1)
		::suspend()
		
		cs.DialogSpeakerLabel.SetText("Scout")
		cs.DialogLabel.SetText("Uh doc, where's my leg at?!")
		actor2.PlayVCD("scenes/workshop/player/scout/low/taunt_unleashed_rage.vcd", null, true, false)
		actor2.HoldItemInSlot(1)
		::suspend()
		
		local script2 = @"Animate ActorPanel1 xpos 50 Linear 0 1.0
		SetVisible ActorPanel1 0 1.0"
		SoloPanel.RunAnimationScript(script2, false)
		actor1.PlayVCD("scenes/player/medic/low/conga.vcd", null, true, false)
		actor1.HoldItemInSlot(1)
		cs.DialogSpeakerLabel.SetText("Medic")
		cs.DialogLabel.SetText("Uh oh, gotta go!")
		::suspend()
		
		cs.ActorPanel1.SetVisible(false)
		cs.DialogSpeakerLabel.SetText("Scout")
		cs.DialogLabel.SetText("Hey! HEY!")
		::suspend()
		
		TFSOLO.Cutscenes.Test.Exit()
		return
	}
	
	Name = "TestCutscene"
	constructor() { }
}