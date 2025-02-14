///Forced directional movement, but with a twist
///Let's block pressure and client movements while doing it so we can't be interrupted
///Supports spinning on each move, for lube related reasons
/datum/component/force_move

/datum/component/force_move/Initialize(atom/target, spin, atom/slipper = null, lube = null)
	if(!target || !ismob(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/mob_parent = parent
	var/dist = get_dist(mob_parent, target)
	var/datum/move_loop/loop = SSmove_manager.move_towards(mob_parent, target, delay = 1, timeout = dist)
	RegisterSignal(mob_parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(stop_move))
	RegisterSignal(mob_parent, COMSIG_ATOM_PRE_PRESSURE_PUSH, PROC_REF(stop_pressure))

	//This handles slipping to differentiate it from say AI forced movement.
	if(istype(slipper) && !isnull(lube))
		RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_SLIP, PROC_REF(before_crash))

	if(spin)
		RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(slip_spin))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_ended))

/datum/component/force_move/proc/stop_move(datum/source)
	SIGNAL_HANDLER
	return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

/datum/component/force_move/proc/stop_pressure(datum/source)
	SIGNAL_HANDLER
	return COMSIG_ATOM_BLOCKS_PRESSURE

/datum/component/force_move/proc/slip_spin(datum/source)
	SIGNAL_HANDLER
	var/mob/mob_parent = parent
	mob_parent.spin(1, 1)

/datum/component/force_move/proc/before_crash(datum/source, datum/next_location)
	SIGNAL_HANDLER
	// check if something funny is in our way for slipping circumstances we need to have a target location to check.
	if(istype(source, /datum/move_loop/has_target/move_towards))
		var/mob/living/mob_parent = parent
		var/obj/machinery/door/blocking_door = (locate(/obj/machinery/door) in next_location)
		if(istype(blocking_door, /obj/machinery/door) && (blocking_door.density))
			if(!blocking_door.operating && blocking_door.is_operational)
				return MOVELOOP_BUMPDOOR_PROCEED
			else
				INVOKE_ASYNC(mob_parent, /atom/movable/proc/throw_at, next_location, 1, 1)
				return MOVELOOP_PATH_BLOCKED

		var/obj/machinery/disposal/dis_machine = (locate(/obj/machinery/disposal/bin) in next_location)
		if(istype(dis_machine, /obj/machinery/disposal/bin))
			mob_parent.Immobilize(0.8 SECONDS) // Keeps them in the bin for a moment.
			INVOKE_ASYNC(mob_parent, /atom/movable/proc/throw_at, next_location, 1, 1)
			return MOVELOOP_PATH_BLOCKED

		var/obj/structure/table/table = (locate(/obj/structure/table) in next_location)
		if(istype(table, /obj/structure/table))
			mob_parent.Immobilize(0.8 SECONDS) // Keeps them in the bin for a moment.
			INVOKE_ASYNC(mob_parent, /atom/movable/proc/throw_at, next_location, 1, 1)
			return MOVELOOP_PATH_BLOCKED

		var/obj/machinery/heavy_weight = (locate(/obj/machinery/vending) in next_location)
		if(istype(heavy_weight, /obj/machinery/vending)) // When a stoppable force hits immovable capitalism.
			INVOKE_ASYNC(heavy_weight, /obj/machinery/vending/proc/tilt, mob_parent) // We hit the machine so let them hit back.
			return MOVELOOP_PATH_BLOCKED

	/*
		if(istype(next_place, /turf/closed/wall))
			mob_parent.Immobilize(0.8 SECONDS) // Prevent them from throw bending around objects.
			// We don't exactly know what stopped us. So throw us at the turf and let physics handle it.
			INVOKE_ASYNC(mob_parent, /atom/movable/proc/throw_at, next_place, 1, 1, special = TRUE)
			return MOVELOOP_PATH_BLOCKED
	*/
	return

/datum/component/force_move/proc/slip_crash(datum/source, result, delay, old_loc, turf/target_turf, datum/blocked)
	SIGNAL_HANDLER

/datum/component/force_move/proc/loop_ended(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)
