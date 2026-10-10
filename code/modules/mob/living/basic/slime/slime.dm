#define SLIME_EXTRA_SHOCK_COST 3
#define SLIME_BASE_SHOCK_PERCENTAGE 10
#define SLIME_SHOCK_PERCENTAGE_PER_LEVEL 7
/// Moves a human-sized worn hat down onto the slime's head, fits both baby and adult sprites
#define SLIME_HAT_PIXEL_Y -5

/mob/living/basic/slime
	name = "grey baby slime (123)"
	icon = 'icons/obj/xenobiology/slime_rancher/slimes.dmi'
	icon_state = "grey-baby"
	pass_flags = PASSTABLE | PASSGRILLE
	gender = NEUTER
	faction = list(FACTION_SLIME, FACTION_NEUTRAL)

	icon_living = "grey-baby"
	icon_dead = "grey-baby-dead"

	attack_sound = 'sound/weapons/bite.ogg'

	maxHealth = 150
	health = 150
	mob_biotypes = MOB_SLIME
	melee_damage_lower = 7
	melee_damage_upper = 17
	wound_bonus = -45
	can_buckle_to = FALSE
	can_be_held = TRUE

	damage_coeff = list(BRUTE = 1, BURN = -1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) //Healed by fire
	unsuitable_cold_damage = 15
	unsuitable_heat_damage = 0
	bodytemp_heat_damage_limit = INFINITY
	habitable_atmos = null

	attack_verb_simple = "glomp"
	attack_verb_continuous = "glomps"

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"

	speak_emote = list("blorbles")
	bubble_icon = "slime"
	initial_language_holder = /datum/language_holder/slime

	verb_say = "blorbles"
	verb_ask = "inquisitively blorbles"
	verb_exclaim = "loudly blorbles"
	verb_yell = "loudly blorbles"

	ai_controller = /datum/ai_controller/basic_controller/slime

	///What is our current lifestage?
	var/life_stage = SLIME_LIFE_STAGE_BABY

	///Our slime's current mood
	var/current_mood = SLIME_MOOD_NONE

	///If the slime is currently overcrowded and unable to reproduce.
	var/overcrowded = FALSE

	///The number of /obj/item/slime_extract's the slime has left inside
	var/cores = 1
	///Chance of mutating, should be between 25 and 35
	var/mutation_chance = 30
	///1-10 controls how much electricity they are generating
	var/powerlevel = SLIME_MIN_POWER
	///Controls how long the slime has been overfed, if 10, grows or reproduces
	var/amount_grown = 0
	/// No hunger
	var/hunger_disabled = FALSE
	/// Only goes after mobs smaller than us.
	var/cat_slime = FALSE
	/// How many damaging hits in a row a cat slime has put up with so far
	var/cat_patience_hits = 0
	/// world.time of the last damaging hit
	var/cat_patience_last_hit = 0
	/// Cleans messes and pests instead of hunting.
	var/cleaner_slime = FALSE

	///Has a mutator been used on the slime? Only one is allowed
	var/mutator_used = FALSE

	/// The datum that handles the slime color's core and possible mutations
	var/datum/slime_type/slime_type = null
	/// Progress toward each mutation our color can take
	var/list/datum/slime_mutation/mutation_progress
	/// After a slime is initialized, a list of all possible initialized datums of slime_types
	var/static/alist/possible_slime_types = null

	///What cross core modification is being used.
	var/crossbreed_modification
	///How many extracts of the modtype have been applied.
	var/applied_crossbreed_amount = 0

	/// Transformative extracts stuck onto us, oldest first. Our babies get all of them.
	var/list/datum/slime_transformation/transformations
	/// Every transformation's color mixed into one, for the warping core drawn inside us.
	var/transformation_color
	/// Extra babies we make per split.
	var/extra_babies = 0
	/// A split leaves us an adult.
	var/keeps_parent_adult = FALSE
	/// Never splits and never mutates.
	var/blocks_reproduction = FALSE
	/// Added on top of every bit of charge we build up on our own.
	var/extra_charge = 0
	/// Nutrition doesn't drain over time.
	var/stops_hunger = FALSE
	/// Alpha we use instead of our color's whenever we aren't latched onto someone.
	var/stealth_alpha

	/// the pen currently tracking us, if any - null when we're not in one
	var/datum/slime_pen/pen
	COOLDOWN_DECLARE(pen_expiry_cooldown)

	/// health actually drained while adult, banked toward the next extract/split/mutation
	var/ranch_progress = 0
	/// 0 = not primed, otherwise how much ranch_progress a split needs before it fires
	var/primed_split_cost = 0
	/// Slime type a ranch mutation already rolled, held onto until that mutation actually happens
	var/datum/slime_type/pending_ranch_mutation
	COOLDOWN_DECLARE(ranch_retry_cooldown)
	/// Slime type we rolled to become when the current reproduction wind-up finishes
	var/datum/slime_type/queued_mutation

	/// Runs after we get forced off a meal. We can't latch onto anything until it's over.
	COOLDOWN_DECLARE(latch_cooldown)
	COOLDOWN_DECLARE(reaction_mood_cooldown)
	COOLDOWN_DECLARE(nuzzle_cooldown)
	COOLDOWN_DECLARE(bounce_cooldown)
	COOLDOWN_DECLARE(stack_cooldown)

	/// The hat sitting on our head, put on through the strip menu
	var/obj/item/equipped_hat

	/// TRUE while our player is being asked whether someone can pick us up.
	var/pickup_prompt_open = FALSE

	/// Instructions you can give to slimes
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/attack/slime,
		/datum/pet_command/slime_split,
	)

	/// Our evolve action
	var/datum/action/innate/slime/evolve/evolve_action
	/// Our reproduction action
	var/datum/action/innate/slime/reproduce/reproduce_action

/mob/living/basic/slime/Initialize(mapload, new_type = /datum/slime_type/grey, new_life_stage = SLIME_LIFE_STAGE_BABY)
	. = ..()

	evolve_action = new (src)
	evolve_action.Grant(src)

	reproduce_action = new (src)
	reproduce_action.Grant(src)

	if(isnull(possible_slime_types))
		possible_slime_types = alist()
		for(var/datum/slime_type/slime_type as anything in subtypesof(/datum/slime_type))
			possible_slime_types[slime_type] = new slime_type

	set_life_stage(new_life_stage, TRUE)
	set_slime_type(new_type)
	set_nutrition(SLIME_STARTING_NUTRITION)

	AddComponent(/datum/component/health_scaling_effects, min_health_slowdown = 2)
	AddComponent(/datum/component/obeys_commands, pet_commands)

	AddElement(/datum/element/relay_attackers)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SLIME)
	AddElement(/datum/element/soft_landing)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLIME, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

	AddElement(/datum/element/pet_bonus, "jiggles!")
	AddElement(/datum/element/strippable, GLOB.strippable_slime_items)

	// TRAIT_CAREFUL_STEPS so we don't squash iceroaches and such. slimes are soft and squishy it makes sense.
	// TRAIT_NO_IMMOBILIZE is for slimes sitting on us - can_feed_on() refuses a slime that can't move, so they'd never leave for food
	add_traits(list(TRAIT_CANT_RIDE, TRAIT_VENTCRAWLER_ALWAYS, TRAIT_CAREFUL_STEPS, TRAIT_LIGHTWEIGHT, TRAIT_NO_IMMOBILIZE), INNATE_TRAIT)

	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_slime_pre_attack))
	RegisterSignal(src, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(src, COMSIG_SLIME_LATCH_DRAINED, PROC_REF(on_ranch_drain))
	RegisterSignal(src, COMSIG_SLIME_CHECK_WANTED_ITEM, PROC_REF(on_check_wanted_pellet))
	RegisterSignal(src, COMSIG_ANIMAL_PET, PROC_REF(on_petted))
	RegisterSignal(src, COMSIG_SLIME_ATE_ITEM, PROC_REF(on_slime_happy_yay))
	RegisterSignal(src, COMSIG_LIVING_BEFRIENDED, PROC_REF(on_befriended))
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignals(src, list(COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_CURRENT_PET_TARGET), COMSIG_AI_BLACKBOARD_KEY_SET(BB_CURRENT_PET_TARGET)), PROC_REF(on_blackboard_key_changed))

	ai_controller.set_blackboard_key(BB_SLIME_EVOLVE, evolve_action)
	ai_controller.set_blackboard_key(BB_SLIME_REPRODUCE, reproduce_action)

/mob/living/basic/slime/Destroy()
	QDEL_NULL(evolve_action)
	QDEL_NULL(reproduce_action)
	QDEL_LIST(mutation_progress)
	QDEL_LIST(transformations)
	slime_type = null
	equipped_hat?.forceMove(drop_location())

	return ..()

/mob/living/basic/slime/proc/on_blackboard_key_changed(datum/source)
	SIGNAL_HANDLER
	update_ai_movement_type()

/// Cleaners and slimes with a pet target use the adaptive movement.
/mob/living/basic/slime/proc/update_ai_movement_type()
	var/picked_type = /datum/ai_movement/basic_avoidance
	if(cleaner_slime || ai_controller.blackboard_key_exists(BB_CURRENT_PET_TARGET))
		picked_type = /datum/ai_movement/basic_avoidance/adaptive
	if(!istype(ai_controller.ai_movement, picked_type))
		ai_controller.change_ai_movement_type(picked_type)

///Random slime subtype
/mob/living/basic/slime/random

/mob/living/basic/slime/random/Initialize(mapload, new_type, new_life_stage)
	return ..(mapload, pick(subtypesof(/datum/slime_type)), prob(50) ? SLIME_LIFE_STAGE_ADULT : SLIME_LIFE_STAGE_BABY)

///Friendly docile subtype
/mob/living/basic/slime/pet
	hunger_disabled = TRUE

/mob/living/basic/slime/pet/Initialize(mapload, new_type, new_life_stage)
	. = ..()
	set_pacified_behavior()

//Hilbert subtype
/mob/living/basic/slime/hilbert

/mob/living/basic/slime/hilbert/Initialize(mapload, new_type, new_life_stage)
	. = ..(mapload, /datum/slime_type/bluespace)
	ai_controller?.set_blackboard_key(BB_SLIME_RABID, TRUE)

/mob/living/basic/slime/adjust_nutrition(change, forced)
	. = ..()
	nutrition = min(nutrition, SLIME_MAX_NUTRITION)

/mob/living/basic/slime/set_nutrition(set_to, forced = FALSE)
	. = ..()
	nutrition = min(nutrition, SLIME_MAX_NUTRITION)

/mob/living/basic/slime/get_fullness(only_consumable)
	return round((nutrition / SLIME_MAX_NUTRITION) * NUTRITION_LEVEL_FAT)

/mob/living/basic/slime/update_name()
	///Checks if the slime has a generic name, in the format of baby/adult slime (123)
	var/static/regex/slime_name_regex = new("\\w+ (baby|adult) slime \\(\\d+\\)")
	if(slime_name_regex.Find(name))
		var/slime_id = rand(1, 1000)
		name = "[slime_type.color] [life_stage] slime ([slime_id])"
		real_name = name
	return ..()

/mob/living/basic/slime/regenerate_icons()
	if(stealth_alpha && !is_latched())
		alpha = stealth_alpha
	else
		alpha = slime_type.transparent ? SLIME_TRANSPARENCY_ALPHA : src::alpha
	update_appearance(UPDATE_ICON)
	return ..()

/mob/living/basic/slime/set_buckled(new_buckled)
	var/atom/movable/old_seat = buckled
	. = ..()
	if(buckled == old_seat)
		return
	if(isslime(old_seat))
		start_stack_cooldown()
	pixel_z = initial(pixel_z) + stack_pixel_z()
	// whatever we just did, we moved out from under anyone sitting on us
	dump_riders()
	// not COMSIG_LIVING_SET_BUCKLED, that fires before buckled changes, so regenerate_icons() would still see the old meal
	if(stealth_alpha)
		regenerate_icons()

/mob/living/basic/slime/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	// riders only follow a seat that walks. one that gets teleported, picked up or vacuumed leaves them behind, still buckled
	if(isslime(buckled) && buckled.loc != loc)
		hop_off_stack()
	if(forced || !isturf(loc))
		dump_riders()

/mob/living/basic/slime/update_icon_state()
	var/icon_prefix = replacetext(slime_type.color, " ", "-")
	icon_living = "[icon_prefix]-[life_stage]"
	icon_dead = !cores ? "[icon_prefix]-cut" : "[icon_prefix]-[life_stage]-dead"
	icon_state = stat == DEAD ? icon_dead : icon_living
	return ..()

/mob/living/basic/slime/update_overlays()
	. = ..()
	if(stat == DEAD)
		return
	if(transformation_color)
		var/mutable_appearance/warping_core = mutable_appearance('icons/obj/xenobiology/slimecrossing.dmi', "warping", MOB_BELOW_PIGGYBACK_LAYER)
		warping_core.color = transformation_color
		. += warping_core
	if(current_mood && current_mood != SLIME_MOOD_NONE && !stat)
		. += mutable_appearance(icon, "aslime-[current_mood]")
	if(cat_slime)
		var/mutable_appearance/cat_ears = mutable_appearance('icons/obj/xenobiology/slime_rancher/slime_cat_ears.dmi', "cat_ears-[life_stage]")
		cat_ears.color = slime_type.rgb_code
		. += cat_ears
	if(equipped_hat)
		var/mutable_appearance/hat_overlay = equipped_hat.build_worn_icon(default_layer = 0.15, default_icon_file = 'icons/mob/clothing/head/default.dmi')
		SET_PLANE_EXPLICIT(hat_overlay, PLANE_TO_TRUE(plane), src)
		hat_overlay.appearance_flags = RESET_COLOR|KEEP_APART
		hat_overlay.pixel_y += SLIME_HAT_PIXEL_Y
		. += hat_overlay

/mob/living/basic/slime/mouse_drop_dragged(atom/target_atom, mob/user)
	if(isliving(target_atom) && target_atom != src && user == src)
		var/mob/living/food = target_atom
		if(can_feed_on(food))
			start_feeding(food)

/mob/living/basic/slime/mob_try_pickup(mob/living/user, instant = FALSE)
	if(isnull(client))
		if(!(user in ai_controller?.blackboard[BB_FRIENDS_LIST]))
			to_chat(user, span_notice("[src] doesn't trust you enough to let you pick them up"))
			balloon_alert(user, "not enough trust!")
			return FALSE
		return ..()

	if(pickup_prompt_open)
		return FALSE
	pickup_prompt_open = TRUE
	var/answer = tgui_alert(src, "[user] wants to pick you up. Let them?", "Pick up", list("Yes", "No"), timeout = 10 SECONDS)
	pickup_prompt_open = FALSE
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(answer != "Yes")
		balloon_alert(user, "doesn't want to be picked up!")
		return FALSE
	if(user.pulling != src)
		return FALSE
	return ..()

///Slimes can hop off mobs they have latched onto
/mob/living/basic/slime/resist_buckle()
	if(isliving(buckled))
		buckled.unbuckle_mob(src, force = TRUE)

/mob/living/basic/slime/examine(mob/user)
	. = ..()

	switch(powerlevel)
		if(SLIME_MIN_POWER to SLIME_EXTRA_SHOCK_COST)
			. += span_notice("It is flickering gently with harmless levels of electrical activity.")

		if(SLIME_EXTRA_SHOCK_COST to SLIME_MEDIUM_POWER)
			. += span_warning("It is glowing brightly with medium levels electrical activity.")

		if(SLIME_MEDIUM_POWER to SLIME_MAX_POWER)
			. += span_boldwarning("It is glowing alarmingly with high levels of electrical activity.")

		if(SLIME_MAX_POWER)
			. += span_danger("It is radiating with massive levels of electrical activity!")
	if(overcrowded)
		. += span_warning("It seems too overcrowded to properly reproduce!")
	for(var/datum/slime_transformation/transformation as anything in transformations)
		. += span_notice(transformation.desc)

///Changes the slime's current life state
/mob/living/basic/slime/proc/set_life_stage(new_life_stage = SLIME_LIFE_STAGE_BABY, initial = FALSE)
	// how high they sit depends on our size, and so does who's allowed up there at all
	dump_riders()
	life_stage = new_life_stage
	if(life_stage == SLIME_LIFE_STAGE_ADULT)
		health /= 0.75
		maxHealth /= 0.75
		melee_damage_lower *= 2
		melee_damage_upper *= 2
		obj_damage = 15
		wound_bonus = -90

	else if(!initial)
		health *= 0.75
		maxHealth *= 0.75
		melee_damage_lower *= 0.5
		melee_damage_upper *= 0.5
		obj_damage = initial(obj_damage)
		wound_bonus = initial(wound_bonus)

	update_mob_action_buttons()

/// Sets the slime's type, name and its icons.
/// If not provided with a type it will instead be random
/mob/living/basic/slime/proc/set_slime_type(datum/slime_type/new_type)
	if(isnull(new_type))
		new_type = pick(subtypesof(/datum/slime_type))

	slime_type = possible_slime_types[new_type]
	update_name()
	regenerate_icons()
	reset_mutation_progress()

///Handles slime attacking restrictions, and any extra effects that would trigger
/mob/living/basic/slime/proc/on_slime_pre_attack(mob/living/basic/slime/our_slime, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(LAZYACCESS(modifiers, RIGHT_CLICK) && isliving(target) && target != src)
		if(our_slime.can_feed_on(target))
			our_slime.start_feeding(target)
		return COMPONENT_HOSTILE_NO_ATTACK

	// attacking a wanted item eats it instead, so a player slime can just click it
	if(isitem(target) && our_slime.eat_wanted_item(target))
		return COMPONENT_HOSTILE_NO_ATTACK

	if(our_slime.try_dissolve(target))
		return COMPONENT_HOSTILE_NO_ATTACK

	if(isAI(target)) //The aI is not tasty!
		target.balloon_alert(our_slime, "not tasty!")
		return COMPONENT_HOSTILE_NO_ATTACK

	if(our_slime.buckled == target)
		our_slime.stop_feeding()
		return COMPONENT_HOSTILE_NO_ATTACK

	if(iscyborg(target))
		var/mob/living/silicon/robot/borg_target = target
		borg_target.flash_act()
		do_sparks(5, TRUE, borg_target)
		var/stunprob = our_slime.powerlevel * SLIME_SHOCK_PERCENTAGE_PER_LEVEL + SLIME_BASE_SHOCK_PERCENTAGE
		if(prob(stunprob) && our_slime.powerlevel >= SLIME_EXTRA_SHOCK_COST)
			our_slime.adjust_power_level(-SLIME_EXTRA_SHOCK_COST)
			borg_target.apply_damage(our_slime.powerlevel * rand(6, 10), BRUTE, spread_damage = TRUE, wound_bonus = CANT_WOUND)
			borg_target.visible_message(span_danger("\The [our_slime] shocks [borg_target]!"), span_userdanger("\The [our_slime] shocks you!"))
		else
			borg_target.visible_message(span_danger("\The [our_slime] fails to hurt [borg_target]!"), span_userdanger("\The [our_slime] failed to hurt you!"))

		return COMPONENT_HOSTILE_NO_ATTACK

	if(iscarbon(target) && our_slime.powerlevel > SLIME_MIN_POWER)
		var/mob/living/carbon/carbon_target = target
		var/stunprob = our_slime.powerlevel * SLIME_SHOCK_PERCENTAGE_PER_LEVEL + SLIME_BASE_SHOCK_PERCENTAGE  // 17 at level 1, 80 at level 10
		if(!prob(stunprob))
			return NONE // normal attack

		carbon_target.visible_message(span_danger("\The [our_slime] shocks [carbon_target]!"), span_userdanger("\The [our_slime] shocks you!"))

		do_sparks(5, TRUE, carbon_target)
		var/power = our_slime.powerlevel + rand(0,3)
		if(TIMER_COOLDOWN_FINISHED(carbon_target, COOLDOWN_SLIME_SHOCK_KNOCKDOWN))
			carbon_target.Knockdown(power * 0.5 SECONDS)
			TIMER_COOLDOWN_START(carbon_target, COOLDOWN_SLIME_SHOCK_KNOCKDOWN, 10 SECONDS)
		carbon_target.set_stutter_if_lower(power * 2 SECONDS)
		SEND_SIGNAL(our_slime, COMSIG_SLIME_SHOCKED, carbon_target)
		if (prob(stunprob) && our_slime.powerlevel >= SLIME_EXTRA_SHOCK_COST)
			adjust_power_level(-SLIME_EXTRA_SHOCK_COST)
			carbon_target.apply_damage(min(our_slime.powerlevel * rand(6, 10), 25), BURN, spread_damage = TRUE, wound_bonus = CANT_WOUND)

	if(isslime(target))
		if(target == our_slime)
			return COMPONENT_HOSTILE_NO_ATTACK
		var/mob/living/basic/slime/target_slime = target
		if(target_slime.buckled)
			target_slime.stop_feeding(silent = TRUE)
			visible_message(span_danger("[our_slime] pulls [target_slime] off!"), \
				span_danger("You pull [target_slime] off!"))
			return NONE // normal attack

		var/is_adult_slime = our_slime.life_stage == SLIME_LIFE_STAGE_ADULT
		if(target_slime.nutrition >= 100) //steal some nutrition. negval handled in life()
			var/stolen_nutrition = min(is_adult_slime ? 90 : 50, target_slime.nutrition)
			target_slime.adjust_nutrition(-stolen_nutrition)
			our_slime.adjust_nutrition(stolen_nutrition)
		if(target_slime.health > 0)
			our_slime.adjustBruteLoss(is_adult_slime ? -20 : -10)

///Spawns a crossed slimecore item
/mob/living/basic/slime/proc/spawn_corecross()
	var/static/list/crossbreeds = subtypesof(/obj/item/slimecross)
	visible_message(span_danger("[src] shudders, its mutated core consuming the rest of its body!"))
	playsound(src, 'sound/magic/smoke.ogg', 50, TRUE)
	var/selected_crossbreed_path
	for(var/obj/item/slimecross/cross_item as anything in crossbreeds)
		if(cross_item::slime_type == slime_type.type && cross_item::effect == crossbreed_modification)
			selected_crossbreed_path = cross_item
			break
	if(selected_crossbreed_path)
		new selected_crossbreed_path(loc)
	else
		visible_message(span_warning("The mutated core shudders, and collapses into a puddle, unable to maintain its form."))
	qdel(src)

///Proc for slime core removal surgery, tries to remove cores from a dead slime.
/mob/living/basic/slime/proc/try_extract_cores(count = 1)
	if(stat != DEAD)
		return FALSE
	if(count <= 0 || cores < count)
		return FALSE

	var/core_count = min(count, cores)
	for(var/i in 1 to core_count)
		var/obj/item/slime_extract/core = new slime_type.core_type(loc)
		core.fresh_from_slime = TRUE
		cores--

	regenerate_icons()

	return TRUE

///Makes the slime peaceful and content
/mob/living/basic/slime/proc/set_pacified_behavior()
	hunger_disabled = TRUE
	ai_controller?.set_blackboard_key(BB_SLIME_RABID, FALSE)
	ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_DISABLED, TRUE)
	set_nutrition(SLIME_STARTING_NUTRITION)

///Makes the slime angry and hungry
/mob/living/basic/slime/proc/set_enraged_behavior()
	hunger_disabled = FALSE
	ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_DISABLED, FALSE)
	ai_controller?.set_blackboard_key(BB_SLIME_RABID, TRUE)

///Makes the slime hungry but mostly friendly
/mob/living/basic/slime/proc/set_default_behavior()
	hunger_disabled = FALSE
	ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_DISABLED, FALSE)
	ai_controller?.set_blackboard_key(BB_SLIME_RABID, FALSE)

/mob/living/basic/slime/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_SET_TYPE, "Set Slime Type")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_ADD_TRANSFORMATION, "Add Transformation")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_SET_LIFE_STAGE, "Set Life Stage")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_SET_POWER, "Set Power Level")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_SET_BEHAVIOR, "Set Behavior")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_FILL_GROWTH, "Fill Growth")
	VV_DROPDOWN_OPTION(VV_HK_SLIME_FORCE_SPLIT, "Force Split")

/mob/living/basic/slime/vv_do_topic(list/href_list)
	. = ..()

	if(href_list[VV_HK_SLIME_SET_TYPE])
		admin_set_slime_type(usr)
	if(href_list[VV_HK_SLIME_ADD_TRANSFORMATION])
		admin_add_transformation(usr)
	if(href_list[VV_HK_SLIME_SET_LIFE_STAGE])
		admin_set_life_stage(usr)
	if(href_list[VV_HK_SLIME_SET_POWER])
		admin_set_power_level(usr)
	if(href_list[VV_HK_SLIME_SET_BEHAVIOR])
		admin_set_behavior(usr)
	if(href_list[VV_HK_SLIME_FILL_GROWTH])
		admin_fill_growth(usr)
	if(href_list[VV_HK_SLIME_FORCE_SPLIT])
		admin_force_split(usr)

/mob/living/basic/slime/proc/admin_set_slime_type(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	var/list/types_by_color = list()
	for(var/datum/slime_type/type_path as anything in subtypesof(/datum/slime_type))
		types_by_color[type_path::color] = type_path

	var/chosen_color = tgui_input_list(admin, "Which slime type?", "Set Slime Type", types_by_color, default = slime_type.color)
	if(!chosen_color || QDELETED(src) || !check_rights(NONE))
		return

	set_slime_type(types_by_color[chosen_color])
	// set_slime_type only renames slimes that still have a generic name, and this one may have been named by hand
	name = "[slime_type.color] [life_stage] slime ([rand(1, 1000)])"
	real_name = name
	log_admin("[key_name(admin)] set [key_name(src)]'s slime type to [chosen_color].")

/mob/living/basic/slime/proc/admin_add_transformation(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	var/list/types_by_name = list()
	for(var/datum/slime_transformation/transformation_type as anything in subtypesof(/datum/slime_transformation))
		if(locate(transformation_type) in transformations)
			continue
		types_by_name[replacetext("[transformation_type]", "/datum/slime_transformation/", "")] = transformation_type

	if(!length(types_by_name))
		tgui_alert(admin, "This slime already has every transformation.", "Add Transformation")
		return
	if(length(transformations) >= SLIME_MAX_TRANSFORMATIONS)
		tgui_alert(admin, "This slime can't hold any more transformations.", "Add Transformation")
		return

	var/chosen_name = tgui_input_list(admin, "Which transformation?", "Add Transformation", types_by_name)
	if(!chosen_name || QDELETED(src) || !check_rights(NONE))
		return

	if(!add_transformation(types_by_name[chosen_name], admin))
		tgui_alert(admin, "The slime couldn't take that transformation.", "Add Transformation")
		return
	log_admin("[key_name(admin)] gave [key_name(src)] the [chosen_name] transformation.")

/mob/living/basic/slime/proc/admin_set_life_stage(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	var/chosen_stage = tgui_input_list(admin, "Which life stage?", "Set Life Stage", list(SLIME_LIFE_STAGE_BABY, SLIME_LIFE_STAGE_ADULT), default = life_stage)
	if(!chosen_stage || QDELETED(src) || !check_rights(NONE))
		return
	// set_life_stage scales health and damage from the current numbers, so doing it twice would stack
	if(chosen_stage == life_stage)
		return

	set_life_stage(chosen_stage)
	amount_grown = 0
	update_name()
	regenerate_icons()
	log_admin("[key_name(admin)] set [key_name(src)]'s life stage to [chosen_stage].")

/mob/living/basic/slime/proc/admin_set_power_level(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	var/new_power = tgui_input_number(admin, "Power level?", "Set Power Level", default = powerlevel, max_value = SLIME_MAX_POWER, min_value = SLIME_MIN_POWER, round_value = TRUE)
	if(isnull(new_power) || QDELETED(src) || !check_rights(NONE))
		return

	adjust_power_level(new_power - powerlevel)
	log_admin("[key_name(admin)] set [key_name(src)]'s power level to [new_power].")

/mob/living/basic/slime/proc/admin_set_behavior(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	var/static/list/behaviors = list("Pacified", "Default", "Enraged")
	var/chosen_behavior = tgui_input_list(admin, "Which behavior?", "Set Behavior", behaviors)
	if(!chosen_behavior || QDELETED(src) || !check_rights(NONE))
		return

	switch(chosen_behavior)
		if("Pacified")
			set_pacified_behavior()
		if("Default")
			set_default_behavior()
		if("Enraged")
			set_enraged_behavior()
	log_admin("[key_name(admin)] set [key_name(src)]'s behavior to [chosen_behavior].")

/mob/living/basic/slime/proc/admin_fill_growth(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	amount_grown = SLIME_EVOLUTION_THRESHOLD
	log_admin("[key_name(admin)] filled [key_name(src)]'s growth.")

/mob/living/basic/slime/proc/admin_force_split(mob/admin)
	if(!admin || !check_rights(NONE))
		return

	amount_grown = SLIME_EVOLUTION_THRESHOLD
	if(!reproduce())
		tgui_alert(admin, "The slime can't split right now (needs to be a conscious adult with room, and not blocked from splitting).", "Force Split")
		return
	log_admin("[key_name(admin)] forced [key_name(src)] to split.")

#undef SLIME_EXTRA_SHOCK_COST
#undef SLIME_BASE_SHOCK_PERCENTAGE
#undef SLIME_SHOCK_PERCENTAGE_PER_LEVEL
#undef SLIME_HAT_PIXEL_Y
