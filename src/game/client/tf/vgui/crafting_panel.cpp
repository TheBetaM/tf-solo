//========= Copyright Valve Corporation, All rights reserved. ============//
//
// Purpose:
//
//=============================================================================//


#include "cbase.h"
#include "crafting_panel.h"
#include "vgui/ISurface.h"
#include "vgui/ISystem.h"
#include "c_tf_player.h"
#include "gamestringpool.h"
#include "iclientmode.h"
#include "tf_item_inventory.h"
#include "ienginevgui.h"
#include <vgui/ILocalize.h>
#include "vgui_controls/TextImage.h"
#include "vgui_controls/CheckButton.h"
#include "vgui_controls/ComboBox.h"
#include <vgui_controls/TextEntry.h>
#include "vgui/IInput.h"
#include "gcsdk/gcclient.h"
#include "gcsdk/gcclientjob.h"
#include "character_info_panel.h"
#include "charinfo_loadout_subpanel.h"
#include "econ_item_system.h"
#include "econ_item_constants.h"
#include "tf_hud_notification_panel.h"
#include "tf_hud_chat.h"
#include "c_tf_gamestats.h"
#include "confirm_dialog.h"
#include "econ_notifications.h"
#include "gc_clientsystem.h"
#include "charinfo_loadout_subpanel.h"
#include "item_selection_criteria.h"
#include "rtime.h"
#include "c_tf_freeaccount.h"
#include "tf_playermodelpanel.h"
#include "KeyValues.h"
#include "filesystem.h"

// memdbgon must be the last include file in a .cpp file!!!
#include <tier0/memdbgon.h>

ConVar tf_explanations_craftingpanel( "tf_explanations_craftingpanel", "0", FCVAR_ARCHIVE, "Whether the user has seen explanations for this panel." );

struct recipefilter_data_t
{
	const char *pszTooltipString;
	const char *pszButtonImage;
	const char *pszButtonImageMouseover;
};
recipefilter_data_t g_RecipeFilters[NUM_RECIPE_CATEGORIES] =
{
	{ "#TFSOLO_Bestiary_Map",	"crafticon_crafting_items", "crafticon_crafting_items_over" },			// RECIPE_CATEGORY_CRAFTINGITEMS,
	{ "#TFSOLO_Bestiary_Common", "crafticon_common_items", "crafticon_common_items_over" },		// RECIPE_CATEGORY_COMMONITEMS,
	{ "#TFSOLO_Bestiary_Rare", "crafticon_rare_items", "crafticon_rare_items_over" },			// RECIPE_CATEGORY_RAREITEMS,
	{ "#TFSOLO_Bestiary_Special", "crafticon_special_blueprints", "crafticon_special_blueprints_over" }			// RECIPE_CATEGORY_SPECIAL,
};

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
wchar_t *LocalizeRecipeStringPiece( const char *pszString, wchar_t *pszConverted, int nConvertedSizeInBytes ) 
{
	if ( !pszString )
		return L"";

	if ( pszString[0] == '#' )
		return g_pVGuiLocalize->Find( pszString );

	g_pVGuiLocalize->ConvertANSIToUnicode( pszString, pszConverted, nConvertedSizeInBytes );
	return pszConverted;
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void SetItemPanelToRecipe( CItemModelPanel *pPanel, const CEconCraftingRecipeDefinition *pRecipeDef, bool bShowName )
{
	wchar_t	wcTmpName[512];
	wchar_t	wcTmpDesc[512];
	int iNegAttribsBegin = 0;

	Q_wcsncpy(wcTmpName, g_pVGuiLocalize->Find("#Craft_Recipe_Custom"), sizeof(wcTmpName));
	Q_wcsncpy(wcTmpDesc, g_pVGuiLocalize->Find("#TFSOLO_Bestiary_DescGeneric"), sizeof(wcTmpDesc));
	iNegAttribsBegin = Q_wcslen(wcTmpDesc);

	pPanel->SetAttribOnly( !bShowName );
	pPanel->SetTextYPos( 0 );
	pPanel->SetItem( NULL );
	pPanel->SetNoItemText( wcTmpName, wcTmpDesc, iNegAttribsBegin );
	pPanel->InvalidateLayout(true);
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void PositionMouseOverPanelForRecipe( vgui::Panel *pScissorPanel, vgui::Panel *pRecipePanel, vgui::ScrollableEditablePanel *pRecipeScroller, CItemModelPanel *pMouseOverItemPanel )
{
	int x,y;
	vgui::ipanel()->GetAbsPos( pRecipePanel->GetVPanel(), x, y );
	int xs,ys;
	vgui::ipanel()->GetAbsPos( pMouseOverItemPanel->GetParent()->GetVPanel(), xs, ys );
	x -= xs;
	y -= ys;

	int iXPos = (x + (pRecipePanel->GetWide() * 0.5)) - (pMouseOverItemPanel->GetWide() * 0.5);
	int iYPos = (y + pRecipePanel->GetTall());

	// Make sure the popup stays onscreen.
	if ( iXPos < 0 )
	{
		iXPos = 0;
	}
	else if ( (iXPos + pMouseOverItemPanel->GetWide()) > pMouseOverItemPanel->GetParent()->GetWide() )
	{
		iXPos = pMouseOverItemPanel->GetParent()->GetWide() - pMouseOverItemPanel->GetWide();
	}

	if ( iYPos < 0 )
	{
		iYPos = 0;
	}
	else if ( (iYPos + pMouseOverItemPanel->GetTall() + YRES(32)) > pMouseOverItemPanel->GetParent()->GetTall() )
	{
		// Move it up above our item
		iYPos = y - pMouseOverItemPanel->GetTall() - YRES(4);
	}

	pMouseOverItemPanel->SetPos( iXPos, iYPos );
	pMouseOverItemPanel->SetVisible( true );
}


//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
CCraftingPanel::CCraftingPanel( vgui::Panel *parent, const char *panelName ) : CBaseLoadoutPanel( parent, panelName )
{
	m_pRecipeListContainer = new vgui::EditablePanel( this, "recipecontainer" );
	m_pRecipeListContainerScroller = new vgui::ScrollableEditablePanel( this, m_pRecipeListContainer, "recipecontainerscroller" );
	m_pSelectedRecipeContainer = new vgui::EditablePanel( this, "selectedrecipecontainer" );
	m_pRecipeButtonsKV = NULL;
	m_pRecipeFilterButtonsKV = NULL;
	m_bEventLogging = false;
	m_iCraftingAttempts = 0;
	m_iRecipeCategoryFilter = RECIPE_CATEGORY_COMMONITEMS;
	m_iCurrentlySelectedRecipe = "";
	CleanupPostCraft( true );

	m_pToolTip = new CTFTextToolTip( this );
	m_pToolTipEmbeddedPanel = new vgui::EditablePanel( this, "TooltipPanel" );
	m_pToolTipEmbeddedPanel->SetKeyBoardInputEnabled( false );
	m_pToolTipEmbeddedPanel->SetMouseInputEnabled( false );
	m_pToolTip->SetEmbeddedPanel( m_pToolTipEmbeddedPanel );
	m_pToolTip->SetTooltipDelay( 0 );

	m_pSelectionPanel = NULL;
	m_iSelectingForSlot = 0;

	m_pCraftButton = NULL;

	m_pPlayerModelPanel = m_pSelectedRecipeContainer->FindControl<CTFPlayerModelPanel>("classmodelpanel", false);

	m_presetsKV = new KeyValues("bot_presets");
	if (!m_presetsKV->LoadFromFile(g_pFullFileSystem, "cfg/bot_presets.txt", "GAME"))
	{
		Msg("Unable to parse bot_presets.txt into keyvalues.\n");
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
CCraftingPanel::~CCraftingPanel( void )
{
	if ( m_pRecipeButtonsKV )
	{
		m_pRecipeButtonsKV->deleteThis();
		m_pRecipeButtonsKV = NULL;
	}
	if ( m_pRecipeFilterButtonsKV )
	{
		m_pRecipeFilterButtonsKV->deleteThis();
		m_pRecipeFilterButtonsKV = NULL;
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::ApplySchemeSettings( vgui::IScheme *pScheme )
{
	LoadControlSettings( GetResFile() );

	BaseClass::ApplySchemeSettings( pScheme );

	m_pRecipeListContainerScroller->GetScrollbar()->SetAutohideButtons( true );
	m_pCraftButton = dynamic_cast<CExButton*>( m_pSelectedRecipeContainer->FindChildByName("CraftButton") );
	if ( m_pCraftButton )
	{
		m_pCraftButton->AddActionSignalTarget( this );
	}
	m_pPlayerModelPanel = m_pSelectedRecipeContainer->FindControl<CTFPlayerModelPanel>("classmodelpanel", false);

	CreateRecipeFilterButtons();
	UpdateRecipeFilter();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::ApplySettings( KeyValues *inResourceData )
{
	BaseClass::ApplySettings( inResourceData );

	KeyValues *pItemKV = inResourceData->FindKey( "recipebuttons_kv" );
	if ( pItemKV )
	{
		if ( m_pRecipeButtonsKV )
		{
			m_pRecipeButtonsKV->deleteThis();
		}
		m_pRecipeButtonsKV = new KeyValues("recipebuttons_kv");
		pItemKV->CopySubkeys( m_pRecipeButtonsKV );
	}
	
	KeyValues *pButtonKV = inResourceData->FindKey( "recipefilterbuttons_kv" );
	if ( pButtonKV )
	{
		if ( m_pRecipeFilterButtonsKV )
		{
			m_pRecipeFilterButtonsKV->deleteThis();
		}
		m_pRecipeFilterButtonsKV = new KeyValues("recipefilterbuttons_kv");
		pButtonKV->CopySubkeys( m_pRecipeFilterButtonsKV );
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::PerformLayout( void ) 
{
	BaseClass::PerformLayout();

	// Need to lay these out before we start making item panels inside them
	m_pRecipeListContainer->InvalidateLayout( true );
	m_pRecipeListContainerScroller->InvalidateLayout( true );

	// Position the recipe filters
	FOR_EACH_VEC( m_pRecipeFilterButtons, i )
	{
		if ( m_pRecipeFilterButtonsKV )
		{
			m_pRecipeFilterButtons[i]->ApplySettings( m_pRecipeFilterButtonsKV );
			m_pRecipeFilterButtons[i]->InvalidateLayout();
		} 

		int iButtonW, iButtonH;
		m_pRecipeFilterButtons[i]->GetSize( iButtonW, iButtonH );

		int iXPos = (GetWide() * 0.5) + m_iFilterOffcenterX + ((iButtonW + m_iFilterDeltaX) * i);
		int iYPos = m_iFilterYPos;// + ((iButtonH + m_iFilterDeltaY) * i);
		m_pRecipeFilterButtons[i]->SetPos( iXPos, iYPos );
	}

	// Position the recipe buttons
	for ( int i = 0; i < m_pRecipeButtons.Count(); i++ )
	{
		if ( m_pRecipeButtonsKV )
		{
			m_pRecipeButtons[i]->ApplySettings( m_pRecipeButtonsKV );
			m_pRecipeButtons[i]->InvalidateLayout();
		} 

		int iYDelta = m_pRecipeButtons[0]->GetTall() + YRES(2);

		// Once we've setup our first item, we know how large to make the container
		if ( i == 0 )
		{
			m_pRecipeListContainer->SetSize( m_pRecipeListContainer->GetWide(), iYDelta * m_pRecipeButtons.Count() );
		}

		int x,y;
		m_pRecipeButtons[i]->GetPos( x,y );
		m_pRecipeButtons[i]->SetPos( x, (iYDelta * i) );
	}

	// Now that the container has been sized, tell the scroller to re-evaluate
	m_pRecipeListContainerScroller->InvalidateLayout();
	m_pRecipeListContainerScroller->GetScrollbar()->InvalidateLayout();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::CreateRecipeFilterButtons( void )
{
	for ( int i = 0; i < NUM_RECIPE_CATEGORIES; i++ )
	{
		if ( m_pRecipeFilterButtons.Count() <= i )
		{
			CImageButton *pNewButton = new CImageButton( this, g_RecipeFilters[i].pszTooltipString );
			m_pRecipeFilterButtons.AddToTail( pNewButton );
		}

		m_pRecipeFilterButtons[i]->SetInactiveImage( g_RecipeFilters[i].pszButtonImage );
		m_pRecipeFilterButtons[i]->SetActiveImage( g_RecipeFilters[i].pszButtonImageMouseover );
		m_pRecipeFilterButtons[i]->SetTooltip( m_pToolTip, g_RecipeFilters[i].pszTooltipString );
		const char *pszCommand = VarArgs("selectfilter%d", i );
		m_pRecipeFilterButtons[i]->SetCommand( pszCommand );
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::UpdateRecipeFilter( void )
{
	int iMatchingRecipes = 0;
	m_iCurrentlySelectedRecipe = "";
	m_iCurrentRecipeTotalInputs = 0;
	m_iCurrentRecipeTotalOutputs = 0;

	FOR_EACH_VEC( m_pRecipeFilterButtons, i )
	{
		bool bForceDepressed = ( i == m_iRecipeCategoryFilter );
		m_pRecipeFilterButtons[i]->ForceDepressed( bForceDepressed );
	}

	// Loop through bot presets
	auto key = m_presetsKV->GetFirstSubKey();
	while (key)
	{
		if (V_strcmp(key->GetName(), "version"))
		{
			auto rarity = key->GetInt("Rarity", 1);
			if (rarity == m_iRecipeCategoryFilter)
			{
				//wchar_t	wTemp[256];
				//g_pVGuiLocalize->ConstructString_safe(wTemp, g_pVGuiLocalize->Find(key->GetString("Name", "Bot")), 1);
				SetButtonToRecipe(iMatchingRecipes, key->GetName(), key->GetString("Name", "Bot"));
				iMatchingRecipes++;
			}
		}
		key = key->GetNextKey();
	}

	// Delete excess buttons
	for ( int i = m_pRecipeButtons.Count() - 1; i >= iMatchingRecipes; i-- )
	{
		m_pRecipeButtons[i]->MarkForDeletion();
		m_pRecipeButtons.Remove( i	);
	}

	// Move the scrollbar to the top
	m_pRecipeListContainerScroller->GetScrollbar()->SetValue( 0 );	

	UpdateSelectedRecipe( true );
	InvalidateLayout();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::OnCancelSelection( void )
{
	if ( m_pSelectionPanel )
	{
		m_pSelectionPanel->SetVisible( false );
	}

	CloseCraftingStatusDialog();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::OnSelectionReturned( KeyValues *data )
{
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::OnShowPanel( bool bVisible, bool bReturningFromArmory )
{
	if ( bVisible )
	{
		if ( m_pSelectionPanel )
		{
			m_pSelectionPanel->SetVisible( false );
		}

		if (m_presetsKV)
		{
			m_presetsKV->deleteThis();
		}
		m_presetsKV = new KeyValues("bot_presets");
		if (!m_presetsKV->LoadFromFile(g_pFullFileSystem, "cfg/bot_presets.txt", "GAME"))
		{
			Msg("Unable to parse bot_presets.txt into keyvalues.\n");
		}

		memset( m_InputItems, 0, sizeof(m_InputItems) );
		memset( m_ItemPanelCriteria, 0, sizeof(m_ItemPanelCriteria) );
		m_iCurrentlySelectedRecipe = "";
		m_iCurrentRecipeTotalInputs = 0;
		m_iCurrentRecipeTotalOutputs = 0;
		UpdateRecipeFilter();
	}
	else
	{
		CloseCraftingStatusDialog();
		vgui::ivgui()->RemoveTickSignal( GetVPanel() );
	}

	BaseClass::OnShowPanel( bVisible, bReturningFromArmory );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::OnClosing()
{
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCraftingPanel::PositionItemPanel( CItemModelPanel *pPanel, int iIndex )
{
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCraftingPanel::UpdateRecipeItems( bool bClearInputItems )
{
	if ( bClearInputItems )
	{
		memset( m_InputItems, 0, sizeof(m_InputItems) );
	}

	memset( m_ItemPanelCriteria, 0, sizeof(m_ItemPanelCriteria) );
	m_iCurrentRecipeTotalInputs = 0;
	m_iCurrentRecipeTotalOutputs = 0;

	if ( m_iCurrentlySelectedRecipe == "" )
		return;

	// Now check to see if they've got the right items in there
	UpdateCraftButton();
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCraftingPanel::UpdateCraftButton( void )
{
	if ( m_pCraftButton )
	{
		if (m_iCurrentlySelectedRecipe == "")
		{
			if (m_pPlayerModelPanel)
			{
				m_pPlayerModelPanel->SetVisible(false);
			}
			m_pCraftButton->SetVisible(false);
			m_pCraftButton->SetEnabled(false);
		}
		else
		{
			if (m_pPlayerModelPanel)
			{
				UpdatePlayerModelPanel();
				m_pPlayerModelPanel->SetVisible(true);
			}
			m_pCraftButton->SetVisible(true);
			m_pCraftButton->SetEnabled(true);
		}
	}
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCraftingPanel::UpdatePlayerModelPanel(void)
{
	if (!m_pPlayerModelPanel)
		return;

	auto key = m_presetsKV->FindKey(m_iCurrentlySelectedRecipe);
	m_pPlayerModelPanel->ClearCarriedItems();
	if (key->FindKey("Class"))
	{
		int iClassIndex = GetClassIndexFromString(key->GetString("Class"));
		if (key->FindKey("Robot") && g_pFullFileSystem->FileExists(g_szBotModels[iClassIndex]))
		{
			m_pPlayerModelPanel->SetToPlayerClass(iClassIndex, true, g_szBotModels[iClassIndex]);
		}
		else if (key->FindKey("Model") && g_pFullFileSystem->FileExists(key->GetString("Model")))
		{
			m_pPlayerModelPanel->SetToPlayerClass(iClassIndex, true, key->GetString("Model"));
		}
		else if (key->FindKey("ModelStatic") && g_pFullFileSystem->FileExists(key->GetString("ModelStatic")))
		{
			m_pPlayerModelPanel->SetToPlayerClass(iClassIndex, true, key->GetString("ModelStatic"));
		}
		else
		{
			m_pPlayerModelPanel->SetToPlayerClass(iClassIndex, true);
		}
	}
	if (key->FindKey("Team"))
	{
		m_pPlayerModelPanel->SetTeam(key->GetInt("Team"));
	}
	else
	{
		m_pPlayerModelPanel->SetTeam(RandomInt(2,3));
	}
	auto kItems = key->FindKey("Items");
	if (kItems)
	{
		FOR_EACH_SUBKEY(kItems, kItem)
		{
			auto itemName = kItem->GetName();
			auto def = GetItemSchema()->GetItemDefinitionByName(itemName);
			if (def)
			{
				CEconItemView* pItemView = new CEconItemView;
				CEconItem* pItem = new CEconItem;
				pItem->SetItemID(def->GetDefinitionIndex());
				pItem->m_unAccountID = 0;
				pItem->m_unDefIndex = def->GetDefinitionIndex();
				pItem->m_unLevel = 1;
				pItemView->Init(def->GetDefinitionIndex(), AE_USE_SCRIPT_VALUE, AE_USE_SCRIPT_VALUE, false);
				pItemView->SetItemID(def->GetDefinitionIndex());
				pItemView->SetNonSOEconItem(pItem);
				m_pPlayerModelPanel->AddCarriedItem(pItemView);
			}
		}
	}
	m_pPlayerModelPanel->HoldItemInSlot(0);
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCraftingPanel::JumpToArmory(void)
{
	if (m_iCurrentlySelectedRecipe == "")
		return;
	auto key = m_presetsKV->FindKey(m_iCurrentlySelectedRecipe);
	auto kItems = key->FindKey("Items");
	if (!kItems)
		return;
	EconUI()->OpenEconUI(ECONUI_ARMORY);
	EconUI()->GetArmoryPanel()->ShowCustomList(key->GetString("Name","Bot"), kItems);
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
const char *CCraftingPanel::GetItemTextForCriteria( const CItemSelectionCriteria *pCriteria )
{
	return NULL;
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
CEconItemDefinition *CCraftingPanel::GetItemDefFromCriteria( const CItemSelectionCriteria *pCriteria )
{
	return NULL;
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCraftingPanel::AddNewItemPanel( int iPanelIndex )
{
}

//-----------------------------------------------------------------------------
// Purpose:
//-----------------------------------------------------------------------------
void CCraftingPanel::UpdateModelPanels( void )
{
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::SetButtonToRecipe( int iButton, const char* iDefIndex, const char *pszText )
{
	// Re-use existing buttons, or make new ones if we need more
	CRecipeButton *pRecipeButton = NULL;
	if ( iButton < m_pRecipeButtons.Count() )
	{
		pRecipeButton = m_pRecipeButtons[iButton];
	}
	else
	{
		pRecipeButton = new CRecipeButton( m_pRecipeListContainer, "selectrecipe", "", this, "selectrecipe" );
		if ( m_pRecipeButtonsKV )
		{
			pRecipeButton->ApplySettings( m_pRecipeButtonsKV );
		} 
		pRecipeButton->MakeReadyForUse();
		m_pRecipeButtons.AddToTail( pRecipeButton );
	}

	const char* pszCommand = VarArgs("selectrecipe%d", iButton);
	pRecipeButton->SetCommand(pszCommand);
	pRecipeButton->SetText( pszText );
	pRecipeButton->SetDefIndex( iDefIndex );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::UpdateSelectedRecipe( bool bClearInputItems )
{
	for ( int i = 0; i < m_pRecipeButtons.Count(); i++ )
	{
		bool bSelected = !V_strcmp(m_pRecipeButtons[i]->m_iRecipeDefIndex, m_iCurrentlySelectedRecipe);
		m_pRecipeButtons[i]->ForceDepressed( bSelected );
		m_pRecipeButtons[i]->RecalculateDepressedState();

		if ( bSelected )
		{
			wchar_t wszText[1024];
			m_pRecipeButtons[i]->GetText( wszText, ARRAYSIZE( wszText ) );
			m_pSelectedRecipeContainer->SetDialogVariable( "recipetitle", wszText );

			m_pSelectedRecipeContainer->SetDialogVariable("recipeinputstring", g_pVGuiLocalize->Find("#TFSOLO_Bestiary_DescGeneric"));
		}
	}

	m_pSelectedRecipeContainer->SetVisible(m_iCurrentlySelectedRecipe != "");

	UpdateRecipeItems( bClearInputItems );
	UpdateModelPanels();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::OnCommand( const char *command )
{
	if ( !Q_strnicmp( command, "selectrecipe", 12 ) )
	{
		const char* pszNum = command + 12;
		if (pszNum && pszNum[0])
		{
			int buttonid = atoi(pszNum);
			auto button = m_pRecipeButtons[buttonid];
			m_iCurrentlySelectedRecipe = button->GetDefIndex();
			UpdateSelectedRecipe(true);
		}
		return;
	}
	if ( !Q_strnicmp( command, "selectfilter", 12 ) )
	{
		const char *pszNum = command+12;
		if ( pszNum && pszNum[0] )
		{
			m_iRecipeCategoryFilter = (recipecategories_t)atoi(pszNum);
			UpdateRecipeFilter();
		}

		return;
	}
	else if ( !Q_strnicmp( command, "back", 4 ) )
	{
		PostMessage( GetParent(), new KeyValues("CraftingClosed") );
		return;
	}
	else if ( !Q_strnicmp( command, "craft", 5 ) )
	{
		JumpToArmory();
		return;
	}
	else if ( !Q_stricmp( command, "upgrade" ) )
	{
		return;
	}
	else if ( !Q_stricmp( command, "reloadscheme" ) )
	{
		InvalidateLayout( true, true );
	}

	BaseClass::OnCommand( command );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::OnRecipePanelEntered( vgui::Panel *panel )
{
	CRecipeButton *pRecipePanel = dynamic_cast < CRecipeButton * > ( panel );

	if ( pRecipePanel && IsVisible() && !IsIgnoringItemPanelEnters() )
	{
		SetItemPanelToRecipe( GetMouseOverPanel(), NULL, false );
		PositionMouseOverPanelForRecipe( this, pRecipePanel, m_pRecipeListContainerScroller, GetMouseOverPanel() );
	}
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::OnRecipePanelExited( vgui::Panel *panel )
{
	GetMouseOverPanel()->SetAttribOnly( false );
	GetMouseOverPanel()->SetTextYPos( YRES(20) );
	GetMouseOverPanel()->SetVisible( false );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
int	CCraftingPanel::GetItemPanelIndex( CItemModelPanel *pItemPanel )
{
	return -1;
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::OnItemPanelMousePressed( vgui::Panel *panel )
{
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
static void ConfirmCraft( bool bConfirmed, void* pContext )
{
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
bool CCraftingPanel::CheckForUntradableItems( void )
{
	return true;
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::Craft( void )
{
	return;
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::OnCraftResponse( EGCMsgResponse eResponse, CUtlVector<uint64> *vecCraftedIndices, int iRecipeUsed )
{
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::ShowCraftFinish( void )
{
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::OnTick( void )
{
	BaseClass::OnTick();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingPanel::CleanupPostCraft( bool bClearInputItems )
{
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
ConVar *CCraftingPanel::GetExplanationConVar( void )
{
	return &tf_explanations_craftingpanel;
}

//================================================================================================================================
// NOT CONNECTED TO STEAM WARNING DIALOG
//================================================================================================================================
static vgui::DHANDLE<CCraftingStatusDialog> g_CraftingStatusPanel;

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
CCraftingStatusDialog::CCraftingStatusDialog( vgui::Panel *pParent, const char *pElementName ) : BaseClass( pParent, "CraftingStatusDialog" )
{
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingStatusDialog::ApplySchemeSettings( vgui::IScheme *pScheme )
{
	BaseClass::ApplySchemeSettings( pScheme );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingStatusDialog::OnCommand( const char *command )
{
	BaseClass::OnCommand( command );
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingStatusDialog::OnTick( void )
{
	BaseClass::OnTick();
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingStatusDialog::UpdateSchemeForVersion( bool bRecipe )
{
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CCraftingStatusDialog::ShowStatusUpdate( bool bAnimateEllipses, bool bAllowClose, bool bShowOnExit )
{
}

//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void SetupCraftingStatusDialog( vgui::Panel *pParent )
{
}

CCraftingStatusDialog *OpenCraftingStatusDialog( vgui::Panel *pParent, const char *pszText, bool bAnimateEllipses, bool bAllowClose, bool bShowOnExit )
{
	return NULL;
}


//-----------------------------------------------------------------------------
// Purpose: 
//-----------------------------------------------------------------------------
void CloseCraftingStatusDialog( void )
{
	if ( g_CraftingStatusPanel )
	{
		g_CraftingStatusPanel->OnCommand( "forceclose" );
	}
}


//-----------------------------------------------------------------------------
// Purpose: GC Msg handler to receive the craft response
//-----------------------------------------------------------------------------
class CGCCraftResponse : public GCSDK::CGCClientJob
{
public:
	CGCCraftResponse( GCSDK::CGCClient *pClient ) : GCSDK::CGCClientJob( pClient ) {}

	virtual bool BYieldingRunGCJob( GCSDK::IMsgNetPacket *pNetPacket )
	{
		GCSDK::CGCMsg<MsgGCStandardResponse_t> msg( pNetPacket );
		return true;
		CUtlVector<uint64> vecCraftedIndices;
		uint16 iItems = 0;
		if ( !msg.BReadUint16Data( &iItems ) )
			return true;
		vecCraftedIndices.SetSize( iItems );
		for ( int i = 0; i < iItems; i++ )
		{
			if( !msg.BReadUint64Data( &vecCraftedIndices[i] ) )
				return true;
		}

		if ( EconUI()->GetCraftingPanel() )
		{
			EconUI()->GetCraftingPanel()->OnCraftResponse( (EGCMsgResponse)msg.Body().m_eResponse, &vecCraftedIndices, msg.Body().m_nResponseIndex );
		}

		//Msg("RECEIVED CGCCraftResponse: %d\n", msg.Body().m_eResponse );
		return true;
	}

};

GC_REG_JOB( GCSDK::CGCClient, CGCCraftResponse, "CGCCraftResponse", k_EMsgGCCraftResponse, GCSDK::k_EServerTypeGCClient );



//-----------------------------------------------------------------------------
// Purpose: GC Msg handler to receive the Golden Wrench broadcast message
//-----------------------------------------------------------------------------
class CGCGoldenWrenchBroadcast : public GCSDK::CGCClientJob
{
public:
	CGCGoldenWrenchBroadcast( GCSDK::CGCClient *pClient ) : GCSDK::CGCClientJob( pClient ) {}

	virtual bool BYieldingRunGCJob( GCSDK::IMsgNetPacket *pNetPacket )
	{
		GCSDK::CProtoBufMsg<CMsgTFGoldenWrenchBroadcast> msg( pNetPacket );
		return true;
		// @todo Tom Bui: should we display this in some other manner?  This gets covered up by the crafting panel.
		CHudNotificationPanel *pNotifyPanel = GET_HUDELEMENT( CHudNotificationPanel );
		if ( pNotifyPanel )
		{
			bool bDeleted = msg.Body().deleted();
			wchar_t szPlayerName[ MAX_PLAYER_NAME_LENGTH ];
			UTIL_GetFilteredPlayerNameAsWChar( CSteamID(), msg.Body().user_name().c_str(), szPlayerName );
			wchar_t szWrenchNumber[16]=L"";
			_snwprintf( szWrenchNumber, ARRAYSIZE( szWrenchNumber ), L"%i", msg.Body().wrench_number() );
			wchar_t szNotification[1024]=L"";
			g_pVGuiLocalize->ConstructString_safe( szNotification, 
											  g_pVGuiLocalize->Find( bDeleted ? "#TF_HUD_Event_GoldenWrench_D": "#TF_HUD_Event_GoldenWrench_C" ), 
											  2, szPlayerName, szWrenchNumber );
			pNotifyPanel->SetupNotifyCustom( szNotification, HUD_NOTIFY_GOLDEN_WRENCH, 10.0f );

			// echo to chat
			CBaseHudChat *pHUDChat = (CBaseHudChat *)GET_HUDELEMENT( CHudChat );
			if ( pHUDChat )
			{
				char szAnsi[1024];
				g_pVGuiLocalize->ConvertUnicodeToANSI( szNotification, szAnsi, sizeof(szAnsi) );

				pHUDChat->Printf( CHAT_FILTER_NONE, "%s", szAnsi );
			}

			// play a sound
			vgui::surface()->PlaySound( bDeleted ? "vo/announcer_failure.mp3" : "vo/announcer_success.mp3" );
		}

		//Msg("RECEIVED CGCCraftResponse: %d\n", msg.Body().m_eResponse );
		return true;
	}

};

GC_REG_JOB( GCSDK::CGCClient, CGCGoldenWrenchBroadcast, "CGCGoldenWrenchBroadcast", k_EMsgGCGoldenWrenchBroadcast, GCSDK::k_EServerTypeGCClient );


//-----------------------------------------------------------------------------
// Purpose: GC Msg handler to receive the Saxxy broadcast message
//-----------------------------------------------------------------------------
class CGSaxxyBroadcast : public GCSDK::CGCClientJob
{
public:
	CGSaxxyBroadcast( GCSDK::CGCClient *pClient ) : GCSDK::CGCClientJob( pClient ) {}

	virtual bool BYieldingRunGCJob( GCSDK::IMsgNetPacket *pNetPacket )
	{
		GCSDK::CProtoBufMsg<CMsgTFSaxxyBroadcast> msg( pNetPacket );
		return true;
		CEconNotification *pNotification = new CEconNotification();
		pNotification->SetText( "#TF_Event_Saxxy_Deleted" );
		pNotification->SetLifetime( 30.0f );

		{
			// Who deleted this?
			wchar_t wszPlayerName[ MAX_PLAYER_NAME_LENGTH ];
			UTIL_GetFilteredPlayerNameAsWChar( CSteamID(), msg.Body().has_user_name() ? msg.Body().user_name().c_str() : NULL, wszPlayerName );
			pNotification->AddStringToken( "owner", wszPlayerName );

			// What category was the Saxxy for?
			char szCategory[MAX_ATTRIBUTE_DESCRIPTION_LENGTH];
			Q_snprintf( szCategory, sizeof( szCategory ), "Replay_Contest_Category%d", msg.Body().category_number() );

			pNotification->AddStringToken( "category", g_pVGuiLocalize->Find( szCategory ) );
		}

		NotificationQueue_Add( pNotification );

		return true;
	}

};

GC_REG_JOB( GCSDK::CGCClient, CGSaxxyBroadcast, "CGSaxxyBroadcast", k_EMsgGCSaxxyBroadcast, GCSDK::k_EServerTypeGCClient );

//-----------------------------------------------------------------------------
// Purpose: GC Msg handler to receive any generic item deletion notification
//-----------------------------------------------------------------------------
class CClientItemBroadcastNotificationJob : public GCSDK::CGCClientJob
{
public:
	CClientItemBroadcastNotificationJob( GCSDK::CGCClient *pClient ) : GCSDK::CGCClientJob( pClient ) {}

	virtual bool BYieldingRunGCJob( GCSDK::IMsgNetPacket *pNetPacket )
	{
		GCSDK::CProtoBufMsg<CMsgGCTFSpecificItemBroadcast> msg( pNetPacket );
		return true;
		CEconNotification *pNotification = new CEconNotification();
		pNotification->SetText( msg.Body().was_destruction() ? "#TF_Event_Item_Deleted" : "#TF_Event_Item_Created" );
		pNotification->SetLifetime( 30.0f );

		// Who deleted this?
		wchar_t wszPlayerName[ MAX_PLAYER_NAME_LENGTH ];
		UTIL_GetFilteredPlayerNameAsWChar( CSteamID(), msg.Body().has_user_name() ? msg.Body().user_name().c_str() : NULL, wszPlayerName );
		pNotification->AddStringToken( "owner", wszPlayerName );

		// What type of item was this?
		const CEconItemDefinition *pItemDef = GetItemSchema()->GetItemDefinition( msg.Body().item_def_index() );
		if ( pItemDef )
		{
			pNotification->AddStringToken( "item_name", g_pVGuiLocalize->Find( pItemDef->GetItemBaseName() ) );

			NotificationQueue_Add( pNotification );
		}

		return true;
	}

};

GC_REG_JOB( GCSDK::CGCClient, CClientItemBroadcastNotificationJob, "CClientItemBroadcastNotificationJob", k_EMsgGCTFSpecificItemBroadcast, GCSDK::k_EServerTypeGCClient );

//-----------------------------------------------------------------------------
// Purpose: GC Msg handler to receive the Saxxy Awarded broadcast message
//-----------------------------------------------------------------------------
class CGSaxxyAwardedBroadcast : public GCSDK::CGCClientJob
{
private:
	// embedded notification for custom trigger
	class CSaxxyAwardedNotification : public CEconNotification
	{
	public:
		CSaxxyAwardedNotification()
		{
			SetSoundFilename( "vo/announcer_success.mp3" );
		}

		virtual EType NotificationType() { return eType_Trigger; }

		virtual void Trigger()
		{
			if ( steamapicontext && steamapicontext->SteamFriends() )
			{
				steamapicontext->SteamFriends()->ActivateGameOverlayToWebPage( "http://www.teamfortress.com/saxxyawards/winners.php" );
			}
			MarkForDeletion();
		}
	};

public:

	CGSaxxyAwardedBroadcast( GCSDK::CGCClient *pClient ) : GCSDK::CGCClientJob( pClient ) {}

	virtual bool BYieldingRunGCJob( GCSDK::IMsgNetPacket *pNetPacket )
	{
		GCSDK::CProtoBufMsg< CMsgSaxxyAwarded > msg( pNetPacket );

		CEconNotification *pNotification = new CSaxxyAwardedNotification();
		pNotification->SetText( "#TF_Event_Saxxy_Awarded" );
		pNotification->SetLifetime( 30.0f );

		{
			// Winners
			CFmtStr1024 strWinners;
			for ( int i = 0; i < msg.Body().winner_names_size(); ++i )
			{
				char szPlayerName[ MAX_PLAYER_NAME_LENGTH ];
				V_strcpy_safe( szPlayerName, msg.Body().winner_names( i ).c_str() );
				UTIL_GetFilteredPlayerName( CSteamID(), szPlayerName );
				strWinners.Append( szPlayerName );
				if ( i + 1 < msg.Body().winner_names_size() )
				{
					strWinners.Append( "\n" );
				}
			}
			wchar_t wszPlayerNames[ 1024 ];
			g_pVGuiLocalize->ConvertANSIToUnicode( strWinners.Access(), wszPlayerNames, sizeof( wszPlayerNames ) );
			pNotification->AddStringToken( "winners", wszPlayerNames );

			// year
			CRTime cTime;
			cTime.SetToCurrentTime();
			cTime.SetToGMT( false );
			locchar_t wszYear[10];
			loc_sprintf_safe( wszYear, LOCCHAR( "%04u" ), cTime.GetYear() );
			pNotification->AddStringToken( "year", wszYear );

			// What category was the Saxxy for?
			char szCategory[MAX_ATTRIBUTE_DESCRIPTION_LENGTH];
			Q_snprintf( szCategory, sizeof( szCategory ), "Replay_Contest_Category%d", msg.Body().category() );
			pNotification->AddStringToken( "category", g_pVGuiLocalize->Find( szCategory ) );
		}

		NotificationQueue_Add( pNotification );

		return true;
	}

};

GC_REG_JOB( GCSDK::CGCClient, CGSaxxyAwardedBroadcast, "CGSaxxyAwardedBroadcast", k_EMsgGCSaxxy_Awarded, GCSDK::k_EServerTypeGCClient );

//-----------------------------------------------------------------------------
// Purpose: GC Msg handler to receive a generic system broadcast message
//-----------------------------------------------------------------------------
class CGCSystemMessageBroadcast : public GCSDK::CGCClientJob
{
public:
	CGCSystemMessageBroadcast( GCSDK::CGCClient *pClient ) : GCSDK::CGCClientJob( pClient ) {}

	virtual bool BYieldingRunGCJob( GCSDK::IMsgNetPacket *pNetPacket )
	{
		CBaseHudChat *pHUDChat = (CBaseHudChat *)GET_HUDELEMENT( CHudChat );
		if ( !pHUDChat )
			return false;

		GCSDK::CProtoBufMsg<CMsgSystemBroadcast> msg( pNetPacket );

		// retrieve the text
		const char *pchMessage = msg.Body().message().c_str();
		wchar_t *pwMessage = g_pVGuiLocalize->Find( pchMessage );
		wchar_t wszConvertedText[2048] = L"";
		if ( pwMessage == NULL )
		{
			g_pVGuiLocalize->ConvertANSIToUnicode( pchMessage, wszConvertedText, sizeof( wszConvertedText ) );
			pwMessage = wszConvertedText;
		}

		Color color( 0xff, 0xcc, 0x33, 255 );
		KeyValuesAD keyValues( "System Message" );
		keyValues->SetWString( "message", pwMessage );
		keyValues->SetColor( "custom_color", color );
		return true;
		// print to chat log
		wchar_t wszLocalizedString[2048] = L"";
		g_pVGuiLocalize->ConstructString_safe( wszLocalizedString, "#Notification_System_Message", keyValues );
		pHUDChat->SetCustomColor( color );
		pHUDChat->Printf( CHAT_FILTER_NONE, "%ls", wszLocalizedString );

		// send to notification
		CEconNotification* pNotification = new CEconNotification();
		pNotification->SetText( "#Notification_System_Message" );
		pNotification->SetKeyValues( keyValues );
		pNotification->SetLifetime( 30.0f );
		pNotification->SetSoundFilename( "ui/system_message_alert.wav" );
		NotificationQueue_Add( pNotification );

		return true;
	}

};

GC_REG_JOB( GCSDK::CGCClient, CGCSystemMessageBroadcast, "CGCSystemMessageBroadcast", k_EMsgGCSystemMessage, GCSDK::k_EServerTypeGCClient );
