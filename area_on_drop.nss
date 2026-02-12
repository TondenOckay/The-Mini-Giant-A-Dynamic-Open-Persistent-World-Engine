/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_on_drop
    Event: OnPlayerUnacquireItem (Module)
    
    DESCRIPTION:
    Tags dropped items with timestamp for cleanup system.
   ============================================================================
*/

#include "area_const_inc"

void main()
{
    object oItem = GetModuleItemLost();
    
    if (GetIsObjectValid(oItem))
    {
        int nCurrentTick = GetDoweTick();
        SetLocalInt(oItem, DOWE_DROP_TICK, nCurrentTick);
    }
}
