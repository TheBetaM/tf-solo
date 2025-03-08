::TFSOLO.BalancingFuncs <- []
IncludeScript("solo/balancing/shortstop.nut")
IncludeScript("solo/balancing/bfb.nut")
IncludeScript("solo/balancing/backscatter.nut")
IncludeScript("solo/balancing/lugermorph.nut")
IncludeScript("solo/balancing/capper.nut")
IncludeScript("solo/balancing/winger.nut")
IncludeScript("solo/balancing/pocketpistol.nut")
IncludeScript("solo/balancing/mutatedmilk.nut")
IncludeScript("solo/balancing/holymackerel.nut")
IncludeScript("solo/balancing/unarmedcombat.nut")
IncludeScript("solo/balancing/batsaber.nut")
IncludeScript("solo/balancing/sandman.nut")
IncludeScript("solo/balancing/threeruneblade.nut")
IncludeScript("solo/balancing/sunonastick.nut")

::TFSOLO.SetupItemSchema <- function()
{
	local kv = Solo.ItemSchemaGetKV()
	foreach (func in TFSOLO.BalancingFuncs)
	{
		func(kv)
	}
	
	Solo.ItemSchemaReload(kv)
	printl("[TFSOLO] Item schema setup")
}

TFSOLO.SetupItemSchema()
TFSOLO.BalancingFuncs.clear()