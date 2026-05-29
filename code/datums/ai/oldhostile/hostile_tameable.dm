///This code needs to be removed at some point as it doesn't actually utilize the AI.

/datum/ai_controller/hostile_friend
	blackboard = list(
		BB_HOSTILE_ORDER_MODE = null,
		BB_HOSTILE_FRIEND = null,
		BB_FOLLOW_TARGET = null,
		BB_ATTACK_TARGET = null,
		BB_VISION_RANGE = BB_HOSTILE_VISION_RANGE,
		BB_HOSTILE_ATTACK_WORD = "growls",
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/hostile_tameable

	var/ride_penalty_movement = 1 SECONDS

	COOLDOWN_DECLARE(command_cooldown)

/datum/ai_controller/hostile_friend/process(seconds_per_tick)
	if(isliving(pawn))
		var/mob/living/living_pawn = pawn
		movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..()

/datum/ai_controller/hostile_friend/TryPossessPawn(atom/new_pawn)
	if(!ishostile(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	RegisterSignal(new_pawn, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(new_pawn, COMSIG_CLICK_ALT, PROC_REF(check_altclicked))
	RegisterSignal(new_pawn, COMSIG_RIDDEN_DRIVER_MOVE, PROC_REF(on_ridden_driver_move))
	RegisterSignal(new_pawn, COMSIG_MOVABLE_PREBUCKLE, PROC_REF(on_prebuckle))
	return ..() //Run parent at end

/datum/ai_controller/hostile_friend/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_EXAMINE,
		COMSIG_CLICK_ALT,
		COMSIG_LIVING_DEATH,
		COMSIG_QDELETING
	))
	unfriend()
	return ..() //Run parent at end

/datum/ai_controller/hostile_friend/proc/on_prebuckle(mob/source, mob/living/buckler, force, buckle_mob_flags)

/datum/ai_controller/hostile_friend/able_to_run()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/hostile_friend/proc/on_ridden_driver_move(atom/movable/movable_parent, mob/living/user, direction)

/// Befriends someone
/datum/ai_controller/hostile_friend/proc/befriend(mob/living/new_friend)


/// Someone is being mean to us, take them off our friends (add actual enemies behavior later)
/datum/ai_controller/hostile_friend/proc/unfriend()

/// Someone is looking at us, if we're currently carrying something then show what it is, and include a message if they're our friend
/datum/ai_controller/hostile_friend/proc/on_examined(datum/source, mob/user, list/examine_text)



// next section is regarding commands

/// Someone alt clicked us, see if they're someone we should show the radial command menu to
/datum/ai_controller/hostile_friend/proc/check_altclicked(datum/source, mob/living/clicker)



/// Show the command radial menu
/datum/ai_controller/hostile_friend/proc/command_radial(mob/living/clicker)



/datum/ai_controller/hostile_friend/proc/check_menu(mob/user)

/// One of our friends said something, see if it's a valid command, and if so, take action
/datum/ai_controller/hostile_friend/proc/check_verbal_command(mob/speaker, speech_args)






/// Whether we got here via radial menu or a verbal command, this is where we actually process what our new command will be
/datum/ai_controller/hostile_friend/proc/set_command_mode(mob/commander, command)

		// heel: stop what you're doing, relax and try not to do anything for a little bit
		// follow: whatever the commander points to, try and bring it back
		// attack: harass whoever the commander points to

/// Someone we like is pointing at something, see if it's something we might want to interact with (like if they might want us to fetch something for them)
/datum/ai_controller/hostile_friend/proc/check_point(mob/pointing_friend, atom/movable/pointed_movable)






/datum/idle_behavior/idle_random_walk/hostile_tameable
	walk_chance = 5
