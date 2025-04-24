#base "custom_base.res"

"Resource/UI/Solo/Results_Credits.res"
{	
	"ObjectiveStatusSolo"
	{
		"Results"
		{
			"ControlName"	"EditablePanel"
			"fieldName"	"Results"
			"xpos"		"c80"
			"ypos"		"105"
			"zpos"		"1"
			"wide"		"200"
			"tall"		"380"
			"visible"	"1"
			"enabled"	"1"

			"ResultsLabel"
			{
				"ControlName"		"Label"
				"fieldName"		"ResultsLabel"
				"font"			"HudFontMediumSmallBold"
				"labelText"		"RESULTS"
				"textAlignment"		"center"
				"xpos"			"0"
				"ypos"			"10"
				"zpos"			"1"
				"wide"			"200"
				"tall"			"20"
				"autoResize"		"0"
				"pinCorner"		"0"
				"visible"		"1"
				"enabled"		"1"
			}
			"ResultsBG"
			{
				"ControlName"	"EditablePanel"
				"fieldName"		"ResultsBG"
				"xpos"			"0"
				"ypos"			"0"
				"wide"			"200"
				"tall"			"175"
				"visible"		"1"
				"PaintBackgroundType"	"2"
				"border"		"TrainingResultsBG"
			}
			"ResultsText"
			{
				"ControlName"		"CExRichText"
				"fieldName"		"ResultsText"
				"xpos"			"15"
				"ypos"			"40"//"150"
				"zpos"			"2"
				"wide"			"170"
				"tall"			"225"//"215"
				"autoResize"		"3"
				"pinCorner"		"0"
				"visible"		"1"
				"enabled"		"1"
				"tabPosition"		"0"
				"maxchars"		"-1"
				"text"			""
				"wrap"			"1"
				"textAlignment"		"north-west"
				"font"			"HudFontSmall"
			}
		}
	}
}
