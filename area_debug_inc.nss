/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_debug_inc
    
    PILLARS:
    1. Independent Mini-Servers Architecture
    2. Phase-Staggered Performance Optimization
    3. Total Resource Management (Zero-Waste)
    
    DESCRIPTION:
    Debug reporting system for all DOWE components. Provides unified logging
    and player chat output for troubleshooting and performance monitoring.
    
    USAGE:
    #include "area_debug_inc"
    DebugReport(oArea, "System X completed action Y");
    
    PERFORMANCE:
    When debug is disabled, this has ZERO performance overhead (early return).
    When enabled, outputs are batched and sent via efficient chat messages.
   ============================================================================
*/

#include "area_const_inc"

// ============================================================================
// CORE DEBUG FUNCTION
// ============================================================================

// Main debug reporting function used by all DOWE systems
// oArea: The area this debug message relates to (can be OBJECT_INVALID for module-level)
// sMessage: The debug message to output
// nVerboseOnly: If TRUE, only shows when DOWE_DEBUG_VERBOSE is enabled
void DebugReport(object oArea, string sMessage, int nVerboseOnly = FALSE)
{
    object oModule = GetModule();
    
    // Early exit if debug is disabled (zero performance cost)
    int bDebugEnabled = GetLocalInt(oModule, DOWE_DEBUG_ENABLED);
    if (!bDebugEnabled) return;
    
    // Check verbose flag
    if (nVerboseOnly)
    {
        int bVerbose = GetLocalInt(oModule, DOWE_DEBUG_VERBOSE);
        if (!bVerbose) return;
    }
    
    // Format the message with timestamp and area tag
    string sAreaTag = GetIsObjectValid(oArea) ? GetTag(oArea) : "MODULE";
    int nTick = GetLocalInt(oModule, DOWE_TICK);
    
    string sOutput = "[DOWE-" + IntToString(nTick) + "] [" + sAreaTag + "] " + sMessage;
    
    // Output to server log
    WriteTimestampedLogEntry(sOutput);
    
    // Output to all DMs
    SendMessageToAllDMs(sOutput);
    
    // If area is valid, send to all PCs in that area
    if (GetIsObjectValid(oArea))
    {
        object oPC = GetFirstPC();
        while (GetIsObjectValid(oPC))
        {
            if (GetArea(oPC) == oArea)
            {
                SendMessageToPC(oPC, sOutput);
            }
            oPC = GetNextPC();
        }
    }
}

// ============================================================================
// SPECIALIZED DEBUG FUNCTIONS
// ============================================================================

// Registry-specific debug (only shows if DOWE_DEBUG_REGISTRY is enabled)
void DebugRegistry(object oArea, string sMessage)
{
    object oModule = GetModule();
    if (!GetLocalInt(oModule, DOWE_DEBUG_REGISTRY)) return;
    
    DebugReport(oArea, "[REGISTRY] " + sMessage);
}

// Encounter-specific debug
void DebugEncounter(object oArea, string sMessage)
{
    object oModule = GetModule();
    if (!GetLocalInt(oModule, DOWE_DEBUG_ENCOUNTERS)) return;
    
    DebugReport(oArea, "[ENCOUNTER] " + sMessage);
}

// MUD command debug
void DebugMud(object oPC, string sMessage)
{
    object oModule = GetModule();
    if (!GetLocalInt(oModule, DOWE_DEBUG_MUD)) return;
    
    object oArea = GetArea(oPC);
    string sPlayerName = GetName(oPC);
    DebugReport(oArea, "[MUD:" + sPlayerName + "] " + sMessage);
}

// SQL debug
void DebugSQL(string sQuery, int nSuccess)
{
    object oModule = GetModule();
    if (!GetLocalInt(oModule, DOWE_DEBUG_SQL)) return;
    
    string sStatus = nSuccess ? "SUCCESS" : "FAILED";
    string sMessage = "[SQL-" + sStatus + "] " + sQuery;
    
    WriteTimestampedLogEntry(sMessage);
    SendMessageToAllDMs(sMessage);
}

// ============================================================================
// PERFORMANCE PROFILING
// ============================================================================

// Start a performance timer for a system
// Returns the current timestamp (use with DebugProfileEnd)
int DebugProfileStart(string sSystemName)
{
    object oModule = GetModule();
    if (!GetLocalInt(oModule, DOWE_DEBUG_VERBOSE)) return 0;
    
    // Store start time in milliseconds (NWN doesn't have native ms timer, so we fake it)
    int nStartTime = GetTimeSecond() * 1000 + GetTimeMillisecond();
    SetLocalInt(oModule, "DOWE_PROFILE_" + sSystemName, nStartTime);
    
    return nStartTime;
}

// End a performance timer and report duration
void DebugProfileEnd(string sSystemName, object oArea = OBJECT_INVALID)
{
    object oModule = GetModule();
    if (!GetLocalInt(oModule, DOWE_DEBUG_VERBOSE)) return;
    
    int nStartTime = GetLocalInt(oModule, "DOWE_PROFILE_" + sSystemName);
    if (nStartTime == 0) return; // Timer wasn't started
    
    int nEndTime = GetTimeSecond() * 1000 + GetTimeMillisecond();
    int nDuration = nEndTime - nStartTime;
    
    string sMessage = "[PROFILE] " + sSystemName + " completed in " + 
                     IntToString(nDuration) + "ms";
    
    DebugReport(oArea, sMessage, TRUE);
    
    // Clean up
    DeleteLocalInt(oModule, "DOWE_PROFILE_" + sSystemName);
}

// ============================================================================
// ERROR REPORTING
// ============================================================================

// Report critical errors (always shows, even if debug is off)
void DebugError(object oArea, string sErrorMessage)
{
    string sAreaTag = GetIsObjectValid(oArea) ? GetTag(oArea) : "MODULE";
    string sOutput = "[DOWE-ERROR] [" + sAreaTag + "] " + sErrorMessage;
    
    // Always log errors
    WriteTimestampedLogEntry(sOutput);
    SendMessageToAllDMs(sOutput);
    
    // Alert in server log with severity marker
    PrintString("!!! " + sOutput + " !!!");
}

// ============================================================================
// DEBUG TOGGLE COMMANDS (Called by DM console commands)
// ============================================================================

// Enable/disable debug mode
void SetDoweDebug(int bEnabled)
{
    SetLocalInt(GetModule(), DOWE_DEBUG_ENABLED, bEnabled);
    
    string sStatus = bEnabled ? "ENABLED" : "DISABLED";
    SendMessageToAllDMs("DOWE Debug Mode: " + sStatus);
}

// Enable/disable verbose mode
void SetDoweDebugVerbose(int bEnabled)
{
    SetLocalInt(GetModule(), DOWE_DEBUG_VERBOSE, bEnabled);
    
    string sStatus = bEnabled ? "ENABLED" : "DISABLED";
    SendMessageToAllDMs("DOWE Verbose Debug: " + sStatus);
}

// Enable/disable specific subsystem debugging
void SetDoweDebugSubsystem(string sSubsystem, int bEnabled)
{
    string sVarName = "DOWE_DEBUG_" + sSubsystem;
    SetLocalInt(GetModule(), sVarName, bEnabled);
    
    string sStatus = bEnabled ? "ENABLED" : "DISABLED";
    SendMessageToAllDMs("DOWE Debug [" + sSubsystem + "]: " + sStatus);
}
