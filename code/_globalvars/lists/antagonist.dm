/// Assoc list of stringified opt_in_## define to the front-end string to show users as a representation of the setting.
GLOBAL_LIST_INIT(antag_opt_in_strings, list(
	"0" = OPT_IN_NOT_TARGET_STRING,
	"1" = OPT_IN_YES_TEMP_STRING,
	"2" = OPT_IN_YES_KILL_STRING,
	"3" = OPT_IN_YES_ROUND_REMOVE_STRING,
))

/// Assoc list of stringified opt_in_## define to the color associated with it.
GLOBAL_LIST_INIT(antag_opt_in_colors, list(
	OPT_IN_NOT_TARGET_STRING = COLOR_GRAY,
	OPT_IN_YES_TEMP_STRING = COLOR_EMERALD,
	OPT_IN_YES_KILL_STRING = COLOR_ORANGE,
	OPT_IN_YES_ROUND_REMOVE_STRING = COLOR_RED
))
