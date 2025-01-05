///Forced directional movement, but with a twist
///Let's block pressure and client movements while doing it so we can't be interrupted
///Supports spinning on each move, for lube related reasons
/datum/component/force_move

/datum/component/force_move/Initialize(atom/target, spin)
	if(!target || !ismob(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/mob_parent = parent
	var/dist = get_dist(mob_parent, target)
	var/datum/move_loop/loop = SSmove_manager.move_towards(mob_parent, target, delay = 1, timeout = dist)
	RegisterSignal(mob_parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(stop_move))
	RegisterSignal(mob_parent, COMSIG_ATOM_PRE_PRESSURE_PUSH, PROC_REF(stop_pressure))
	RegisterSignal(mob_parent, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(slip_crash))
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

/datum/component/force_move/proc/slip_crash(datum/source, var/result, var/delay, turf/target_turf, /datum/move_loop/blocked)
	SIGNAL_HANDLER
	if(!result) // Something prevented us from moving into the space.
		var/obj/machinery/vending/heavy_weight = (locate(/obj/machinery/vending) in target_turf)
		var/obj/structure/table/tabled = (locate(/obj/structure/table) in target_turf)
		if(istype(heavy_weight))
			heavy_weight.tilt(parent)

		if(istype(tabled))
			var/mob/mob_parent = parent
			mob_parent.throw_at(target_turf, 1, 1)

/datum/component/force_move/proc/loop_ended(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)


