/datum/robot_skin
	/// The abstract type. Not used anywhere at the moment.
	var/abstract_type = /datum/robot_skin
	/// The name of the skin.
	var/name = "Unknown"
	/// The icon of the sprite.
	var/icon = 'icons/mob/silicon/robots.dmi'
	/// The icon state of the sprite.
	var/icon_state = "robot"
	/// The prefix of the icon state used for the cover panel.
	var/icon_state_cover = "ov"
	/// The prefix of the icon state used for the head lights.
	var/icon_state_light = "robot"
	/// The icon state of the sprite's transform sequence.
	var/icon_state_transform = null
	/// The amount of deciseconds to lockdown whoever being transformed; this is usually the time it takes for icon_state_transform to finish.
	var/transformation_duration = 3 SECONDS
	/// The icon of the chat bubble.
	var/bubble_icon = "robot"
	/// The X offset of the sprite.
	var/base_pixel_x = 0
	/// The Y offset of the sprite.
	var/base_pixel_y = 0
	/// The X offset of any worn hats. If not null, allows hat to be worn.
	var/list/hat_offset = null
	/// The X offset of any worn badges. If not null, allows badges to be worn.
	var/list/badge_offset = null
	/// The offsets of any buckled individuals.
	var/list/ride_offset = list(
		"north" = list(0, 4),
		"south" = list(0, 4),
		"east" = list(-6, 3),
		"west" = list(6, 3),
	)
	/// The traits that are given when using this skin.
	var/list/traits = null

/// Performs the transformation animation, if there is any.
/datum/robot_skin/proc/do_transformation_animation(mob/living/silicon/robot/cyborg_target, should_immobilize = TRUE)
	if(HAS_TRAIT(cyborg_target, TRAIT_NO_TRANSFORM))
		return FALSE
	ADD_TRAIT(cyborg_target, TRAIT_NO_TRANSFORM, REF(src))
	cyborg_target.cut_overlays()
	LAZYNULL(cyborg_target.managed_overlays) // This is cleared because cutting the overlays isn't enough as it thinks we still have them.
	cyborg_target.setDir(SOUTH)
	if(icon_state_transform)
		flick(icon_state_transform, cyborg_target)
	INVOKE_ASYNC(src, PROC_REF(play_transformation_sounds), cyborg_target)
	if(!transformation_duration) // No need to immobilize if our transformation is instant.
		return TRUE
	if(should_immobilize)
		cyborg_target.SetLockdown(TRUE)
		cyborg_target.set_anchored(TRUE)
	INVOKE_ASYNC(src, PROC_REF(end_transformation_animation), cyborg_target, should_immobilize, transformation_duration) // This works. Timers don't work. Why? I don't know.
	return TRUE

/// Ends the transformation animation.
/datum/robot_skin/proc/end_transformation_animation(mob/living/silicon/robot/cyborg_target, should_undo_immobilize = TRUE, transformation_duration)
	if(transformation_duration)
		sleep(transformation_duration)
	if(QDELETED(cyborg_target) || !HAS_TRAIT_FROM(cyborg_target, TRAIT_NO_TRANSFORM, REF(src)))
		return
	REMOVE_TRAIT(cyborg_target, TRAIT_NO_TRANSFORM, REF(src))
	if(should_undo_immobilize)
		cyborg_target.SetLockdown(FALSE)
		cyborg_target.set_anchored(FALSE)
	cyborg_target.updatehealth()
	cyborg_target.update_icons()

/// Play the sounds associated with the transformation.
/datum/robot_skin/proc/play_transformation_sounds(mob/living/silicon/robot/cyborg_target, intervals = 4, time_between = 0.7 SECONDS)
	for(var/i in 1 to intervals)
		if(QDELETED(cyborg_target))
			return
		playsound(cyborg_target, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, TRUE, -1)
		sleep(time_between)
