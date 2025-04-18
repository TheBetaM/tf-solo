#include "cbase.h"
#include "tf_solo_node_panel.h"
#include <vgui/IInput.h>
#include <vgui_controls/Slider.h>
#include "vgui/ISurface.h"
#include "vgui_controls/CircularProgressBar.h"
#include "vscript_client.h"
#include "clientmode_tf.h"
#include "tf_solo_panel.h"

const float node_cycle_time(3.f);
const float node_alpha_start(255);
const float node_alpha_end(0);
const float node_anim_time(3);
const float node_small_radius(5);
//const float node_medium_radius(17);
//const float node_large_radius(30);
const float node_pulse_time(2);
const float node_pulse_scale(1.3f);
const float node_selected_brightness(70);
const float node_mouseover_brightness(50);
const float node_pulse_alpha(50);
const float node_pulse_bias(0.2);

uint32 CSoloNodePanel::m_nDraggingID = (uint32)-1;

void DrawAmbientActiveCirlceSolo(float flXPos, float flYPos, const Color& color)
{
	const float flNow = Plat_FloatTime();
	const float flSmallRadius = YRES(node_small_radius);
	const float flMediumRadius = YRES(node_medium_radius);
	const float flLargeRadius = YRES(node_large_radius);

	const float flRingInterval = 1.f;
	for (float flStepBack = 0.f; flStepBack < node_cycle_time; flStepBack += flRingInterval)
	{
		float flCycle = node_cycle_time - fmod(flNow - flStepBack, node_cycle_time);
		// Start a full alpha and fade out
		float flAlphaScale = Bias(RemapValClamped(flCycle, node_anim_time, 0.f, 0.f, 1.f), 0.2f);
		float flAlpha = RemapValClamped(flAlphaScale, 0.f, 1.f, node_alpha_start, node_alpha_end);
		// Start at small radius and grow to large
		float flRadius = RemapValClamped(flCycle, node_anim_time, 0.f, 0.f, YRES(node_large_radius));

		Color colorPartial = color;
		colorPartial.SetColor(colorPartial.r(), colorPartial.g(), colorPartial.b(), flAlpha);
		// A circle that grows from small to large while fading out
		DrawColoredCircle(flXPos, flYPos, flRadius, colorPartial);
		colorPartial[3] = colorPartial[3] * 0.4f;
		DrawFilledColoredCircle(flXPos, flYPos, flRadius, colorPartial);
	}
}

CSoloNodePanel::CSoloNodePanel(Panel* pParent, const char* pszPanelName)
	: EditablePanel(pParent, pszPanelName)
	, m_flMapStateEnterTime(0.f)
	, m_eMapState(NEUTRAL)
	, m_bOverSelected(false)
	, m_bRequirementsMet(false)
	, m_bIsIngame(false)
	, m_bHasItem(false)
	, m_bIsLocked(false)
	, m_nCompletionState(0)
	, m_nCompletionSegments(1)
	, m_nNodeID(0)
	, m_nStarCount(0)
	, m_nCreditsType(0)
{
	m_pSelectButton = new CExButton(this, "SelectButton", (char*)NULL);
	m_pSelectButton->PassMouseTicksTo(this, true);
	m_pNameLabel = new Label(this, "NodeNameLabel", (const char*)NULL);
	m_pStarCostImage = new ImagePanel(this, "StarCostImage");
}

CSoloNodePanel::~CSoloNodePanel()
{}

void CSoloNodePanel::ApplySchemeSettings(IScheme* pScheme)
{
	BaseClass::ApplySchemeSettings(pScheme);
	LoadControlSettings("Resource/UI/econ/QuestMapNodePanel.res");
}

void CSoloNodePanel::ApplySettings(KeyValues* inResourceData)
{
	BaseClass::ApplySettings(inResourceData);

	m_nStartWide = GetWide();
	m_nStartTall = GetTall();

	m_nCreditsType = inResourceData->GetInt("hasCredits");
	m_pszNodeText = inResourceData->GetString("nodeText");
	m_nStarCount = inResourceData->GetInt("hasStarCount");
	m_bHasItem = inResourceData->GetInt("hasItem");
	m_bIsLocked = inResourceData->GetInt("isLocked");
	m_nCompletionState = inResourceData->GetInt("completionState");
	m_nCompletionSegments = inResourceData->GetInt("completionSegments", 1);
	m_pszIconName = inResourceData->GetString("iconName");
	m_nNodeID = inResourceData->GetInt("nodeID");
	m_pszTooltipText = inResourceData->GetString("tooltipText");

	UpdateStateVisuals();
}

void CSoloNodePanel::PerformLayout()
{
	
}

void CSoloNodePanel::UpdateStateVisuals()
{
	Color colorActive = vgui::scheme()->GetIScheme(GetScheme())->GetColor("QuestMap_ActiveOrange", Color(255, 255, 255, 255));
	ImagePanel* pIcon = FindControl< ImagePanel >("NodeIcon");
	pIcon->SetImage(m_pszIconName);

	//bool bEffects = pKVParams && pKVParams->GetBool("effects", false);
	//bool bNewRequirementsMetState = pNode || pDef->BCanUnlock(GetQuestMapHelper());
	/*
	bool bNewRequirementsMetState = false;
	if (bNewRequirementsMetState && !m_bRequirementsMet && bEffects)
	{
		//PlaySoundEntry("CYOA.ObjectivePanelExpand");
		Color colorStart = vgui::scheme()->GetIScheme(GetScheme())->GetColor("QuestMap_ActiveOrange", Color(255, 255, 255, 255));
		colorStart.SetColor(colorStart.r(), colorStart.g(), colorStart.b(), 200);
		Color colorEnd(colorStart.r(), colorStart.g(), colorStart.b(), 0);

		KeyValues* pKVCreateCircle = new KeyValues("CreateCircle");
		pKVCreateCircle->SetColor("start_color", colorStart);
		pKVCreateCircle->SetColor("end_color", colorEnd);
		pKVCreateCircle->SetFloat("start_time", Plat_FloatTime());
		pKVCreateCircle->SetFloat("end_time", Plat_FloatTime() + 1.f);
		pKVCreateCircle->SetFloat("xpos", GetXPos() + GetWide() * 0.5f);
		pKVCreateCircle->SetFloat("ypos", GetYPos() + GetTall() * 0.5f);
		pKVCreateCircle->SetFloat("start_radius", 120.f);
		pKVCreateCircle->SetFloat("end_radius", 115.f);
		pKVCreateCircle->SetBool("filled", true);
		PostActionSignal(pKVCreateCircle);

	}
	m_bRequirementsMet = bNewRequirementsMetState;
	*/

	if ( m_nCompletionState > m_nCompletionSegments || m_bIsIngame )
	{
		pIcon->SetDrawColor( colorActive );
	}
	else
	{
		pIcon->SetDrawColor( Color(100, 100, 100, 255) );
	}
	SetControlVisible("LockedIcon", m_bIsLocked);
	SetControlVisible("ItemIcon", m_bHasItem);
	SetControlVisible("CashIcon", m_nCreditsType != 0);
	SetControlVisible("StarCount", m_nStarCount != 0, true);

	{
		m_pNameLabel->SetText(m_pszNodeText);
		//if (pNode)
		//{
			//m_pNameLabel->SetText(g_pVGuiLocalize->Find(pDef->GetNameLocToken()));
		//}
		//else
		//{
			//locchar_t locName[MAX_ITEM_NAME_LENGTH];
			//loc_sprintf_safe(locName, LOCCHAR("%ls: %dx"), g_pVGuiLocalize->Find(pDef->GetNameLocToken()), pDef->GetNumStarsToUnlock());
			//m_pNameLabel->SetText(locName);
			//int nWide, nTall;
			//m_pNameLabel->GetContentSize(nWide, nTall);
			//m_pStarCostImage->SetPos(m_pNameLabel->GetXPos() + (m_pNameLabel->GetWide() + nWide) / 2, m_pStarCostImage->GetYPos());
		//}

		//m_pStarCostImage->SetVisible(!pNode);
		m_pStarCostImage->SetVisible(false);
	}

	switch (m_nCreditsType)
	{
	case 3: SetDialogVariable("cash", "$$$"); break;
	case 2: SetDialogVariable("cash", "$$"); break;
	case 1: SetDialogVariable("cash", "$"); break;
	case 0: SetDialogVariable("cash", ""); break;
	}

	Label* pCashIcon = FindControl< Label >("CashIcon");
	Panel* pItemIcon = FindChildByName("ItemIcon");
	if (pCashIcon && pItemIcon)
	{
		pCashIcon->SizeToContents();
		int nRewardsWide = pCashIcon->GetWide() + (pItemIcon->IsVisible() ? pItemIcon->GetWide() : 0);
		int nCashWide = pCashIcon->GetWide();
		if (m_nCreditsType == 0)
		{
			nCashWide = 0;
		}
		pCashIcon->SetPos(GetWide() * 0.5f - nRewardsWide * 0.5f, pCashIcon->GetYPos());
		pItemIcon->SetPos(pCashIcon->GetXPos() + pCashIcon->GetWide(), pItemIcon->GetYPos());
	}

	EditablePanel* pTooltipRegion = FindControl< EditablePanel >("ToolTipRegion");
	if (pTooltipRegion)
	{
		pTooltipRegion->InstallMouseHandler(m_pSelectButton, true, true);
		if (Q_strlen(m_pszTooltipText) > 0)
		{
			pTooltipRegion->SetTooltip(GetSoloPanel()->GetTextTooltip(), NULL);
			pTooltipRegion->SetDialogVariable("tiptext", m_pszTooltipText);
		}
	}
}

void CSoloNodePanel::DrawNode(float flXPos,
	float flYPos,
	bool bPurchased,
	const Color& colorActive,
	const Color& colorBonus,
	const Color& colorInactive,
	float flScale) const
{
	Color colorBlack(0, 0, 0, 255);

	const float flNow = Plat_FloatTime();
	const float flSmallRadius = YRES(node_small_radius) * flScale;
	const float flMediumRadius = YRES(node_medium_radius) * flScale;
	const float flLargeRadius = YRES(node_large_radius) * flScale;

	// Black background to start
	DrawFilledColoredCircle(flXPos, flYPos, flMediumRadius + YRES(1), colorBlack);

	int nNumSegments = m_nCompletionSegments;

	float flGap = nNumSegments == 1 ? 0.f : 2.f;		// Gap between segment

	auto lambdaPaintCompletionSegment = [&](int nSegment, const Color& color)
	{
		float flStart = (float)nSegment / (float)nNumSegments * 360.f + flGap;
		float flEnd = (float)(nSegment + 1) / (float)nNumSegments * 360.f - flGap;
		DrawFilledColoredCircleSegment(flXPos, flYPos, flMediumRadius, flMediumRadius - YRES(2), color, flStart, flEnd);
	};

	for (int i = 0; i < nNumSegments; ++i)
	{
		if (i >= m_nCompletionState)
		{
			lambdaPaintCompletionSegment(i, colorInactive);
		}
		else
		{
			lambdaPaintCompletionSegment(i, colorActive);
		}
	}
}

void CSoloNodePanel::Paint()
{
	Color colorActive = vgui::scheme()->GetIScheme(GetScheme())->GetColor("QuestMap_ActiveOrange", Color(255, 255, 255, 255));
	Color colorInactive = vgui::scheme()->GetIScheme(GetScheme())->GetColor("QuestMap_InactiveGrey", Color(255, 255, 255, 255));

	bool bBrighten = m_eMapState == MOUSE_OVER || m_eMapState == SELECTED;

	if (bBrighten)
	{
		// Brighten up a little when selected and moused over
		int nGlow = node_mouseover_brightness;
		BrigthenColor(colorActive, nGlow);
		BrigthenColor(colorInactive, nGlow);
	}

	const float x = (GetWide() * 0.5f) - 0.5f;
	const float y = (GetTall() * 0.5f) - 0.5f;

	const float flSmallRadius = node_small_radius;
	const float flMediumRadius = node_medium_radius;
	const float flLargeRadius = node_large_radius;

	float flScale = 1.f;

	if (m_eMapState == MOUSE_OVER)
	{
		const float flSelectScalePulse = 1.2f;
		flScale *= RemapValClamped(Plat_FloatTime() - m_flMapStateEnterTime, 0.2f, 0.0f, 1.0f, flSelectScalePulse);
	}

	// Draw the node
	DrawNode(x, y, true, colorActive, colorActive, colorInactive, flScale);
}

void CSoloNodePanel::OnCursorEntered()
{
	if (m_pSelectButton->IsCursorOver())
	{
		//PostActionSignal(new KeyValues("NodeCursorEntered", "node", m_msgLocalState.defindex()));
		m_bOverSelected = true;

		EnterMapState(MOUSE_OVER);
	}
}

void CSoloNodePanel::OnCursorExited()
{
	if (!m_pSelectButton->IsCursorOver() && m_eMapState == MOUSE_OVER)
	{
		m_bOverSelected = false;
		//PostActionSignal(new KeyValues("NodeCursorExited", "node", m_msgLocalState.defindex()));

		EnterMapState(NEUTRAL);
	}
}


void CSoloNodePanel::OnMousePressed(MouseCode code)
{
	if (!m_pSelectButton->IsCursorOver())
	{
		CallParentFunction(new KeyValues("MousePressed", "code", code));
		return;
	}

	BaseClass::OnMousePressed(code);
}

void CSoloNodePanel::OnMouseDoublePressed(MouseCode code)
{
	if (!m_pSelectButton->IsCursorOver())
	{
		CallParentFunction(new KeyValues("MousePressed", "code", code));
		return;
	}

	BaseClass::OnMouseDoublePressed(code);
}

void CSoloNodePanel::OnThink()
{
	BaseClass::OnThink();

}


void CSoloNodePanel::OnCommand(const char* pCommand)
{
	if (FStrEq(pCommand, "selected"))
	{
		// Play a sound when the cursor enters us
		if (input()->IsKeyDown(KEY_LCONTROL))
		{
			//CMsgProtoDefID msgDefId;
			//msgDefId.set_type(DEF_TYPE_QUEST_MAP_NODE);
			//msgDefId.set_defindex(m_msgLocalState.defindex());
		}
		else
		{
			IScriptVM* pVM = g_pScriptVM;
			ScriptVariant_t varTable;
			pVM->CreateTable(varTable);
			pVM->SetValue(varTable, "nodeID", m_nNodeID);
			RunScriptHook("node_selected", varTable);

			//PostActionSignal(new KeyValues("NodeSelected", "node", m_msgLocalState.defindex()));
			EnterMapState(SELECTED);
		}
		return;
	}
}

void CSoloNodePanel::EnterMapState(EMapState eMapState)
{
	if (m_eMapState == eMapState)
		return;

	m_eMapState = eMapState;

	switch (eMapState)
	{
	case MOUSE_OVER:
	{
		if (!m_bIsLocked)
		{
			PlaySoundEntry("CYOA.PingAvailable");
		}
		else if (m_bIsIngame)
		{
			PlaySoundEntry("CYOA.PingInProgress");
		}
		else
		{
			PlaySoundEntry("CYOA.NodeLocked");
		}
	}
	break;
	}

	m_flMapStateEnterTime = Plat_FloatTime();
}

