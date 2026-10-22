#define DEFER_MOVE 1 //Let /client/Move() handle the movement
#define MOVE_ALLOWED 2 //Allow mob to pass through
#define MOVE_NOT_ALLOWED 3 //Do not let the mob through

#define WALK_COMPONENT_TRAIT "walk_component_trait"

/datum/component/walk

/datum/component/walk/Initialize()
	if(!istype(parent, /mob/living))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(handle_move))
	ADD_TRAIT(parent, TRAIT_SILENT_FOOTSTEPS, WALK_COMPONENT_TRAIT)

/datum/component/walk/ClearFromParent()
	REMOVE_TRAIT(parent, TRAIT_SILENT_FOOTSTEPS, WALK_COMPONENT_TRAIT)
	return ..()

/datum/component/walk/proc/handle_move(datum/source, direction)
	SIGNAL_HANDLER
	var/mob/living/target = parent
	var/turf/next_turf = get_step(target, direction)
	target.setDir(direction)
	if(!next_turf)
		return
	var/allowed = can_walk(target, next_turf)
	switch(allowed)
		if(DEFER_MOVE)
			return FALSE
		if(MOVE_NOT_ALLOWED)
			return TRUE
		if(MOVE_ALLOWED)
			preprocess_move(target, next_turf)
			target.forceMove(next_turf)
			finalize_move(target, next_turf)
			return TRUE

/datum/component/walk/proc/can_walk(mob/living/user, turf/destination)
	return MOVE_ALLOWED

/datum/component/walk/proc/preprocess_move(mob/living/user, turf/destination)
	return

/datum/component/walk/proc/finalize_move(mob/living/user, turf/destination)
	return

/datum/component/walk/shadow
	///use for tracking movement delay for shadow walking through walls
	var/move_delay = 0
	var/atom/movable/pulled

/datum/component/walk/shadow/handle_move(datum/source, list/move_args)
	if(world.time < move_delay) //do not move anything ahead of this check please
		return TRUE
	var/mob/living/Livin = source

	var/direction = move_args[MOVE_ARG_DIRECTION]
	var/turf/Destination = get_step(Livin, direction)
	Livin.setDir(direction)
	if(!Destination)
		return

	var/old_move_delay = move_delay
	move_delay = world.time + world.tick_lag
	//We are now going to move
	var/add_delay = Livin.cached_multiplicative_slowdown
	var/new_glide_size = DELAY_TO_GLIDE_SIZE(add_delay * ( (NSCOMPONENT(direction) && EWCOMPONENT(direction)) ? sqrt(2) : 1 ) )
	Livin.set_glide_size(new_glide_size) // set it now in case of pulled objects
	//If the move was recent, count using old_move_delay
	//We want fractional behavior and all
	if(old_move_delay + world.tick_lag > world.time)
		//Yes this makes smooth movement stutter if add_delay is too fractional
		//Yes this is better then the alternative
		move_delay = old_move_delay
	else
		move_delay = world.time

	var/allowed = can_walk(Livin, Destination)
	switch(allowed)
		if(DEFER_MOVE)
			return FALSE
		if(MOVE_NOT_ALLOWED)
			return TRUE
		if(MOVE_ALLOWED)
			preprocess_move(Livin, Destination)
			Livin.forceMove(Destination)
			INVOKE_ASYNC(src, PROC_REF(finalize_move), Livin, Destination)
			if(direction & (direction - 1) && Livin.loc == Destination) //extra delay for diagonals
				add_delay *= sqrt(2)
			Livin.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay))
			move_delay += add_delay
			return TRUE

/datum/component/walk/shadow/can_walk(mob/living/user, turf/destination)
	if(istype(destination, /turf/closed/mineral))
		return DEFER_MOVE // if not asteroid rocks n shit
	return (destination.get_lumcount() <= SHADOW_SPECIES_DIM_LIGHT ? MOVE_ALLOWED : DEFER_MOVE)

/datum/component/walk/shadow/preprocess_move(mob/living/user, turf/destination)
	if(user.pulling)
		if(user.pulling.anchored || (user.pulling == user.loc && user.pulling.density))
			user.stop_pulling()
			return
		if(isliving(user.pulling))
			var/mob/living/abductee = user.pulling
			abductee.stop_pulling()
			if(abductee.buckled && abductee.buckled.buckle_prevents_pull)
				user.stop_pulling()
				return
			abductee.face_atom(user)
		pulled = user.pulling
		pulled.set_glide_size(user.glide_size)
		user.pulling.forceMove(get_turf(user))

/datum/component/walk/shadow/finalize_move(mob/living/user, turf/destination)
	if(pulled)
		user.start_pulling(pulled, TRUE, supress_message = TRUE)
		pulled = null

/datum/component/walk/jaunt

/datum/component/walk/jaunt/can_walk(mob/living/user, turf/destination)
	if(destination.turf_flags & NOJAUNT || is_secret_level(destination.z))
		to_chat(user, span_warning("Some strange aura is blocking the way."))
		return MOVE_NOT_ALLOWED
	if (locate(/obj/effect/blessing, destination))
		to_chat(user, span_warning("Holy energies block your path!"))
		return MOVE_NOT_ALLOWED
	return MOVE_ALLOWED

#undef DEFER_MOVE
#undef MOVE_ALLOWED
#undef MOVE_NOT_ALLOWED
