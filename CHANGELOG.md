# 1.0.0
## General
- Added Campaigns - new stories, new characters, standalone progression and mechanics!  
-- Headhunt, enhanced from the original Workshop release!  
-- Bloodthirst, a new campaign featuring Dracula!  
- Added Scenarios - story vignettes from across Team Fortress history, and beyond!  
-- Meet The Team - An introduction for each individual class  
-- Territory Control - Choose from a randomly generated set of scenarios to control every map  
- Added Quickplay - a new interface for setting up regular TF gameplay, and in new ways!  
-- Maps can now be played in other gamemodes without having to modify them, including such modes as: Arena, King of the Hill, Capture the Flag, Player Destruction  
-- Mirror Mode - The entire world flipped, it's like having two maps in one!  
-- Map Mods - Any map can be modded to suit new gamemodes better or implement other changes and additions  
- Added new gamemodes:  
-- Mad Dash  
-- Property Damage  
- Added new maps  
- Loadouts now work offline; accessing your base TF2 inventory still requires an internet connection
- Added Armory - a way to unlock items using credits earned in the game
- Added new weapon and taunt items
- Added Hit List - browse enemies encountered in the game
- Added Subs - class substitute playable characters
- Added the Game Instructor feature from Alien Swarm:  
-- Optional context-sensitive tutorials for base TF2 mechanics  
-- Optional context-sensitive tutorials for new mechanics  
-- Plus additional flavor text  
- Added a map overview, replacing the scoreboard
- Added new achievements
- Added console commands: mp_humans_must_join_class, tf_player_responses_mute, tf_viewmodel_forcehide, 
tf_bot_quota_use_presets, nav_generate_noreload, tf_bot_add preset <presetname>, 
nav_generate_auto, nav_generate_auto_view_distance, tf_mvm_popfile_requested, 
mp_restartblock, tf_roundstarttalk_disable, tf_gamemode_override, 
nav_save_compressed, tf_bot_spells, 
tf_vision_force, tf_bot_buy_upgrades, tf_mirrormode, tf_revives_enable, 
sv_mapentities_override, sv_mapentities_mod, nav_begin_ladder, 
tf_flamethrower_oldeffects, cl_lockview, sv_lockview_force, 
sv_thirdperson_platformer_force, tf_subclass_allow, mp_humans_must_join_subclass, 
tf_bot_sniper_lasersight, tf_player_maxspeed_override, tf_scoreboard_allow, 
tf_player_preventdeath, tf_player_preventteamchange, nav_connect_ladder_bottom, 
mp_humans_maxrespawntime, mp_bots_maxrespawntime, tf_respawn_on_loadoutchanges_type, 
tf_overview_scoreboard, tf_allow_taunt_aerial, tf_allow_taunt_disguised, 
tf_halloween_zombie_forceteam, tf_hud_deathnotice_filter, tf_taunt_disable_attack
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
- Added #basedir to KeyValues to base on top of all files in a directory
- Added functionality to change Pyrovision into any custom vision
- Improved thirdperson_platformer, now allows firing in the direction you're aiming
- Increased maximum FoV to 130
- Spawning is no longer prevented while having the class select menu open with hud_classautokill 0
- Fixed loadout changes not respawning players during the preround period in Arena mode
- Added SVG and bitmap support to ImagePanel (can now use SVG/BMP/JPG/TGA/PNG files directly in VGUI images)
## TFBot improvements
- Added MvM style bot presets, configurable in cfg/bot_presets.txt
- Added/Improved nav files for existing maps
- Saved nav files now get compressed by default
- Human players can now manually manage bot teammates' PvP/MvM upgrades by inspecting them
- Bots can now play the objective in all gamemodes
- Bots can now auto-buy PvP/MvM upgrades where available
- Bots can now proactively seek out spells, crumpkins, credits, cores and powerup pickups
- Bots can now use spellbook spells and canteens
- Bots can now stun Merasmus and seek him out while he's hiding
- Bots can now use all ZI abilities
- Bots can now wall climb in VSH using nav mesh ladders
- Bots can now use the Grappling Hook on nav mesh ladders
- Bots can now use Sweeping Charge and Brave Jump in VSH
- Bots can now buyback in MvM
- Medic bots can now revive teammates if revives are active in MvM/PvP
- Bots will now try to escape the Underworld and Loot Island through nav areas marked with nav_stop, detected through TF_COND_PURGATORY, TF_COND_HALLOWEEN_IN_HELL, or nav areas marked with nav_no_hostages
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
- Where needed, bots will now follow the capture zone instead of the payload model directly
- Fixed bots using Payload logic on hybrid maps like Snowplow
- Fixed crash with bots after playing on a Mannpower map
- Giants will now always avoid nav areas marked with nav_stop
- Fixed bots not moving during setup in symmetrical capture point maps
- Fixed bots trying to use resupply lockers in Sudden Death/Arena
- Fixed players/bots firing weapons never affecting bot behavior in Sudden Death/Arena
- Nav mesh blocked state now also updates after tf_logic_cp_timer countdown ends
- Bots will no longer try to attack using flamethrowers underwater
## VScript updates
- Added Client VScript functionality for main menu UI and ingame HUD elements
- Added in Solo table (Client/Server): ItemSchemaGetKV(), ItemSchemaReload(KeyValues), ItemDefExists(string), 
ItemDefIDExists(int), ItemDefName(int), ItemDefID(string)  
- Added server script hooks: team_round_respawn, team_round_cleanup, team_round_activate, OnClientScriptTable
- Global scope: Added SetBotPresetsFile(string), FileExists(string), FileToKeyValues(string), 
SetSoloObjectivesResFile(string), SetRoundToPlayNext(string), LocalizeString(string), 
ScriptTableToFile(table, string), FileToScriptTable(string), BroadcastTable(table), 
BroadcastTablePlayer(int, table)
- Clientside/Singleplayer dynamic asset loading from map files: BSP_CacheStartSingle, BSP_CacheStartArray, 
BSP_CacheStartRemap, BSP_GetCacheJobsRunning, BSP_CacheRemove, BSP_CacheRemoveArray, BSP_CacheClear  
- KeyValues: Added GetKey(string, bool), GetKeyName/GetName, GetInt/GetFloat/GetBool/GetString,
SetInt/SetFloat/SetBool/SetString/SetKeyInt/SetKeyFloat/SetKeyBool/SetKeyString,SetName/SetKeyName,RemoveSubKey  
-- KeyValues are no longer deleted after automatically disposing the script
- TFBot: Added GetPreset(), SetPreset(string)
- TFPlayer: Added PostInventoryApplication(), GetKills(), GetDeaths(), GetSuicides(), GetBuildingsBuilt(), 
GetDamageDone(), GetCrits(), GetPoints()
- NavMesh: RecomputeBlockers(delay), RecomputeBlockersWithCapture(delay)
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
-- Reverted to its original functionality:  
-- Restored re-deploy in mid-air  
-- Restored air control  
  
- Rainblower  
-- Removed Pyrovision requirement  
- Backburner  
-- Added: Airblast dashes  
- Manmelter  
-- Removed flaming particle effect obstructing view  
- Panic Attack  
-- Reverted to its original functionality/older stats:  
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

