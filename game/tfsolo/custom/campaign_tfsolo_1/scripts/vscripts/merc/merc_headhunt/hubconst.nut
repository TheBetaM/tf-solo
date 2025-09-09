Merc.SceneFiles_Yes <- [
	"scenes/Player/Demoman/low/1037.vcd",
	"scenes/Player/Demoman/low/1038.vcd",
	"scenes/Player/Demoman/low/1039.vcd",
	"scenes/Player/Engineer/low/187.vcd",
	"scenes/Player/Engineer/low/188.vcd",
	"scenes/Player/Engineer/low/189.vcd",
	"scenes/Player/Heavy/low/350.vcd",
	"scenes/Player/Heavy/low/351.vcd",
	"scenes/Player/Heavy/low/352.vcd",
	"scenes/Player/Medic/low/689.vcd",
	"scenes/Player/Medic/low/690.vcd",
	"scenes/Player/Medic/low/691.vcd",
	"scenes/Player/Pyro/low/1558.vcd",
	"scenes/Player/Scout/low/516.vcd",
	"scenes/Player/Scout/low/517.vcd",
	"scenes/Player/Scout/low/518.vcd",
	"scenes/Player/Sniper/low/1767.vcd",
	"scenes/Player/Sniper/low/1768.vcd",
	"scenes/Player/Sniper/low/1769.vcd",
	"scenes/Player/Soldier/low/1350.vcd",
	"scenes/Player/Soldier/low/1220.vcd",
	"scenes/Player/Soldier/low/1221.vcd",
	"scenes/Player/Soldier/low/1219.vcd",
	"scenes/Player/Spy/low/857.vcd",
	"scenes/Player/Spy/low/858.vcd",
	"scenes/Player/Spy/low/859.vcd",
]
Merc.SceneFiles_No <- [
	"scenes/Player/Demoman/low/977.vcd",
	"scenes/Player/Demoman/low/978.vcd",
	"scenes/Player/Demoman/low/979.vcd",
	"scenes/Player/Engineer/low/127.vcd",
	"scenes/Player/Engineer/low/128.vcd",
	"scenes/Player/Engineer/low/129.vcd",
	"scenes/Player/Heavy/low/291.vcd",
	"scenes/Player/Heavy/low/292.vcd",
	"scenes/Player/Heavy/low/293.vcd",
	"scenes/Player/Medic/low/627.vcd",
	"scenes/Player/Medic/low/628.vcd",
	"scenes/Player/Medic/low/629.vcd",
	"scenes/Player/Pyro/low/1507.vcd",
	"scenes/Player/Scout/low/455.vcd",
	"scenes/Player/Scout/low/456.vcd",
	"scenes/Player/Scout/low/457.vcd",
	"scenes/Player/Sniper/low/1694.vcd",
	"scenes/Player/Sniper/low/1695.vcd",
	"scenes/Player/Sniper/low/1696.vcd",
	"scenes/Player/Sniper/low/1782.vcd",
	"scenes/Player/Soldier/low/1159.vcd",
	"scenes/Player/Soldier/low/1161.vcd",
	"scenes/Player/Soldier/low/1160.vcd",
	"scenes/Player/Spy/low/797.vcd",
	"scenes/Player/Spy/low/798.vcd",
	"scenes/Player/Spy/low/799.vcd",
]
Merc.SceneFiles_Left <- [
	"scenes/Player/Demoman/low/917.vcd",
	"scenes/Player/Demoman/low/918.vcd",
	"scenes/Player/Demoman/low/919.vcd",
	"scenes/Player/Engineer/low/73.vcd",
	"scenes/Player/Engineer/low/75.vcd",
	"scenes/Player/Heavy/low/237.vcd",
	"scenes/Player/Heavy/low/238.vcd",
	"scenes/Player/Heavy/low/239.vcd",
	"scenes/Player/Heavy/low/2276.vcd",
	"scenes/Player/Medic/low/571.vcd",
	"scenes/Player/Medic/low/572.vcd",
	"scenes/Player/Medic/low/573.vcd",
	"scenes/Player/Pyro/low/1457.vcd",
	"scenes/Player/Scout/low/398.vcd",
	"scenes/Player/Scout/low/399.vcd",
	"scenes/Player/Scout/low/400.vcd",
	"scenes/Player/Sniper/low/1644.vcd",
	"scenes/Player/Sniper/low/1645.vcd",
	"scenes/Player/Sniper/low/1646.vcd",
	"scenes/Player/Soldier/low/1098.vcd",
	"scenes/Player/Soldier/low/1100.vcd",
	"scenes/Player/Soldier/low/1099.vcd",
	"scenes/Player/Spy/low/746.vcd",
	"scenes/Player/Spy/low/747.vcd",
	"scenes/Player/Spy/low/748.vcd",
]
Merc.SceneFiles_Right <- [
	"scenes/Player/Demoman/low/920.vcd",
	"scenes/Player/Demoman/low/921.vcd",
	"scenes/Player/Demoman/low/922.vcd",
	"scenes/Player/Engineer/low/76.vcd",
	"scenes/Player/Engineer/low/77.vcd",
	"scenes/Player/Engineer/low/78.vcd",
	"scenes/Player/Heavy/low/240.vcd",
	"scenes/Player/Heavy/low/241.vcd",
	"scenes/Player/Heavy/low/242.vcd",
	"scenes/Player/Heavy/low/2275.vcd",
	"scenes/Player/Medic/low/574.vcd",
	"scenes/Player/Medic/low/575.vcd",
	"scenes/Player/Medic/low/576.vcd",
	"scenes/Player/Pyro/low/1460.vcd",
	"scenes/Player/Scout/low/401.vcd",
	"scenes/Player/Scout/low/402.vcd",
	"scenes/Player/Scout/low/403.vcd",
	"scenes/Player/Sniper/low/1647.vcd",
	"scenes/Player/Sniper/low/1648.vcd",
	"scenes/Player/Sniper/low/1649.vcd",
	"scenes/Player/Soldier/low/1103.vcd",
	"scenes/Player/Soldier/low/1101.vcd",
	"scenes/Player/Soldier/low/1102.vcd",
	"scenes/Player/Spy/low/749.vcd",
	"scenes/Player/Spy/low/750.vcd",
	"scenes/Player/Spy/low/751.vcd",
]

enum MercHubTrig
{
	RED_Enter,
	BLU_Enter,
	RED_PCorner,
}

Merc.Bot <- class {
	Name = "Bot"
	Skill = TFBOT_MEDIUM
	Team = TF_TEAM_RED
	Class = TF_CLASS_SCOUT
	Handle = null
	Items = []
	Conds = []
	Attribs = []
	BotAttribs = []
	Flags = 0
	BotWpnFlags = 0
	Preset = "NoPresetGiven"
	SpawnPos = Vector(0,0,0)
	SpawnRot = 0
	AltSpawnPos = Vector(0,0,0)
	AltSpawnRot = 0
	
	constructor (bteam, bskill, pname)
	{
		Preset = pname
		Team = bteam
		Skill = bskill
	}
	
	function Start()
	{
		if (Flags == 1)
		{
			return
		}
		if (Team == TF_TEAM_RED)
			ToConsole("tf_bot_add preset "+Preset+" red "+TFBOT_SKILLS[Skill]+"")
		else
			ToConsole("tf_bot_add preset "+Preset+" blue "+TFBOT_SKILLS[Skill]+"")
	}
	
	function OnSpawn(player)
	{
		Handle = player
		if (Flags == 2)
		{
			player.Teleport(true, AltSpawnPos, true, QAngle(0, AltSpawnRot, 0), true, Vector(0, 0, 0))
		}
		else
		{
			player.Teleport(true, SpawnPos, true, QAngle(0, SpawnRot, 0), true, Vector(0, 0, 0))
		}
		player.AddFlag(FL_FROZEN)
	}
	function OnItems(player)
	{
		Handle = player
		foreach (i in Items)
		{
			player.GenerateAndWearItem(i)
		}
	}
	
	function Kick()
	{
		ToConsole("tf_bot_kick \""+Name+"\"")
	}
	
	function UpdateResupply(player)
	{
		Handle = player
		foreach (i in Conds)
		{
			player.AddCond(i)
		}
		foreach (i in BotAttribs)
		{
			player.AddBotAttribute(i)
		}
		if (BotWpnFlags != 0)
		{
			player.AddWeaponRestriction(BotWpnFlags)
		}
	}
	
	
}
Merc.BotGeneric <- class extends Merc.Bot 
{
	constructor (bteam, bskill, bclass, bname)
	{
		Preset = ""
		Name = bname
		Team = bteam
		Skill = bskill
		Class = bclass
	}
	
	function Start()
	{
		if (Flags == 1) return
		if (Team == TF_TEAM_RED)
			ToConsole("tf_bot_add 1 "+Merc.BotClassNames[Class]+" red "+TFBOT_SKILLS[Skill]+" \""+Name+"\" noquota")
		else
			ToConsole("tf_bot_add 1 "+Merc.BotClassNames[Class]+" blue "+TFBOT_SKILLS[Skill]+" \""+Name+"\" noquota")
	}
}

Merc.HubBots <- [
	Merc.BotGeneric(TF_TEAM_RED,  2, TF_CLASS_ENGINEER, Merc.HandlerRED_Name),
	Merc.BotGeneric(TF_TEAM_BLUE, 2, TF_CLASS_SCOUT, Merc.HandlerBLU_Name),
	Merc.Bot(TF_TEAM_RED,  1, "Headhunt_RecruitRED"),
	Merc.Bot(TF_TEAM_BLUE, 2, "Headhunt_RecruitBLU"),
]
Merc.HubBots[0].Conds = [TF_COND_FREEZE_INPUT]
Merc.HubBots[0].BotAttribs = [IGNORE_ENEMIES]
Merc.HubBots[0].SpawnPos = Vector(-1386,0,110)
Merc.HubBots[1].Conds = [TF_COND_FREEZE_INPUT]
Merc.HubBots[1].BotAttribs = [IGNORE_ENEMIES]
Merc.HubBots[1].SpawnPos = Vector(-1871,0,110)

Merc.HubBots[2].Conds = [TF_COND_FREEZE_INPUT,TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED]
Merc.HubBots[2].BotAttribs = [IGNORE_ENEMIES]
Merc.HubBots[2].Flags = 1
Merc.HubBots[2].SpawnPos = Vector(450,930,110)
Merc.HubBots[2].SpawnRot = 270
Merc.HubBots[2].AltSpawnPos = Vector(989,622,110)
Merc.HubBots[2].AltSpawnRot = 180

Merc.HubBots[3].Conds = [TF_COND_FREEZE_INPUT,TF_COND_INVULNERABLE_HIDE_UNLESS_DAMAGED]
Merc.HubBots[3].BotAttribs = [IGNORE_ENEMIES]
Merc.HubBots[3].Flags = 1
Merc.HubBots[3].SpawnPos = Vector(310,-835,110)
Merc.HubBots[3].AltSpawnPos = Vector(989,-634,110)
Merc.HubBots[3].AltSpawnRot = 180

::LOCM_MISSION_STARTING <- "You're heading to"
::LOCM_MISSION_OPEN <- "Hit this\nto select!"
::LOCM_MISSION_CLEARED <- "CLEARED"
::LOCM_MISSION_COMPLETED <- "100%"
::LOCM_MISSION_LOCKED <- "LOCKED"
::LOCM_MISSION_FINAL_LOCKED <- "Complete 10\nmissions for\nRED and BLU\nto unlock!"
::LOCM_MISSION_SELECT <- "Select a mission!"
::LOCM_MISSION_COMPLETION <- "Completion"

::SUB_RED_INTRO_1 <- @"Welcome! I'm glad you could join us.
Folks call me RED Ed, and I'll be handlin' your missions here."
::SUB_RED_INTRO_2 <- @"You can already start a few of them, so get goin'!"
::SUB_RED_M01 <- @"We're movin' out to the Badlands to secure land for a new base.
You'll be joined by the finest C-Team we have available."
::SUB_RED_M02_1 <- @"Here's an unconventional demolition job for you.
There's a ton of garbage left lying around from the victory party on Dustbowl."
::SUB_RED_M02_2 <- @"Though, you weren't invited to that one.
Still, someone's gotta clean that up before BLU comes around."
::SUB_RED_M03 <- @"Our bomb-cart factory is under attack!
We're gonna send in more carts, just don't get in their way or you'll go BOOM!"
::SUB_RED_M04_1 <- @"Those BLU bozos are getting desperate.
Apparently, they're sending a squad to bumrush our Swiftwater facility."
::SUB_RED_M04_2 <- @"Make them regret ever steppin' foot on our turf!"
::SUB_RED_M05_1 <- @"Alright merc, how about goin' on the offensive this time?
We're going to be raidin' BLU's Metalworks base, and we need this to be a show of force."
::SUB_RED_M05_2 <- @"I'm counting on ya!"
::SUB_RED_M06_1 <- @"We here at Reliable Excavation Demolition 
support usin' all kinds of explosives."
::SUB_RED_M06_2 <- @"Just not nukes. No nukes."
::SUB_RED_M06_3 <- @"Today, BLU has threatened our base with a nuclear payload.
That abomination must be disarmed at all costs."
::SUB_RED_M07_1 <- @"There's an outpost on Pelican Peak 
where we setup a counter-intelligence operation."
::SUB_RED_M07_2 <- @"Somehow, BLU had the same idea, so now we need help 
taking over that base. Should be simple, right?"
::SUB_RED_M08_1 <- @"This is bad!
BLU has launched a surprise attack on our Gorge base."
::SUB_RED_M08_2 <- @"We left some automated defenses there, 
but you have to help fend them off! Hurry!"
::SUB_RED_M09_1 <- @"We've been defendin' Badwater Basin for the past 12 hours..."
::SUB_RED_M09_2 <- @"Our boys need reinforcements badly. 
Them BLU folks must be tired by now, right?"
::SUB_RED_M10_1 <- @"This is a joint mission between RED and Mann Co.
BLU has taken over our co-owned beer distillery."
::SUB_RED_M10_2 <- @"You're gonna distract the enemy away from the facility 
while Mr. Hale from Mann Co. cleans house."
::SUB_RED_M10_3 <- @"If everything goes right, beer and business will be back to normal!"
::SUB_RED_M11_1 <- @"We need to secure valuable cargo stuck on a ship in Shark Bay."
::SUB_RED_M11_2 <- @"If livin' in Florida taught me anything, it's to not mess with sharks.
Or any other varmints for that matter."
::SUB_RED_M12_1 <- @"Our folks at Gold Rush have been wiped out, 
and we don't know who or what to expect."
::SUB_RED_M12_2 <- @"I'm sending you in to check the damage
and eliminate anyone that remains. Good luck."
::SUB_RED_M13_1 <- @"Alright, let's begin."
::SUB_RED_M13_2 <- @"Now wait a minute here. You can't just..."
::SUB_RED_M13_3 <- @"Is that you, Louis? Give up man, this merc is gonna work for us!"
::SUB_RED_M13_4 <- @"But we've been through so much together."
::SUB_RED_M13_5 <- @"You're a loser now, just like you were back in college."
::SUB_RED_M13_6 <- @"That's it! I'm fast tracking a full force assault on Viaduct!"
::SUB_RED_M13_7 <- @"Oh yeah? You think yer the only one with the resources to do a raid?"
::SUB_RED_M13_8 <- @"We'll see each other there then!"
::SUB_RED_M13_9 <- @"Well merc, looks like our battle will be your job interview. 
Now, let's go kick his ass!"
::SUB_RED_Weapon_1 <- @"Well done on clearin' out those missions.
We're supplyin' you with a new weapon, if you wanna use it."
::SUB_RED_Weapon_2 <- @"Amazin' job!
You're earned yerself another new weapon."
::SUB_RED_PCorner <- @"What're you doin' in that corner, takin' a leak? 
That's what the other corner is for."
::SUB_RED_FinalMissionOpen <- @"Great job man! You're ready for a full-time gig here at RED.
Your final mission will be a formal job interview, so choose it when yer ready to join us."
::SUB_RED_Ending_1 <- @"Hey, we did good out there, didn't we?
Congrats, you're officially hired."
::SUB_RED_Ending_2 <- @"That said, I think you deserve a vacation.
You know, Brazil is nice this time of year."
::SUB_RED_Choice1_Intro_1 <- @"Hey, I think you could use some additional backup.
Don't be afraid to rely on your team to get things done."
::SUB_RED_Choice1_Intro_2 <- @"What'cha say - Do you want this extra guy on your team?"
::SUB_RED_Choice1_Idle <- @"Just say yes or no."
::SUB_RED_Choice1_Chosen1 <- @"Alright, from now on this guy will tag along with you on missions."
::SUB_RED_Choice1_Chosen2 <- @"Alright, I get it. You can handle things just fine without him."
::SUB_RED_Choice1_NoAnswer <- @"Alright... I'm gonna take that as a no then."
::SUB_RED_Choice1_BadAnswer1 <- @"Huh? What'cha say?"
::SUB_RED_Choice1_BadAnswer2 <- @"What are you sayin'? Can you just say yes or no?"
::SUB_RED_Choice1_BadAnswer3 <- @"Damn it... DO YOU WANT THIS GUY, YES OR NO?"
::SUB_RED_Choice1_Chosen3 <- @"Alright, I'm takin' away all resupply lockers from your missions 
until you learn to behave."
::SUB_RED_Choice2_Intro_1 <- @"We got some new equipment for you to try."
::SUB_RED_Choice2_Intro_2 <- @"You can either take the one on the left to avoid headshots,
or the right one to be safe from backstabs. Left or right?"
::SUB_RED_Choice2_Chosen1 <- @"Good, now Snipers won't be so annoyin' to you."
::SUB_RED_Choice2_Chosen2 <- @"Good, now Spies won't be so annoyin' to you."
::SUB_RED_Choice2_NoAnswer <- @"Can't decide, huh? I'll pick it then. No more backstabs!"
::SUB_RED_Choice2_BadAnswer1 <- @"What are you sayin'? Just pick left or right."
::SUB_RED_Choice2_Chosen3 <- @"I'm gettin' sick of your attitude. From now on, 
you might not feel so lucky with your critical hits."
::SUB_RED_Choice3_Intro_1 <- @"We are upgradin' bases to better support our teams.
You can choose one new thing."
::SUB_RED_Choice3_Intro_2 <- @"The left one will give you a speed boost when resupplyin'.
The right one will let you see your teammates at all times."
::SUB_RED_Choice3_Intro_3 <- @"Which one: Left or right?"
::SUB_RED_Choice3_Chosen1 <- @"Okay, your rollouts should be much faster now."
::SUB_RED_Choice3_Chosen2 <- @"Okay, you'll be coordinatin' things better now."
::SUB_RED_Choice3_NoAnswer <- @"Why don't I pick it for ya this time? 
Hmm... the right one then."
::SUB_RED_Choice3_BadAnswer1 <- @"What are you sayin'? Just pick left or right."
::SUB_RED_Choice3_Chosen3 <- @"You know what? Screw you! 
No more ammo packs anywhere from now on!"

::SUB_BLU_INTRO_1 <- @"Greetings! It's a pleasure to be working with you.
I'm Lou, your handler on missions with BLU."
::SUB_BLU_INTRO_2 <- @"We've drafted up a couple missions for you to start, 
so choose when you're ready."
::SUB_BLU_M01 <- @"Our Nucleus facility is under attack by RED.
We're short staffed there, but that should be no problem, right?"
::SUB_BLU_M02_1 <- @"Mercenary Park has been left abandoned as far as we know.
We're sending you to scout out the place."
::SUB_BLU_M02_2 <- @"Beware of the local animals..."
::SUB_BLU_M03_1 <- @"It's official - we're launching monkeys to space!"
::SUB_BLU_M03_2 <- @"Mann Co. has sent us the best monkeynauts this planet has to offer, 
but some of them got intercepted by RED."
::SUB_BLU_M03_3 <- @"You must recover them for this launch to succeed."
::SUB_BLU_M04_1 <- @"We've hit a breakthrough at Thunder Mountain.
A new route built for our payload which should catch RED by surprise."
::SUB_BLU_M04_2 <- @"Now get out there!"
::SUB_BLU_M05_1 <- @"We're storming RED's Vanguard facility, but we're low on supplies.
Can you make do with these limitations and secure our victory?"
::SUB_BLU_M05_2 <- @"I'm counting on you."
::SUB_BLU_M06_1 <- @"We need your help at our Caper compound."
::SUB_BLU_M06_2 <- @"There's something strange going on there - maybe even supernatural.
I trust you can stabilize the situation."
::SUB_BLU_M07_1 <- @"How hard is it to keep a facility secret these days?
Some blabbermouth leaked the location of Turbine, and now RED is at its doorstep."
::SUB_BLU_M07_2 <- @"Keep them away from our confidential data!"
::SUB_BLU_M08_1 <- @"Your aim has been lacking as of late.
I'm sending you away to Sawmill for target practice with your sniper rifle."
::SUB_BLU_M08_2 <- @"Be quick about it, alright?"
::SUB_BLU_M09_1 <- @"We have intel on RED operating out of a base 
atop a giant spiral mountain."
::SUB_BLU_M09_2 <- @"It's a chance to finally get the upper hand.
Let's chase them away from that place."
::SUB_BLU_M10_1 <- @"This is a stealth mission.
We need you to infiltrate RED's base on Mossrock."
::SUB_BLU_M10_2 <- @"The security there is airtight. 
I recommend taking a slow and steady approach."
::SUB_BLU_M11_1 <- @"We need more backup to take over Rotunda.
You're going to need to support our team more than ever."
::SUB_BLU_M11_2 <- @"Good luck."
::SUB_BLU_M12_1 <- @"Multiple proximity alerts have been triggered at our Hoodoo base."
::SUB_BLU_M12_2 <- @"This area will need a thorough spy-checking.
Are you up for the task?"
::SUB_BLU_M13_1 <- @"Good, let's get started."
::SUB_BLU_M13_2 <- @"ARE YOU KIDDIN' ME?"
::SUB_BLU_M13_3 <- @"We're having a company meeting here, Edmund. Do you mind?"
::SUB_BLU_M13_4 <- @"YOU CAN'T DO THIS TO ME!"
::SUB_BLU_M13_5 <- @"That's the kind of attitude 
that makes you lose at poker every time."
::SUB_BLU_M13_6 <- @"I AM GOING TO DESTROY YOUR LITTLE SHACK 
ON VIADUCT WITH EVERYTHING AT MY DISPOSAL!"
::SUB_BLU_M13_7 <- @"Don't think we're just going to let you take it without a fight."
::SUB_BLU_M13_8 <- @"YOU WILL REGRET THIS."
::SUB_BLU_M13_9 <- @"It looks like your job interview is going to have to wait.
We have a battle to win!"
::SUB_BLU_Weapon_1 <- @"Adequate job.
We've provisioned you with a new weapon, if you want to use it."
::SUB_BLU_Weapon_2 <- @"Good going.
We're providing you another new weapon, if you so choose."
::SUB_BLU_FinalMissionOpen_1 <- @"I think you've earned yourself a permanent job here at BLU.
For your final mission, prepare for a formal job interview."
::SUB_BLU_FinalMissionOpen_2 <- @"Feel free to choose it when you're ready to join us."
::SUB_BLU_Ending_1 <- @"Excellent. We managed to pull through out there.
You're officially hired."
::SUB_BLU_Ending_2 <- @"I believe a vacation is in order.
How about Brazil? I feel like you'll enjoy it."
::SUB_BLU_Choice1_Intro_1 <- @"I'm sensing you need some reinforcements.
You're going to need all the help you can get."
::SUB_BLU_Choice1_Intro_2 <- @"Do you want him as an additional team member?"
::SUB_BLU_Choice1_Idle <- @"You can just say yes or no."
::SUB_BLU_Choice1_Chosen1 <- @"Okay, he will be joining you on your missions from now on."
::SUB_BLU_Choice1_Chosen2 <- @"Okay, he won't be joining you then."
::SUB_BLU_Choice1_NoAnswer <- @"Okay... I guess you don't want him then? That's fine too."
::SUB_BLU_Choice1_BadAnswer1 <- @"I didn't get that. Do you want this guy or not?"
::SUB_BLU_Choice1_BadAnswer2 <- @"I don't understand you. Just respond yes or no."
::SUB_BLU_Choice1_BadAnswer3 <- @"I'm really struggling with you here... Yes or no?"
::SUB_BLU_Choice1_Chosen3 <- @"Okay, since you're being so rude to me, 
I'll be requesting the removal of all resupply lockers from your missions."
::SUB_BLU_Choice2_Intro_1 <- @"We're supplying you with new equipment."
::SUB_BLU_Choice2_Intro_2 <- @"You can either get the left one to prevent fall damage
or the right one to protect against afterburn."
::SUB_BLU_Choice2_Intro_3 <- @"Choose left or right."
::SUB_BLU_Choice2_Chosen1 <- @"From now on, you won't have to worry about long falls."
::SUB_BLU_Choice2_Chosen2 <- @"From now on, you won't have to worry about afterburn."
::SUB_BLU_Choice2_NoAnswer <- @"So indecisive... How about I choose for you.
No more afterburn."
::SUB_BLU_Choice2_BadAnswer1 <- @"Just choose left or right."
::SUB_BLU_Choice2_Chosen3 <- @"What is your problem? Seriously.
From now on, your critical damage will not be so significant anymore."
::SUB_BLU_Choice3_Intro_1 <- @"The Builders League United has raised our supply budget to allow for a new upgrade.
You can choose one new enhancement."
::SUB_BLU_Choice3_Intro_2 <- @"The one on the left will protect you for a while after resupplying.
The one on the right will protect you from fatal damage once every resupply."
::SUB_BLU_Choice3_Intro_3 <- @"Which one will you pick: Left or right?"
::SUB_BLU_Choice3_Chosen1 <- @"Wise choice. You will now be briefly protected in our bases."
::SUB_BLU_Choice3_Chosen2 <- @"Wise choice. You will now be protected from fatal damage once every resupply."
::SUB_BLU_Choice3_NoAnswer <- @"Fine. Since you can't communicate adequately I've made the decision for you.
You'll be protected against fatal damage once every resupply."
::SUB_BLU_Choice3_BadAnswer1 <- @"Just choose left or right."
::SUB_BLU_Choice3_Chosen3 <- @"Clearly I'm not making this hard enough for you. 
Now you have to suffer with no healthkits. Anywhere."