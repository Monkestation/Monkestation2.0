/// I feel funny...
/datum/status_effect/feeling_funny
	id = "feelingfunnyy"
	alert_type = null
	remove_on_fullheal = TRUE
	var/current_rot = 90
	var/last_switch = 0
/datum/status_effect/feeling_funny/on_creation(mob/living/new_owner, duration = 10 SECONDS, smitten = FALSE)
	if(smitten)
		remove_on_fullheal = FALSE
		duration = -1
	else
		src.duration = duration
	return ..()

/datum/status_effect/feeling_funny/on_apply()
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE, TYPE_PROC_REF(/datum/status_effect/feeling_funny,on_move))
	return TRUE

/datum/status_effect/feeling_funny/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE)

/datum/status_effect/feeling_funny/proc/on_move(datum/source, list/move_args)
	SIGNAL_HANDLER

	// How much time is left in the duration, in seconds.
	var/dt = (duration - world.time) / 10
	last_switch += dt

	var/direction = move_args[MOVE_ARG_DIRECTION]
	var/new_dir = angle2dir(dir2angle(direction) + current_rot)
	if(last_switch >= 15)
		current_rot += pick(90,180,-90,-180)
		current_rot = current_rot % 360
		last_switch = 0

	if(!isnull(new_dir))
		move_args[MOVE_ARG_NEW_LOC] = get_step(owner, new_dir)
		move_args[MOVE_ARG_DIRECTION] = new_dir
