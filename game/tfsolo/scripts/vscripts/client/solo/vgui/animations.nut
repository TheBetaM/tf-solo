TFSOLO.PlayTransitionScreenEffects <- function()
{
	VGUI_PlaySoundEntry("CYOA.MapOpen")
	local script = @"RunEvent QuestMap_StaticBar1Loop 0
	RunEvent QuestMap_StaticBar2Loop 0
	Animate StaticOverlay	alpha	128	Linear 0 0
	Animate StaticOverlay	alpha	20	Deaccel 0 0.4
	RunEvent QuestMap_StaticBarOverlayLoop 1"
	SoloPanel.RunAnimationScript(script, false)
}

TFSOLO.PlayMenuOpenEffects <- function()
{
	VGUI_PlaySoundEntry("CYOA.StaticFade")
	local script = @"FireCommand	0.4 ""solopanel_opened""
	StopEvent QuestMap_StaticBarOverlayLoop 0
	StopEvent QuestMap_StaticBarOverlayBrighten 0
	StopEvent QuestMap_StaticBarOverlayDarken 0
	StopEvent SoloMenu_StaticFadeOut 0
	StopEvent QuestMap_StaticBar1Loop 0
	StopEvent QuestMap_StaticBar2Loop 0
	Animate StaticBar1		ypos -80 Linear 0 0
	Animate StaticBar2		ypos -40 Linear 0 0
	Animate StaticOverlay	alpha 255 Linear 0 0
	Animate StaticOverlay	ypos cs-0.5 Linear 0 0
	Animate StaticOverlay	tall 0 Linear 0 0
	Animate BlackOverlay	alpha 0 Linear 0 0
	Animate StaticOverlay ypos cs-0.5-10	Accel 0.01 0.25
	Animate StaticOverlay tall 10	Accel 0.01 0.25
	Animate StaticOverlay tall 1080	Accel 0.3 0.15
	Animate StaticOverlay ypos 0	Accel 0.3 0.15
	Animate StaticOverlay	alpha	20	Deaccel 0.6 1.2
	Animate BlackOverlay	alpha 0 Linear 0.6 0
	RunEvent QuestMap_StaticBarOverlayLoop 2
	RunEvent QuestMap_StaticBar1Loop 0.7
	RunEvent QuestMap_StaticBar2Loop 0.7"
	SoloPanel.RunAnimationScript(script, false)
}