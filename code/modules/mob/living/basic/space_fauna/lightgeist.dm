/**
 * ## Lightgeists
 *
 * Small critters meant to heal other living mobs and unable to interact with almost everything else.
 *
 */
/mob/living/basic/lightgeist
	name = "lightgeist"
	desc = "This small floating creature is a completely unknown form of life... being near it fills you with a sense of tranquility."
	icon_state = "lightgeist"
	icon_living = "lightgeist"
	icon_dead = "butterfly_dead"
	response_help_continuous = "waves away"
	response_help_simple = "wave away"
	response_disarm_continuous = "brushes aside"
	response_disarm_simple = "brush aside"
	response_harm_continuous = "disrupts"
	response_harm_simple = "disrupt"
	speak_emote = list("oscillates")
	maxHealth = 2
	health = 2
	melee_damage_lower = 5
	melee_damage_upper = 5
	melee_attack_cooldown = 5 SECONDS
	friendly_verb_continuous = "taps"
	friendly_verb_simple = "tap"
	density = FALSE
	basic_mob_flags = DEL_ON_DEATH
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = HOSTILE_SPAWN
	verb_say = "warps"
	verb_ask = "floats inquisitively"
	verb_exclaim = "zaps"
	verb_yell = "bangs"
	initial_language_holder = /datum/language_holder/lightbringer
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	light_outer_range = 4
	faction = list(FACTION_NEUTRAL)
	unsuitable_atmos_damage = 0
	bodytemp_cold_damage_limit = -1
	bodytemp_heat_damage_limit = 1500
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE

	ai_controller = /datum/ai_controller/basic_controller/lightgeist

/mob/living/basic/lightgeist/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	remove_verb(src, /mob/living/verb/pulled)
	remove_verb(src, /mob/verb/me_verb)

	var/datum/atom_hud/medical_sensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medical_sensor.show_to(src)

	AddElement(/datum/element/simple_flying)
	AddComponent(\
		/datum/component/healing_touch,\
		heal_brute = melee_damage_upper,\
		heal_burn = melee_damage_upper,\
		heal_time = 0,\
		valid_targets_typecache = typecacheof(list(/mob/living)),\
		action_text = "%SOURCE% begins mending the wounds of %TARGET%",\
		complete_text = "%TARGET%'s wounds mend together.",\
	)

/mob/living/basic/lightgeist/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if (. && isliving(target))
		faction |= REF(target) // Anyone we heal will treat us as a friend

/mob/living/basic/lightgeist/ghost()
	. = ..()
	if(.)
		death()

/datum/ai_controller/basic_controller/lightgeist
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/lightgeist,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree, // We heal things by attacking them
	)

/// Attack only mobs who have damage that we can heal, I think this is specific enough not to be a generic type
/datum/targeting_strategy/lightgeist
	/// Types of mobs we can heal, not in a blackboard key because there is no point changing this at runtime because the component will already exist
	var/heal_biotypes = MOB_ORGANIC | MOB_MINERAL
	/// Type of limb we can heal
	var/required_bodytype = BODYTYPE_ORGANIC

/datum/targeting_strategy/lightgeist/can_attack(mob/living/living_mob, mob/living/target, vision_range)
	if (!isliving(target) || target.stat == DEAD)
		return FALSE
	if (!(heal_biotypes & target.mob_biotypes))
		return FALSE
	if (!iscarbon(target))
		return target.getBruteLoss() > 0 || target.getFireLoss() > 0
	var/mob/living/carbon/carbon_target = target
	for (var/obj/item/bodypart/part in carbon_target.bodyparts)
		if (!part.brute_dam && !part.burn_dam)
			continue
		if (!(part.bodytype & required_bodytype))
			continue
		return TRUE
	return FALSE

/mob/living/basic/lightgeist/photogeist
	name = "photogeist"
	icon_state = "photogeist"
	icon_living = "photogeist"
	faction = list(FACTION_PLANTS, FACTION_VINES)
	initial_language_holder = /datum/language_holder/photogeist //only speak plant language, understand it and common
	maxHealth = 10 //tough enough to resist a punch or something small, since they cost a fair bit of favor.
	health = 10
	light_outer_range = 6
	melee_damage_upper = 3

/obj/effect/mob_spawn/ghost_role/photogeist
	name = "dormant photogeist"
	prompt_name = "photogeist"
	desc = "A strange plant creature. It seems to be peacefully sleeping, and its mere presence soothes your nerves."
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "dormantphotogeist"
	density = FALSE
	anchored = FALSE
	dont_be_a_shit = FALSE

	mob_type = /mob/living/basic/lightgeist/photogeist
	mob_name = "photogeist"
	you_are_text = "You are a photogeist, a peaceful creature summoned by a plant god"
	flavour_text = "Try to prevent plant creatures from dying and listen to your summoner otherwise."

/obj/effect/mob_spawn/ghost_role/photogeist/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A photogeist has been summoned in [A.name].", 'sound/effects/shovel_dig.ogg', source = src, action = NOTIFY_JUMP)
