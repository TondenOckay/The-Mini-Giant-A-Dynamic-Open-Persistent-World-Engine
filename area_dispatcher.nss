/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard - Manifest Architecture)
    DATE: February 12, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_dispatcher
    Event: OnModuleHeartbeat
    
    DESCRIPTION:
    Uses manifest for O(1) player count checks instead of registry.
   ============================================================================
*/

#include "area_manifest_inc"
#include "area_const_inc"

void main()
{
    object oModule = GetModule();
    
    // Tick management
    int nTick = GetLocalInt(oModule, DOWE_TICK) + 1;
    if (nTick > DOWE_TICK_RESET_THRESHOLD) nTick = 1;
    SetLocalInt(oModule, DOWE_TICK, nTick);
    SetLocalInt(oModule, DOWE_LAST_DISPATCH_TICK, nTick);
    
    // Count active areas via manifest
    int nActiveAreas = 0;
    object oArea = GetFirstArea();
    
    while (GetIsObjectValid(oArea))
    {
        if (ManifestGetPlayerCount(oArea) > 0) nActiveAreas++;
        oArea = GetNextArea();
    }
    
    // Dynamic stagger calculation
    float fIncrement = 4.5 / IntToFloat(nActiveAreas);
    if (fIncrement < 0.1) fIncrement = 0.1;
    if (fIncrement > 0.5) fIncrement = 0.5;
    if (nActiveAreas == 0) fIncrement = 0.25;
    
    // Dispatch loop
    float fStagger = 0.0;
    oArea = GetFirstArea();
    
    while (GetIsObjectValid(oArea))
    {
        if (ManifestGetPlayerCount(oArea) > 0)
        {
            DelayCommand(fStagger, ExecuteScript("area_switchboard", oArea));
            fStagger += fIncrement;
        }
        
        oArea = GetNextArea();
    }
    
    if (GetDoweDebug())
    {
        SendMessageToAllDMs("DISPATCHER: Tick " + IntToString(nTick) + 
                           " | Active: " + IntToString(nActiveAreas));
    }
}
