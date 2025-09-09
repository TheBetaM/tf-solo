::TFSOLO.BalancingFuncs <- []
IncludeScriptsDir("solo/balancing", this)

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