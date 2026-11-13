/mob/living/basic/pet/bumbles
	name = "Bumbles"
	desc = "Bumbles, the very humble bumblebee."
	icon = 'monkestation/code/modules/blueshift/icons/mob/pets.dmi'
	icon_state = "bumbles"
	icon_living = "bumbles"
	icon_dead = "bumbles_dead"
	maxHealth = 15
	health = 15
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "brushes aside"
	response_help_simple = "brush aside"
	response_harm_continuous = "squashes"
	response_harm_simple = "squash"
	speak_emote = list("buzzes")
	friendly_verb_continuous = "bzzs"
	friendly_verb_simple = "bzz"
	butcher_results = list(/obj/item/reagent_containers/honeycomb = 2)
	density = FALSE
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "buzzs"
	verb_ask = "buzzes inquisitively"
	verb_exclaim = "buzzes intensely"
	verb_yell = "buzzes intensely"
	unique_name = TRUE
	ai_controller = /datum/ai_controller/basic_controller/bumbles

	/// List of flower types that can be attacked to smell, or are targetted by AI.
	var/list/flower_types = list(
		/obj/item/bouquet,
		/obj/item/food/grown/poppy,
		/obj/item/food/grown/sunflower,
		/obj/item/food/grown/moonflower,
		/obj/item/food/grown/rose,
		/obj/item/food/grown/harebell,
	)

/mob/living/basic/pet/bumbles/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/simple_flying)
	add_verb(src, /mob/living/proc/toggle_resting)

	ai_controller.set_blackboard_key(BB_BASIC_FOODS, flower_types)

	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(smell_flower))

/mob/living/basic/pet/bumbles/update_resting()
	if(stat == DEAD)
		return ..()

	if (resting)
		icon_state = "[icon_living]_rest"

		manual_emote(pick("curls up on the surface below.", "is looking very sleepy.", "buzzes happily.", "looks around for a flower nap."))
		REMOVE_TRAIT(src, TRAIT_MOVE_FLYING, ROUNDSTART_TRAIT)
	else
		icon_state = "[icon_living]"

		manual_emote(pick("wakes up with a smiling buzz.", "rolls upside down before waking up.", "stops resting."))
		ADD_TRAIT(src, TRAIT_MOVE_FLYING, ROUNDSTART_TRAIT)

	regenerate_icons()
	return ..()

/mob/living/basic/pet/bumbles/bee_friendly()
	return TRUE // treaty signed at the Beeneeva convention

/mob/living/basic/pet/bumbles/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	if(!. || !proximity_flag || (istate & ISTATE_HARM))
		return

	smell_flower(src, attack_target)

/**
 * Smell a flower, either via AI or unarmed attack.
 *
 * Arguments:
 * * source - Signal source. Will be the same as src.
 * * target - The thing being attacked.
 */
/mob/living/basic/pet/bumbles/proc/smell_flower(atom/source, atom/target)
	SIGNAL_HANDLER

	if(!is_type_in_list(target, flower_types))
		return

	manual_emote(pick("smells [target].", "sniffs [target].", "collects some nectar."))

	// Clear the target, if any or we'll stunlock on a flower.
	ai_controller.clear_blackboard_key(BB_CURRENT_TARGET)

	return TRUE

/mob/living/basic/pet/bumbles/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	if(resting)
		set_resting(FALSE)

///////////////////////////////
// Bumbles AI below.
///////////////////////////////

// Bumble AI controller that adds find flowers, resting, and buzzing subtrees.
/datum/ai_controller/basic_controller/bumbles
	behavior_tree_json = "monkestation/code/modules/blueshift/mobs/bumbles.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_HEAR = list("buzzes.", "makes a loud buzz.", "buzzes happily."),
			BB_EMOTE_SEE = list("rolls several times."),
			BB_SPEAK_CHANCE = 1,
		),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance

/// Sniffs the flower, then leaves it alone for 30 seconds
/datum/bt_node/ai_behavior/hunt_target/bumbles_smell
	hunt_cooldown = 30 SECONDS
	always_reset_target = TRUE

/datum/bt_node/ai_behavior/hunt_target/bumbles_smell/target_caught(mob/living/basic/pet/bumbles/hunter, atom/hunted)
	hunter.smell_flower(hunter, hunted)

/// Passes while the pawn is lying down for a rest
/datum/bt_node/decorator/pawn_resting

/datum/bt_node/decorator/pawn_resting/check_condition(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	return isliving(living_pawn) && living_pawn.resting

/// Bumbles rests or sits up.
/datum/bt_node/ai_behavior/bumbles_rest
	/// Chance per second to flip between resting and not
	var/chance = 0.5

/datum/bt_node/ai_behavior/bumbles_rest/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || living_pawn.buckled || !SPT_PROB(chance, seconds_per_tick))
		return AI_BEHAVIOR_FAILED
	living_pawn.set_resting(!living_pawn.resting)
	return AI_BEHAVIOR_SUCCEEDED
