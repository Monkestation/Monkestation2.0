/obj/effect/temp_visual/slasher_jaunt
	name = "slasher jaunt in"
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "slasherj_start"
	duration = 3.3
/obj/effect/temp_visual/slasher_jaunt/out
	name = "slasher jaunt out"
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "slasherj_end"
	duration = 3.3

/datum/action/cooldown/slasher/envelope_darkness
	name = "Slasher Stalking"
	desc = "Phase through doors and windows like a classic horror monster, but you cannot pass through walls."
	button_icon_state = "incorporealize"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 120 SECONDS

	/// Sound played when entering the jaunt
	var/enter_sound = 'monkestation/sound/effects/slasher_jauntstart.ogg'
	/// Sound played when exiting the jaunt
	var/exit_sound = 'monkestation/sound/effects/slasher_jauntappear.ogg'
	/// For how long are we jaunting?
	var/jaunt_duration = 4 SECONDS
	/// For how long we become immobilized after exiting the jaunt
	var/jaunt_in_time = 0.33 SECONDS
	/// For how long we become immobilized when using this spell
	var/jaunt_out_time = 0.33 SECONDS
	/// Visual for jaunting
	var/obj/effect/jaunt_in_type = /obj/effect/temp_visual/slasher_jaunt
	/// Visual for exiting the jaunt
	var/obj/effect/jaunt_out_type = /obj/effect/temp_visual/slasher_jaunt/out
	/// List of valid exit points
	var/list/exit_point_list

/datum/action/cooldown/slasher/envelope_darkness/Activate(atom/target)
	if(!owner || !target)
		return FALSE

	if(!isliving(owner))
		return FALSE

	var/mob/living/living_owner = owner
	do_jaunt(living_owner)
	StartCooldown()
	return TRUE

/**
 * Begin the jaunt, and the entire jaunt chain.
 * Puts owner in the phased mob holder here.
 */
/datum/action/cooldown/slasher/envelope_darkness/proc/do_jaunt(mob/living/jaunter)
	ADD_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
	var/obj/effect/dummy/phased_mob/slasher_jaunt/holder = enter_jaunt(jaunter)
	REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
	if(!holder)
		return

	if(jaunt_out_time > 0)
		ADD_TRAIT(jaunter, TRAIT_IMMOBILIZED, REF(src))
		addtimer(CALLBACK(src, PROC_REF(do_jaunt_out), jaunter, holder), jaunt_out_time)
	else
		start_jaunt(jaunter, holder)

/**
 * Creates the jaunt holder and moves the jaunter into it
 */
/datum/action/cooldown/slasher/envelope_darkness/proc/enter_jaunt(mob/living/jaunter)
	var/obj/effect/dummy/phased_mob/slasher_jaunt/holder = new(get_turf(jaunter), jaunter)

	// Add blood trail effect to the holder with callback removal
//	var/datum/component/blood_trail/trail = holder.AddComponent(/datum/component/blood_trail)
	var/turf/cast_turf = get_turf(holder)
	new jaunt_out_type(cast_turf, jaunter.dir)
	jaunter.extinguish_mob()

	if(enter_sound)
		playsound(cast_turf, enter_sound, 50, TRUE)

	return holder

/**
 * The wind-up to the jaunt.
 * Optional, only called if jaunt_out_time is set.
 */
/datum/action/cooldown/slasher/envelope_darkness/proc/do_jaunt_out(mob/living/jaunter, obj/effect/dummy/phased_mob/slasher_jaunt/holder)
	if(QDELETED(jaunter) || QDELETED(holder) || QDELETED(src))
		return

	REMOVE_TRAIT(jaunter, TRAIT_IMMOBILIZED, REF(src))
	start_jaunt(jaunter, holder)

/**
 * The actual process of starting the jaunt.
 * Sets up the signals and exit points and allows
 * the jaunter to actually start moving around.
 */
/datum/action/cooldown/slasher/envelope_darkness/proc/start_jaunt(mob/living/jaunter, obj/effect/dummy/phased_mob/slasher_jaunt/holder)
	if(QDELETED(jaunter) || QDELETED(holder) || QDELETED(src))
		return

	LAZYINITLIST(exit_point_list)
	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(update_exit_point))
	addtimer(CALLBACK(src, PROC_REF(stop_jaunt), jaunter, holder, get_turf(holder)), jaunt_duration)

/**
 * The stopping of the jaunt.
 * Unregisters signals and places
 * the jaunter on the turf they will exit at.
 */
/datum/action/cooldown/slasher/envelope_darkness/proc/stop_jaunt(mob/living/jaunter, obj/effect/dummy/phased_mob/slasher_jaunt/holder, turf/start_point)
	if(QDELETED(jaunter) || QDELETED(holder) || QDELETED(src))
		return

	UnregisterSignal(holder, COMSIG_MOVABLE_MOVED)
	// The jaunter escaped our holder somehow?
	if(jaunter.loc != holder)
		qdel(holder)
		return

	// Pick an exit turf to deposit the jaunter
	var/turf/found_exit
	for(var/turf/possible_exit as anything in exit_point_list)
		if(possible_exit.is_blocked_turf_ignore_climbable())
			continue
		found_exit = possible_exit
		break

	// No valid exit was found
	if(!found_exit)
		if(get_turf(jaunter) != start_point)
			to_chat(jaunter, span_danger("Unable to find an unobstructed space, you find yourself ripped back to where you started."))
		found_exit = start_point

	exit_point_list = null
	holder.forceMove(found_exit)
	holder.reappearing = TRUE
	if(exit_sound)
		playsound(found_exit, exit_sound, 50, TRUE)

	ADD_TRAIT(jaunter, TRAIT_IMMOBILIZED, REF(src))

	if(2.5 SECONDS - jaunt_in_time <= 0)
		do_jaunt_in(jaunter, holder, found_exit)
	else
		addtimer(CALLBACK(src, PROC_REF(do_jaunt_in), jaunter, holder, found_exit), 2.5 SECONDS - jaunt_in_time)

/**
 * The wind-up of exiting the jaunt.
 */
/datum/action/cooldown/slasher/envelope_darkness/proc/do_jaunt_in(mob/living/jaunter, obj/effect/dummy/phased_mob/slasher_jaunt/holder, turf/final_point)
	if(QDELETED(jaunter) || QDELETED(holder) || QDELETED(src))
		return

	new jaunt_in_type(final_point, holder.dir)
	jaunter.setDir(holder.dir)

	if(jaunt_in_time > 0)
		addtimer(CALLBACK(src, PROC_REF(end_jaunt), jaunter, holder, final_point), jaunt_in_time)
	else
		end_jaunt(jaunter, holder, final_point)

/**
 * Finally, the actual veritable end of the jaunt chains.
 * Deletes the phase holder, ejecting the jaunter at final_point.
 */
/datum/action/cooldown/slasher/envelope_darkness/proc/end_jaunt(mob/living/jaunter, obj/effect/dummy/phased_mob/slasher_jaunt/holder, turf/final_point)
	if(QDELETED(jaunter) || QDELETED(holder) || QDELETED(src))
		return

	ADD_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))

	// Remove blood trail effect before cleanup
	qdel(holder.GetComponent(/datum/component/blood_trail))

	// Exit the jaunt
	jaunter.forceMove(final_point)
	holder.jaunter = null
	qdel(holder)

	REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
	REMOVE_TRAIT(jaunter, TRAIT_IMMOBILIZED, REF(src))
	if(final_point.density)
		var/list/aside_turfs = get_adjacent_open_turfs(final_point)
		if(length(aside_turfs))
			jaunter.forceMove(pick(aside_turfs))

/**
 * Updates the exit point of the jaunt
 */
/datum/action/cooldown/slasher/envelope_darkness/proc/update_exit_point(obj/effect/dummy/phased_mob/slasher_jaunt/source)
	SIGNAL_HANDLER

	var/turf/location = get_turf(source)
	if(location.is_blocked_turf_ignore_climbable())
		return
	exit_point_list.Insert(1, location)
	if(length(exit_point_list) >= 5)
		exit_point_list.Cut(5)

/// The dummy that holds people jaunting
/obj/effect/dummy/phased_mob/slasher_jaunt
	name = "shadow"
	movespeed = 1.5
	var/reappearing = FALSE

/obj/effect/dummy/phased_mob/slasher_jaunt/phased_check(mob/living/user, direction)
	if(reappearing)
		return
	. = ..()
	if(!.)
		return

	var/turf/destination = get_step_multiz(src, direction)
	if(!destination)
		return null

	// Check if the destination is a wall - if so, we can't move there
	if(destination.density)
		// But we can pass through doors and windows
		var/can_pass = FALSE
		for(var/obj/structure/window/window in destination)
			can_pass = TRUE
			break
		for(var/obj/machinery/door/door in destination)
			can_pass = TRUE
			break

		if(!can_pass)
			to_chat(user, span_warning("You cannot phase through solid walls!"))
			return null

	return destination
