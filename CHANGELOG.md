# 1.0.0
## General
- Loadouts now work offline; live TF2 items still require a connection
- Added MvM style bot presets, configurable in cfg/bot_presets.txt
- Added Armory - a way to unlock items using credits earned in the game
- Added Bestiary - browse enemies encountered in the game
- Added Campaigns
- Added weapon items:  
-- The Bottled Sorrow  
-- The Shocking Truth
- Added taunt items:  
-- Thriller (All-Class)  
-- Robot (Soldier)  
-- Werewolf (Demoman)  
-- Frankenheavy (Heavy)  
-- Come And Get Me (Scout)  
-- Hero Pose (All-Class)
- Added console commands: r_drawfriendslist, mp_humans_must_join_class, 
tf_bot_quota_use_presets, nav_generate_noreload, tf_bot_add preset <presetname>,
nav_generate_auto, tf_mvm_popfile_requested
- New inputs for tf_gamerules:  
-- SoloSaveData, SoloUnlockItem<string>, SoloUnlockItemID<int>, SoloAddCredits<int>
- The item schema is now loaded from items_custom.txt, allowing for extension and modularity
- Disabled halloween taunts, holiday restrictions by default
- Fixed generated nav meshes for workshop maps not being loaded
- Fixed some cases of MvM workshop maps not being able to find any popfile
## TFBot improvements
- Fixed bots not working correctly in PLR
- Fixed bots ignoring SD, PD, RD and neutral flags
- Fixed bots ignoring neutral flag capture zones
- Fixed bots not moving in Arena
- Fixed crash on disconnect from PD maps with bots caused by flag dispensers
- Fixed bots not firing during setup outside Attack/Defend maps
## VScript updates
- Added Client VScript functionality
- Added in Solo table (Client/Server): ItemSchemaGetKV(), ItemSchemaReload(KeyValues), ItemDefExists(string), 
ItemDefIDExists(int), ItemDefName(int)
- Global scope: Added SetBotPresetsFile(string), FileExists(string), FileToKeyValues(string)
- KeyValues: Added GetKey(string, bool), GetKeyName/GetName, GetInt/GetFloat/GetBool/GetString,
SetInt/SetFloat/SetBool/SetString/SetKeyInt/SetKeyFloat/SetKeyBool/SetKeyString,SetName/SetKeyName,RemoveSubKey  
-- KeyValues are no longer deleted after automatically disposing the script
- TFBot: Added GetPreset(), SetPreset(string)
- Moved TFBot.GenerateAndWearItem to TFPlayer
## Item changes
- Shortstop
-- Removed 50% reload speed penalty
- Baby Face's Blaster  
-- Boost no longer reduced on taking damage  
-- Lowered Boost loss with air jumps from 75% to 10%  
- Back Scatter  
-- 20% more accurate instead of 20% less accurate
- Winger  
-- Jump height increase now always active  
- Pretty Boy's Pocket Pistol  
-- New design:  
-- +50% weapon switch speed  
-- +100% secondary ammo  
-- -75% reload speed  
- Sandman  
-- Replaced health penalty with -50% firing speed  
- Sun-on-a-Stick  
-- Added: On Hit: Ignite enemy for 2 seconds  
-- Added: No random critical hits  
- Black Box  
-- New design:  
-- +30% damage  
-- +10% explosion radius  
-- -75% reload speed  
-- -30% projectile speed  
-- -75% clip size  
- Air Strike  
-- Reduced damage penalty to 10%  
- Reserve Shooter  
-- Now only usable by Soldier  
- Righteous Bison  
-- Allow the projectile to deal damage every tick, instead of every 2 ticks  
- B.A.S.E. Jumper  
-- Restored re-deploy in mid-air  
-- Restored air control to before the 50% decrease  
- Panic Attack  
-- Now only usable by Pyro  
-- Reverted the weapon to its original functionality  
-- +50% reload speed  
-- +30% firing speed  
- Pain Train  
-- Now only usable by Soldier  
- Half-Zatoichi  
-- Now only usable by Demoman  
