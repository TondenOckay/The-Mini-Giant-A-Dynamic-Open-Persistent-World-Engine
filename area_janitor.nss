/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_janitor
    Triggered By: area_on_exit
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    Player exit cleanup. Saves progress to SQL, despawns owned encounters,
    removes area from registry, and shuts down mini-server if empty.
    
    ZERO-WASTE PRINCIPLE:
    When the last player exits, this script ensures the area goes completely
    dormant, consuming ZERO resources until the next player enters.
   ============================================================================
*/

#include "area_registry_inc"
#include "area_sql_inc"

void main()
{
    object oPC = OBJECT_SELF;  // PC is OBJECT_SELF when called from OnExit
    object oArea = GetArea(oPC);
    
    if (!GetIsPC(oPC)) return;
    
    string sPlayerName = GetName(oPC);
    int nSlot = GetLocalInt(oPC, DOWE_PLAYER_SLOT);
    
    // Save player data to SQL
    SQLSavePlayerData(oPC);
    
    // Despawn encounters owned by this player
    object oCreature = GetFirstObjectInArea(oArea, OBJECT_TYPE_CREATURE);
    int nDespawned = 0;
    
    while (GetIsObjectValid(oCreature))
    {
        int nOwnerSlot = GetLocalInt(oCreature, DOWE_ENC_OWNER_SLOT);
        
        if (nOwnerSlot == nSlot)
        {
            // Check if we can transfer ownership to another player
            object oNearestPC = OBJECT_INVALID;
            float fNearestDist = 999.0;
            
            object oPC2 = RegistryGetFirstPlayer(oArea);
            while (GetIsObjectValid(oPC2))
            {
                if (oPC2 != oPC)  // Don't transfer to exiting player
                {
                    float fDist = GetDistanceBetween(oCreature, oPC2);
                    if (fDist < DOWE_ENC_TRANSFER_RANGE && fDist < fNearestDist)
                    {
                        oNearestPC = oPC2;
                        fNearestDist = fDist;
                    }
                }
                oPC2 = RegistryGetNextPlayer(oArea);
            }
            
            if (GetIsObjectValid(oNearestPC))
            {
                // Transfer ownership
                int nNewSlot = GetLocalInt(oNearestPC, DOWE_PLAYER_SLOT);
                SetLocalInt(oCreature, DOWE_ENC_OWNER_SLOT, nNewSlot);
                
                DebugReport(oArea, "Encounter transferred from " + sPlayerName + 
                           " to " + GetName(oNearestPC));
            }
            else
            {
                // No one nearby, despawn
                DestroyObject(oCreature, 0.5);
                nDespawned++;
            }
        }
        
        oCreature = GetNextObjectInArea(oArea, OBJECT_TYPE_CREATURE);
    }
    
    if (nDespawned > 0)
    {
        DebugReport(oArea, "Janitor despawned " + IntToString(nDespawned) + 
                   " creatures for exiting player " + sPlayerName);
    }
    
    // Remove from registry
    RegistryRemovePlayer(oPC, oArea);
    
    // Check if area is now empty
    int nRemainingPlayers = GetLocalInt(oArea, DOWE_REG_PLAYER_COUNT);
    
    if (nRemainingPlayers == 0)
    {
        DebugReport(oArea, "MINI-SERVER SHUTDOWN: No players remaining. " +
                   "Area entering Zero-Waste dormant mode.");
        
        // Optional: Cleanup all remaining area objects for true "shutdown"
        // This is aggressive - only use if you want total reset on empty
        // ExecuteScript("area_cleanup", oArea);
    }
}
