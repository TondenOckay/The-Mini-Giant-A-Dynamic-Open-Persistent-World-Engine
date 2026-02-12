/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 1.0 (Master Build)
    DATE: February 11, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_on_death
    Event: OnCreatureDeath (Module)
    
    DESCRIPTION:
    Tags corpses with timestamp and marks player corpses.
   ============================================================================
*/

#include "area_const_inc"

void main()
{
    object oCorpse = OBJECT_SELF;
    int nCurrentTick = GetDoweTick();
    
    SetLocalInt(oCorpse, DOWE_DEATH_TICK, nCurrentTick);
    
    if (GetIsPC(oCorpse))
    {
        SetLocalInt(oCorpse, DOWE_PLAYER_CORPSE, TRUE);
    }
}
