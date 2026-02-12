/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard)
    DATE: February 12, 2026
    Script Name: area_on_exit
   ============================================================================
*/

void main()
{
    object oPC = GetExitingObject();
    
    if (!GetIsPC(oPC)) return;
    
    ExecuteScript("area_janitor", oPC);
}
