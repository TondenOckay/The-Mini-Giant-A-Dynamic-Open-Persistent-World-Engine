/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_on_load
    Event: OnModuleLoad
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    Module initialization. Caches 2DA config, initializes registry,
    and prepares all DOWE systems for operation.
   ============================================================================
*/

#include "area_const_inc"
#include "area_debug_inc"
#include "area_registry_inc"

void main()
{
    object oModule = GetModule();
    
    // Initialize tick counter
    SetLocalInt(oModule, DOWE_TICK, 0);
    SetLocalInt(oModule, DOWE_LAST_DISPATCH_TICK, 0);
    
    // Cache 2DA configuration
    int nRemainsLife = StringToInt(Get2DAString("cleanup_config", "LifespanTicks", 0));
    int nLootBagLife = StringToInt(Get2DAString("cleanup_config", "LifespanTicks", 1));
    int nItemLife    = StringToInt(Get2DAString("cleanup_config", "LifespanTicks", 2));
    int nPlayerCorpseLife = StringToInt(Get2DAString("cleanup_config", "LifespanTicks", 3));
    
    SetLocalInt(oModule, DOWE_CFG_REMAINS_LIFE, nRemainsLife);
    SetLocalInt(oModule, DOWE_CFG_LOOTBAG_LIFE, nLootBagLife);
    SetLocalInt(oModule, DOWE_CFG_ITEM_LIFE, nItemLife);
    SetLocalInt(oModule, DOWE_CFG_PLAYER_CORPSE_LIFE, nPlayerCorpseLife);
    
    // Set default debug levels
    SetLocalInt(oModule, DOWE_DEBUG_ENABLED, FALSE);
    SetLocalInt(oModule, DOWE_DEBUG_VERBOSE, FALSE);
    
    // Initialize all areas
    object oArea = GetFirstArea();
    int nAreaCount = 0;
    
    while (GetIsObjectValid(oArea))
    {
        RegistryInitialize(oArea, DOWE_DEFAULT_MAX_SLOTS);
        nAreaCount++;
        oArea = GetNextArea();
    }
    
    string sMsg = "DOWE 'The Mini Giant' v1.0 initialized | " +
                 "Areas: " + IntToString(nAreaCount) + " | " +
                 "Ready for 480+ players";
    
    WriteTimestampedLogEntry(sMsg);
    SendMessageToAllDMs(sMsg);
}
