//========= Copyright Valve Corporation, All rights reserved. ============//
//
// Purpose: Exposes bsp tools to game for e.g. workshop use
//
// $NoKeywords: $
//===========================================================================//

#include "../utils/common/bsplib.h"
#include "ibsppack.h"
#include <tier1/utlhashtable.h>

#ifdef CLIENT_DLL
// Loads bsppack module (IBSPPack) and calls RepackBSP()
bool BSP_SyncRepack( const char *pszInputMapFile,
                     const char *pszOutputMapFile,
                     IBSPPack::eRepackBSPFlags eRepackFlags = (IBSPPack::eRepackBSPFlags) ( IBSPPack::eRepackBSP_CompressLumps |
                                                                                            IBSPPack::eRepackBSP_CompressPackfile ) );

// Helper to spawn a background thread that runs SyncRepack
void BSP_BackgroundRepack( const char *pszInputMapFile,
                           const char *pszOutputMapFile,
                           IBSPPack::eRepackBSPFlags eRepackFlags = (IBSPPack::eRepackBSPFlags) ( IBSPPack::eRepackBSP_CompressLumps |
                                                                                                  IBSPPack::eRepackBSP_CompressPackfile ) );
#endif // CLIENT_DLL

int g_bspCacheJobsRunning = 0;

class BackgroundBSPCacheThread : public CThread, public CAutoGameSystemPerFrame
{
public:
	BackgroundBSPCacheThread(const char* pszInputFile)
		: m_strInput(pszInputFile)
	{
		g_bspCacheJobsRunning++;
	}

	bool BSP_CacheAssets(const char* pszInputMapFile);

	// CThread job - returns 0 for success
	virtual int Run() OVERRIDE
	{
		return BSP_CacheAssets(m_strInput) ? 0 : 1;
	}

	// GameSystem
	virtual const char* Name(void) OVERRIDE { return "BackgroundBSPCacheThread"; }

	// Runs on main thread
	void CheckFinished()
	{
		if (!IsAlive())
		{
			// Thread finished
			if (GetResult() != 0)
			{
				Warning("Map %s cache thread failed :(\n", m_strInput);
			}

			g_bspCacheJobsRunning--;
			// AutoGameSystem deregisters itself on destruction, we're done
			delete this;
		}
	}

	void AddFile(const char* key, const char* value)
	{
		m_FileTable.Insert(key, value);
	}

#ifdef CLIENT_DLL
	virtual void Update(float frametime) OVERRIDE { CheckFinished(); }
#else // GAME DLL
	virtual void FrameUpdatePostEntityThink() OVERRIDE { CheckFinished(); }
#endif

	CUtlHashtable<const char*, const char*> m_FileTable;
private:
	const char* m_strInput;
};

// Remove an asset from BSP cache.
void BSP_RemoveAssetFromCache(const char* pszAsset);

// Clear out the BSP cache;
void BSP_ClearCache();
