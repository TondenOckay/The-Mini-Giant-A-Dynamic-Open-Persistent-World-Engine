/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_on_exit
    Event: OnAreaExit
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    Handles player exit from areas. Triggers janitor cleanup.
   ============================================================================
*/

#include "area_registry_inc"

void main()
{
    object oPC = GetExitingObject();
    object oArea = OBJECT_SELF;
    
    if (!GetIsPC(oPC)) return;
    
    // Trigger janitor for this player
    ExecuteScript("area_janitor", oPC);
}
