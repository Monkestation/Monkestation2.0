//" Among Us Promise "
//I promise you, in full not part
//That Among Us Creatures come first in my heart
//Whether it be night or day
//A game of Among Us, I'd love to play!
//Recite this promise if you would drop everything to play a game of "Among Us" - no matter the costs.

/mob/living/basic/amoung //default color is red, others are defined below
	name = "amoung"
	desc = "What a fascinating and strange little creature. Probably harmless?"
	icon = 'monkestation/code/modules/biodome/icons/amoung.dmi'
	icon_state = "amoung"
	icon_living = "amoung"
	icon_dead = "amoung_dead"
	speed = 1
	response_help_continuous = "bumps"
	response_help_simple = "bump"
	response_disarm_continuous = "pushes aside"
	response_disarm_simple = "push aside"
	response_harm_continuous = "attacks"
	response_harm_simple = "attack"
	speak_emote = list("communicates")
	maxHealth = 25
	health = 25
	friendly_verb_continuous = "nudges"
	friendly_verb_simple = "nudge"
	mob_biotypes = MOB_ORGANIC
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "communicates"
	verb_ask = "communicates"
	verb_exclaim = "communicates"
	verb_yell = "communicates"
	gender = NEUTER
	held_items = list(null, null)
	greyscale_colors = "#ffffff"
	ai_controller = /datum/ai_controller/basic_controller/amoung
	// They're wearing space suits
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	/// List of possible amongus colours.
	var/static/list/amoung_colors = list(
		"red" = "#ff0033",
		"blue" = "#3366ff",
		"green" = "#10802d",
		"pink" = "#ee55ba",
		"yellow" = "#e9ea53",
		"black" = "#3f484e",
		"white" = "#d6e1f0",
		"purple" = "#6b30bc",
		"brown" = "#72491e",
		"cyan" = "#39e2dd",
		"lime" = "#50f038"
	)

/datum/ai_controller/basic_controller/amoung
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

/mob/living/basic/amoung/Initialize(mapload)
	. = ..()
	random_colour()
	set_greyscale(new_config=/datum/greyscale_config/amoung)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE)

///picks a random colour for our amoung
/mob/living/basic/amoung/proc/random_colour()
	var/our_color = pick(amoung_colors)
	set_greyscale(colors = list(amoung_colors[our_color]))

/mob/living/basic/amoung/bee_friendly()
	return TRUE //why not lol

//amoung pequeño amoung pequeño amoung pequeño amoung pequeño amoung pequeño
//amoung pequeño amoung pequeño amoung pequeño amoung pequeño amoung pequeño

/mob/living/basic/amoung/pequeno
	name = "amoung pequeño"
	desc = "What a sooooo small creature. Probably harmless?"
	icon_state = "amoung_pequeno"
	icon_living = "amoung_pequeno"
	icon_dead = "amoung_pequeno_dead"

/mob/living/basic/amoung/pequeno/Initialize(mapload)
	. = ..()
	set_greyscale(new_config=/datum/greyscale_config/amoung_pequeno)

// corpse spawners, you monster

/obj/effect/mob_spawn/corpse/amoung
	mob_type = /mob/living/basic/amoung

/obj/effect/mob_spawn/corpse/amoung/pequeno
	mob_type = /mob/living/basic/amoung/pequeno

// amoung... surgeon??
// Can probably be replaced when I do my future 'among us content expansion', if that ever happens

/mob/living/basic/cat_butcherer/Initialize(mapload)
	. = ..()
	new /mob/living/basic/amoung/surgeon(loc)
	return INITIALIZE_HINT_QDEL

/mob/living/basic/amoung/surgeon
	name = "suspicious surgeon"
	desc = "Hey! What's this guy up to?"
	icon = 'monkestation/code/modules/biodome/icons/amoung.dmi'
	icon_state = "amoung"
	icon_living = "amoung"
	icon_dead = "amoung_dead"
	basic_mob_flags = DEL_ON_DEATH
	maxHealth = 100
	health = 100
	verb_say = "purrs"
	verb_ask = "purrs"
	verb_exclaim = "loudly purrs"
	verb_yell = "loudly purrs"
	speak_emote = list("purrs", "meows")
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "slashes at"
	attack_verb_simple = "slash at"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	istate = ISTATE_HARM
	sentience_type = SENTIENCE_HUMANOID
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("hostile")
	status_flags = CANPUSH
	ai_controller = /datum/ai_controller/basic_controller/amoung/hostile

/mob/living/basic/amoung/surgeon/random_colour()
	set_greyscale(colors=list(amoung_colors["white"]))

// Shock twist!
/mob/living/basic/amoung/surgeon/death(gibbed)
	var/obj/effect/particle_effect/fluid/smoke/poof = new(get_turf(src))
	poof.lifetime = 2 SECONDS
	do_sparks(3, TRUE, src)
	visible_message(span_notice("[src] collapses to the ground! ...and something crawls out of its empty suit?"))

	new /obj/item/stack/cable_coil(loc)
	new /obj/item/stack/sheet/cloth(loc)
	new /obj/item/stock_parts/manipulator(loc)
	new /obj/item/circular_saw(loc)
	var/mob/living/simple_animal/pet/cat/kitten/surgeon = new(loc)
	surgeon.name = "suspicious kitten"
	surgeon.desc = "You don't think this cat was... no... it couldn't be, could it?"
	..(TRUE)

/datum/ai_controller/basic_controller/amoung/hostile
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

/datum/ai_controller/basic_controller/amoung/hostile
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/carp, // Can't be bothered to change the subtype, it has the right cooldown
		/datum/ai_planning_subtree/basic_melee_attack_subtree/amoung/surgeon
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/amoung/surgeon
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/amoung/surgeon

/datum/ai_behavior/basic_melee_attack/amoung/surgeon
	action_cooldown = 1.5 SECONDS

/datum/ai_behavior/basic_melee_attack/amoung/surgeon/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)

	var/mob/living/basic/surgeon = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])

	if(!targeting_strategy.can_attack(surgeon, target))
		finish_action(controller, FALSE, target_key)
		return
	if (!prob(35))
		return
	surgeon.say(pick(list("Meow!", "Esp!", "Purr!", "HSSSSS")))

	return ..()

/datum/greyscale_config/amoung
	name = "Amoung"
	icon_file = 'monkestation/code/modules/biodome/icons/amoung.dmi'
	json_config = 'code/datums/greyscale/json_configs/amoung.json'

/datum/greyscale_config/amoung_pequeno
	name = "Amoung Pequeno"
	icon_file = 'monkestation/code/modules/biodome/icons/amoung.dmi'
	json_config = 'code/datums/greyscale/json_configs/amoung_pequeno.json'
