#include "tf_controls.h"
#include "tf_imagepanel.h"
#include "hud_controlpointicons.h"
#include "GameEventListener.h"
#include "tf_logic_robot_destruction.h"
#include "tf_time_panel.h"
#include "entity_capture_flag.h"
#include "vscript_client.h"
#include "vscript_utils.h"

class CTFHUDSoloObjectives : public vgui::EditablePanel, public CGameEventListener
{
	DECLARE_CLASS_SIMPLE(CTFHUDSoloObjectives, vgui::EditablePanel );

public:
	CTFHUDSoloObjectives( vgui::Panel *parent, const char *name );
	~CTFHUDSoloObjectives();

	virtual void ApplySettings( KeyValues *inResourceData ) OVERRIDE;
	virtual void ApplySchemeSettings( vgui::IScheme *pScheme ) OVERRIDE;
	virtual void PerformLayout() OVERRIDE;
	virtual bool IsVisible( void ) OVERRIDE;
	virtual void Reset();
	virtual void Think();
	virtual void PaintBackground() OVERRIDE;
	virtual void Paint() OVERRIDE;

	virtual void FireGameEvent( IGameEvent *pEvent ) OVERRIDE;
	virtual void OnCommand( const char* pCommand ) OVERRIDE;

	void ReinitializeEverything();

	const char* GetResFile() { return m_pszResFile; }
	void SetResFile(const char* file);
	void ResetResFile();
	void SyncResFile();

	void ClearAllScriptPanels();
	void RunAnimationScript(const char* pszScript, bool bCanBeCancelled);
	int GetScreenWidth();
	int GetScreenHeight();
	virtual HSCRIPT CreatePanel(HSCRIPT hTable, const char* hParent);
	virtual HSCRIPT CreatePanelRoot(HSCRIPT hTable);
	void ApplyPanelSettings(HSCRIPT hPanelHandle, HSCRIPT hTable);
	virtual HSCRIPT CreatePanelInternal(HSCRIPT hTable, Panel* hParent);
	virtual HSCRIPT FindPanelRoot(const char* hPanel);
	virtual HSCRIPT FindPanel(HSCRIPT hPanelRoot, const char* hPanel);
	virtual void AddActionSignalTargetForPanel(HSCRIPT hPanel);
	virtual void DeleteSubPanel(const char* hPanel);

	virtual HSCRIPT GetMatchStatusPanel();
	virtual HSCRIPT GetKothTimersPanel();
	virtual HSCRIPT GetBuildingStatusSpyPanel();
	virtual HSCRIPT GetBuildingStatusEngineerPanel();

	CUtlString m_pszResFile;
	bool m_bHideRealTimer;

private:
	struct ScriptPanelData
	{
		HSCRIPT m_Handle;
		Panel* m_Panel;
		bool m_RootChild;
	};

	CUtlVector< ScriptPanelData > m_scriptPanels;
};


