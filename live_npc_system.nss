/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard)
    DATE: February 12, 2026
    Script Name: live_npc_system
    
    NO AREA SCANNING:
    NPCs self-register to manifest on spawn. We just check manifest for
    Type 2 waypoints and spawn if not already present.
   ============================================================================
*/

#include "area_manifest_inc"
#include "area_const_inc"

void main()
{
    object oArea = OBJECT_SELF;
    
    if (!GetLocalInt(GetModule(), DOWE_LIVE_NPC_ENABLED)) return;
    
    // Look at waypoint manifest (these were added on area load)
    object oWP = ManifestGetFirst(oArea, MANIFEST_FLAG_WAYPOINT_NPC);
    int nSpawned = 0;
    
    while (GetIsObjectValid(oWP))
    {
        string sTag = GetTag(oWP);
        
        // Check if this is Type 2 (normal spawn)
        if (GetStringRight(sTag, 1) == "2")
        {
            // Check if NPC already spawned
            if (!GetLocalInt(oWP, "NPC_SPAWNED"))
            {
                // TODO: Spawn NPC from blueprint
                // object oNPC = CreateObject(OBJECT_TYPE_CREATURE, "blueprint", GetLocation(oWP));
                // ManifestAdd(oArea, oNPC, MANIFEST_FLAG_LIVE_NPC);
                
                SetLocalInt(oWP, "NPC_SPAWNED", TRUE);
                nSpawned++;
            }
        }
        
        oWP = ManifestGetNext(oArea);
    }
    
    if (nSpawned > 0 && GetDoweDebug())
    {
        SendMessageToAllDMs("LIVE_NPC: Spawned " + IntToString(nSpawned) + " Type 2 NPCs");
    }
}
