/// Applies a skin to the cyborg.
/mob/living/silicon/robot/proc/apply_skin(datum/robot_skin/applied_skin)
	if(current_skin)
		remove_traits(current_skin.traits, REF(current_skin))
	if(ispath(applied_skin))
		applied_skin = new
	current_skin = applied_skin
	icon = current_skin.icon
	icon_state = applied_skin.icon_state
	base_pixel_x = current_skin.base_pixel_x
	base_pixel_y = current_skin.base_pixel_y
	if(hat && isnull(applied_skin.hat_offset))
		if(HAS_TRAIT(hat, TRAIT_NODROP)) // Highlander's hat.
			qdel(hat)
		else
			hat.forceMove(drop_location())
	if(isnull(applied_skin.badge_offset) && worn_badge)
		if(HAS_TRAIT(worn_badge, TRAIT_NODROP))
			qdel(worn_badge)
		else
			worn_badge.forceMove(drop_location())
	add_traits(current_skin.traits, REF(current_skin))
	update_icons()

/mob/living/silicon/robot/regenerate_icons()
	return update_icons()

/mob/living/silicon/robot/update_icons()
	icon_state = current_skin.icon_state
	update_appearance(UPDATE_OVERLAYS)

/mob/living/silicon/robot/update_overlays()
	. = ..()
	if(stat != DEAD && !(HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || IsStun() || IsParalyzed() || low_power_mode)) // Not dead, not stunned.
		if(!eye_lights)
			eye_lights = new()
		if(lamp_enabled || lamp_doom)
			eye_lights.icon_state = "[current_skin.icon_state_light]_l"
			eye_lights.color = lamp_doom ? COLOR_RED : lamp_color
			set_light_range(max(MINIMUM_USEFUL_LIGHT_RANGE, lamp_intensity))
			set_light_color(lamp_doom ? COLOR_RED : lamp_color) //Red for doomsday killborgs, borg's choice otherwise
			SET_PLANE_EXPLICIT(eye_lights, ABOVE_LIGHTING_PLANE, src) //glowy eyes
		else
			eye_lights.icon_state = "[current_skin.icon_state_light]_e"
			eye_lights.color = COLOR_WHITE
			SET_PLANE_EXPLICIT(eye_lights, ABOVE_GAME_PLANE, src)
		eye_lights.icon = icon
		. += eye_lights
	if(opened)
		if(wiresexposed)
			. += "[current_skin.icon_state_cover]-opencover +w"
		else if(cell)
			. += "[current_skin.icon_state_cover]-opencover +c"
		else
			. += "[current_skin.icon_state_cover]-opencover -c"
	if(hat)
		var/mutable_appearance/head_overlay = hat.build_worn_icon(default_layer = 20, default_icon_file = 'icons/mob/clothing/head/default.dmi')
		head_overlay.pixel_z += current_skin.hat_offset
		. += head_overlay
	if(worn_badge)
		var/mutable_appearance/accessory_overlay = mutable_appearance(worn_badge.worn_icon, worn_badge.icon_state)
		accessory_overlay.pixel_z += current_skin.badge_offset
		. += accessory_overlay
