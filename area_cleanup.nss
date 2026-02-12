/* ============================================================================
    PROJECT: Dynamic Open World Engine (DOWE) "The Mini Giant"
    VERSION: 2.0 (Platinum Standard - Manifest Architecture)
    DATE: February 12, 2026
    PLATFORM: Neverwinter Nights: Enhanced Edition (NWN:EE)
    Script Name: area_cleanup
    
    DESCRIPTION:
    Manifest-driven cleanup. NO AREA SCANNING. Just filters manifest by
    cullable flags and removes expired entries.
    
    REVOLUTION:
    Old way: Iterate 1000+ objects in area
    New way: Filter manifest by flags, check expiration
    
    Performance: O(n) where n = manifest entries, not area objects
   ============================================================================
*/

#include "area_manifest_inc"
#include "area_const_inc"

void main()
{
    object oArea = OBJECT_SELF;
    
    // ONE FUNCTION CALL - That's it. No scanning, no iteration.
    int nCulled = ManifestCullExpired(oArea);
    
    if (nCulled > 0 && GetDoweDebug())
    {
        SendMessageToAllDMs("CLEANUP: Culled " + IntToString(nCulled) + 
                           " expired objects from " + GetTag(oArea));
    }
}
