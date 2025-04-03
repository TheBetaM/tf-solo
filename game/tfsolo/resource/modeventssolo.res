"ModEvents"
{
	"solo_add_credits"
	{
		"amount"	"long"
	}
	"solo_unlock_item"
	{
		"item"	"string"
	}
	"solo_unlock_itemid"
	{
		"item"	"long"
	}
	"solo_client_armory_unlocked"
	{
		"item"	"string"
		"itemid"	"long"
	}
	"solo_save_data"
	{
	}
	"solo_nav_complete"
	{
	}
	"solo_armory_flag"
	{
		"flag"	"string"
		"count"	"long"
		"setflag"	"bool" // if false, increment flag by count
	}
	"solo_campaign_flag"
	{
		"campaign"	"string"
		"flag"	"string"
		"count"	"long"
		"setflag"	"bool" // if false, increment flag by count
	}
	"solo_botpreset_flag"
	{
		"preset"	"string"
		"flag"	"string"
		"count"	"long"
		"setflag"	"bool" // if false, increment flag by count
	}
	"solo_generic_flag"
	{
		"flag"	"string"
		"count"	"long"
		"setflag"	"bool" // if false, increment flag by count
	}
	"solohud_file_changed"
	{
		"path"	"string"
	}
	"solohud_int"
	{
		"key"	"string"
		"value"	"long"
	}
	"solohud_float"
	{
		"key"	"string"
		"value"	"float"
	}
	"solohud_string"
	{
		"key"	"string"
		"value"	"string"
	}
	"solohud_event"
	{
		"key"	"string"
		"value"	"string"
	}
}