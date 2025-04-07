#base "custom_base.res"

"Resource/UI/Solo/Mission_Basic.res"
{	
	"ObjectiveStatusSolo"
	{
		"ObjText1"
		{
			"ControlName"		"CExLabel"
			"fieldName"		"ObjText1"
			"font"			"HudFontMediumSmallBold"
			"fgcolor"		"TanLight"
			"xpos"			"cs-0.5"
			"ypos"			"-5"
			"zpos"			"5"
			"wide"			"f0"
			"tall"			"50"
			"visible"		"1"
			"enabled"		"1"
			"textAlignment"		"center"
			"labelText"		"%objective1%"
		}
		
		"ObjBG"
		{
			"ControlName"		"ScalableImagePanel"
			"fieldName"		"ObjBG"
			"xpos"			"cs-0.5"
			"ypos"			"10"
			"zpos"			"4"
			"wide"			"400"
			"tall"			"20"
			"autoResize"	"0"
			"pinCorner"		"0"
			"visible"		"1"
			"enabled"		"1"
			"image"			"../hud/color_panel_brown"

			"src_corner_height"	"22"
			"src_corner_width"	"22"
		
			"draw_corner_width"	"5"
			"draw_corner_height" 	"5"	
		}
	}
}
