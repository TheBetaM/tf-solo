TFSOLO.CreditPool <- 0
TFSOLO.CreditLines <- []
TFSOLO.Rewards <- {
	CampaignMain = 100
	CampaignBonus = 150
	CampaignReplay = 20
	Victory = 50	
	Point = 1
	UniqueKill = 10
	
}

TFSOLO.StartResults <- function()
{
	local resultsText = ""
	resultsText += "Total earned: " + TFSOLO.CreditPool
	foreach (a in TFSOLO.CreditLines)
	{
		resultsText += "\n"
		resultsText += a
	}
	
	SetSoloObjectivesResFile("resource/ui/solo/results_credits.res")
	SendGlobalGameEvent("solohud_string", {
		key = "result_text",
		value = resultsText
	})
	
	local gamerules = Entities.FindByClassname(null,"tf_gamerules")
	gamerules.AcceptInput("SoloAddCredits",""+TFSOLO.CreditPool,null,null)
}

TFSOLO.CreditsEventTag <- UniqueString()
getroottable()[TFSOLO.CreditsEventTag] <- {
OnGameEvent_teamplay_round_start = function(params)
{
}
	
OnGameEvent_teamplay_round_win = function(params)
{
}
	
OnGameEvent_teamplay_game_over = function(params)
{
}
	
OnGameEvent_scorestats_accumulated_update = function(_)
{
}
	
OnScriptHook_campaign_mission_over = function(params)
{
	TFSOLO.CreditPool = 0
	TFSOLO.CreditLines = []
	if (params.reward_main)
	{
		TFSOLO.CreditPool += TFSOLO.Rewards.CampaignMain
		TFSOLO.CreditLines.push("+" + TFSOLO.Rewards.CampaignMain + " Main Objective")
	}
	if (params.reward_bonus)
	{
		TFSOLO.CreditPool += TFSOLO.Rewards.CampaignBonus
		TFSOLO.CreditLines.push("+" + TFSOLO.Rewards.CampaignBonus + " Bonus Objective")
	}
	if (!params.reward_main && !params.reward_bonus)
	{
		TFSOLO.CreditPool += TFSOLO.Rewards.CampaignReplay
		TFSOLO.CreditLines.push("+" + TFSOLO.Rewards.CampaignReplay + " Mission Replay")
	}
	
	local PointTally = 0
	foreach (a in GetHumans())
	{
		PointTally += a.GetPoints()
	}
	PointTally = PointTally * TFSOLO.Rewards.Point
	if (PointTally > 0)
	{
		TFSOLO.CreditPool += PointTally
		TFSOLO.CreditLines.push("+" + PointTally + " Points")
	}
	
	if (TFSOLO.CreditPool != 0)
	{
		TFSOLO.StartResults()
	}
}
	
OnScriptHook_solo_mission_over = function(params)
{
	if (TFSOLO.CanRetry && !params.playerWon)
	{
		return
	}
	TFSOLO.CreditPool = 0
	TFSOLO.CreditLines = []
	if (params.playerWon)
	{
		TFSOLO.CreditPool += TFSOLO.Rewards.Victory
		TFSOLO.CreditLines.push("+" + TFSOLO.Rewards.Victory + " Victory")
	}
	
	local PointTally = 0
	foreach (a in GetHumans())
	{
		PointTally += a.GetPoints()
	}
	PointTally = PointTally * TFSOLO.Rewards.Point
	if (PointTally > 0)
	{
		TFSOLO.CreditPool += PointTally
		TFSOLO.CreditLines.push("+" + PointTally + " Points")
	}
	
	if (TFSOLO.CreditPool != 0)
	{
		TFSOLO.StartResults()
	}
}

}
__CollectGameEventCallbacks(getroottable()[TFSOLO.CreditsEventTag])