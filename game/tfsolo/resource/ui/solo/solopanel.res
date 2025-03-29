"Resource/UI/Solo/SoloPanel.res"
{
	"Solo"
	{
		"ControlName"	"CSoloPanel"
		"fieldName"		"QuestMap"
		"xpos"			"0"
		"ypos"			"0"
		"zpos"			"100"
		"wide"			"f0"
		"tall"			"f60"
		"pinCorner"		"0"
		"visible"		"0"
		"enabled"		"1"
		"tabPosition"	"0"
		"PaintBackgroundType"	"0"
		"paintbackground"		"0"
		"skip_autoresize"	"1"

		"RewardItemKV"
		{
			"wide"	"250"
			"tall"	"60"
		}

		"mouseoveritempanel"
		{
			"ControlName"	"CItemModelPanel"
			"fieldName"		"mouseoveritempanel"
			"xpos"			"c-70"
			"ypos"			"270"
			"zpos"			"1000"
			"wide"			"300"
			"tall"			"300"
			"visible"		"0"
			"bgcolor_override"		"0 0 0 0"
			"noitem_textcolor"		"117 107 94 255"
			"PaintBackgroundType"	"2"
			"paintborder"	"1"
			"border"		"MainMenuBGBorder"
		
			"text_center"		"1"
			"model_hide"		"1"
			"resize_to_text"	"1"
			"padding_height"	"15"
		
			"attriblabel"
			{
				"font"			"ItemFontAttribLarge"
				"xpos"			"0"
				"ypos"			"30"
				"zpos"			"2"
				"wide"			"140"
				"tall"			"60"
				"autoResize"	"0"
				"pinCorner"		"0"
				"visible"		"1"
				"enabled"		"1"
				"labelText"		"%attriblist%"
				"textAlignment"	"center"
				"fgcolor"		"117 107 94 255"
				"centerwrap"	"1"
			}
		}

		"TooltipPanel"
		{
			"ControlName"	"EditablePanel"
			"fieldName"		"TooltipPanel"
			"xpos"			"0"
			"ypos"			"0"
			"zpos"			"1001"
			"wide"			"240"
			"tall"			"50"
			"visible"		"0"
			"PaintBackgroundType"	"2"
			"border"		"MainMenuBGBorder"
		
			"TipLabel"
			{
				"ControlName"	"CExLabel"
				"fieldName"		"TipLabel"
				"font"			"HudFontSmallest"
				"labelText"		"%tiptext%"
				"textAlignment"	"center"
				"xpos"			"20"
				"ypos"			"10"
				"zpos"			"2"
				"wide"			"200"
				"tall"			"30"
				"autoResize"	"0"
				"pinCorner"		"0"
				"visible"		"1"
				"enabled"		"1"
				"fgcolor_override"	"235 226 202 255"
				"wrap"			"1"
			}

			"QuestObjective"
			{
				"fieldName"	"QuestObjective"
				"wide"		"200"
				"zpos"		"1002"
			}
		}	

		"Dimmer"
		{
			"ControlName"	"EditablePanel"
			"fieldName"		"Dimmer"
			"xpos"		"0"
			"ypos"		"0"
			"zpos"		"-2"
			"wide"		"f0"
			"tall"		"f60"
			"autoResize"		"0"
			"pinCorner"		"0"
			"visible"		"1"
			"enabled"		"1"
			"tabPosition"		"0"
			"bgcolor_override"	"42 39 37 255"
			//"bgcolor_override"	"20 15 5 230"
		}

		"MainContainer"
		{
			"ControlName"	"EditablePanel"
			"fieldName"		"MainContainer"
			"xpos"			"cs-0.5"
			"ypos"			"20"
			"zpos"			"1"
			"wide"			"f0"//"700"
			"tall"			"f0"
			"skip_autoresize"	"1"
			"visible"		"1"
			"enabled"		"1"
			"tabPosition"	"0"
			"paintborder"		"0"
			
			"PathsPanel"
			{
				//"ControlName"	"CSoloPathsPanel"
				"fieldName"		"PathsPanel"
				"xpos"			"0"
				"ypos"			"0"
				"zpos"			"2"
				"wide"			"f0"
				"tall"			"f0"
				"visible"		"1"
				"enabled"		"1"
				"proportionaltoparent" "1"
				"mouseinputenabled"		"0"
				"keyboardinputenabled"	"0"
			}

			"MapAreaPanel"
			{
				"ControlName"	"EditablePanel"
				"fieldName"		"MapAreaPanel"
				"xpos"			"cs-0.5"
				"ypos"			"cs-0.5"
				"wide"			"f0"//"540"
				"tall"			"f0"//"315"
				"zpos"			"0"
				"proportionaltoparent" "1"
				"mouseinputenabled"	"1"

				"SelectedNodeInfoPanel"
				{
					"fieldName"		"SelectedNodeInfoPanel"
					"xpos"			"0"
					"ypos"			"0"
					"zpos"			"10"
					"wide"			"200"
					"tall"			"220"
					"visible"		"0"
					"enabled"		"1"
					"proportionaltoparent" "1"
					"mouseinputenabled"		"1"
					"keyboardinputenabled"	"0"
					"border"	"CYOANodeViewBorder"
					"collapsed_height"	"165"
					"expanded_height"	"220"
				}

				"QuestObjective"
				{
					"fieldName"	"QuestObjective"
					"wide"		"200"
					"zpos"		"11"
					"visible"	"0"
					"mouseinputenabled"	"0"

					"border"	"CYOAPopupBorder"
					"bgcolor_override"	"37 37 37 255"

					"ObjectivesLabel"
					{
						"fieldName"	"ObjectivesLabel"
						"ControlName"	"Label"
						"xpos"		"2"
						"ypos"		"2"
						"zpos"		"100"
						"wide"		"f2"
						"tall"		"20"
						"labelText"	"#TF_QuestView_Objectives"
						"visible"	"1"
						"font"		"QuestMap_Medium"
						"fgcolor_override"	"75 75 75 255"
						"bgcolor_override"	"0 0 0 255"
						"textAlignment"	"west"
						"textinsetx"	"5"
					}

					"ItemTrackerPanel"
					{
						"fieldName"		"ItemTrackerPanel"
						"xpos"			"0"	
						"ypos"			"25"
						"wide"			"f0"	
						"tall"			"200"
						"progress_bar_standard_loc_token"	"#QuestPoints_Standard"
						"progress_bar_advanced_loc_token"	"#QuestPoints_Bonus"
						"item_attribute_res_file" "resource/UI/quests/CYOA/QuestObjectivePanel_CYOA.res"
						"mouseinputenabled"	"0"
						"map_view"	"1"
						"show_item_name"	"0"
						"bar_gap"		"5"
						"group_bars_with_objectives"	"1"
						"proportionaltoparent"	"1"

						"ModelImageKV"
						{
							"fieldName"	"ModelImage"
							"wide"		"20"
							"tall"		"20"
							"scaleimage"	"1"
							"zpos"		"10"
						}

						"progressbarKV"
						{
							"xpos"			"0"
							"ypos"			"8"
							"wide"			"f15"
							"tall"			"6"
							"zpos"			"4"
							"visible"		"1"
							"enabled"		"1"
							"proportionaltoparent" "1"

							"bgcolor_override"		"250 234 201 51"

							"PointsLabel"
							{
								"ControlName"	"Label"
								"fieldName"		"PointsLabel"
								"labeltext"		"%points%"
								"xpos"			"0"
								"ypos"			"0"
								"wide"			"f0"
								"tall"			"f0"
								"zpos"			"1"
								"font"			"QuestMap_Small"
								"textinsety"	"-1"
								"TextAlignment"		"center"
								"proportionaltoparent" "1"
							}

							"ProgressBarStandardHighlight" // current completed
							{
								"ControlName"	"EditablePanel"
								"fieldName"		"ProgressBarStandardHighlight"
								"xpos"			"0"
								"ypos"			"0"
								"wide"			"f0"
								"tall"			"f0"
								"bgcolor_override"		"QuestUncommitted"
								"zpos"			"2"
								"visible"		"1"
								"enabled"		"1"
								"proportionaltoparent" "1"

								"PointsLabelInvert"
								{
									"ControlName"	"Label"
									"fieldName"		"PointsLabelInvert"
									"labeltext"		"%points%"
									"xpos"			"0"
									"ypos"			"0"
									"wide"			"f0"
									"tall"			"f0"
									"zpos"			"8"
									"font"			"QuestMap_Small"
									"textinsety"	"-1"
									"TextAlignment"		"center"
									"proportionaltoparent" "1"
									"fgcolor_override"	"Black"
								}
							}

							"ProgressBarStandard" // current completed
							{
								"ControlName"	"EditablePanel"
								"fieldName"		"ProgressBarStandard"
								"xpos"			"0"
								"ypos"			"0"
								"wide"			"f0"
								"tall"			"f0"
								"zpos"			"3"
								"visible"		"1"
								"enabled"		"1"
								"proportionaltoparent" "1"

								"bgcolor_override"		"251 235 202 255"

								"PointsLabelInvert"
								{
									"ControlName"	"Label"
									"fieldName"		"PointsLabelInvert"
									"labeltext"		"%points%"
									"xpos"			"0"
									"ypos"			"0"
									"wide"			"f0"
									"tall"			"f0"
									"zpos"			"8"
									"font"			"QuestMap_Small"
									"textinsety"	"-1"
									"TextAlignment"		"center"
									"proportionaltoparent" "1"
									"fgcolor_override"	"Black"
								}
							}
						}
					}
				}



				"StaticBar1"
				{
					"ControlName"	"ImagePanel"
					"fieldName"		"StaticBar1"
					"xpos"			"0"
					"ypos"			"50"
					"zpos"			"9000"
					"wide"			"f0"
					"tall"			"50"
					"visible"		"1"
					"PaintBackgroundType"	"0"
					"proportionaltoparent"	"1"
					"mouseinputenabled"		"0"
					"keyboardinputenabled"	"0"

					"alpha"		"50"
					"image"			"..\overlays\black_gradient"
					"scaleimage"	"1"
					"rotation"	"3"
				}

				"StaticBar2"
				{
					"ControlName"	"EditablePanel"
					"fieldName"		"StaticBar2"
					"xpos"			"0"
					"ypos"			"120"
					"zpos"			"9000"
					"wide"			"f0"
					"tall"			"50"
					"visible"		"1"
					"PaintBackgroundType"	"0"
					"proportionaltoparent"	"1"
					"mouseinputenabled"		"0"
					"keyboardinputenabled"	"0"

					"bgcolor_override"	"255 255 255 3"
				}

				"BlackOverlay"
				{
					"ControlName"	"Panel"
					"fieldName"		"BlackOverlay"
					"xpos"			"0"
					"ypos"			"0"
					"zpos"			"8999"
					"wide"			"f0"
					"tall"			"f0"
					"visible"		"1"
					"PaintBackgroundType"	"0"
					"proportionaltoparent"	"1"
					"mouseinputenabled"		"0"
					"keyboardinputenabled"	"0"
					
					"bgcolor_override" "0 0 0 255"
				}

				"StaticOverlay"
				{
					"ControlName"	"ImagePanel"
					"fieldName"		"StaticOverlay"
					"xpos"			"0"
					"ypos"			"0"
					"zpos"			"9000"
					"wide"			"f0"
					"tall"			"f0"
					"visible"		"1"
					"PaintBackgroundType"	"0"
					"proportionaltoparent"	"1"
					"mouseinputenabled"		"0"
					"keyboardinputenabled"	"0"

					"alpha"			"20"
					"image"			"..\models\passtime\tv\passtime_tv_screen_static"
					"tileImage"	"1"
				}

			} // MapAreaPanel

		} // MainContainer
	}
}
