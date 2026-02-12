/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_const_inc
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    Central constants and configuration values for the entire DOWE system.
    All systems include this file to access shared configuration.
    
    USAGE:
    #include "area_const_inc" at the top of every DOWE script
    
    DESIGN PHILOSOPHY:
    By centralizing constants, we can tune the entire system from one file.
    This makes server optimization much easier for a single developer.
   ============================================================================
*/

// ============================================================================
// DEBUG CONFIGURATION
// ============================================================================

// Debug levels - set on module object
const string DOWE_DEBUG_ENABLED         = "DOWE_DEBUG";          // Main debug toggle
const string DOWE_DEBUG_VERBOSE         = "DOWE_DEBUG_VERBOSE";  // Detailed trace
const string DOWE_DEBUG_REGISTRY        = "DOWE_DEBUG_REGISTRY"; // Registry operations
const string DOWE_DEBUG_ENCOUNTERS      = "DOWE_DEBUG_ENCOUNTERS"; // Encounter spawning
const string DOWE_DEBUG_MUD             = "DOWE_DEBUG_MUD";      // MUD commands
const string DOWE_DEBUG_SQL             = "DOWE_DEBUG_SQL";      // Database operations

// ============================================================================
// TICK SYSTEM (Monotonic Clock)
// ============================================================================

const string DOWE_TICK                  = "DOWE_TICK";           // Current tick counter
const string DOWE_LAST_DISPATCH_TICK    = "DOWE_LAST_DISPATCH_TICK";
const int DOWE_TICK_RESET_THRESHOLD     = 10000;                 // Reset at 10k

// ============================================================================
// REGISTRY SYSTEM (VIP Player List)
// ============================================================================

const string DOWE_REG_PLAYER_COUNT      = "DOWE_REG_PLAYER_COUNT";
const string DOWE_REG_VIP_COUNT         = "DOWE_REG_VIP_COUNT";
const string DOWE_REG_PLAYER_PREFIX     = "DOWE_REG_PC_";        // + slot number
const string DOWE_REG_CDKEY_PREFIX      = "DOWE_REG_KEY_";       // + slot number
const string DOWE_REG_MAX_SLOTS         = "DOWE_REG_MAX_SLOTS";

const int DOWE_DEFAULT_MAX_SLOTS        = 100;                   // Max players per area

// Player variables (stored on PC object)
const string DOWE_PLAYER_SLOT           = "DOWE_PLAYER_SLOT";    // Their VIP slot number
const string DOWE_PLAYER_AREA_TAG       = "DOWE_CURRENT_AREA_TAG";
const string DOWE_PLAYER_AREA_OBJ       = "DOWE_CURRENT_AREA_OBJ";

// ============================================================================
// CLEANUP SYSTEM (Phase 1)
// ============================================================================

// 2DA cache keys
const string DOWE_CFG_REMAINS_LIFE      = "DOWE_CFG_REMAINS_LIFE";
const string DOWE_CFG_LOOTBAG_LIFE      = "DOWE_CFG_LOOTBAG_LIFE";
const string DOWE_CFG_ITEM_LIFE         = "DOWE_CFG_ITEM_LIFE";
const string DOWE_CFG_PLAYER_CORPSE_LIFE = "DOWE_CFG_PLAYER_CORPSE_LIFE";

// Object lifecycle tags
const string DOWE_DROP_TICK             = "DOWE_DROP_TICK";
const string DOWE_DEATH_TICK            = "DOWE_DEATH_TICK";
const string DOWE_PLAYER_CORPSE         = "DOWE_PLAYER_CORPSE";

// ============================================================================
// LIVE NPC SYSTEM (Testing)
// ============================================================================

const string DOWE_LIVE_NPC_ENABLED      = "DOWE_LIVE_NPC_ENABLED";
const string DOWE_LIVE_NPC_TAG_PREFIX   = "LIVENPC_";
const int DOWE_LIVE_NPC_TYPE_FAST       = 1;  // Spawns before player enters
const int DOWE_LIVE_NPC_TYPE_NORMAL     = 2;  // Spawns after player enters

// ============================================================================
// ENCOUNTER SYSTEM (Phase 3)
// ============================================================================

// Encounter timing
const int DOWE_ENC_CHECK_INTERVAL       = 4;  // Check every 4 beats (2 minutes)
const float DOWE_ENC_SPAWN_CHANCE       = 0.40; // 40% chance per check

// Encounter distances
const float DOWE_ENC_DIST_CLOSE         = 10.0; // Close spawn ring
const float DOWE_ENC_DIST_MEDIUM        = 20.0; // Standard spawn ring
const float DOWE_ENC_DIST_FAR           = 30.0; // Distant spawn ring

// Encounter ownership
const float DOWE_ENC_TRANSFER_RANGE     = 30.0; // Transfer ownership within 30m
const float DOWE_ENC_DESPAWN_RANGE      = 50.0; // Despawn if player 50m+ away

// Encounter combat checks
const float DOWE_ENC_COMBAT_CHECK_RANGE = 40.0; // Don't spawn if PC within 40m of combat

// Encounter rarity weights
const int DOWE_ENC_RARITY_COMMON        = 70;   // 70% common
const int DOWE_ENC_RARITY_UNCOMMON      = 25;   // 25% uncommon
const int DOWE_ENC_RARITY_RARE          = 5;    // 5% rare

// Encounter size (number of creatures)
const int DOWE_ENC_SIZE_MIN             = 1;
const int DOWE_ENC_SIZE_MAX             = 6;

// Encounter variables
const string DOWE_ENC_OWNER_SLOT        = "DOWE_ENC_OWNER_SLOT";
const string DOWE_ENC_SPAWN_TICK        = "DOWE_ENC_SPAWN_TICK";
const string DOWE_ENC_TYPE              = "DOWE_ENC_TYPE";  // "dynamic" or "static"
const string DOWE_ENC_CREATURE_LIST     = "DOWE_ENC_CREATURE_LIST_";  // + index

// ============================================================================
// MUD COMMAND SYSTEM
// ============================================================================

const string DOWE_MUD_COMMAND_PREFIX    = "//";  // All MUD commands start with //
const int DOWE_MUD_MAX_PARSE_LENGTH     = 200;   // Max command length to parse

// MUD system toggles
const string DOWE_MUD_OBJECTS_ENABLED   = "DOWE_MUD_OBJECTS_ENABLED";
const string DOWE_MUD_QUESTS_ENABLED    = "DOWE_MUD_QUESTS_ENABLED";
const string DOWE_MUD_SHOPS_ENABLED     = "DOWE_MUD_SHOPS_ENABLED";
const string DOWE_MUD_CRAFTING_ENABLED  = "DOWE_MUD_CRAFTING_ENABLED";
const string DOWE_MUD_GATHERING_ENABLED = "DOWE_MUD_GATHERING_ENABLED";

// ============================================================================
// CRAFTING & GATHERING SYSTEM
// ============================================================================

// Skill gain
const float DOWE_SKILL_GAIN_CHANCE      = 0.10;  // 10% chance to gain skill
const float DOWE_SKILL_SUCCESS_BONUS    = 0.05;  // 5% bonus per point above min

// Skill variable names (stored on PC)
const string DOWE_SKILL_BLACKSMITHING   = "DOWE_SKILL_BLACKSMITHING";
const string DOWE_SKILL_LEATHERWORKING  = "DOWE_SKILL_LEATHERWORKING";
const string DOWE_SKILL_TAILORING       = "DOWE_SKILL_TAILORING";
const string DOWE_SKILL_ALCHEMY         = "DOWE_SKILL_ALCHEMY";
const string DOWE_SKILL_MINING          = "DOWE_SKILL_MINING";
const string DOWE_SKILL_WOODCUTTING     = "DOWE_SKILL_WOODCUTTING";
const string DOWE_SKILL_HERBALISM       = "DOWE_SKILL_HERBALISM";

// ============================================================================
// SQL DATABASE CONFIGURATION
// ============================================================================

const string DOWE_SQL_DATABASE          = "dowe_miniserver";  // Database name
const string DOWE_SQL_TABLE_PLAYERS     = "player_data";
const string DOWE_SQL_TABLE_AREAS       = "area_state";

// ============================================================================
// PERFORMANCE TUNING
// ============================================================================

// Stagger timing
const float DOWE_STAGGER_PHASE2         = 1.5;   // Medium operations
const float DOWE_STAGGER_PHASE3         = 3.0;   // Heavy operations

// Safety thresholds
const int DOWE_FAILSAFE_MISSED_BEATS    = 3;     // Activate failsafe after 3 missed beats

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

// Quick debug check
int GetDoweDebug()
{
    return GetLocalInt(GetModule(), DOWE_DEBUG_ENABLED);
}

// Get current tick
int GetDoweTick()
{
    return GetLocalInt(GetModule(), DOWE_TICK);
}

// Check if area is active (has players)
int GetAreaIsActive(object oArea)
{
    return GetLocalInt(oArea, DOWE_REG_PLAYER_COUNT) > 0;
}
