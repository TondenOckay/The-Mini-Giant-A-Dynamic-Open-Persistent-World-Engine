/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_registry_inc
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    VIP Player Registry System. Maintains a fixed-slot player list per area
    that doesn't reshuffle when players leave. Empty slots become voids that
    are filled by the next entering player.
    
    KEY FEATURES:
    - O(1) player count lookups
    - CD Key tracking for anti-exploit
    - Fixed slots prevent list churn
    - Void filling for efficient memory use
    
    ARCHITECTURE NOTE:
    This is the "source of truth" for which players are in which areas.
    All other systems query the registry instead of iterating players.
   ============================================================================
*/

#include "area_const_inc"
#include "area_debug_inc"

// ============================================================================
// REGISTRY CORE FUNCTIONS
// ============================================================================

// Register a player entering an area
// Returns the slot number assigned (1-based index)
int RegistryAddPlayer(object oPC, object oArea)
{
    if (!GetIsPC(oPC)) return 0;
    
    string sCDKey = GetPCPublicCDKey(oPC);
    string sPlayerName = GetName(oPC);
    
    // Get max slots for this area (default 100)
    int nMaxSlots = GetLocalInt(oArea, DOWE_REG_MAX_SLOTS);
    if (nMaxSlots == 0) nMaxSlots = DOWE_DEFAULT_MAX_SLOTS;
    
    // Find an empty slot (void) or use next available
    int nAssignedSlot = 0;
    int nSlot;
    
    for (nSlot = 1; nSlot <= nMaxSlots; nSlot++)
    {
        string sSlotVar = DOWE_REG_PLAYER_PREFIX + IntToString(nSlot);
        object oExistingPC = GetLocalObject(oArea, sSlotVar);
        
        // Found an empty slot (void)
        if (!GetIsObjectValid(oExistingPC))
        {
            nAssignedSlot = nSlot;
            break;
        }
    }
    
    // If no void found, assign next slot
    if (nAssignedSlot == 0)
    {
        int nCurrentCount = GetLocalInt(oArea, DOWE_REG_PLAYER_COUNT);
        nAssignedSlot = nCurrentCount + 1;
        
        // Safety check: don't exceed max slots
        if (nAssignedSlot > nMaxSlots)
        {
            DebugError(oArea, "Registry full! Cannot add " + sPlayerName + 
                      " (Max: " + IntToString(nMaxSlots) + ")");
            return 0;
        }
    }
    
    // Assign the slot
    string sSlotVar = DOWE_REG_PLAYER_PREFIX + IntToString(nAssignedSlot);
    string sKeyVar = DOWE_REG_CDKEY_PREFIX + IntToString(nAssignedSlot);
    
    SetLocalObject(oArea, sSlotVar, oPC);
    SetLocalString(oArea, sKeyVar, sCDKey);
    
    // Store slot number on player
    SetLocalInt(oPC, DOWE_PLAYER_SLOT, nAssignedSlot);
    SetLocalObject(oPC, DOWE_PLAYER_AREA_OBJ, oArea);
    SetLocalString(oPC, DOWE_PLAYER_AREA_TAG, GetTag(oArea));
    
    // Increment player count
    int nCount = GetLocalInt(oArea, DOWE_REG_PLAYER_COUNT);
    SetLocalInt(oArea, DOWE_REG_PLAYER_COUNT, nCount + 1);
    
    DebugRegistry(oArea, "Player '" + sPlayerName + "' registered in slot " + 
                 IntToString(nAssignedSlot) + " | Count: " + IntToString(nCount + 1));
    
    return nAssignedSlot;
}

// Remove a player from the registry (creates a void)
void RegistryRemovePlayer(object oPC, object oArea)
{
    if (!GetIsPC(oPC)) return;
    
    int nSlot = GetLocalInt(oPC, DOWE_PLAYER_SLOT);
    if (nSlot == 0) return; // Player wasn't registered
    
    string sPlayerName = GetName(oPC);
    
    // Clear the slot (create a void)
    string sSlotVar = DOWE_REG_PLAYER_PREFIX + IntToString(nSlot);
    string sKeyVar = DOWE_REG_CDKEY_PREFIX + IntToString(nSlot);
    
    DeleteLocalObject(oArea, sSlotVar);
    DeleteLocalString(oArea, sKeyVar);
    
    // Clear player's stored data
    DeleteLocalInt(oPC, DOWE_PLAYER_SLOT);
    DeleteLocalObject(oPC, DOWE_PLAYER_AREA_OBJ);
    DeleteLocalString(oPC, DOWE_PLAYER_AREA_TAG);
    
    // Decrement count
    int nCount = GetLocalInt(oArea, DOWE_REG_PLAYER_COUNT);
    if (nCount > 0)
    {
        SetLocalInt(oArea, DOWE_REG_PLAYER_COUNT, nCount - 1);
    }
    
    DebugRegistry(oArea, "Player '" + sPlayerName + "' removed from slot " + 
                 IntToString(nSlot) + " (void created) | Count: " + 
                 IntToString(nCount - 1));
}

// ============================================================================
// REGISTRY QUERY FUNCTIONS
// ============================================================================

// Get a player by their slot number
object RegistryGetPlayer(object oArea, int nSlot)
{
    string sSlotVar = DOWE_REG_PLAYER_PREFIX + IntToString(nSlot);
    return GetLocalObject(oArea, sSlotVar);
}

// Get a player's CD Key by slot
string RegistryGetCDKey(object oArea, int nSlot)
{
    string sKeyVar = DOWE_REG_CDKEY_PREFIX + IntToString(nSlot);
    return GetLocalString(oArea, sKeyVar);
}

// Get total player count in area (includes voids in count)
int RegistryGetPlayerCount(object oArea)
{
    return GetLocalInt(oArea, DOWE_REG_PLAYER_COUNT);
}

// Get actual active players (excluding voids) - more expensive
int RegistryGetActivePlayerCount(object oArea)
{
    int nMaxSlots = GetLocalInt(oArea, DOWE_REG_MAX_SLOTS);
    if (nMaxSlots == 0) nMaxSlots = DOWE_DEFAULT_MAX_SLOTS;
    
    int nActiveCount = 0;
    int nSlot;
    
    for (nSlot = 1; nSlot <= nMaxSlots; nSlot++)
    {
        object oPC = RegistryGetPlayer(oArea, nSlot);
        if (GetIsObjectValid(oPC)) nActiveCount++;
    }
    
    return nActiveCount;
}

// Check if a specific CD Key is already in the area (anti-exploit)
int RegistryHasCDKey(object oArea, string sCDKey)
{
    int nMaxSlots = GetLocalInt(oArea, DOWE_REG_MAX_SLOTS);
    if (nMaxSlots == 0) nMaxSlots = DOWE_DEFAULT_MAX_SLOTS;
    
    int nSlot;
    for (nSlot = 1; nSlot <= nMaxSlots; nSlot++)
    {
        string sStoredKey = RegistryGetCDKey(oArea, nSlot);
        if (sStoredKey == sCDKey && sStoredKey != "") return TRUE;
    }
    
    return FALSE;
}

// ============================================================================
// REGISTRY ITERATION HELPER
// ============================================================================

// Get the first valid player in registry (use with RegistryGetNextPlayer)
object RegistryGetFirstPlayer(object oArea)
{
    // Store iteration state on area
    SetLocalInt(oArea, "DOWE_REG_ITER_SLOT", 1);
    
    int nMaxSlots = GetLocalInt(oArea, DOWE_REG_MAX_SLOTS);
    if (nMaxSlots == 0) nMaxSlots = DOWE_DEFAULT_MAX_SLOTS;
    
    // Find first valid player
    for (int nSlot = 1; nSlot <= nMaxSlots; nSlot++)
    {
        object oPC = RegistryGetPlayer(oArea, nSlot);
        if (GetIsObjectValid(oPC))
        {
            SetLocalInt(oArea, "DOWE_REG_ITER_SLOT", nSlot + 1);
            return oPC;
        }
    }
    
    return OBJECT_INVALID;
}

// Get next valid player in registry iteration
object RegistryGetNextPlayer(object oArea)
{
    int nCurrentSlot = GetLocalInt(oArea, "DOWE_REG_ITER_SLOT");
    int nMaxSlots = GetLocalInt(oArea, DOWE_REG_MAX_SLOTS);
    if (nMaxSlots == 0) nMaxSlots = DOWE_DEFAULT_MAX_SLOTS;
    
    // Continue from where we left off
    for (int nSlot = nCurrentSlot; nSlot <= nMaxSlots; nSlot++)
    {
        object oPC = RegistryGetPlayer(oArea, nSlot);
        if (GetIsObjectValid(oPC))
        {
            SetLocalInt(oArea, "DOWE_REG_ITER_SLOT", nSlot + 1);
            return oPC;
        }
    }
    
    // Clean up iteration state
    DeleteLocalInt(oArea, "DOWE_REG_ITER_SLOT");
    return OBJECT_INVALID;
}

// ============================================================================
// REGISTRY MAINTENANCE
// ============================================================================

// Clean up invalid entries (run occasionally, not every heartbeat)
void RegistryCleanup(object oArea)
{
    int nMaxSlots = GetLocalInt(oArea, DOWE_REG_MAX_SLOTS);
    if (nMaxSlots == 0) nMaxSlots = DOWE_DEFAULT_MAX_SLOTS;
    
    int nCleaned = 0;
    
    for (int nSlot = 1; nSlot <= nMaxSlots; nSlot++)
    {
        object oPC = RegistryGetPlayer(oArea, nSlot);
        
        // If player object is invalid or not in this area anymore, clean up
        if (GetIsObjectValid(oPC))
        {
            if (GetArea(oPC) != oArea || !GetIsPC(oPC))
            {
                RegistryRemovePlayer(oPC, oArea);
                nCleaned++;
            }
        }
    }
    
    if (nCleaned > 0)
    {
        DebugRegistry(oArea, "Cleanup removed " + IntToString(nCleaned) + 
                     " invalid registry entries");
    }
}

// Initialize registry for an area
void RegistryInitialize(object oArea, int nMaxSlots = DOWE_DEFAULT_MAX_SLOTS)
{
    SetLocalInt(oArea, DOWE_REG_MAX_SLOTS, nMaxSlots);
    SetLocalInt(oArea, DOWE_REG_PLAYER_COUNT, 0);
    
    DebugRegistry(oArea, "Registry initialized with " + IntToString(nMaxSlots) + " slots");
}
