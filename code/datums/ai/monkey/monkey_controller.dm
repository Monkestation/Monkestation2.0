/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/
///OOK OOK OOK

/datum/ai_controller/monkey
	ai_movement = /datum/ai_movement/basic_avoidance
	movement_delay = 0.4 SECONDS
	planning_subtrees = list(
		/datum/ai_planning_subtree/generic_resist,
		/datum/ai_planning_subtree/monkey_combat,
		/datum/ai_planning_subtree/generic_hunger,
		/datum/ai_planning_subtree/generic_play_instrument,
		/datum/ai_planning_subtree/monkey_shenanigans,
	)
	blackboard = list(
		BB_MONKEY_AGGRESSIVE = FALSE,
		BB_MONKEY_BEST_FORCE_FOUND = 0,
		BB_MONKEY_ENEMIES = list(),
		BB_MONKEY_BLACKLISTITEMS = list(),
		BB_MONKEY_PICKUPTARGET = null,
		BB_MONKEY_PICKPOCKETING = FALSE,
		BB_MONKEY_DISPOSING = FALSE,
		BB_MONKEY_TARGET_DISPOSAL = null,
		BB_MONKEY_CURRENT_ATTACK_TARGET = null,
		BB_MONKEY_GUN_NEURONS_ACTIVATED = FALSE,
		BB_MONKEY_GUN_WORKED = TRUE,
		BB_SONG_LINES = MONKEY_SONG,
	)
	idle_behavior = /datum/idle_behavior/idle_monkey

/datum/ai_controller/monkey/New(atom/new_pawn)
	AddElement(/datum/element/ai_control_examine, list(
		ORGAN_SLOT_EYES = span_monkey("eyes have a primal look in them."),
	))
	return ..()

/datum/ai_controller/monkey/pun_pun
	movement_delay = 0.7 SECONDS //pun pun moves slower so the bartender can keep track of them
	planning_subtrees = list(
		/datum/ai_planning_subtree/generic_resist,
		/datum/ai_planning_subtree/monkey_combat,
		/datum/ai_planning_subtree/generic_hunger,
		/datum/ai_planning_subtree/generic_play_instrument,
		/datum/ai_planning_subtree/punpun_shenanigans,
	)
	idle_behavior = /datum/idle_behavior/idle_monkey/pun_pun

/datum/ai_controller/monkey/angry

/datum/ai_controller/monkey/angry/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	pawn = new_pawn
	set_blackboard_key(BB_MONKEY_AGGRESSIVE, TRUE) //Angry
	set_trip_mode(mode = FALSE)

/datum/ai_controller/monkey/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	var/mob/living/living_pawn = new_pawn
	living_pawn.AddElement(/datum/element/relay_attackers)
	RegisterSignal(new_pawn, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignal(new_pawn, COMSIG_LIVING_START_PULL, PROC_REF(on_startpulling))
	RegisterSignals(new_pawn, list(COMSIG_LIVING_TRY_SYRINGE_INJECT, COMSIG_LIVING_TRY_SYRINGE_WITHDRAW), PROC_REF(on_try_syringe))
	RegisterSignal(new_pawn, COMSIG_CARBON_CUFF_ATTEMPTED, PROC_REF(on_attempt_cuff))
	RegisterSignal(new_pawn, COMSIG_MOB_MOVESPEED_UPDATED, PROC_REF(update_movespeed))

	movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..() //Run parent at end

/datum/ai_controller/monkey/UnpossessPawn(destroy)

	UnregisterSignal(pawn, list(
		COMSIG_ATOM_WAS_ATTACKED,
		COMSIG_LIVING_START_PULL,
		COMSIG_LIVING_TRY_SYRINGE_INJECT,
		COMSIG_LIVING_TRY_SYRINGE_WITHDRAW,
		COMSIG_CARBON_CUFF_ATTEMPTED,
		COMSIG_MOB_MOVESPEED_UPDATED,
	))

	return ..() //Run parent at end

/datum/ai_controller/monkey/on_sentience_lost()
	. = ..()
	set_trip_mode(mode = TRUE)

/datum/ai_controller/monkey/able_to_run()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/monkey/proc/set_trip_mode(mode = TRUE)

///re-used behavior pattern by monkeys for finding a weapon
/datum/ai_controller/monkey/proc/TryFindWeapon()


		// We have a gun, what could we possibly want?








///Reactive events to being hit
/datum/ai_controller/monkey/proc/retaliate(mob/living/living_mob)
	// just to be safe


/proc/monkeyfriend_check(mob/living/user)

/datum/ai_controller/monkey/proc/on_attacked(datum/source, mob/attacker)

/datum/ai_controller/monkey/proc/on_startpulling(datum/source, atom/movable/puller, state, force)

/datum/ai_controller/monkey/proc/on_try_syringe(datum/source, mob/user)
	// chance of monkey retaliation

/datum/ai_controller/monkey/proc/on_attempt_cuff(datum/source, mob/user)
	// chance of monkey retaliation

/datum/ai_controller/monkey/proc/update_movespeed(mob/living/pawn)
