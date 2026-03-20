#if !defined( CHOREOSYSTEM_H )
#define CHOREOSYSTEM_H
#ifdef _WIN32
#pragma once
#endif

enum ChoreoLoopMode
{
	CHOREO_LOOP_NONE,
	CHOREO_LOOP_LINEAR,
	CHOREO_LOOP_PINGPONG,
	CHOREO_LOOP_LINEAR_TELEPORT,

	CHOREO_LOOP_MAX,
};

struct PlayerChoreo
{
	uint64_t PlaybackTick;
	bool bReversePlayback;
	bool bIsPlaying;
	bool bIsPaused;
	bool bIsRecording;
	bool bIsBlockingCommands;
	bool bIsInterruptable;
	int iLoopMode;
	const char* pszRecordFile;
	Vector StartOrigin;
	QAngle StartAngles;
	Vector StartVelocity;
	CUtlMap<uint64_t, CUserCmd*>* CmdList;
	CUtlMap<uint64_t, const char*>* ClientCmdList;
	uint64_t TickCount;
	uint64_t RecordStartTick;
};

class CChoreoSystem : public CAutoGameSystemPerFrame
{
public:
	DECLARE_DATADESC();

	CChoreoSystem() : CAutoGameSystemPerFrame( "CChoreoSystem" )
	{
		Q_memset( m_PlayerChoreo, 0, sizeof( m_PlayerChoreo ) );
	}

	virtual void LevelInitPreEntity();
	virtual void LevelShutdownPreEntity();
	void RoundRestart();
	void PrePlayerRunCommand( CBasePlayer* pPlayer, CUserCmd* pUserCmds );
	bool ClientCommand( CBasePlayer* pPlayer, const CCommand& args );
	void Play( int entindex, const char* pszFile, bool bTeleport );
	void Pause( int entindex );
	void Resume( int entindex );
	void Seek( int entindex, int iTick );
	void Stop( int entindex );
	void RecordStart( int entindex, const char* pszFile );
	void RecordStop( int entindex );
	uint64_t GetTick( int entindex );
	uint64_t GetTickCount( int entindex );
	void SetTickCount( int entindex, uint64_t count );
	bool IsPlaying( int entindex );
	bool IsRecording( int entindex );
	bool IsBlockingCommands( int entindex );
	int GetLoopMode( int entindex );
	void SetLoopMode( int entindex, int iLoopMode );
	void SetInterruptable( int entindex, bool bInterrupt );
	void Enqueue( int entindex, const char* pszFile, bool bInterrupt );
	Vector GetStartOrigin( int entindex );
	QAngle GetStartAngles( int entindex );
	Vector GetStartVelocity( int entindex );
	void ResetChoreo( int entindex );

private:
	PlayerChoreo m_PlayerChoreo[MAX_PLAYERS];
};

extern CChoreoSystem g_ChoreoSystem;

#endif