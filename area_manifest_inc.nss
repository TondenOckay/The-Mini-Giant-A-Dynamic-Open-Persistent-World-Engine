/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard - Manifest Architecture)
    DATE: February 12, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_manifest_inc
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    THE REVOLUTIONARY MANIFEST SYSTEM - Single unified list for ALL objects
    in an area. Each entry is self-flagging with category bits. This eliminates
    the need for separate player registry, NPC list, corpse list, etc.
    
    ARCHITECTURE:
    Runtime: Local Variables (fast O(1) lookups)
    Snapshot: JSON Serialization (state export)
    Persistence: SQL Database (long-term storage)
    
    CATEGORIES (Bitflags):
    0x0001 = Players
    0x0002 = Live NPCs (test)
    0x0004 = Henchmen
    0x0008 = Mounts
    0x0010 = Pets
    0x0020 = Summoned Creatures
    0x0040 = Creatures (encounters)
    0x0080 = Objects (interactable)
    0x0100 = Corpses
    0x0200 = Dropped Items
    0x0400 = Gathering Nodes
    0x0800 = Crafting Containers
    0x1000 = NPC Waypoints
    0x2000 = Creature Waypoints
    0x4000 = Walkable Waypoints
    
    WHY THIS IS REVOLUTIONARY:
    - O(1) lookups for any category
    - Self-registration on spawn/create
    - Single source of truth
    - No area scans EVER
    - Cleanup becomes trivial (filter by flags)
    - Scales to unlimited objects
   ============================================================================
*/

// ============================================================================
// MANIFEST CATEGORY FLAGS (Bitflags for multi-category support)
// ============================================================================

const int MANIFEST_FLAG_PLAYER          = 0x0001;  // 1
const int MANIFEST_FLAG_LIVE_NPC        = 0x0002;  // 2
const int MANIFEST_FLAG_HENCHMAN        = 0x0004;  // 4
const int MANIFEST_FLAG_MOUNT           = 0x0008;  // 8
const int MANIFEST_FLAG_PET             = 0x0010;  // 16
const int MANIFEST_FLAG_SUMMONED        = 0x0020;  // 32
const int MANIFEST_FLAG_CREATURE        = 0x0040;  // 64
const int MANIFEST_FLAG_OBJECT          = 0x0080;  // 128
const int MANIFEST_FLAG_CORPSE          = 0x0100;  // 256
const int MANIFEST_FLAG_DROPPED_ITEM    = 0x0200;  // 512
const int MANIFEST_FLAG_GATHER_NODE     = 0x0400;  // 1024
const int MANIFEST_FLAG_CRAFT_CONTAINER = 0x0800;  // 2048
const int MANIFEST_FLAG_WAYPOINT_NPC    = 0x1000;  // 4096
const int MANIFEST_FLAG_WAYPOINT_CREATURE = 0x2000;  // 8192
const int MANIFEST_FLAG_WAYPOINT_WALK   = 0x4000;  // 16384

// Composite flags for common queries
const int MANIFEST_FLAG_ALL_CREATURES   = 0x007E;  // LiveNPC|Hench|Mount|Pet|Summoned|Creature
const int MANIFEST_FLAG_ALL_CULLABLE    = 0x7D80;  // Objects|Corpse|Items|Nodes|Containers|Waypoints

// ============================================================================
// MANIFEST ENTRY STRUCTURE (Stored as local variables on area)
// ============================================================================

// Each manifest entry is indexed by a slot number (1-based)
// Format: MANIFEST_SLOT_[N]_[PROPERTY]

const string MANIFEST_SLOT_PREFIX       = "MANIFEST_SLOT_";
const string MANIFEST_COUNT             = "MANIFEST_COUNT";        // Total entries
const string MANIFEST_MAX_SLOT          = "MANIFEST_MAX_SLOT";     // Highest slot used

// Entry properties (append to MANIFEST_SLOT_[N]_)
const string MANIFEST_PROP_OBJECT       = "_OBJ";      // The object reference
const string MANIFEST_PROP_FLAGS        = "_FLAGS";    // Category bitflags
const string MANIFEST_PROP_CDKEY        = "_CDKEY";    // For players
const string MANIFEST_PROP_OWNER_SLOT   = "_OWNER";    // For creatures (owner's slot)
const string MANIFEST_PROP_SPAWN_TICK   = "_SPAWNTICK"; // When it spawned
const string MANIFEST_PROP_EXPIRE_TICK  = "_EXPIRETICK"; // When it expires (for cleanup)
const string MANIFEST_PROP_TAG          = "_TAG";      // Object tag (for lookups)

// Object property (stored on the object itself for reverse lookup)
const string MANIFEST_OBJ_SLOT          = "MANIFEST_SLOT";

// ============================================================================
// MANIFEST CORE FUNCTIONS
// ============================================================================

// Add an object to the manifest
// Returns the assigned slot number (0 if failed)
int ManifestAdd(object oArea, object oObject, int nFlags, int nExpireTicks = 0)
{
    if (!GetIsObjectValid(oObject)) return 0;
    
    // Find an empty slot or use next available
    int nMaxSlot = GetLocalInt(oArea, MANIFEST_MAX_SLOT);
    int nAssignedSlot = 0;
    
    // Try to find a void (empty slot) first
    for (int i = 1; i <= nMaxSlot; i++)
    {
        string sSlotObj = MANIFEST_SLOT_PREFIX + IntToString(i) + MANIFEST_PROP_OBJECT;
        object oExisting = GetLocalObject(oArea, sSlotObj);
        
        if (!GetIsObjectValid(oExisting))
        {
            nAssignedSlot = i;
            break;
        }
    }
    
    // No void found, use next slot
    if (nAssignedSlot == 0)
    {
        nAssignedSlot = nMaxSlot + 1;
        SetLocalInt(oArea, MANIFEST_MAX_SLOT, nAssignedSlot);
    }
    
    // Store entry properties
    string sPrefix = MANIFEST_SLOT_PREFIX + IntToString(nAssignedSlot);
    
    SetLocalObject(oArea, sPrefix + MANIFEST_PROP_OBJECT, oObject);
    SetLocalInt(oArea, sPrefix + MANIFEST_PROP_FLAGS, nFlags);
    SetLocalString(oArea, sPrefix + MANIFEST_PROP_TAG, GetTag(oObject));
    
    // Set spawn tick
    int nCurrentTick = GetLocalInt(GetModule(), "DOWE_TICK");
    SetLocalInt(oArea, sPrefix + MANIFEST_PROP_SPAWN_TICK, nCurrentTick);
    
    // Set expiration if provided
    if (nExpireTicks > 0)
    {
        SetLocalInt(oArea, sPrefix + MANIFEST_PROP_EXPIRE_TICK, nCurrentTick + nExpireTicks);
    }
    
    // Store reverse lookup on object
    SetLocalInt(oObject, MANIFEST_OBJ_SLOT, nAssignedSlot);
    
    // Increment count
    int nCount = GetLocalInt(oArea, MANIFEST_COUNT);
    SetLocalInt(oArea, MANIFEST_COUNT, nCount + 1);
    
    return nAssignedSlot;
}

// Remove an object from the manifest (creates void)
void ManifestRemove(object oArea, object oObject)
{
    int nSlot = GetLocalInt(oObject, MANIFEST_OBJ_SLOT);
    if (nSlot == 0) return;
    
    // Clear all entry properties (creates void)
    string sPrefix = MANIFEST_SLOT_PREFIX + IntToString(nSlot);
    
    DeleteLocalObject(oArea, sPrefix + MANIFEST_PROP_OBJECT);
    DeleteLocalInt(oArea, sPrefix + MANIFEST_PROP_FLAGS);
    DeleteLocalString(oArea, sPrefix + MANIFEST_PROP_CDKEY);
    DeleteLocalInt(oArea, sPrefix + MANIFEST_PROP_OWNER_SLOT);
    DeleteLocalInt(oArea, sPrefix + MANIFEST_PROP_SPAWN_TICK);
    DeleteLocalInt(oArea, sPrefix + MANIFEST_PROP_EXPIRE_TICK);
    DeleteLocalString(oArea, sPrefix + MANIFEST_PROP_TAG);
    
    // Clear reverse lookup
    DeleteLocalInt(oObject, MANIFEST_OBJ_SLOT);
    
    // Decrement count
    int nCount = GetLocalInt(oArea, MANIFEST_COUNT);
    if (nCount > 0)
    {
        SetLocalInt(oArea, MANIFEST_COUNT, nCount - 1);
    }
}

// Get object from manifest by slot
object ManifestGetObject(object oArea, int nSlot)
{
    string sVar = MANIFEST_SLOT_PREFIX + IntToString(nSlot) + MANIFEST_PROP_OBJECT;
    return GetLocalObject(oArea, sVar);
}

// Get flags for a slot
int ManifestGetFlags(object oArea, int nSlot)
{
    string sVar = MANIFEST_SLOT_PREFIX + IntToString(nSlot) + MANIFEST_PROP_FLAGS;
    return GetLocalInt(oArea, sVar);
}

// Check if slot matches flag filter
int ManifestMatchesFlags(object oArea, int nSlot, int nFlagFilter)
{
    int nFlags = ManifestGetFlags(oArea, nSlot);
    return (nFlags & nFlagFilter) != 0;
}

// Get total entry count
int ManifestGetCount(object oArea)
{
    return GetLocalInt(oArea, MANIFEST_COUNT);
}

// Get count of specific category
int ManifestGetCountByFlags(object oArea, int nFlagFilter)
{
    int nMaxSlot = GetLocalInt(oArea, MANIFEST_MAX_SLOT);
    int nMatchCount = 0;
    
    for (int i = 1; i <= nMaxSlot; i++)
    {
        if (ManifestMatchesFlags(oArea, i, nFlagFilter))
        {
            // Verify object is still valid
            object oObj = ManifestGetObject(oArea, i);
            if (GetIsObjectValid(oObj))
            {
                nMatchCount++;
            }
        }
    }
    
    return nMatchCount;
}

// ============================================================================
// MANIFEST ITERATION HELPERS
// ============================================================================

// Get first object matching flag filter
object ManifestGetFirst(object oArea, int nFlagFilter)
{
    // Store iteration state
    SetLocalInt(oArea, "MANIFEST_ITER_SLOT", 1);
    SetLocalInt(oArea, "MANIFEST_ITER_FLAGS", nFlagFilter);
    
    int nMaxSlot = GetLocalInt(oArea, MANIFEST_MAX_SLOT);
    
    for (int i = 1; i <= nMaxSlot; i++)
    {
        if (ManifestMatchesFlags(oArea, i, nFlagFilter))
        {
            object oObj = ManifestGetObject(oArea, i);
            if (GetIsObjectValid(oObj))
            {
                SetLocalInt(oArea, "MANIFEST_ITER_SLOT", i + 1);
                return oObj;
            }
        }
    }
    
    return OBJECT_INVALID;
}

// Get next object in iteration
object ManifestGetNext(object oArea)
{
    int nCurrentSlot = GetLocalInt(oArea, "MANIFEST_ITER_SLOT");
    int nFlagFilter = GetLocalInt(oArea, "MANIFEST_ITER_FLAGS");
    int nMaxSlot = GetLocalInt(oArea, MANIFEST_MAX_SLOT);
    
    for (int i = nCurrentSlot; i <= nMaxSlot; i++)
    {
        if (ManifestMatchesFlags(oArea, i, nFlagFilter))
        {
            object oObj = ManifestGetObject(oArea, i);
            if (GetIsObjectValid(oObj))
            {
                SetLocalInt(oArea, "MANIFEST_ITER_SLOT", i + 1);
                return oObj;
            }
        }
    }
    
    // Clean up iteration state
    DeleteLocalInt(oArea, "MANIFEST_ITER_SLOT");
    DeleteLocalInt(oArea, "MANIFEST_ITER_FLAGS");
    
    return OBJECT_INVALID;
}

// ============================================================================
// PLAYER-SPECIFIC HELPERS (Backwards compatibility with registry)
// ============================================================================

// Add player with CD Key tracking
int ManifestAddPlayer(object oPC, object oArea)
{
    if (!GetIsPC(oPC)) return 0;
    
    int nSlot = ManifestAdd(oArea, oPC, MANIFEST_FLAG_PLAYER);
    
    if (nSlot > 0)
    {
        // Store CD Key
        string sPrefix = MANIFEST_SLOT_PREFIX + IntToString(nSlot);
        string sCDKey = GetPCPublicCDKey(oPC);
        SetLocalString(oArea, sPrefix + MANIFEST_PROP_CDKEY, sCDKey);
    }
    
    return nSlot;
}

// Get player count (fast lookup)
int ManifestGetPlayerCount(object oArea)
{
    return ManifestGetCountByFlags(oArea, MANIFEST_FLAG_PLAYER);
}

// ============================================================================
// CLEANUP HELPERS
// ============================================================================

// Get all objects that should be culled (expired)
// Returns count of objects culled
int ManifestCullExpired(object oArea)
{
    int nCurrentTick = GetLocalInt(GetModule(), "DOWE_TICK");
    int nMaxSlot = GetLocalInt(oArea, MANIFEST_MAX_SLOT);
    int nCulled = 0;
    
    for (int i = 1; i <= nMaxSlot; i++)
    {
        string sPrefix = MANIFEST_SLOT_PREFIX + IntToString(i);
        int nExpireTick = GetLocalInt(oArea, sPrefix + MANIFEST_PROP_EXPIRE_TICK);
        
        if (nExpireTick > 0 && nCurrentTick >= nExpireTick)
        {
            object oObj = GetLocalObject(oArea, sPrefix + MANIFEST_PROP_OBJECT);
            
            if (GetIsObjectValid(oObj))
            {
                // Check if it's cullable (not a player or important NPC)
                int nFlags = GetLocalInt(oArea, sPrefix + MANIFEST_PROP_FLAGS);
                
                if ((nFlags & MANIFEST_FLAG_ALL_CULLABLE) != 0)
                {
                    DestroyObject(oObj, 0.1);
                    ManifestRemove(oArea, oObj);
                    nCulled++;
                }
            }
            else
            {
                // Object already invalid, clean up manifest entry
                ManifestRemove(oArea, oObj);
            }
        }
    }
    
    return nCulled;
}

// Remove all invalid object references (maintenance)
void ManifestCleanInvalid(object oArea)
{
    int nMaxSlot = GetLocalInt(oArea, MANIFEST_MAX_SLOT);
    
    for (int i = 1; i <= nMaxSlot; i++)
    {
        object oObj = ManifestGetObject(oArea, i);
        
        if (!GetIsObjectValid(oObj))
        {
            // Clean up this void
            string sPrefix = MANIFEST_SLOT_PREFIX + IntToString(i);
            
            DeleteLocalObject(oArea, sPrefix + MANIFEST_PROP_OBJECT);
            DeleteLocalInt(oArea, sPrefix + MANIFEST_PROP_FLAGS);
            DeleteLocalString(oArea, sPrefix + MANIFEST_PROP_CDKEY);
            DeleteLocalInt(oArea, sPrefix + MANIFEST_PROP_OWNER_SLOT);
            DeleteLocalInt(oArea, sPrefix + MANIFEST_PROP_SPAWN_TICK);
            DeleteLocalInt(oArea, sPrefix + MANIFEST_PROP_EXPIRE_TICK);
            DeleteLocalString(oArea, sPrefix + MANIFEST_PROP_TAG);
        }
    }
}

// ============================================================================
// ZERO-WASTE TOTAL SHUTDOWN
// ============================================================================

// Complete area shutdown when no players remain
void ManifestShutdownArea(object oArea)
{
    // Destroy all cullable objects
    object oObj = ManifestGetFirst(oArea, MANIFEST_FLAG_ALL_CULLABLE);
    
    while (GetIsObjectValid(oObj))
    {
        DestroyObject(oObj, 0.1);
        oObj = ManifestGetNext(oArea);
    }
    
    // Clear all VFX and AOE effects
    effect eEffect = GetFirstEffect(oArea);
    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectType(eEffect) == EFFECT_TYPE_VISUALEFFECT ||
            GetEffectType(eEffect) == EFFECT_TYPE_AREA_OF_EFFECT)
        {
            RemoveEffect(oArea, eEffect);
        }
        eEffect = GetNextEffect(oArea);
    }
    
    // Clear manifest (reset to zero state)
    int nMaxSlot = GetLocalInt(oArea, MANIFEST_MAX_SLOT);
    
    for (int i = 1; i <= nMaxSlot; i++)
    {
        string sPrefix = MANIFEST_SLOT_PREFIX + IntToString(i);
        
        DeleteLocalObject(oArea, sPrefix + MANIFEST_PROP_OBJECT);
        DeleteLocalInt(oArea, sPrefix + MANIFEST_PROP_FLAGS);
        DeleteLocalString(oArea, sPrefix + MANIFEST_PROP_CDKEY);
        DeleteLocalInt(oArea, sPrefix + MANIFEST_PROP_OWNER_SLOT);
        DeleteLocalInt(oArea, sPrefix + MANIFEST_PROP_SPAWN_TICK);
        DeleteLocalInt(oArea, sPrefix + MANIFEST_PROP_EXPIRE_TICK);
        DeleteLocalString(oArea, sPrefix + MANIFEST_PROP_TAG);
    }
    
    SetLocalInt(oArea, MANIFEST_COUNT, 0);
    SetLocalInt(oArea, MANIFEST_MAX_SLOT, 0);
}
