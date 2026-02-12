/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard)
    DATE: February 12, 2026
    Script Name: area_heartbeat
   ============================================================================
*/

#include "area_manifest_inc"
#include "area_const_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oModule = GetModule();
    
    int nCurrentTick = GetDoweTick();
    int nLastDispatchTick = GetLocalInt(oModule, DOWE_LAST_DISPATCH_TICK);
    
    if (nCurrentTick - nLastDispatchTick > DOWE_FAILSAFE_MISSED_BEATS)
    {
        if (ManifestGetPlayerCount(oArea) > 0)
        {
            ExecuteScript("area_switchboard", oArea);
            SendMessageToAllDMs("FAILSAFE: Dispatcher offline. Emergency processing for " + GetTag(oArea));
        }
    }
}
