/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_heartbeat
    Event: OnAreaHeartbeat
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    Area Heartbeat Safety Net. Normally dormant while area_dispatcher
    handles processing. Activates failsafe if dispatcher fails.
   ============================================================================
*/

#include "area_debug_inc"
#include "area_const_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oModule = GetModule();
    
    int nCurrentTick = GetDoweTick();
    int nLastDispatchTick = GetLocalInt(oModule, DOWE_LAST_DISPATCH_TICK);
    
    int nTicksSinceDispatch = nCurrentTick - nLastDispatchTick;
    
    if (nTicksSinceDispatch > DOWE_FAILSAFE_MISSED_BEATS)
    {
        int nPlayerCount = GetLocalInt(oArea, DOWE_REG_PLAYER_COUNT);
        
        if (nPlayerCount > 0)
        {
            ExecuteScript("area_switchboard", oArea);
            
            string sWarning = "FAILSAFE: Dispatcher offline for " + 
                            IntToString(nTicksSinceDispatch) + " ticks. " +
                            "Emergency processing activated.";
            
            DebugError(oArea, sWarning);
        }
    }
}
