TFSOLO.Screens.Cutscene <- class extends TFSOLO.Screen
{
	Name = "Cutscene"
	SkipButton = null
	DialogHolder = null
	DialogLabel = null
	DialogSpeakerLabel = null
	DialogProgressButton = null
	BackgroundPanel = null
	InteractIconPanel = null
	ActorPanel1 = null
	ActorPanel2 = null
	constructor() {
		SkipButton = null
		DialogHolder = null
		DialogLabel = null
		DialogSpeakerLabel = null
		DialogProgressButton = null
		BackgroundPanel = null
		InteractIconPanel = null
		ActorPanel1 = null
		ActorPanel2 = null
	}
	
	function OnEnter()
	{
		local kvSkip = {
			ControlName =	"CExImageButton",
			fieldName =		"CutsceneScreenButtonSkip",
			xpos =			"cs-0.5+150",
			ypos =			"cs-0.5-150",
			zpos =			"16",
			wide =			"110",
			tall =			"25",
			autoResize =	"0",
			pinCorner =		"3",
			visible =		"1",
			enabled =		"1",
			tabPosition =	"0",
			labelText =		"SKIP",
			font =			"HudFontSmallBold",
			textAlignment =	"center",
			textinsetx =	"5",
			use_proportional_insets = "1",
			dulltext =		"0",
			brighttext =	"0",
			Command =		"cts_skip",
			proportionaltoparent = "1",

			sound_depressed =	"UI/buttonclick.wav",
			sound_released =	"UI/buttonclickrelease.wav",
		}
		kvSkip["default"] <- "0"
		SkipButton <- SoloPanel.CreatePanelRoot(kvSkip)
		
		local kvHolder = {
			ControlName=	"EditablePanel"
			fieldName=		"DialoguePanel"
			xpos=			"cs-0.5"
			ypos=			"r80"
			zpos=			"10"
			wide=			"470"
			tall=			"80"
			visible=		"1"
			PaintBackgroundType=	"0"
			paintborder=	"1"
			border=		"StorePreviewBorder"
			proportionaltoparent = "1"
			mouseinputenabled=	"1"
			keyboardinputenabled= "1"
		}
		DialogHolder <- SoloPanel.CreatePanelRoot(kvHolder)
		
		local kvDialogLabel = {
			ControlName	=	"CExRichText"//"CExLabel"
			fieldName=		"DialogueRichText2"
			font=			"HudFontMediumSmallSecondary"//"Default"//"ScoreboardMedium"
			labelText=		"very long text test"
			textAlignment=	"north-west"
			xpos=			"5"
			ypos=			"5"
			zpos=			"11"
			wide=			"460"
			tall=			"75"
			autoResize=		"3"//"0"
			pinCorner=		"0"
			visible=		"1"
			enabled=		"1"
			fgcolor=		"TanLight"
			wrap=			"1"
			highlight_color=	"177 168 149 255"
			itemset_color=		"216 244 9 255"
			link_color=		"252 191 27 255"
			image_up_arrow=				"scroll_up_off"
			image_up_arrow_mouseover=		"scroll_up_on"
			image_down_arrow=				"scroll_down_off"
			image_down_arrow_mouseover=	"scroll_down_on"
			//image_line=		"ArmoryScrollbarWell"
			//image_box=			"ArmoryScrollbarBox"
			tabPosition=		"0"
			maxchars=		"-1"
			text=			""
		}
		kvDialogLabel["default"] <- "0"
		DialogLabel <- SoloPanel.CreatePanel(kvDialogLabel, kvHolder.fieldName)
		
		local kvSpeakerHolder = {
			ControlName=	"EditablePanel"
			fieldName=		"DialogueSpeakerPanel"
			xpos=			"cs-0.5"
			ypos=			"r110"
			zpos=			"10"
			wide=			"470"
			tall=			"80"
			visible=		"1"
			PaintBackgroundType=	"0"
			paintborder=	"0"
			//border=		"StorePreviewBorder"
			proportionaltoparent = "1"
			mouseinputenabled=	"0"
			keyboardinputenabled= "0"
		}
		local DialogSpeakerHolder = SoloPanel.CreatePanelRoot(kvSpeakerHolder)
		
		local kvSpeakerLabel = {
			ControlName	=	"CExRichText"//"CExLabel"
			fieldName=		"DialogueRichText3"
			font=			"HudFontMediumBold"//"HudFontMedium"
			labelText=		"very long text test"
			textAlignment=	"north-west"
			xpos=			"0"
			ypos=			"5"
			zpos=			"11"
			wide=			"460"
			tall=			"75"
			autoResize=		"3"//"0"
			pinCorner=		"0"
			visible=		"1"
			enabled=		"1"
			fgcolor=		"TanLight"
			wrap=			"1"
			highlight_color=	"177 168 149 255"
			itemset_color=		"216 244 9 255"
			link_color=		"252 191 27 255"
			image_up_arrow=				"scroll_up_off"
			image_up_arrow_mouseover=		"scroll_up_on"
			image_down_arrow=				"scroll_down_off"
			image_down_arrow_mouseover=	"scroll_down_on"
			//image_line=		"ArmoryScrollbarWell"
			//image_box=			"ArmoryScrollbarBox"
			tabPosition=		"0"
			maxchars=		"-1"
			text=			""
		}
		kvSpeakerLabel["default"] <- "0"
		DialogSpeakerLabel <- SoloPanel.CreatePanel(kvSpeakerLabel, kvSpeakerHolder.fieldName)
		
		local kvProgressButton = {
			ControlName=	"Button"
			fieldName=		"DialogueProgressButton"
			xpos=			"0"//"cs-0.5"
			ypos=			"0"//"r80"
			zpos=			"15"
			wide=			"f0"//"470"
			tall=			"f0"//"80"
			autoResize=		"0"
			pinCorner=		"0"
			visible=		"1"
			enabled=		"1"
			tabPosition=		"0"
			labelText=			""
			bgcolor_override=	"0 0 0 220"
			command=	"cts_continue"
			paintbackground=	"0"
			paintborder=		"0"
			proportionaltoparent = "1"
		}
		kvProgressButton["default"] <- "1"
		DialogProgressButton <- SoloPanel.CreatePanelRoot(kvProgressButton)
		
		local kvBackgroundPanel = {
			ControlName=	"ImagePanel"
			fieldName=		"DialgueBackgroundImage"
			xpos=			"cs-0.5"
			ypos=			"cs-0.5"
			zpos=			"0"
			wide=			"350"
			tall=			"o1"
			visible=		"1"
			enabled=		"1"
			scaleImage=		"1"
			image=			"cyoa/cyoa_bg_icon_globe"
			proportionaltoparent=	"1"
			mouseinputenabled=	"0"
			keyboardinputenabled= "0"
			drawcolor=		"QuestMap_BGImages"
		}
		BackgroundPanel <- SoloPanel.CreatePanelRoot(kvBackgroundPanel)
		
		local kvInteractIconPanel = {
			ControlName=	"ScalableImagePanel"
			fieldName=		"InteractIconImage"
			xpos=			"r35"
			ypos=			"r30"
			zpos=			"14"
			wide=			"24"
			tall=			"24"
			visible=		"1"
			enabled=		"1"
			//scaleImage=		"1"
			image=			"blog_forward_solid"
			proportionaltoparent=	"1"
			mouseinputenabled=	"0"
			keyboardinputenabled= "0"
			//drawcolor=		"QuestMap_BGImages"
		}
		InteractIconPanel <- SoloPanel.CreatePanel(kvInteractIconPanel, kvHolder.fieldName)
		
		local kvActorPanel1 = {
			ControlName=	"CTFPlayerModelPanel"
			fieldName=		"ActorPanel1"
			
			xpos=			"cs-0.5-135"
			ypos=			"cs-0.5"
			zpos=			"5"		
			wide=			"270"
			tall=			"340"
			autoResize=	"0"
			pinCorner=		"0"
			visible=		"1"
			enabled=		"1"
			
			render_texture=	"0"
			fov=			"30"
			allow_rot=		"0"
					
			model=
			{
				force_pos=	"1"

				angles_x= "0"
				angles_y= "190"
				angles_z= "0"
				origin_x= "190"
				origin_y= "0"
				origin_z= "-48"
				frame_origin_x=	"0"
				frame_origin_y=	"0"
				frame_origin_z=	"0"
				spotlight= "1"
			
				modelname=		""
			}
		}
		ActorPanel1 <- SoloPanel.CreatePanelRoot(kvActorPanel1)
		ActorPanel1.SetToPlayerClass(5, true, null)
		ActorPanel1.SetDisableSpeak(false)
		
		local kvActorPanel2 = {
			ControlName=	"CTFPlayerModelPanel"
			fieldName=		"ActorPanel2"
			
			xpos=			"cs-0.5+135"
			ypos=			"cs-0.5"
			zpos=			"5"		
			wide=			"270"
			tall=			"340"
			autoResize=	"0"
			pinCorner=		"0"
			visible=		"1"
			enabled=		"1"
			
			render_texture=	"0"
			fov=			"30"
			allow_rot=		"0"
					
			model=
			{
				force_pos=	"1"

				angles_x= "0"
				angles_y= "170"
				angles_z= "0"
				origin_x= "190"
				origin_y= "0"
				origin_z= "-48"
				frame_origin_x=	"0"
				frame_origin_y=	"0"
				frame_origin_z=	"0"
				spotlight= "1"
			
				modelname=		""
			}
		}
		ActorPanel2 <- SoloPanel.CreatePanelRoot(kvActorPanel2)
		ActorPanel2.SetToPlayerClass(1, true, null)
		ActorPanel2.SetDisableSpeak(false)
	}
}

TFSOLO.VguiCutsceneEventTag <- UniqueString()
getroottable()[TFSOLO.VguiCutsceneEventTag] <- {
	OnScriptHook_solopanel_command = function(params)
	{
		if (TFSOLO.Screens.Active != TFSOLO.Screens.Cutscene) return;
		if (params.command == "cts_continue")
		{
			if (TFSOLO.Cutscenes.Active != null)
			{
				TFSOLO.Cutscenes.Active.Progress()
			}
		}
		else if (params.command == "cts_skip")
		{
			if (TFSOLO.Cutscenes.Active != null)
			{
				TFSOLO.Cutscenes.Active.Skip()
			}
		}
	}
}
TFSOLO.VguiCutsceneEventTable <- getroottable()[TFSOLO.VguiCutsceneEventTag]
__CollectGameEventCallbacks(TFSOLO.VguiCutsceneEventTable)
