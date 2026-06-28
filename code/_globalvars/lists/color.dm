GLOBAL_LIST_INIT(contrast_colors, list(
	COLOR_BLACK,
	COLOR_DARK_CYAN,
	COLOR_RED,
	COLOR_TAN_ORANGE,
	COLOR_VIOLET,
))

GLOBAL_LIST_INIT(color_list_blood_brothers, initialize_bb_colors())

/proc/initialize_bb_colors()
	var/static/list/base_colors = list("red", "purple", "navy", "darkbluesky", "bluesky", "cyan", "lime", "orange", "redorange")
	. = list()
	for(var/color in shuffle(base_colors))
		. += "cfc_[color]"
