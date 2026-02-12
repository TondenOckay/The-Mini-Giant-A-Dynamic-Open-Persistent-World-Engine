/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard)
    DATE: February 12, 2026
    Script Name: area_on_enter
    
    REVOLUTION:
    Old: Scan entire area for Type 1 NPCs
    New: NPCs are already in manifest, O(1) lookup
   ============================================================================
*/

#include "area_manifest_inc"

void main()
{
    object oPC = GetEnteringObject();
    object oArea = OBJECT_SELF;
    
    if (!GetIsPC(oPC)) return;
    
    // Add to manifest (self-registering)
    ManifestAddPlayer(oPC, oArea);
    
    // Type 1 NPCs spawn happens in live_npc_system via manifest lookup
    // NO AREA SCANNING
}
