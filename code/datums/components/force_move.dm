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
	var/slip_spin = FALSE
	/// If TRUE termination of movement causes a stun and can cause vendors to fall
	var/slip_crash = FALSE

/datum/component/force_move/Destroy(force)
	if(!QDELETED(our_looper))
		qdel(our_looper)
	our_looper = null
	return ..()

/datum/component/force_move/Initialize(atom/target, slip_spin = FALSE, slip_crash = FALSE)
	if(!target || !ismob(parent))
		return COMPONENT_INCOMPATIBLE

	src.slip_spin = slip_spin
	src.slip_crash = slip_crash

	create_loop(target)

/datum/component/force_move/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(stop_move))
	RegisterSignal(parent, COMSIG_ATOM_PRE_PRESSURE_PUSH, PROC_REF(stop_pressure))

/datum/component/force_move/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, COMSIG_ATOM_PRE_PRESSURE_PUSH))

// Slipping allowed for two force_move components to be added, this breaks the movement loop signals and if slide distance is too high,
// it causes people to get stuck until the loop expires. So is to prevent the creation of an unmanaged loop.
/datum/component/force_move/InheritComponent(datum/component/force_move/new_mover, i_am_original, atom/target, slip_spin, slip_crash)
	if(!i_am_original)
		return

	// Remove the old loop such it doesn't delete us with it
	if(!QDELETED(our_looper))
		UnregisterSignal(our_looper, list(COMSIG_MOVELOOP_POSTPROCESS, COMSIG_QDELETING))
		QDEL_NULL(our_looper)

	src.slip_spin = slip_spin
	src.slip_crash = slip_crash

	create_loop(target)

/// Create a new movement loop for us
/datum/component/force_move/proc/create_loop(atom/target)
	var/dist = get_dist(parent, target)
	our_looper = SSmove_manager.move_towards(parent, target, delay = 1, timeout = dist)
	if(slip_spin || slip_crash)
		RegisterSignal(our_looper, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_process))
	RegisterSignal(our_looper, COMSIG_QDELETING, PROC_REF(loop_ended))

/// Signal proc to prevent client movement
/datum/component/force_move/proc/stop_move(datum/source)
	SIGNAL_HANDLER

	return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

/// Signal proc to prevent pressure movement
/datum/component/force_move/proc/stop_pressure(datum/source)
	SIGNAL_HANDLER

	return COMSIG_ATOM_BLOCKS_PRESSURE

/// Signal proc for after the moveloop has processed
/datum/component/force_move/proc/post_process(datum/source, result, delay)
	SIGNAL_HANDLER


	if(!result)
		if(slip_spin)
			var/mob/mob_parent = parent
			mob_parent.spin(1, 1)
		return

	if(!slip_crash || !isliving(parent))
		return

	var/mob/living/living_parent = parent
	var/turf/target_turf = get_step(living_parent, living_parent.dir)

	var/obj/machinery/heavy_weight = (locate(/obj/machinery/vending) in target_turf)
	if(heavy_weight) // When a stoppable force hits immovable capitalism.
		INVOKE_ASYNC(heavy_weight, TYPE_PROC_REF(/obj/machinery/vending, tilt), living_parent) // We hit the machine so let them hit back.
	else
		// We hit a dense atom and we need to stop.
		living_parent.Immobilize(0.8 SECONDS) // Prevent them from throw bending around objects.
		living_parent.apply_status_effect(/datum/status_effect/no_throw_back) // Stops the default knockback when tossed into walls

		// We don't exactly know what stopped us. So throw us at the turf and let physics handle it.
		INVOKE_ASYNC(living_parent, TYPE_PROC_REF(/atom/movable, throw_at), target_turf, 1, 1)

	qdel(our_looper)

/// Signal proc to cleanup once we're done moving
/datum/component/force_move/proc/loop_ended(datum/source)
	SIGNAL_HANDLER

	if(QDELETED(src))
		return

	qdel(src)
