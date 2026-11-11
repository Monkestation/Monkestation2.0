/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/
///OOK OOK OOK

/datum/ai_controller/monkey
	ai_movement = /datum/ai_movement/basic_avoidance
	movement_delay = 0.4 SECONDS
	behavior_tree_json = "code/datums/ai/monkey/monkey.bt.json"
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
		BB_MONKEY_GIVE_CHANCE = 5,
		BB_MONKEY_PICKUP_IS_PICKPOCKET = null,
		BB_MONKEY_IDLE_COMMON_EMOTES = list("screech", "roar"),
		BB_MONKEY_IDLE_RARE_EMOTES = list("scratch", "jump", "roll", "tail"),
	)

/datum/targeting_strategy/basic/monkey
	custom_faction_check = TRUE

/datum/targeting_strategy/basic/monkey/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	// if they wronged us, all bets are off
	if(controller.blackboard[BB_MONKEY_ENEMIES][the_target])
		return FALSE
	// target was forcibly set, all bets are off again
	if(controller.blackboard[BB_CURRENT_TARGET] == the_target)
		return FALSE
	return ..()

/datum/ai_controller/monkey/New(atom/new_pawn)
	AddElement(/datum/element/ai_control_examine, list(
		ORGAN_SLOT_EYES = span_monkey("eyes have a primal look in them."),
	))
	return ..()

/datum/ai_controller/monkey/pun_pun/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	pawn = new_pawn
	set_blackboard_key(BB_IGNORE_DRINKS, TRUE)
	set_blackboard_key(BB_MONKEY_TAMED, TRUE)
	set_blackboard_key(BB_MONKEY_GIVE_CHANCE, 30)
	set_blackboard_key(BB_MONKEY_PRESS_TYPEPATH, /obj/structure/desk_bell)
	override_blackboard_key(BB_MONKEY_IDLE_COMMON_EMOTES, list("tunesing", "dance", "bow"))
	override_blackboard_key(BB_MONKEY_IDLE_RARE_EMOTES, list("clear", "sign", "tail"))
	set_trip_mode(mode = FALSE)

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
	var/mob/living/carbon/regressed_monkey = pawn
	var/brain = regressed_monkey.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(istype(brain, /obj/item/organ/internal/brain/primate)) // In case we are a monkey AI in a human brain by who was previously controlled by a client but it now not by some marvel
		var/obj/item/organ/internal/brain/primate/monkeybrain = brain
		monkeybrain.tripping = mode

///Reactive events to being hit
/datum/ai_controller/monkey/proc/retaliate(mob/living/living_mob)
	// just to be safe
	if(QDELETED(living_mob))
		return

	add_blackboard_key_assoc(BB_MONKEY_ENEMIES, living_mob, MONKEY_HATRED_AMOUNT)
	if(HAS_TRAIT(living_mob, TRAIT_MONKEYFRIEND))
		REMOVE_TRAIT(living_mob, TRAIT_MONKEYFRIEND, SPECIES_TRAIT)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(monkeyfriend_check), living_mob), 60 SECONDS)

/proc/monkeyfriend_check(mob/living/user)
	var/obj/item/clothing/suit/costume/monkeysuit/S
	var/obj/item/clothing/mask/gas/monkeymask/M
	var/list/equipped = user.get_equipped_items(FALSE)
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(TRAIT_MONKEYFRIEND in carbon_user?.dna?.species.inherent_traits)
			ADD_TRAIT(user, TRAIT_MONKEYFRIEND, SPECIES_TRAIT)
	if(((M in equipped) && (S in equipped)))
		ADD_TRAIT(user, TRAIT_MONKEYFRIEND, CLOTHING_TRAIT)

/datum/ai_controller/monkey/proc/on_attacked(datum/source, mob/attacker)
	SIGNAL_HANDLER
	// penned monkeys have become jaded to getting glomped, and thus are less likely to lose their mcfucking marbles
	var/mob/living/basic/slime/slime = astype(attacker)
	if(prob(slime?.is_ranched() ? PENNED_MONKEY_RETALIATE_PROB : MONKEY_RETALIATE_PROB))
		retaliate(attacker)

/datum/ai_controller/monkey/proc/on_startpulling(datum/source, atom/movable/puller, state, force)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(!IS_DEAD_OR_INCAP(living_pawn) && prob(MONKEY_PULL_AGGRO_PROB)) // nuh uh you don't pull me!
		retaliate(living_pawn.pulledby)
		return TRUE

/datum/ai_controller/monkey/proc/on_try_syringe(datum/source, mob/user)
	SIGNAL_HANDLER
	// chance of monkey retaliation
	if(prob(MONKEY_SYRINGE_RETALIATION_PROB))
		retaliate(user)

/datum/ai_controller/monkey/proc/on_attempt_cuff(datum/source, mob/user)
	SIGNAL_HANDLER
	// chance of monkey retaliation
	if(prob(MONKEY_CUFF_RETALIATION_PROB))
		retaliate(user)

/datum/ai_controller/monkey/proc/update_movespeed(mob/living/pawn)
	SIGNAL_HANDLER
	movement_delay = pawn.cached_multiplicative_slowdown
