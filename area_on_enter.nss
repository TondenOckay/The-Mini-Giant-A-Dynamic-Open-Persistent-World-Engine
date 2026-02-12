/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_on_enter
    Event: OnAreaEnter
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    Handles player entry into areas. Registers player in VIP list,
    spawns fast NPCs if enabled, and wakes up the mini-server.
   ============================================================================
*/

#include "area_registry_inc"

void main()
{
    object oPC = GetEnteringObject();
    object oArea = OBJECT_SELF;
    
    if (!GetIsPC(oPC)) return;
    
    // Register player in VIP list
    int nSlot = RegistryAddPlayer(oPC, oArea);
    
    // Spawn Type 1 (fast) NPCs if enabled
    if (GetLocalInt(GetModule(), DOWE_LIVE_NPC_ENABLED))
    {
        ExecuteScript("live_npc_spawn_fast", oArea);
    }
}
