# 1.0
## General
- Inventory and loadouts now work offline; live TF2 items still require a connection
- Added MvM style bot presets, configurable in cfg/bot_presets.txt
- Added Armory - a way to unlock items using credits earned in the game
- Added Bestiary - browse enemies encountered in the game
- Added Campaigns
- Added weapons:  
-- The Bottled Sorrow  
-- The Shocking Truth
- Added taunts:  
-- Thriller (All-Class)  
-- Robot (Soldier)  
-- Werewolf (Demoman)  
-- Frankenheavy (Heavy)  
-- Come And Get Me (Scout)  
-- Hero Pose (All-Class)
- Added ConVars: r_drawfriendslist, mp_humans_must_join_class, 
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
