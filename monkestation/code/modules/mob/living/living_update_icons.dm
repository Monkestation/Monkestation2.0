/**
 * Used to restore the mob's transform when it is in an undefined state
 * If the mob's transform is not messed up just use update_transform()
 */
/mob/living/proc/rebuild_transform()
	var/matrix/ntransform = matrix()

	if(lying_angle && rotate_on_lying)
		ntransform.Turn(lying_angle)

	if(current_size != RESIZE_DEFAULT_SIZE)
		ntransform.Scale(current_size)

	if(!lying_angle || !rotate_on_lying)
		var/translate = get_transform_translation_size(current_size)
		if(translate)
			ntransform.Translate(0, translate)

	//Update the height of the maptext according to the size of the mob so they don't overlap.
	var/old_maptext_offset = body_maptext_height_offset
	body_maptext_height_offset = initial(maptext_height) * (current_size - 1) * 0.5
	maptext_height += body_maptext_height_offset - old_maptext_offset

	SEND_SIGNAL(src, COMSIG_PAUSE_FLOATING_ANIM, 0.3 SECONDS)
	animate(src, transform = ntransform, time = 0, dir = dir, easing = NONE)
	update_offsets()
	SEND_SIGNAL(src, COMSIG_LIVING_POST_UPDATE_TRANSFORM, TRUE, lying_angle, TRUE)
