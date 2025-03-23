::TFSOLO.PreloadItemFuncs <- []
IncludeScript("client/solo/items/spineyard_tommygun.nut")

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