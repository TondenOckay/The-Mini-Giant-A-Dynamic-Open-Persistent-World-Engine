/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard)
    DATE: February 12, 2026
    Script Name: area_on_drop
    
    OPTIMIZATION:
    Plot flag pre-check prevents plot items from ever entering manifest.
    Self-registers to manifest with expiration tick.
   ============================================================================
*/

#include "area_manifest_inc"
#include "area_const_inc"

void main()
{
    object oItem = GetModuleItemLost();
    
    if (!GetIsObjectValid(oItem)) return;
    
    // PLOT FLAG PRE-CHECK - Plot items never enter cleanup system
    if (GetPlotFlag(oItem) || GetItemCursedFlag(oItem)) return;
    
    object oArea = GetArea(oItem);
    int nItemLife = GetLocalInt(GetModule(), DOWE_CFG_ITEM_LIFE);
    
    // Self-register to manifest with expiration
    ManifestAdd(oArea, oItem, MANIFEST_FLAG_DROPPED_ITEM, nItemLife);
}
