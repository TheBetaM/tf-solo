#base "custom_base.res"

"Resource/UI/Solo/Mission_Basic.res"
{	
	"ObjectiveStatusSolo"
	{
		"ObjText1"
		{
			"ControlName"		"CExLabel"
			"fieldName"		"ObjText1"
			"font"			"HudFontMediumSmallSecondary"
			"fgcolor"		"TanLight"
			"xpos"			"10"
			"ypos"			"-5"
			"zpos"			"5"
			"wide"			"f0"
			"tall"			"50"
			"visible"		"1"
			"enabled"		"1"
			"textAlignment"		"west"
			"labelText"		"%objective1%"
		}
		"ObjText1Dropshadow"
		{	
			"ControlName"		"CExLabel"
			"fieldName"		"ObjText1Dropshadow"
			"font"			"HudFontMediumSmallSecondary"
			"fgcolor"		"black"
			"xpos"			"11"
			"ypos"			"-4"
			"zpos"			"5"
			"wide"			"f0"
			"tall"			"50"
			"visible"		"1"
			"enabled"		"1"
			"textAlignment"		"west"
			"labelText"		"%objective1%"
		}
		
		"ObjText2"
		{
			"ControlName"		"CExLabel"
			"fieldName"		"ObjText2"
			"font"			"HudFontMediumSmallSecondary"
			"fgcolor"		"TanLight"
			"xpos"			"10"
			"ypos"			"15"
			"zpos"			"5"
			"wide"			"f0"
			"tall"			"50"
			"visible"		"1"
			"enabled"		"1"
			"textAlignment"		"west"
			"labelText"		"%objective2%"
		}
		"ObjText2Dropshadow"
		{
			"ControlName"		"CExLabel"
			"fieldName"		"ObjText2Dropshadow"
			"font"			"HudFontMediumSmallSecondary"
			"fgcolor"		"black"
			"xpos"			"11"
			"ypos"			"16"
			"zpos"			"5"
			"wide"			"f0"
			"tall"			"50"
			"visible"		"1"
			"enabled"		"1"
			"textAlignment"		"west"
			"labelText"		"%objective2%"
		}
		
		"ObjBG"
		{
			"ControlName"		"ScalableImagePanel"
			"fieldName"		"ObjBG"
			"xpos"			"-10"
			"ypos"			"10"
			"zpos"			"4"
			"wide"			"350"
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
		
		"ObjBG2"
		{
			"ControlName"		"ScalableImagePanel"
			"fieldName"		"ObjBG2"
			"xpos"			"-10"
			"ypos"			"30"
			"zpos"			"4"
			"wide"			"350"
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
