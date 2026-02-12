/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard)
    DATE: February 12, 2026
    Script Name: area_on_death
    
    SELF-REGISTRATION:
    Corpses add themselves to manifest with appropriate expiration.
   ============================================================================
*/

#include "area_manifest_inc"
#include "area_const_inc"

void main()
{
    object oCorpse = OBJECT_SELF;
    object oArea = GetArea(oCorpse);
    
    int bIsPlayerCorpse = GetIsPC(oCorpse);
    
    // Get appropriate lifespan
    int nLifespan = bIsPlayerCorpse ? 
                   GetLocalInt(GetModule(), DOWE_CFG_PLAYER_CORPSE_LIFE) :
                   GetLocalInt(GetModule(), DOWE_CFG_REMAINS_LIFE);
    
    // Self-register to manifest
    ManifestAdd(oArea, oCorpse, MANIFEST_FLAG_CORPSE, nLifespan);
}
