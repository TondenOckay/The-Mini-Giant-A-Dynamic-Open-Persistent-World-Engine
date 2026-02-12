/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_cleanup
    Triggered By: area_switchboard (Phase 1)
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    Enhanced Resource Cleanup - Phase 1 of area processing cycle.
    Prepares the area "canvas" for NPCs and encounters by removing
    expired corpses, dropped items, and empty containers.
   ============================================================================
*/

#include "area_debug_inc"
#include "area_const_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oModule = GetModule();
    int nObjectsCleaned = 0;
    
    int nCurrentTick = GetDoweTick();
    
    // Load cached config
    int nRemainsLife = GetLocalInt(oModule, DOWE_CFG_REMAINS_LIFE);
    int nItemLife    = GetLocalInt(oModule, DOWE_CFG_ITEM_LIFE);
    int nPlayerCorpseLife = GetLocalInt(oModule, DOWE_CFG_PLAYER_CORPSE_LIFE);
    
    // Fallback defaults
    if (nRemainsLife == 0) nRemainsLife = 30;
    if (nItemLife == 0) nItemLife = 100;
    if (nPlayerCorpseLife == 0) nPlayerCorpseLife = 600;
    
    object oItem = GetFirstObjectInArea(oArea);
    
    while (GetIsObjectValid(oItem))
    {
        int nType = GetObjectType(oItem);
        
        // Early exit for non-target types
        if (nType != OBJECT_TYPE_PLACEABLE && nType != OBJECT_TYPE_ITEM)
        {
            oItem = GetNextObjectInArea(oArea);
            continue;
        }
        
        // TARGET A: BODY BAGS & REMAINS
        if (nType == OBJECT_TYPE_PLACEABLE)
        {
            string sTag = GetTag(oItem);
            
            if (sTag == "BodyBag" || GetStringLeft(sTag, 8) == "NW_CORP_")
            {
                if (GetFirstItemInInventory(oItem) == OBJECT_INVALID)
                {
                    int nDeathTick = GetLocalInt(oItem, DOWE_DEATH_TICK);
                    
                    if (nDeathTick == 0)
                    {
                        SetLocalInt(oItem, DOWE_DEATH_TICK, nCurrentTick);
                    }
                    else
                    {
                        int bIsPlayerCorpse = GetLocalInt(oItem, DOWE_PLAYER_CORPSE);
                        int nLifespan = bIsPlayerCorpse ? nPlayerCorpseLife : nRemainsLife;
                        
                        int nTicksElapsed = nCurrentTick - nDeathTick;
                        
                        if (nTicksElapsed > nLifespan)
                        {
                            DestroyObject(oItem, 0.1);
                            nObjectsCleaned++;
                        }
                    }
                }
            }
        }
        
        // TARGET B: DROPPED ITEMS
        else if (nType == OBJECT_TYPE_ITEM)
        {
            if (GetPlotFlag(oItem) || GetItemCursedFlag(oItem))
            {
                oItem = GetNextObjectInArea(oArea);
                continue;
            }
            
            int nDropTick = GetLocalInt(oItem, DOWE_DROP_TICK);
            
            if (nDropTick == 0)
            {
                SetLocalInt(oItem, DOWE_DROP_TICK, nCurrentTick);
            }
            else
            {
                int nTicksElapsed = nCurrentTick - nDropTick;
                
                if (nTicksElapsed > nItemLife)
                {
                    DestroyObject(oItem, 0.1);
                    nObjectsCleaned++;
                }
            }
        }
        
        oItem = GetNextObjectInArea(oArea);
    }
    
    if (nObjectsCleaned > 0)
    {
        DebugReport(oArea, "CLEANUP: Purged " + IntToString(nObjectsCleaned) + " objects");
    }
}
