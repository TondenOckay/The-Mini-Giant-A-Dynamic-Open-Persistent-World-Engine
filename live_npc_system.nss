/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: live_npc_system
    Triggered By: area_switchboard (Phase 2)
    
    DESCRIPTION:
    Spawns Type 2 (normal) test NPCs from waypoints.
    Type 1 (fast) NPCs are spawned in area_on_enter.
    
    WAYPOINT NAMING:
    - LIVENPC_[NAME]_1 = Fast spawn (before player enters)
    - LIVENPC_[NAME]_2 = Normal spawn (after player enters)
   ============================================================================
*/

#include "area_const_inc"

void main()
{
    object oArea = OBJECT_SELF;
    
    // Check if system is enabled
    if (!GetLocalInt(GetModule(), DOWE_LIVE_NPC_ENABLED)) return;
    
    // Find all Type 2 waypoints and spawn NPCs
    object oWP = GetFirstObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
    int nSpawned = 0;
    
    while (GetIsObjectValid(oWP))
    {
        string sTag = GetTag(oWP);
        
        if (GetStringLeft(sTag, 8) == "LIVENPC_")
        {
            // Extract spawn type (last character)
            string sType = GetStringRight(sTag, 1);
            
            if (sType == "2")  // Type 2 = Normal spawn
            {
                // Check if NPC already spawned
                if (!GetLocalInt(oWP, "NPC_SPAWNED"))
                {
                    // Extract NPC name (between LIVENPC_ and _2)
                    string sNPCName = GetSubString(sTag, 8, GetStringLength(sTag) - 10);
                    
                    // TODO: Spawn NPC from blueprint
                    // object oNPC = CreateObject(OBJECT_TYPE_CREATURE, "blueprint_" + sNPCName, 
                    //                            GetLocation(oWP));
                    
                    // Register NPC as PC for testing
                    // RegistryAddPlayer(oNPC, oArea);
                    
                    SetLocalInt(oWP, "NPC_SPAWNED", TRUE);
                    nSpawned++;
                }
            }
        }
        
        oWP = GetNextObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
    }
    
    if (nSpawned > 0)
    {
        DebugReport(oArea, "Live NPC System: Spawned " + IntToString(nSpawned) + 
                   " Type 2 (normal) NPCs");
    }
}
