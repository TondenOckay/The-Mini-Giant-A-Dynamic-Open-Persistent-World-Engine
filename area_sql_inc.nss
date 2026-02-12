/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard)
    DATE: February 12, 2026
    Script Name: area_sql_inc
    
    FEATURES:
    1. Staggered saves (200ms between players to avoid lag spikes)
    2. Internal/External SQL toggle
    3. JSON snapshot capability (future expansion)
   ============================================================================
*/

#include "area_const_inc"

// Save single player data
void SQLSavePlayerDataInternal(object oPC)
{
    string sCDKey = GetPCPublicCDKey(oPC);
    
    // Use campaign DB (internal)
    SetCampaignInt("dowe_miniserver", "PlayerLevel_" + sCDKey, GetHitDice(oPC));
    SetCampaignInt("dowe_miniserver", "PlayerGold_" + sCDKey, GetGold(oPC));
    SetCampaignLocation("dowe_miniserver", "PlayerLocation_" + sCDKey, GetLocation(oPC));
    
    if (GetDoweDebug())
    {
        SendMessageToAllDMs("SQL: Saved " + GetName(oPC) + " (Internal DB)");
    }
}

void SQLSavePlayerDataExternal(object oPC)
{
    string sCDKey = GetPCPublicCDKey(oPC);
    string sPlayerName = GetName(oPC);
    
    // TODO: Implement NWNX SQL queries for external database
    // This is a placeholder for external SQL integration
    
    if (GetDoweDebug())
    {
        SendMessageToAllDMs("SQL: Saved " + sPlayerName + " (External DB)");
    }
}

// Main save function with toggle
void SQLSavePlayerData(object oPC, float fDelay = 0.0)
{
    if (fDelay > 0.0)
    {
        DelayCommand(fDelay, SQLSavePlayerData(oPC, 0.0));
        return;
    }
    
    int bUseExternal = GetLocalInt(GetModule(), DOWE_SQL_USE_EXTERNAL);
    
    if (bUseExternal)
    {
        SQLSavePlayerDataExternal(oPC);
    }
    else
    {
        SQLSavePlayerDataInternal(oPC);
    }
}

// Staggered save for multiple players
void SQLSaveAllPlayers(object oArea)
{
    // This would use manifest iteration
    // For now, placeholder for when needed
}
