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
	
	"set_instructor_group_enabled"
	{
		"group"		"string"
		"enabled"	"short"
	}
	
	"instructor_server_hint_create"
	{
		"hint_name"					"string"
		"hint_replace_key"			"string"
		"hint_target"				"long"
		"hint_activator_userid"		"short"
		"hint_timeout"				"short"
		"hint_icon_onscreen"		"string"
		"hint_icon_offscreen"		"string"
		"hint_caption"				"string"
		"hint_activator_caption"	"string"
		"hint_color"				"string"
		"hint_icon_offset"			"float"	
		"hint_range"				"float"
		"hint_flags"				"long"
		"hint_binding"				"string"
		"hint_allow_nodraw_target"	"bool"
		"hint_nooffscreen"			"bool"
		"hint_forcecaption"			"bool"
		"hint_local_player_only"	"bool"
		"hint_subtype"				"short"
	}
	
	"instructor_server_hint_stop"
	{
		"hint_name"					"string"
	}
}