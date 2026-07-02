/datum/robot_skin
	/// The abstract type. Not used anywhere at the moment.
	var/abstract_type = /datum/robot_skin
	/// The name of the skin.
	var/name = "Unknown"
	/// The icon of the sprite.
	var/icon = 'icons/mob/silicon/robots.dmi'
	/// The icon state of the sprite.
	var/icon_state = "robot"
	/// The icon state of the sprite's cover panel.
	var/icon_state_cover = "ov"
	/// The icon state of the sprite's head lights.
	var/icon_state_light = "robot"
	/// The icon state of the sprite's transform sequence.
	var/icon_state_transform = null
	/// The amount of deciseconds it takes for the icon state that is transformation animation to complete.
	var/transformation_duration = 3 SECONDS
	/// The icon of the chat bubble.
	var/bubble_icon = "robot"
	/// The X offset of the sprite.
	var/base_pixel_x = 0
	/// The Y offset of the sprite.
	var/base_pixel_y = 0
	/// The X offset of any worn hats. Enables hat wearing if it is not null.
	var/hat_offset = null
	/// The X offset of any worn badges. Enables badge wearing if it is not null.
	var/badge_offset = null
	/// The X offsets for any buckled individuals.
	var/list/ride_offset_x = list("north" = 0, "south" = 0, "east" = -6, "west" = 6)
	/// The Y offsets for any buckled people.
	var/list/ride_offset_y = list("north" = 4, "south" = 4, "east" = 3, "west" = 3)
	/// The traits that are given when using this skin.
	var/list/traits

/// Performs the transformation animation, if there is any.
/datum/robot_skin/proc/do_transformation_animation(mob/living/silicon/robot/cyborg_target, should_immobilize = TRUE)
	if(HAS_TRAIT(cyborg_target, TRAIT_NO_TRANSFORM))
		return FALSE
	ADD_TRAIT(cyborg_target, TRAIT_NO_TRANSFORM, REF(src))
	// This is cleared because overlays won't be re-applied later on since it thinks we still have them.
	cyborg_target.cut_overlays()
	LAZYNULL(cyborg_target.managed_overlays)
	if(icon_state_transform)
		cyborg_target.setDir(SOUTH)
		flick(icon_state_transform, cyborg_target)
	INVOKE_ASYNC(src, PROC_REF(play_transformation_sounds), cyborg_target)
	if(!transformation_duration) // No need to immobilize if our transformation is instant.
		return TRUE
	if(should_immobilize)
		cyborg_target.SetLockdown(TRUE)
		cyborg_target.set_anchored(TRUE)
	INVOKE_ASYNC(src, PROC_REF(play_transformation_sounds), cyborg_target)
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
