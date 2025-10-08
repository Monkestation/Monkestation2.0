/// 1 tile down
#define UI_BLOOD_DISPLAY "WEST:6,CENTER-1:0"
/// 2 tiles down
#define UI_VAMPRANK_DISPLAY "WEST:6,CENTER-2:-5"

///Maptext define for Bloodsucker HUDs
#define FORMAT_BLOODSUCKER_HUD_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[round(value,1)]</font></div>")

/atom/movable/screen/bloodsucker
	icon = 'monkestation/icons/bloodsuckers/actions_bloodsucker.dmi'

/atom/movable/screen/bloodsucker/blood_counter
	name = "Blood Consumed"
	icon_state = "blood_display"
	screen_loc = UI_BLOOD_DISPLAY

/atom/movable/screen/bloodsucker/rank_counter
	name = "Bloodsucker Rank"
	icon_state = "rank"
	screen_loc = UI_VAMPRANK_DISPLAY

/// Update Blood Counter + Rank Counter
/datum/antagonist/bloodsucker/proc/update_hud()
	var/valuecolor
	if(bloodsucker_blood_volume > BLOOD_VOLUME_SAFE)
		valuecolor = "#FFDDDD"
	else if(bloodsucker_blood_volume > BLOOD_VOLUME_BAD)
		valuecolor = "#FFAAAA"

	blood_display?.maptext = FORMAT_BLOODSUCKER_HUD_TEXT(valuecolor, bloodsucker_blood_volume)

	if(!QDELETED(vamprank_display))
		if(bloodsucker_level_unspent > 0)
			vamprank_display.icon_state = "[initial(vamprank_display.icon_state)]_up"
		else
			vamprank_display.icon_state = initial(vamprank_display.icon_state)
		vamprank_display.maptext = FORMAT_BLOODSUCKER_HUD_TEXT(valuecolor, bloodsucker_level)


/// 1 tile down
#undef UI_BLOOD_DISPLAY
/// 2 tiles down
#undef UI_VAMPRANK_DISPLAY

///Maptext define for Bloodsucker HUDs
#undef FORMAT_BLOODSUCKER_HUD_TEXT
