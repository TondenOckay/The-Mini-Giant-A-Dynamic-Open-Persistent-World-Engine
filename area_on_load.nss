/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard)
    DATE: February 12, 2026
    Script Name: area_on_load
   ============================================================================
*/

#include "area_const_inc"

void main()
{
    object oModule = GetModule();
    
    // Initialize tick
    SetLocalInt(oModule, DOWE_TICK, 0);
    SetLocalInt(oModule, DOWE_LAST_DISPATCH_TICK, 0);
    
    // Cache 2DA configuration
    int nRemainsLife = StringToInt(Get2DAString("cleanup_config", "LifespanTicks", 0));
    int nItemLife = StringToInt(Get2DAString("cleanup_config", "LifespanTicks", 2));
    int nPlayerCorpseLife = StringToInt(Get2DAString("cleanup_config", "LifespanTicks", 3));
    
    SetLocalInt(oModule, DOWE_CFG_REMAINS_LIFE, nRemainsLife);
    SetLocalInt(oModule, DOWE_CFG_ITEM_LIFE, nItemLife);
    SetLocalInt(oModule, DOWE_CFG_PLAYER_CORPSE_LIFE, nPlayerCorpseLife);
    
    // Set defaults
    SetLocalInt(oModule, DOWE_DEBUG_ENABLED, FALSE);
    SetLocalInt(oModule, DOWE_SQL_USE_EXTERNAL, FALSE);  // Default to internal
    
    WriteTimestampedLogEntry("DOWE 'The Mini Giant' v2.0 (Platinum Standard) initialized - Manifest Architecture");
}
