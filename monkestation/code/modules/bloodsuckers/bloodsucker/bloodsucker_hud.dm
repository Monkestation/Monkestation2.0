/// dead center
#define UI_THICKENING_DISPLAY "WEST:6,CENTER:0"
/// 1 tile down
#define UI_BLOOD_DISPLAY "WEST:6,CENTER-1:0"
/// 2 tiles down
#define UI_VAMPRANK_DISPLAY "WEST:6,CENTER-2:-5"

///Maptext define for Bloodsucker HUDs
#define FORMAT_BLOODSUCKER_HUD_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[round(value,1)]</font></div>")

/atom/movable/screen/bloodsucker
	icon = 'icons/bloodsuckers/actions_bloodsucker.dmi'

/atom/movable/screen/bloodsucker/blood_counter
	name = "Blood Consumed"
	icon_state = "blood_display"
	screen_loc = UI_BLOOD_DISPLAY

/atom/movable/screen/bloodsucker/rank_counter
	name = "Bloodsucker Rank"
	icon_state = "rank"
	screen_loc = UI_VAMPRANK_DISPLAY

/atom/movable/screen/bloodsucker/thickening_counter
	name = "Blood Thickening"
	icon_state = "thickening"
	screen_loc = UI_THICKENING_DISPLAY
	var/closed = FALSE //boolean to tell us the icon state instead of making icon state conditionals cause i don't wanna do that

/atom/movable/screen/bloodsucker/thickening_counter/update_icon_state()
		icon_state = "[initial(icon_state)]_[closed ? "close" : "open"]"
		return ..()

/// Update counters with values, colors and other information (Current: Blood, Rank, Thickening)
/datum/antagonist/bloodsucker/proc/update_hud()
	var/valuecolor = "#da5959" //red = very bad <-> white = doing good
	if(bloodsucker_blood_volume > BLOOD_VOLUME_BAD)
		valuecolor = "#FFAAAA"
	if(bloodsucker_blood_volume > BLOOD_VOLUME_SAFE)
		valuecolor = "#FFDDDD"

	blood_display?.maptext = FORMAT_BLOODSUCKER_HUD_TEXT(valuecolor, bloodsucker_blood_volume)

	if(!QDELETED(vamprank_display))
		if(bloodsucker_level_unspent > 0)
			vamprank_display.icon_state = "[initial(vamprank_display.icon_state)]_up"
		else
			vamprank_display.icon_state = initial(vamprank_display.icon_state)
		vamprank_display.maptext = FORMAT_BLOODSUCKER_HUD_TEXT(valuecolor, bloodsucker_level)


	if(!QDELETED(thickening_display))
		if(!thickening_display.closed)
			thickening_display.maptext = FORMAT_BLOODSUCKER_HUD_TEXT(valuecolor, blood_level_gain)
			if(blood_level_gain >= get_level_cost())
				thickening_display.closed = TRUE
				thickening_display.maptext = null
				thickening_display.update_appearance(UPDATE_ICON_STATE)
		else
			if(blood_level_gain < get_level_cost())
				thickening_display.closed = FALSE
				thickening_display.update_appearance(UPDATE_ICON_STATE)
				thickening_display.maptext = FORMAT_BLOODSUCKER_HUD_TEXT(valuecolor, blood_level_gain)

/// dead center
#undef UI_THICKENING_DISPLAY
/// 1 tile down
#undef UI_BLOOD_DISPLAY
/// 2 tiles down
#undef UI_VAMPRANK_DISPLAY

///Maptext define for Bloodsucker HUDs
#undef FORMAT_BLOODSUCKER_HUD_TEXT
