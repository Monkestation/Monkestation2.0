#define ui_slimedisplay "WEST,CENTER+1:15"

#define FORMAT_SLIME_HUD_MAPTEXT(color_value, value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color=[color_value]>[round(value,1)]</font></div>")

/atom/movable/screen/slime_stacks
	name = "slime wetness"
	icon_state = "slime_wetness"
	screen_loc = ui_slimedisplay

/obj/item/organ/internal/heart/slime/proc/update_hud(mob/living/carbon/human/slime)
	var/color_value
	var/datum/status_effect/fire_handler/wet_stacks/oozeling/slime_wetness = slime.has_status_effect(/datum/status_effect/fire_handler/wet_stacks/oozeling)
	switch(slime_wetness ? slime_wetness.stacks : 0)
		if(0 to 9)
			color_value = "#d84d54"
		if(10 to 19)
			color_value = "#caffca"
		if(20 to INFINITY)
			color_value = "#5ac745"

	slime_wetness_display?.maptext = FORMAT_SLIME_HUD_MAPTEXT(color_value, slime_wetness?.stacks)

#undef FORMAT_SLIME_HUD_MAPTEXT
