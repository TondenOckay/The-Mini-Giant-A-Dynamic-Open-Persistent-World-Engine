/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_switchboard
    Triggered By: area_dispatcher (via DelayCommand)
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    The Area-level Switchboard. Receives dispatch signal and orchestrates
    the three-phase processing sequence with internal staggering to prevent
    single-frame CPU spikes.
    
    PHASE ARCHITECTURE:
    Phase 1 (0.0s):  Resource Cleanup - Prepare the "canvas" (LIGHT)
    Phase 2 (1.5s):  Live NPCs & Maintenance - Moderate operations (MEDIUM)
    Phase 3 (3.0s):  Encounter System - Heavy spawning/AI (HEAVY)
    
    WHY THIS MATTERS:
    By staggering heavy operations, we ensure that spawning NPCs doesn't
    compete with cleanup for CPU cycles. This is the "breathing" pattern
    that allows mini-servers to handle high player counts smoothly.
   ============================================================================
*/

#include "area_debug_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oModule = GetModule();
    
    // Update area's last processed tick
    int nCurrentTick = GetLocalInt(oModule, "DOWE_TICK");
    SetLocalInt(oArea, "DOWE_LAST_SWITCHBOARD_TICK", nCurrentTick);
    
    // ========================================================================
    // PHASE 1: RESOURCE CLEANUP (0.0s - Immediate)
    // ========================================================================
    // Removes corpses, dropped items, expired containers.
    // MUST run first to reduce object count for later phases.
    ExecuteScript("area_cleanup", oArea);
    
    // ========================================================================
    // PHASE 2: LIVE NPCs & MAINTENANCE (1.5s - Medium Load)
    // ========================================================================
    // Spawns Type 2 (normal) test NPCs if system is enabled.
    // Handles any area maintenance tasks.
    DelayCommand(1.5, ExecuteScript("live_npc_system", oArea));
    
    // ========================================================================
    // PHASE 3: ENCOUNTER SYSTEM (3.0s - Heavy Load)
    // ========================================================================
    // Dynamic spawning, GPS tracking, encounter ownership.
    // This is the heaviest operation, so it runs last.
    DelayCommand(3.0, ExecuteScript("enc_main", oArea));
    
    // ========================================================================
    // DEBUG REPORTING
    // ========================================================================
    if (GetLocalInt(oModule, "DOWE_DEBUG"))
    {
        string sAreaTag = GetTag(oArea);
        int nPlayerCount = GetLocalInt(oArea, "DOWE_REG_PLAYER_COUNT");
        
        DebugReport(oArea, "SWITCHBOARD: 3-Phase cycle for " + sAreaTag + 
                   " (" + IntToString(nPlayerCount) + " players) | " +
                   "Cleanup(0.0s) -> NPCs(1.5s) -> Encounters(3.0s)");
    }
}
