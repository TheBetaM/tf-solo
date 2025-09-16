HomePos <- self.GetOrigin()
targetDir <- 0
targetPos <- HomePos + Vector(0,100,0)
if (RandomInt(0, 1) == 0)
{
	targetPos = HomePos + Vector(0,-100,0)
	targetDir = 1
}

::BotThink <- function()
{
	local locomotion = self.GetLocomotionInterface()
	locomotion.SetDesiredSpeed(50.0)
	locomotion.FaceTowards(targetPos)
	locomotion.Approach(targetPos, 1.0)
	
	local fromTop = Vector(self.GetOrigin().x,self.GetOrigin().y,0)
	local toTop = Vector(targetPos.x,targetPos.y,0)
	local dist = fromTop- toTop;
	if (dist.Length() < 3.0)
	{
		self.ResetSequence(self.LookupSequence("idle"))
		self.SetPlaybackRate(1.0)
		if (targetDir == 0)
		{
			targetPos = HomePos + Vector(0,-100,0)
			targetDir = 1
		}
		else
		{
			targetPos = HomePos + Vector(0,100,0)
			targetDir = 0
		}
	}
	
	self.StudioFrameAdvance()
	self.DispatchAnimEvents(self)
	
	return 0.1
}
	
AddThinkToEnt(self, "BotThink")
self.SetPlaybackRate(1.0)
self.ResetSequence(self.LookupSequence("idle"))
self.SetPlaybackRate(1.0)
self.AcceptInput("SetStepHeight", "18", null, null)


