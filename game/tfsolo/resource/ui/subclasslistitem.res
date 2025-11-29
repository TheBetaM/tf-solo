"classes/SubClassListItem.res"
{
	"ClassTipsItemPanel"
	{
		"ControlName"			"CTFClassTipsItemPanel"
		"fieldName"				"ClassTipsItemPanel"
		"xpos"					"0"
		"ypos"					"0"
		"wide"					"160"
		"tall"					"30"
		"autoResize"			"0"
		"pinCorner"				"1"
		"visible"				"1"
		"enabled"				"1"
		"bgcolor_override"		"0 0 0 0"
		"textAlignment"			"north-west"

		"TipIcon"
		{
			"ControlName"	"ImagePanel"
			"fieldName"		"TipIcon"
			"xpos"			"0"
			"ypos"			"4"
			"wide"			"16"
			"tall"			"16"
			"visible"		"1"
			"enabled"		"1"
			"scaleimage"	"1"
		}
				
		"TipLabel"
		{
			"ControlName"	"CExButton"
			"fieldName"		"TipLabel"
			"xpos"			"25"
			"ypos"			"2"
			"wide"			"140"
			"tall"			"30"
			"visible"		"1"
			"enabled"		"1"
			"wrap"			"1"
			"font"			"ChalkboardText"
			"autoResize"	"3"
			"pinCorner"		"1"
			"textAlignment"	"north-west"
			
			"sound_depressed"	"UI/buttonclick.wav"
			"sound_released"	"UI/buttonclickrelease.wav"
			"sound_armed"		"UI/buttonrollover.wav"
			
			"stayselectedonclick"	"1"
			"selectonhover"			"1"
			"paintbackground"	"0"
		}
	}
}