/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard)
    DATE: February 12, 2026
    Script Name: area_janitor
    
    TRUE ZERO-WASTE:
    - Saves player data (staggered if multiple players)
    - Transfers or despawns owned encounters
    - Clears AOEs, VFX, summons when area empties
    - Complete manifest shutdown on last player exit
   ============================================================================
*/

#include "area_manifest_inc"
#include "area_sql_inc"

void main()
{
    object oPC = OBJECT_SELF;
    object oArea = GetArea(oPC);
    
    if (!GetIsPC(oPC)) return;
    
    int nPlayerSlot = GetLocalInt(oPC, "MANIFEST_SLOT");
    
    // Save player data
    SQLSavePlayerData(oPC);
    
    // Handle encounters owned by this player
    object oCreature = ManifestGetFirst(oArea, MANIFEST_FLAG_CREATURE);
    int nTransferred = 0;
    int nDespawned = 0;
    
    while (GetIsObjectValid(oCreature))
    {
        string sPrefix = "MANIFEST_SLOT_" + IntToString(GetLocalInt(oCreature, "MANIFEST_SLOT"));
        int nOwnerSlot = GetLocalInt(oArea, sPrefix + "_OWNER");
        
        if (nOwnerSlot == nPlayerSlot)
        {
            // Try to transfer to nearby player
            object oNearestPC = ManifestGetFirst(oArea, MANIFEST_FLAG_PLAYER);
            object oTransferTarget = OBJECT_INVALID;
            float fNearestDist = 999.0;
            
            while (GetIsObjectValid(oNearestPC))
            {
                if (oNearestPC != oPC)
                {
                    float fDist = GetDistanceBetween(oCreature, oNearestPC);
                    if (fDist < 30.0 && fDist < fNearestDist)
                    {
                        oTransferTarget = oNearestPC;
                        fNearestDist = fDist;
                    }
                }
                oNearestPC = ManifestGetNext(oArea);
            }
            
            if (GetIsObjectValid(oTransferTarget))
            {
                // Transfer ownership
                int nNewSlot = GetLocalInt(oTransferTarget, "MANIFEST_SLOT");
                SetLocalInt(oArea, sPrefix + "_OWNER", nNewSlot);
                nTransferred++;
            }
            else
            {
                // Despawn
                DestroyObject(oCreature, 0.5);
                ManifestRemove(oArea, oCreature);
                nDespawned++;
            }
        }
        
        oCreature = ManifestGetNext(oArea);
    }
    
    // Remove player from manifest
    ManifestRemove(oArea, oPC);
    
    // Check if area is now empty
    int nRemainingPlayers = ManifestGetPlayerCount(oArea);
    
    if (nRemainingPlayers == 0)
    {
        // TRUE ZERO-WASTE: Complete shutdown
        ManifestShutdownArea(oArea);
        
        if (GetDoweDebug())
        {
            SendMessageToAllDMs("JANITOR: Area " + GetTag(oArea) + 
                               " entered Zero-Waste dormancy (complete shutdown)");
        }
    }
    else if (GetDoweDebug())
    {
        SendMessageToAllDMs("JANITOR: " + GetName(oPC) + " exited. " +
                           "Transferred: " + IntToString(nTransferred) + 
                           " | Despawned: " + IntToString(nDespawned) +
                           " | Remaining players: " + IntToString(nRemainingPlayers));
    }
}
