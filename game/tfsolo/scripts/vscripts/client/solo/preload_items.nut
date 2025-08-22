::TFSOLO.PreloadItemFuncs <- []
IncludeScript("client/solo/items/spineyard_tommygun.nut")
//IncludeScript("client/solo/items/bonesaw_bigaxe_burnt.nut")
//IncludeScript("client/solo/items/murky_televisionhead.nut")
//IncludeScript("client/solo/actors/selbyen_seal.nut")
//IncludeScript("client/solo/actors/farmageddon_scarecrow.nut")
//IncludeScript("client/solo/actors/graveyard_ghost_healing.nut")
//IncludeScript("client/solo/actors/sharkbay_shark.nut")
//IncludeScript("client/solo/actors/spineyard_skeleton_mobster.nut")
//IncludeScript("client/solo/actors/skirmish_saxton_hale.nut")
//IncludeScript("client/solo/actors/maul_saxton_santa.nut")
//IncludeScript("client/solo/actors/outburst_saxton_hell.nut")

::TFSOLO.PreloadItems <- function()
{
	local cache = {}
	foreach (func in TFSOLO.PreloadItemFuncs)
	{
		func(cache)
	}
	
	BSP_CacheStartArray(cache)
	printl("[TFSOLO] Item assets setup")
}

TFSOLO.PreloadItems()