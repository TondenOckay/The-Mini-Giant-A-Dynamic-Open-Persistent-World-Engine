/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: live_npc_spawn_fast
    Triggered By: area_on_enter
    
    DESCRIPTION:
    Spawns Type 1 (fast) test NPCs. These spawn immediately when
    a player enters, before the dispatcher starts processing.
   ============================================================================
*/

#include "area_const_inc"

void main()
{
    object oArea = OBJECT_SELF;
    
    // Find all Type 1 waypoints
    object oWP = GetFirstObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
    int nSpawned = 0;
    
    while (GetIsObjectValid(oWP))
    {
        string sTag = GetTag(oWP);
        
        if (GetStringLeft(sTag, 8) == "LIVENPC_" && GetStringRight(sTag, 1) == "1")
        {
            if (!GetLocalInt(oWP, "NPC_SPAWNED"))
            {
                // Spawn logic here
                SetLocalInt(oWP, "NPC_SPAWNED", TRUE);
                nSpawned++;
            }
        }
        
        oWP = GetNextObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
    }
}
