/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_sql_inc
    
    DESCRIPTION:
    SQL wrapper functions for saving player data and area state.
    Uses NWN:EE's internal campaign database.
   ============================================================================
*/

#include "area_const_inc"
#include "area_debug_inc"

// Save player data to database
void SQLSavePlayerData(object oPC)
{
    string sCDKey = GetPCPublicCDKey(oPC);
    string sPlayerName = GetName(oPC);
    
    // Use campaign database (simpler than raw SQL for single-developer setup)
    SetCampaignInt(DOWE_SQL_DATABASE, "PlayerLevel_" + sCDKey, GetHitDice(oPC));
    SetCampaignInt(oPC, "PlayerGold_" + sCDKey, GetGold(oPC));
    SetCampaignLocation(DOWE_SQL_DATABASE, "PlayerLocation_" + sCDKey, GetLocation(oPC));
    
    // Save skills
    SetCampaignInt(DOWE_SQL_DATABASE, sCDKey + "_" + DOWE_SKILL_BLACKSMITHING, 
                  GetLocalInt(oPC, DOWE_SKILL_BLACKSMITHING));
    SetCampaignInt(DOWE_SQL_DATABASE, sCDKey + "_" + DOWE_SKILL_MINING, 
                  GetLocalInt(oPC, DOWE_SKILL_MINING));
    // Add other skills as needed...
    
    DebugSQL("Saved player data for " + sPlayerName, TRUE);
}

// Load player data from database
void SQLLoadPlayerData(object oPC)
{
    string sCDKey = GetPCPublicCDKey(oPC);
    
    // Load skills
    SetLocalInt(oPC, DOWE_SKILL_BLACKSMITHING,
               GetCampaignInt(DOWE_SQL_DATABASE, sCDKey + "_" + DOWE_SKILL_BLACKSMITHING));
    SetLocalInt(oPC, DOWE_SKILL_MINING,
               GetCampaignInt(DOWE_SQL_DATABASE, sCDKey + "_" + DOWE_SKILL_MINING));
    
    DebugSQL("Loaded player data for " + GetName(oPC), TRUE);
}
