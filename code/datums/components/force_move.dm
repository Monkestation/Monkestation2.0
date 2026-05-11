///Forced directional movement, but with a twist
///Let's block pressure and client movements while doing it so we can't be interrupted
///Supports spinning on each move, for lube related reasons
///Supports slip and crashing interactions. Like slamming into a wall or slipping into disposals
/datum/component/force_move
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Current movement loop, so we can prevent a duplicate
	var/datum/move_loop/has_target/our_looper = null
	// Making these vars for ease of inheritance
	/// If TRUE the movement causes a spin every step
	var/spin = FALSE
	/// If TRUE termination of movement causes a stun and can cause vendors to fall
	var/slip_crash = FALSE

/datum/component/force_move/Destroy(force)
	if(!QDELETED(our_looper))
		qdel(our_looper)
	our_looper = null
	return ..()

/datum/component/force_move/Initialize(atom/target, spin = FALSE, slip_crash = FALSE)
	if(!target || !ismob(parent))
		return COMPONENT_INCOMPATIBLE

	src.spin = spin
	src.slip_crash = slip_crash

	create_loop(target)

/datum/component/force_move/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(stop_move))
	RegisterSignal(parent, COMSIG_ATOM_PRE_PRESSURE_PUSH, PROC_REF(stop_pressure))
	if(slip_crash)
		RegisterSignal(parent, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(slip_crash))

/datum/component/force_move/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, COMSIG_ATOM_PRE_PRESSURE_PUSH, COMSIG_MOVELOOP_POSTPROCESS))

// Slipping allows for two force_move components to be added, this breaks the movement loop signals and if slide distance is too high,
// it causes people to get stuck until the loop expires.
// We could just reduce the slide but really we should just make sure that two loops aren't created that conflict eachother.
/datum/component/force_move/InheritComponent(datum/component/force_move/new_mover, i_am_original, atom/target, spin, slip_crash)
	if(!i_am_original)
		return

	clean_loop()

	src.spin = spin
	src.slip_crash = slip_crash

	create_loop(target)

/// Create a new movement loop for us
/datum/component/force_move/proc/create_loop(atom/target)
	var/dist = get_dist(parent, target)
	our_looper = SSmove_manager.move_towards(parent, target, delay = 1, timeout = dist)
	if(spin)
		RegisterSignal(our_looper, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(slip_spin))
	RegisterSignal(our_looper, COMSIG_QDELETING, PROC_REF(loop_ended))

/// Safely remove the old loop in case of inheritance
/datum/component/force_move/proc/clean_loop()
	if(QDELETED(our_looper))
		return
	UnregisterSignal(our_looper, list(COMSIG_MOVELOOP_POSTPROCESS, COMSIG_QDELETING))
	QDEL_NULL(our_looper)

/// Signal proc to prevent client movement
/datum/component/force_move/proc/stop_move(datum/source)
	SIGNAL_HANDLER

	return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

/// Signal proc to prevent pressure movement
/datum/component/force_move/proc/stop_pressure(datum/source)
	SIGNAL_HANDLER

	return COMSIG_ATOM_BLOCKS_PRESSURE

/// Signal proc to spin the mob right around
/datum/component/force_move/proc/slip_spin(datum/source)
	SIGNAL_HANDLER

	var/mob/mob_parent = parent
	mob_parent.spin(1, 1)

/// Signal proc that causes hitting dense atoms to stun the mob
/datum/component/force_move/proc/slip_crash(datum/source, result, delay, turf/target_turf, datum/blocked)
	SIGNAL_HANDLER

	if(result)
		return

	if(!iscarbon(parent))
		return

	var/mob/living/carbon/carbon_parent = parent

	var/obj/machinery/heavy_weight = (locate(/obj/machinery/vending) in target_turf)
	if(heavy_weight) // When a stoppable force hits immovable capitalism.
		INVOKE_ASYNC(heavy_weight, TYPE_PROC_REF(/obj/machinery/vending, tilt), parent) // We hit the machine so let them hit back.
		qdel(blocked)
	else
		// We hit a structure and we need to keep going.
		carbon_parent.Immobilize(0.8 SECONDS) // Prevent them from throw bending around objects.
		carbon_parent.apply_status_effect(/datum/status_effect/no_throw_back) // Stops the default knockback when tossed into walls
		// We don't exactly know what stopped us. So throw us at the turf and let physics handle it.
		INVOKE_ASYNC(carbon_parent, TYPE_PROC_REF(/atom/movable, throw_at), target_turf, 1, 1)
		qdel(blocked)

/// Signal proc to cleanup once we're done moving
/datum/component/force_move/proc/loop_ended(datum/source)
	SIGNAL_HANDLER

	if(QDELETED(src))
		return

	qdel(src)
