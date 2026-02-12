/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard - Manifest Architecture)
    DATE: February 12, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_const_inc
    
    DESCRIPTION:
    Central constants for the Platinum Standard DOWE with Manifest Architecture.
   ============================================================================
*/

// ============================================================================
// DEBUG CONFIGURATION
// ============================================================================

const string DOWE_DEBUG_ENABLED         = "DOWE_DEBUG";
const string DOWE_DEBUG_VERBOSE         = "DOWE_DEBUG_VERBOSE";
const string DOWE_DEBUG_MANIFEST        = "DOWE_DEBUG_MANIFEST";
const string DOWE_DEBUG_ENCOUNTERS      = "DOWE_DEBUG_ENCOUNTERS";
const string DOWE_DEBUG_MUD             = "DOWE_DEBUG_MUD";
const string DOWE_DEBUG_SQL             = "DOWE_DEBUG_SQL";

// ============================================================================
// TICK SYSTEM
// ============================================================================

const string DOWE_TICK                  = "DOWE_TICK";
const string DOWE_LAST_DISPATCH_TICK    = "DOWE_LAST_DISPATCH_TICK";
const int DOWE_TICK_RESET_THRESHOLD     = 10000;

// ============================================================================
// SQL CONFIGURATION
// ============================================================================

const string DOWE_SQL_USE_EXTERNAL      = "DOWE_SQL_USE_EXTERNAL";  // Toggle
const string DOWE_SQL_DATABASE          = "dowe_miniserver";
const string DOWE_SQL_SAVE_STAGGER      = "DOWE_SQL_SAVE_STAGGER";  // Delay between saves
const float DOWE_SQL_STAGGER_INTERVAL   = 0.2;  // 200ms between player saves

// ============================================================================
// CLEANUP SYSTEM
// ============================================================================

const string DOWE_CFG_REMAINS_LIFE      = "DOWE_CFG_REMAINS_LIFE";
const string DOWE_CFG_ITEM_LIFE         = "DOWE_CFG_ITEM_LIFE";
const string DOWE_CFG_PLAYER_CORPSE_LIFE = "DOWE_CFG_PLAYER_CORPSE_LIFE";

// ============================================================================
// ENCOUNTER SYSTEM (Entropic Spawning)
// ============================================================================

const int DOWE_ENC_CHECK_INTERVAL       = 4;  // Check every 4 beats
const float DOWE_ENC_SPAWN_CHANCE       = 0.40;  // 40% base chance
const int DOWE_ENC_PLAYERS_PER_TICK     = 5;  // Process 5 players per tick (entropic)

// Spawn distances
const float DOWE_ENC_DIST_CLOSE         = 10.0;
const float DOWE_ENC_DIST_MEDIUM        = 20.0;
const float DOWE_ENC_DIST_FAR           = 30.0;

// Spawn validation
const float DOWE_ENC_WALKABLE_CHECK_RADIUS = 2.0;  // Check 2m radius for walkability

// ============================================================================
// LIVE NPC SYSTEM
// ============================================================================

const string DOWE_LIVE_NPC_ENABLED      = "DOWE_LIVE_NPC_ENABLED";
const string DOWE_LIVE_NPC_TAG_PREFIX   = "LIVENPC_";

// ============================================================================
// PERFORMANCE TUNING
// ============================================================================

const float DOWE_STAGGER_PHASE2         = 1.5;
const float DOWE_STAGGER_PHASE3         = 3.0;
const int DOWE_FAILSAFE_MISSED_BEATS    = 3;

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

int GetDoweDebug()
{
    return GetLocalInt(GetModule(), DOWE_DEBUG_ENABLED);
}

int GetDoweTick()
{
    return GetLocalInt(GetModule(), DOWE_TICK);
}
