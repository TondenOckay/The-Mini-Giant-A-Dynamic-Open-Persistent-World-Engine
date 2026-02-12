/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard)
    DATE: February 12, 2026
    Script Name: area_switchboard
   ============================================================================
*/

#include "area_const_inc"

void main()
{
    object oArea = OBJECT_SELF;
    
    // Phase 1: Cleanup (0.0s - manifest-driven, instant)
    ExecuteScript("area_cleanup", oArea);
    
    // Phase 2: NPCs & Maintenance (1.5s)
    DelayCommand(DOWE_STAGGER_PHASE2, ExecuteScript("live_npc_system", oArea));
    
    // Phase 3: Encounters (3.0s - entropic spawning)
    DelayCommand(DOWE_STAGGER_PHASE3, ExecuteScript("enc_main", oArea));
}
