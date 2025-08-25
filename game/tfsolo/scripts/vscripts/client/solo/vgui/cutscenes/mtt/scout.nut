TFSOLO.Cutscenes.MTT_Scout <- class extends TFSOLO.Cutscene
{
	function CutsceneRun()
	{
		local cs = TFSOLO.Screens.Cutscene
		local actor1 = TFSOLO.Screens.Cutscene.ActorPanel1
		local actor2 = TFSOLO.Screens.Cutscene.ActorPanel2
		local bg = TFSOLO.Screens.Cutscene.BackgroundPanel
		//TFSOLO.Screens.Cutscene.InteractIconPanel.SetImage("animated/tf2_logo_hourglass")
		
		bg.SetVisible(false)
		actor1.SetVisible(false)
		actor2.SetVisible(false)
		
		local kvBackgroundPanel = {
			ControlName=	"ImagePanel"
			fieldName=		"DialgueBackgroundImage"
			xpos=			"cs-0.5"
			ypos=			"cs-0.5"
			zpos=			"0"
			wide=			"f0"
			tall=			"f0"
			visible=		"1"
			enabled=		"1"
			scaleImage=		"1"
			image=			"solo/bg/well_bluspawn1"
			proportionaltoparent=	"1"
			mouseinputenabled=	"0"
			keyboardinputenabled= "0"
			drawcolor=		"QuestMap_BGImages"
		}
		local bgpanel = SoloPanel.CreatePanelRoot(kvBackgroundPanel)
		
		actor1.SetToPlayerClass(1, true, null)
		actor1.SetTeam(3)
		actor1.SetForceNoItems(true)
		actor1.SetDisableSpeak(true)
		
		actor2.SetToPlayerClass(8, true, null)
		actor2.HoldItemInSlot(1)
		actor2.SetTeam(3)
		actor2.SetForceNoItems(true)
		actor2.SetDisableSpeak(true)
		
		cs.DialogSpeakerLabel.SetText("Scout")
		cs.DialogLabel.SetText("Listen, listen. If there's one thing I'm good at, it's definitely baseball.")
		actor1.SetVisible(true)
		actor1.PlayVCD("scenes/player/scout/low/taunt_chicken_bucket.vcd", null, true, false)
		actor1.HoldItemInSlot(2)
		actor1.AttachModel("models/player/items/taunts/chicken_bucket/chicken_bucket.mdl")
		EmitSound("vo/taunts/scout_taunts20.mp3")
		::suspend()
		
		actor1.ClearCarriedItems()
		actor1.PlayVCD("", null, true, false)
		actor1.SetForceSequence("competitive_loserstate_idle", true)
		actor1.HoldItemInSlot(1)
		cs.DialogLabel.SetText("She hung up...")
		::suspend()
		
		cs.DialogSpeakerLabel.SetText("Spy")
		cs.DialogLabel.SetText("Asking out that dialtone?")
		actor2.SetVisible(true)
		actor2.SetForceSequence("taunt_cyoa_PDA_idle_A", true)
		actor2.HoldItemInSlot(2)
		EmitSound("vo/spy_negativevocalization04.mp3")
		::suspend()
		
		cs.DialogSpeakerLabel.SetText("Scout")
		cs.DialogLabel.SetText("Go to hell, Spy! The ladies just don't know me enough, that's all!")
		EmitSound("vo/scout_negativevocalization01.mp3")
		::suspend()
		
		cs.DialogSpeakerLabel.SetText("Spy")
		cs.DialogLabel.SetText("Trust me - there's no one in this state who can keep up with you.")
		EmitSound("vo/taunts/spy_highfive04.mp3")
		::suspend()
		
		actor2.SetVisible(false)
		actor1.SetForceSequence("taunt_cyoa_PDA_idle", true)
		actor1.HoldItemInSlot(1)
		cs.DialogSpeakerLabel.SetText("Scout")
		cs.DialogLabel.SetText("Guess I ought to run somewhere else.")
		EmitSound("vo/scout_positivevocalization01.mp3")
		::suspend()
		
		cs.DialogSpeakerLabel.SetText("")
		cs.DialogLabel.SetText("Bat\nMelee Weapon\nLeft Click - Swing")
		bgpanel.SetImageConst("solo/bg/well_bluspawn2")
		actor1.ClearCarriedItems()
		actor1.PlayVCD("", null, true, false)
		actor1.SetForceSequence("stand_MELEE", true)
		actor1.HoldItemInSlot(1)
		actor1.AttachModel("models/weapons/c_models/c_bat.mdl")
		EmitSound("Scout.MeleeDare01")
		::suspend()
		
		cs.DialogSpeakerLabel.SetText("")
		cs.DialogLabel.SetText("Pistol\nLong range finisher\nLeft Click - Primary Fire")
		actor1.ClearCarriedItems()
		actor1.PlayVCD("", null, true, false)
		actor1.SetForceSequence("stand_SECONDARY", true)
		actor1.HoldItemInSlot(1)
		actor1.AttachModel("models/weapons/c_models/c_pistol/c_pistol.mdl")
		EmitSound("vo/scout_misc02.mp3")
		::suspend()
		
		cs.DialogSpeakerLabel.SetText("")
		cs.DialogLabel.SetText("Scattergun\nClose range meat-shots\nLeft Click - Primary Fire")
		actor1.ClearCarriedItems()
		actor1.PlayVCD("", null, true, false)
		actor1.SetForceSequence("stand_PRIMARY", true)
		actor1.HoldItemInSlot(1)
		actor1.AttachModel("models/weapons/c_models/c_scattergun.mdl")
		EmitSound("vo/scout_battlecry02.mp3")
		::suspend()
		
		cs.DialogLabel.SetText("OBJECTIVE:\nCapture and hold the control point until time runs out.")
		bgpanel.SetImageConst("solo/bg/well_mid1")
		actor1.SetVisible(false)
		EmitSound("vo/announcer_attention.mp3")
		//TFSOLO.Screens.Cutscene.InteractIconPanel.SetImage("blog_forward_solid")
		//TFSOLO.Screens.Cutscene.InteractIconPanel.SetImage("animated/tf2_logo_hourglass")
		TFSOLO.Screens.Cutscene.InteractIconPanel.SetImage("glyph_multiplayer")
		::suspend()
		
		TFSOLO.Cutscenes.MTT_Scout.Exit()
		return
	}
	
	Name = "MTT_Scout"
	constructor() { }
}