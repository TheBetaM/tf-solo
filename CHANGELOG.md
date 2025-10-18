# 1.0.0
## General
- Added new gamemodes:  
-- Mad Dash  
-- Property Damage  
- Added new maps  
- Added a new main menu interface for selecting maps to play, and in new ways!
-- Arena Mode - Now playable on any map  
-- King of the Hill - Now playable on any symmetrical point map  
-- Capture the Flag - Now playable on any symmetrical multi-point map  
-- Player Destruction - Now playable on any map  
-- Mirror Mode - The entire world flipped, it's like having two maps in one!  
-- Map Mods - Any map can be modded to suit new gamemodes or other changes  
- Added Campaigns:  
-- Headhunt, enhanced from the original Workshop release!  
-- Bloodthirst, a new campaign featuring Dracula!  
- Added Scenarios:  
-- Meet The Team - An introduction for each individual class  
-- Territory Control - Choose from a randomly generated set of scenarios to control every map  
- Loadouts now work offline; accessing your base TF2 inventory still requires a connection
- Added Armory - a way to unlock items using credits earned in the game
- Added new weapon and taunt items
- Added Bestiary - browse enemies encountered in the game
- Added new achievements
- Added console commands: r_drawfriendslist, mp_humans_must_join_class, 
tf_bot_quota_use_presets, nav_generate_noreload, tf_bot_add preset <presetname>, 
nav_generate_auto, nav_generate_auto_view_distance, tf_mvm_popfile_requested, 
mp_restartblock, tf_roundstarttalk_disable, tf_gamemode_override, 
cl_default_networking_off, nav_save_compressed, tf_bot_spells, 
tf_vision_force, tf_bot_buy_upgrades, tf_mirrormode, tf_revives_enable, 
sv_mapentities_override, sv_mapentities_mod, nav_begin_ladder, 
tf_flamethrower_oldeffects  
- New inputs for tf_gamerules:  
-- SoloSaveData, SoloUnlockItem<string>, SoloUnlockItemID<int>, SoloAddCredits<int>
- The item schema is now loaded from items_custom.txt, allowing for extension and modularity
- Disabled halloween taunts, holiday restrictions by default
- Disabled soul gargoyle and halloween soul spawning
- Fixed some cases of MvM workshop maps not being able to find any popfile
- Minimal HUD no longer prevents game_text_tf from appearing
- Fixed round restart commands not working in Arena mode
- Fixed mini-rounds without a setup timer being stuck in setup mode
- Fixed canteens being unusable in Sudden Death/Arena
- Added #basedir to KeyValues to include all files in a directory
## TFBot improvements
- Added MvM style bot presets, configurable in cfg/bot_presets.txt
- Added nav files for many existing maps
- Improved nav meshes in many existing maps
- Saved nav files now get compressed by default
- Human players can now manually manage bot teammates' PvP/MvM upgrades by inspecting them
- Bots can now play the objective in all gamemodes
- Bots can now auto-buy PvP/MvM upgrades where available
- Bots can now proactively seek out spells, crumpkins, credits, cores and powerup pickups
- Bots can now use spellbook spells and canteens
- Bots can now stun Merasmus and seek him out while he's hiding
- Bots can now use all ZI abilities
- Bots can now wall climb in VSH using nav mesh ladders
- Bots can now use Sweeping Charge in VSH
- Bots can now buyback in MvM
- Medic bots can now revive teammates if revives are active in MvM/PvP
- Bots will now try to escape the Underworld and Loot Island through nav areas marked with nav_stop
- Fixed generated nav meshes for workshop maps not being loaded
- Fixed nav_generate nav mesh generation not taking into account multiple spawn areas and stages
- Fixed bots not working correctly in PLR
- Fixed bots ignoring SD, PD, RD and neutral flags
- Fixed bots ignoring neutral flag capture zones
- Fixed bots not moving in Arena
- Fixed crash on disconnect from PD maps with bots caused by flag dispensers
- Fixed bots not firing during setup outside Attack/Defend maps
- Fixed bots not moving if the map has no func_respawnroom's
- Fixed crash on point capture if no nav areas found around point
- Where needed, bots will now follow the capture zone instead of the payload directly
- Fixed bots using Payload logic on hybrid maps like Snowplow
- Fixed crash with bots after playing on a Mannpower map
- Giants will now always avoid nav areas marked with nav_stop
- Fixed bots not moving during setup in symmetrical capture point maps
- Fixed bots trying to use resupply lockers in Sudden Death/Arena
- Fixed players/bots firing weapons never affecting bot behavior in Sudden Death/Arena
- Nav mesh blocked state now also updates after tf_logic_cp_timer countdown ends
## VScript updates
- Added Client VScript functionality
- Added in Solo table (Client/Server): ItemSchemaGetKV(), ItemSchemaReload(KeyValues), ItemDefExists(string), 
ItemDefIDExists(int), ItemDefName(int), ItemDefID(string)  
- Added script hooks: team_round_respawn, team_round_cleanup, team_round_activate
- Global scope: Added SetBotPresetsFile(string), FileExists(string), FileToKeyValues(string), 
SetSoloObjectivesResFile(string), SetRoundToPlayNext(string), LocalizeString(string), 
ScriptTableToFile(table, string), FileToScriptTable(string)
- Clientside/Singleplayer dynamic asset loading from map files: BSP_CacheStartSingle, BSP_CacheStartArray, 
BSP_CacheStartRemap, BSP_GetCacheJobsRunning, BSP_CacheRemove, BSP_CacheRemoveArray, BSP_CacheClear  
- KeyValues: Added GetKey(string, bool), GetKeyName/GetName, GetInt/GetFloat/GetBool/GetString,
SetInt/SetFloat/SetBool/SetString/SetKeyInt/SetKeyFloat/SetKeyBool/SetKeyString,SetName/SetKeyName,RemoveSubKey  
-- KeyValues are no longer deleted after automatically disposing the script
- TFBot: Added GetPreset(), SetPreset(string)
- TFPlayer: Added PostInventoryApplication(), GetKills(), GetDeaths(), GetSuicides(), GetBuildingsBuilt(), 
GetDamageDone(), GetCrits(), GetPoints()
- Moved TFBot.GenerateAndWearItem to TFPlayer and optimized execution time
- Added IncludeScriptsDir(string, scope) to include all files in a directory
## Item changes
- Shortstop  
-- Removed 50% reload speed penalty   
  
- Gunboats  
-- Now also usable by Demoman  
-- Added: Allows wearer to stick to walls by jumping into them  
- Righteous Bison  
-- Allow the projectile to deal damage every tick, instead of every 2 ticks  
- B.A.S.E. Jumper  
-- Restored re-deploy in mid-air  
-- Restored air control to before the 50% decrease   
  
- Rainblower  
-- Removed Pyrovision requirement  
- Backburner  
-- Added: Airblast dashes  
- Manmelter  
-- Removed flaming particle effect  
- Panic Attack  
-- Reverted the weapon to its original functionality/stats  
-- +50% reload speed  
-- +30% firing speed  
- Gas Passer  
-- Gas meter now starts full and resupplies  
- Lollichop  
-- Removed Pyrovision requirement  
- Axtinguisher  
-- Reverted to original stats:  
-- 100% critical chance vs burning players  
-- -50% damage vs non-burning players  
-- No critical hits vs non-burning players  
  
- Loch-n-Load  
-- Reverted to older stats:  
-- Replaced +20% damage to buildings with +20% damage bonus   
- Stickybomb Jumper  
-- Reverted to older stats:  
-- Removed max sticky active penalty  
- Ullapool Caber  
-- Reverted to older stats:  
-- Increased base explosion damage from 75 to 100  
-- Removed firing speed penalty  
-- Removed deploy speed penalty  
-- Added: -45% damage penalty  
  
- Gloves of Running Urgently  
-- Reverted to older stats:  
-- Removed maximum health drain  
-- Added: Marked For Death while active  
-- Added: -25% damage penalty  
- Eviction Notice  
-- Removed maximum health drain  
  
- Pomson 6000  
-- Added projectile penetration  
  
- Sydney Sleeper  
-- Reverted to older stats:  
-- Removed Scoped Hit requirement and variable Jarate time  
-- Added On Hit: 8 seconds of Jarate on target  
  
- Ambassador  
-- Reverted to older stats:  
-- Removed critical damage falloff  
- Your Eternal Reward  
-- Removed cloak drain penalty  

