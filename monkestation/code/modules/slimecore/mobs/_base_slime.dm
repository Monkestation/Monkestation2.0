///This lowest charge a slime can have
#define SLIME_MIN_POWER 0
///Dangerous levels of charge
#define SLIME_MEDIUM_POWER 5
///The highest level of charge a slime can have
#define SLIME_MAX_POWER 10
#define SLIME_EXTRA_SHOCK_COST 3
#define SLIME_EXTRA_SHOCK_THRESHOLD 8
#define SLIME_BASE_SHOCK_PERCENTAGE 10
#define SLIME_SHOCK_PERCENTAGE_PER_LEVEL 7

/mob/living/basic/slime
	name = "grey baby slime (123)"
	icon = 'monkestation/code/modules/slimecore/icons/slimes.dmi'
	icon_state = "grey baby slime"
	base_icon_state = "grey baby slime"
	icon_dead = "grey baby slime dead"

	maxHealth = 150
	health = 150

	ai_controller = /datum/ai_controller/basic_controller/slime
	density = FALSE

	bodytemp_heat_damage_limit = 2000

	pass_flags = PASSTABLE | PASSGRILLE
	gender = NEUTER
	faction = list(FACTION_SLIME)

	melee_damage_lower = 5
	melee_damage_upper = 25
	
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	
	damage_coeff = list(BRUTE = 1, BURN = -1, TOX = 1, STAMINA = 0, OXY = 1)

	//emote_see = list("jiggles", "bounces in place")
	speak_emote = list("blorbles")
	bubble_icon = "slime"
	initial_language_holder = /datum/language_holder/slime


	response_help_continuous = "pets"
	response_help_simple = "pet"
	attack_verb_continuous = "glomps"
	attack_verb_simple = "glomp"

	verb_say = "blorbles"
	verb_ask = "inquisitively blorbles"
	verb_exclaim = "loudly blorbles"
	verb_yell = "loudly blorbles"

	can_be_held = TRUE

	bodytemp_cold_damage_limit = 100
	bodytemp_heat_damage_limit = 600

	// canstun and canknockdown don't affect slimes because they ignore stun and knockdown variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANUNCONSCIOUS|CANPUSH

	///we track flags for slimes here like ADULT_SLIME, and PASSIVE_SLIME
	var/slime_flags = NONE
	
	///1-10 controls how much electricity they are generating
	var/powerlevel = SLIME_MIN_POWER

	///our current datum for slime color
	var/datum/slime_color/current_color = /datum/slime_color/grey
	///this is our last cached hunger precentage between 0 and 1
	var/hunger_precent = 0
	///how much hunger we need to produce
	var/production_precent = 0.6
	///our list of slime traits
	var/list/slime_traits = list()
	///used to help our name changes so we don't rename named slimes
	var/static/regex/slime_name_regex = new("\\w+ (baby|adult) (cleaner )?(cat)?slime \\(\\d+\\)")
	///our number
	var/number

	///list of all possible mutations
	var/list/possible_color_mutations = list()

	var/list/compiled_liked_foods = list()
	///this is our list of trait foods
	var/list/trait_foods = list()
	///the in progress mutation used for descs
	var/datum/slime_color/mutating_into
	///this is our mutation chance
	var/mutation_chance = 30

	var/obj/item/slime_accessory/worn_accessory

	///this is a list of trees that we replace goes from base = replaced
	var/list/replacement_trees = list()
	///this is our emotion overlay states
	var/list/emotion_states = list(
		EMOTION_HAPPY = "aslime-happy",
		EMOTION_SAD = "aslime-sad",
		EMOTION_ANGER = "aslime-angry",
		EMOTION_FUNNY = "aslime-mischevous",
		EMOTION_SCARED = "aslime-scared",
		EMOTION_SUPRISED = "aslime-happy",
		EMOTION_HUNGRY = "aslime-pout",
	)

	///if set and with the trait replaces the grey part with this
	var/icon_state_override
	var/overwrite_color
	var/datum/reagent/chemical_injection
	var/overriding_name_prefix


	/// Commands you can give this slime once it is tamed, not static because subtypes can modify it
	var/friendship_commands = list(
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/attack/latch,
		/datum/pet_command/stop_eating,
	)
	///the amount of ooze we produce
	var/ooze_production = 10

/mob/living/basic/slime/Initialize(mapload, datum/slime_color/passed_color, is_split)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SLIME, 0.5, -11)
	AddElement(/datum/element/soft_landing)

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_CAREFUL_STEPS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_LIGHTWEIGHT, INNATE_TRAIT)

	if(!passed_color)
		current_color = new current_color
	else
		current_color = new passed_color
	current_color.on_add_to_slime(src)

	AddComponent(/datum/component/obeys_commands, friendship_commands)

	AddComponent(/datum/component/liquid_secretion, current_color.secretion_path, ooze_production, 10 SECONDS, TYPE_PROC_REF(/mob/living/basic/slime, check_secretion))
	AddComponent(/datum/component/generic_mob_hunger, 400, 0.1, 5 MINUTES, 200)
	AddComponent(/datum/component/scared_of_item, 5)
	AddComponent(/datum/component/emotion_buffer, emotion_states)
	AddComponent(/datum/component/friendship_container, list(FRIENDSHIP_HATED = -100, FRIENDSHIP_DISLIKED = -50, FRIENDSHIP_STRANGER = 0, FRIENDSHIP_NEUTRAL = 10, FRIENDSHIP_ACQUAINTANCES = 25, FRIENDSHIP_FRIEND = 50, FRIENDSHIP_BESTFRIEND = 100), FRIENDSHIP_FRIEND)

	RegisterSignal(src, COMSIG_HUNGER_UPDATED, PROC_REF(hunger_updated))
	RegisterSignal(src, COMSIG_MOB_OVERATE, PROC_REF(attempt_change))
	RegisterSignals(src, list(COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_CURRENT_PET_TARGET), COMSIG_AI_BLACKBOARD_KEY_SET(BB_CURRENT_PET_TARGET)), PROC_REF(on_blackboard_key_changed))
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_slime_pre_attack))
	RegisterSignal(src, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))

	for(var/datum/slime_mutation_data/listed as anything in current_color.possible_mutations)
		var/datum/slime_mutation_data/data = new listed
		data.on_add_to_slime(src)
		possible_color_mutations += data

	update_slime_varience()

	if (!is_split) // no point recalculating twice
		recompile_ai_tree()

/mob/living/basic/slime/death(gibbed)
	buckled?.unbuckle_mob(src, force = TRUE)
	return ..()

/mob/living/basic/slime/Destroy()
	for(var/datum/slime_trait/trait as anything in slime_traits)
		remove_trait(trait)
	UnregisterSignal(src, list(
		COMSIG_HUNGER_UPDATED,
		COMSIG_MOB_OVERATE,
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_CURRENT_PET_TARGET),
		COMSIG_AI_BLACKBOARD_KEY_SET(BB_CURRENT_PET_TARGET),
		))

	for(var/datum/slime_mutation_data/mutation as anything in possible_color_mutations)
		possible_color_mutations -= mutation
		qdel(mutation)

	QDEL_NULL(current_color)
	return ..()

/mob/living/basic/slime/mob_try_pickup(mob/living/user, instant)
	if(!SEND_SIGNAL(src, COMSIG_FRIENDSHIP_CHECK_LEVEL, user, FRIENDSHIP_FRIEND))
		to_chat(user, span_notice("[src] doesn't trust you enough to let you pick them up"))
		balloon_alert(user, "not enough trust!")
		return FALSE
	. = ..()

/mob/living/basic/slime/examine(mob/user)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_FRIENDSHIP_CHECK_LEVEL, user, FRIENDSHIP_FRIEND))
		if(SEND_SIGNAL(src, COMSIG_FRIENDSHIP_CHECK_LEVEL, user, FRIENDSHIP_BESTFRIEND))
			. += span_notice("You are one of [src]'s best friends!")
		else
			. += span_notice("You are one of [src]'s friends.")
	if(check_secretion())
		switch(ooze_production)
			if(-INFINITY to 10)
				. += span_notice("It's secreting some ooze.")
			if(10 to 40)
				. += span_notice("It's secreting a lot of ooze.")
			if(40 to INFINITY)
				. += span_boldnotice("It's overflowing with ooze!")

	switch(powerlevel)
		if(SLIME_MIN_POWER to SLIME_EXTRA_SHOCK_COST)
			. += "It is flickering gently with harmless levels of electrical activity."

		if(SLIME_EXTRA_SHOCK_COST to SLIME_MEDIUM_POWER)
			. += "It is glowing brightly with medium levels electrical activity."


		if(SLIME_MEDIUM_POWER to SLIME_MAX_POWER)
			. += "It is glowing alarmingly with high levels of electrical activity."

		if(SLIME_MAX_POWER)
			. += span_boldwarning("It is radiating with massive levels of electrical activity!")

/mob/living/basic/slime/resolve_right_click_attack(atom/target, list/modifiers)
	if(GetComponent(/datum/component/latch_feeding))
		buckled?.unbuckle_mob(src, force = TRUE)
		return
	else if(CanReach(target) && !HAS_TRAIT(target, TRAIT_LATCH_FEEDERED))
		AddComponent(/datum/component/latch_feeding, target, CLONE, 2, 4, FALSE, CALLBACK(src, TYPE_PROC_REF(/mob/living/basic/slime, latch_callback), target))
		return
	. = ..()


/mob/living/basic/slime/proc/rebuild_foods()
	compiled_liked_foods = list()
	compiled_liked_foods |= trait_foods
	for(var/datum/slime_mutation_data/data as anything in possible_color_mutations)
		if(length(data.needed_items))
			compiled_liked_foods |= data.needed_items

/mob/living/basic/slime/proc/on_blackboard_key_changed(datum/source)
	SIGNAL_HANDLER
	update_ai_movement_type()

/mob/living/basic/slime/proc/update_ai_movement_type()
	var/picked_type = /datum/ai_movement/basic_avoidance
	if(slime_flags & CLEANER_SLIME)
		picked_type = /datum/ai_movement/jps/slime_cleaner
	if(ai_controller.blackboard_key_exists(BB_CURRENT_PET_TARGET))
		picked_type = /datum/ai_movement/basic_avoidance/adaptive
	if(!istype(ai_controller.ai_movement, picked_type))
		ai_controller.change_ai_movement_type(picked_type)

/mob/living/basic/slime/proc/recompile_ai_tree()
	var/list/new_planning_subtree = list()
	RemoveElement(/datum/element/basic_eating, food_types = compiled_liked_foods)
	rebuild_foods()

	update_ai_movement_type()

	ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET) // else it'll keep going after things it shouldn't

	new_planning_subtree |= add_or_replace_tree(/datum/ai_planning_subtree/pet_planning)

	if(!HAS_TRAIT(src, TRAIT_SLIME_RABID))
		new_planning_subtree |= add_or_replace_tree(/datum/ai_planning_subtree/simple_find_nearest_target_to_flee_has_item)
		new_planning_subtree |= add_or_replace_tree(/datum/ai_planning_subtree/flee_target)

	if(slime_flags & CLEANER_SLIME)
		ai_controller.clear_blackboard_key(BB_CLEAN_TARGET)
		new_planning_subtree |= add_or_replace_tree(/datum/ai_planning_subtree/cleaning_subtree_slime)

	if(!(slime_flags & PASSIVE_SLIME))
		new_planning_subtree |= add_or_replace_tree(/datum/ai_planning_subtree/simple_find_target_no_trait/slime)

	if(length(compiled_liked_foods))
		AddElement(/datum/element/basic_eating, food_types = compiled_liked_foods)
		new_planning_subtree |= add_or_replace_tree(/datum/ai_planning_subtree/find_food)
		ai_controller.override_blackboard_key(BB_BASIC_FOODS, compiled_liked_foods) //since list we override

	new_planning_subtree |= add_or_replace_tree(/datum/ai_planning_subtree/basic_melee_attack_subtree/slime)

	ai_controller.replace_planning_subtrees(new_planning_subtree)

/mob/living/basic/slime/proc/add_or_replace_tree(datum/ai_planning_subtree/checker)
	if(checker in replacement_trees)
		return replacement_trees[checker]
	return checker

/mob/living/basic/slime/proc/update_slime_varience()
	var/prefix = "grey"
	if(icon_state_override)
		prefix = icon_state_override
	else
		prefix = current_color.icon_prefix

	if(slime_flags & ADULT_SLIME)
		icon_state = "[prefix] adult slime"
		icon_dead = "[prefix] baby slime dead"
	else
		icon_state = "[prefix] baby slime"
		icon_dead = "[prefix] baby slime dead"

	if(stat == DEAD)
		icon_state = icon_dead

	update_name()
	if(!chemical_injection)
		SEND_SIGNAL(src, COMSIG_SECRETION_UPDATE, current_color.secretion_path, ooze_production, 10 SECONDS)
	else
		SEND_SIGNAL(src, COMSIG_SECRETION_UPDATE, chemical_injection, ooze_production, 10 SECONDS)

/mob/living/basic/slime/update_overlays()
	. = ..()
	if(worn_accessory)
		if(slime_flags & ADULT_SLIME)
			.+= mutable_appearance(worn_accessory.accessory_icon, "[worn_accessory.accessory_icon_state]-adult", layer + 0.15, src, appearance_flags = (KEEP_APART | RESET_COLOR))
		else
			.+= mutable_appearance(worn_accessory.accessory_icon, "[worn_accessory.accessory_icon_state]-baby", layer + 0.15, src, appearance_flags = (KEEP_APART | RESET_COLOR))

/mob/living/basic/slime/proc/check_secretion()
	if((!(slime_flags & ADULT_SLIME)) || (slime_flags & STORED_SLIME) || (slime_flags & MUTATING_SLIME) || (slime_flags & NOOOZE_SLIME))
		return FALSE
	if(stat == DEAD)
		return FALSE
	if(hunger_precent < production_precent)
		return FALSE
	return TRUE

/mob/living/basic/slime/proc/hunger_updated(datum/source, current_hunger, max_hunger)
	hunger_precent = current_hunger / max_hunger
	if(hunger_precent > production_precent)
		slime_flags |= ADULT_SLIME
		maxHealth = 200
		obj_damage = 15
		melee_damage_lower = initial(melee_damage_lower) + 10
		melee_damage_upper = initial(melee_damage_upper) + 10
	else
		slime_flags &= ~ADULT_SLIME
		maxHealth = initial(maxHealth)
		obj_damage = initial(obj_damage)
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
	update_slime_varience()
	update_appearance()

/mob/living/basic/slime/proc/add_trait(datum/slime_trait/added_trait)
	for(var/datum/slime_trait/trait as anything in slime_traits)
		if(added_trait in trait.incompatible_traits)
			return FALSE

	var/datum/slime_trait/new_trait = new added_trait
	new_trait.on_add(src)
	slime_traits += new_trait
	update_name()
	return TRUE

///unlike add trait this uses a type and is checked against the list don't pass the created one pass the type
/mob/living/basic/slime/proc/remove_trait(datum/slime_trait/removed_trait)
	for(var/datum/slime_trait/trait as anything in slime_traits)
		if(trait.type != removed_trait)
			continue
		slime_traits -= trait
		qdel(trait)
		update_name()
		return

///unlike add trait this uses a type and is checked against the list don't pass the created one pass the type
/mob/living/basic/slime/proc/has_slime_trait(datum/slime_trait/checked_trait)
	for(var/datum/slime_trait/trait as anything in slime_traits)
		if(trait.type != checked_trait)
			continue
		return TRUE
	return FALSE

/mob/living/basic/slime/update_name()
	if(slime_name_regex.Find(name))
		if(!number)
			number = rand(1, 1000)
		var/slime_variant = "slime"
		if(has_slime_trait(/datum/slime_trait/visual/cat))
			slime_variant = "catslime"
		if(slime_flags & CLEANER_SLIME)
			slime_variant = "cleaner [slime_variant]"

		if(overriding_name_prefix)
			name = "[overriding_name_prefix] [current_color.name] [(slime_flags & ADULT_SLIME) ? "adult" : "baby"] [slime_variant] ([number])"
		else
			name = "[current_color.name] [(slime_flags & ADULT_SLIME) ? "adult" : "baby"] [slime_variant] ([number])"
		real_name = name
	update_name_tag()
	return ..()

/mob/living/basic/slime/proc/start_split()
	ai_controller.set_ai_status(AI_STATUS_OFF)
	slime_flags |= SPLITTING_SLIME

	visible_message(span_notice("[name] starts to flatten, it looks to be splitting."))
	balloon_alert_to_viewers("splitting...")

	addtimer(CALLBACK(src, PROC_REF(finish_splitting)), 15 SECONDS)

/mob/living/basic/slime/proc/finish_splitting()
	SEND_SIGNAL(src, COMSIG_MOB_ADJUST_HUNGER, -200)

	slime_flags &= ~SPLITTING_SLIME
	ai_controller.reset_ai_status()

	var/mob/living/basic/slime/new_slime = new(loc, current_color.type, TRUE)
	new_slime.mutation_chance = mutation_chance
	new_slime.ooze_production = ooze_production
	for(var/datum/slime_mutation_data/data as anything in possible_color_mutations)
		data.copy_progress(new_slime)
	for(var/datum/slime_trait/trait as anything in slime_traits)
		new_slime.add_trait(trait.type)
	new_slime.recompile_ai_tree()
	if(mind.has_antag_datum(/datum/antagonist/pyro_slime)) //Pyroclastic slime gives birth to sentient slimes!!!
		var/mob/chosen_one = SSpolling.poll_ghosts_for_target(check_jobban = ROLE_SENTIENCE, poll_time = 10 SECONDS, checked_target = new_slime, ignore_category = POLL_IGNORE_PYROSLIME, alert_pic = new_slime, role_name_text = "pyroclastic anomaly slime")
		if(isnull(chosen_one))
			return
		new_slime.key = chosen_one.key
		new_slime.mind.special_role = ROLE_PYROCLASTIC_SLIME
		new_slime.mind.add_antag_datum(/datum/antagonist/pyro_slime)
		new_slime.log_message("was made into a slime by pyroclastic slime split", LOG_GAME)

/mob/living/basic/slime/proc/start_mutating(random = FALSE)
	if(!pick_mutation(random))
		return FALSE

	ai_controller.set_ai_status(AI_STATUS_OFF)
	visible_message(span_notice("[name] starts to undulate, it looks to be mutating."))
	balloon_alert_to_viewers("mutating...")
	slime_flags |= MUTATING_SLIME

	ungulate()

	addtimer(CALLBACK(src, PROC_REF(finish_mutating)), 30 SECONDS)
	mutation_chance = 30
	return TRUE

/mob/living/basic/slime/proc/change_color(datum/slime_color/new_color)
	var/datum/slime_color/new_slime_color = new new_color
	QDEL_NULL(current_color)
	current_color = new_slime_color
	new_slime_color.on_add_to_slime(src)

	update_slime_varience()

	QDEL_LIST(possible_color_mutations)
	possible_color_mutations = list()

	for(var/datum/slime_mutation_data/listed as anything in current_color.possible_mutations)
		var/datum/slime_mutation_data/data = new listed
		data.on_add_to_slime(src)
		possible_color_mutations += data

	recompile_ai_tree()

/mob/living/basic/slime/proc/finish_mutating()
	animate(src) // empty animate to break ungulating
	if(!mutating_into)
		return
	SEND_SIGNAL(src, COMSIG_MOB_ADJUST_HUNGER, -200)
	change_color(mutating_into)

	slime_flags &= ~MUTATING_SLIME
	ai_controller.reset_ai_status()


/mob/living/basic/slime/proc/pick_mutation(random = FALSE)
	mutating_into = null
	var/list/valid_choices = list()
	for(var/datum/slime_mutation_data/listed as anything in possible_color_mutations)
		if(!random && !listed.can_mutate)
			continue
		if(random && listed.syringe_blocked)
			continue
		valid_choices += listed
		if(!(listed.type in GLOB.mutated_slime_colors))
			listed.weight *= 100
		valid_choices[listed] = listed.weight
	if(!length(valid_choices))
		return FALSE

	var/datum/slime_mutation_data/picked = pick_weight(valid_choices)
	if(!picked)
		return FALSE
	mutating_into = picked.output
	if(!(mutating_into.type in GLOB.mutated_slime_colors))
		GLOB.mutated_slime_colors |= mutating_into.type
	return TRUE

/mob/living/basic/slime/proc/attempt_change(datum/source, hunger_precent)
	if(slime_flags & NOEVOLVE_SLIME)
		return
	if(prob(mutation_chance)) // we try to mutate 30% of the time
		if(!start_mutating())
			start_split()
	else
		mutation_chance += 10
		start_split()

///Handles slime attacking restrictions, and any extra effects that would trigger
/mob/living/basic/slime/proc/on_slime_pre_attack(mob/living/basic/slime/our_slime, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		return COMPONENT_HOSTILE_NO_ATTACK

	if(isAI(target)) //The aI is not tasty!
		target.balloon_alert(our_slime, "not tasty!")
		return COMPONENT_HOSTILE_NO_ATTACK

	if(our_slime.buckled == target) //If you try to attack the creature you are latched on, you instead cancel feeding
		buckled?.unbuckle_mob(src, force = TRUE)
		return COMPONENT_HOSTILE_NO_ATTACK

	if(iscyborg(target))
		var/mob/living/silicon/robot/borg_target = target
		var/stunprob = our_slime.powerlevel * SLIME_SHOCK_PERCENTAGE_PER_LEVEL + SLIME_BASE_SHOCK_PERCENTAGE
		if(prob(stunprob) && our_slime.powerlevel >= SLIME_EXTRA_SHOCK_COST)
			borg_target.flash_act() //Shouldn't be able to infinitely flash borgs.
			do_sparks(5, TRUE, borg_target)
			our_slime.powerlevel = clamp(our_slime.powerlevel - SLIME_EXTRA_SHOCK_COST, SLIME_MIN_POWER, SLIME_MAX_POWER)
			borg_target.apply_damage(our_slime.powerlevel * rand(6, 10), BRUTE, spread_damage = TRUE, wound_bonus = CANT_WOUND)
			borg_target.visible_message(span_danger("The [our_slime.name] shocks [borg_target]!"), span_userdanger("The [our_slime.name] shocks you!"))
		else
			borg_target.visible_message(span_danger("The [our_slime.name] fails to hurt [borg_target]!"), span_userdanger("The [our_slime.name] failed to hurt you!"))

		return COMPONENT_HOSTILE_NO_ATTACK

	if(iscarbon(target) && our_slime.powerlevel > SLIME_MIN_POWER)
		var/mob/living/carbon/carbon_target = target
		var/stunprob = our_slime.powerlevel * SLIME_SHOCK_PERCENTAGE_PER_LEVEL + SLIME_BASE_SHOCK_PERCENTAGE  // 17 at level 1, 80 at level 10
		if(!prob(stunprob))
			return NONE // normal attack

		carbon_target.visible_message(span_danger("The [our_slime.name] shocks [carbon_target]!"), span_userdanger("The [our_slime.name] shocks you!"))

		do_sparks(5, TRUE, carbon_target)
		var/power = our_slime.powerlevel + rand(0,3)
		carbon_target.Paralyze(2 SECONDS)
		carbon_target.Knockdown(power * 2 SECONDS)
		carbon_target.set_stutter_if_lower(power * 2 SECONDS)
		if (prob(stunprob) && our_slime.powerlevel >= SLIME_EXTRA_SHOCK_COST)
			our_slime.powerlevel = clamp(our_slime.powerlevel - SLIME_EXTRA_SHOCK_COST, SLIME_MIN_POWER, SLIME_MAX_POWER)
			carbon_target.apply_damage(our_slime.powerlevel * rand(6, 10), BURN, spread_damage = TRUE, wound_bonus = CANT_WOUND)

	if(isslime(target))
		if(target == our_slime)
			return COMPONENT_HOSTILE_NO_ATTACK
		var/mob/living/basic/slime/target_slime = target
		if(target_slime.buckled)
			target_slime.buckled?.unbuckle_mob(src, force = TRUE)
			visible_message(span_danger("[our_slime] pulls [target_slime] off!"), \
				span_danger("You pull [target_slime] off!"))
			return NONE // normal attack

/mob/living/basic/slime/attackby(obj/item/attacking_item, mob/living/user, params)
	. = ..()
	if(!istype(attacking_item, /obj/item/slime_accessory))
		return
	worn_accessory = attacking_item
	attacking_item.forceMove(src)
	update_appearance()
	
	if(check_item_passthrough(attacking_item, user))
		return

///Checks if an item harmlessly passes through the slime
/mob/living/basic/slime/proc/check_item_passthrough(obj/item/attacking_item, mob/living/user)
	if(attacking_item.force <= 0)
		return FALSE

	if(!prob(25))
		return FALSE

	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	to_chat(user, span_danger("[attacking_item] passes right through [src]!"))
	return TRUE

/mob/living/basic/slime/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(worn_accessory)
		visible_message("[user] takes the [worn_accessory] off the [src].")
		balloon_alert_to_viewers("removed accessory")
		user.put_in_hands(worn_accessory)
		worn_accessory = null
		update_appearance()

/mob/living/basic/slime/Life(seconds_per_tick, times_fired)
	if(isopenturf(loc))
		var/turf/open/my_our_turf = loc
		my_our_turf.pollution?.touch_act(src)
	
	if (production_precent <= hunger_precent)

		if(powerlevel < SLIME_MAX_POWER && SPT_PROB(30-powerlevel*2, seconds_per_tick))
			powerlevel++

	else if (powerlevel < SLIME_MEDIUM_POWER && 0.2 <= hunger_precent && SPT_PROB(25-powerlevel*5, seconds_per_tick))
		powerlevel++
	
	. = ..()

/mob/living/basic/slime/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	powerlevel = 0 // oh no, the power!

///If a slime is attack with an empty hand, shoves included, try to wrestle them off the mob they are on
/mob/living/basic/slime/proc/on_attack_hand(mob/living/basic/slime/defender_slime, mob/living/attacker)
	SIGNAL_HANDLER

	if(isnull(buckled))
		return

	if(buckled == attacker ? prob(60) : prob(30)) //its easier to remove the slime from yourself
		attacker.visible_message(span_warning("[attacker] attempts to wrestle \the [defender_slime.name] off [buckled == attacker ? "" : buckled] !"), \
		span_danger("[buckled == attacker ? "You attempt" : "[attacker] attempts" ] to wrestle \the [defender_slime.name] off [buckled == attacker ? "" : buckled]!"))
		return

	attacker.visible_message(span_warning("[attacker] manages to wrestle \the [defender_slime.name] off!"), span_notice("You manage to wrestle \the [defender_slime.name] off!"))

/mob/living/basic/slime/proc/apply_water()
	adjustBruteLoss(rand(15, 20))
	if(QDELETED(client))
		buckled?.unbuckle_mob(src, force = TRUE)
	return

/mob/living/basic/slime/proc/latch_callback(mob/living/target)
	if(!chemical_injection)
		return FALSE
	if(!target.reagents)
		return FALSE
	target.reagents.add_reagent(chemical_injection, 3) // guh
	return TRUE

/mob/living/basic/slime/rainbow
	current_color = /datum/slime_color/rainbow

/mob/living/basic/slime/random

/mob/living/basic/slime/random/Initialize(mapload, datum/slime_color/passed_color, is_split)
	current_color = pick(subtypesof(/datum/slime_color))
	. = ..()

/mob/living/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(HAS_TRAIT(src, VACPACK_THROW))
		REMOVE_TRAIT(src, VACPACK_THROW, "vacpack")
		pass_flags &= ~PASSMOB

/mob/living/basic/slime/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, gentle, quickstart)
	force = 0
	. = ..()

/mob/living/basic/slime/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_FRIENDSHIP_CHECK_LEVEL, throwingdatum.thrower, FRIENDSHIP_FRIEND))
		if(!HAS_TRAIT(hit_atom, TRAIT_LATCH_FEEDERED) && isliving(hit_atom))
			AddComponent(/datum/component/latch_feeding, hit_atom, CLONE, 2, 4, FALSE, CALLBACK(src, PROC_REF(latch_callback), hit_atom), FALSE)
			visible_message(span_danger("[throwingdatum.thrower] hucks [src] at [hit_atom] causing the [src] to stick to [hit_atom]."))

#undef SLIME_MIN_POWER
#undef SLIME_MEDIUM_POWER
#undef SLIME_MAX_POWER
#undef SLIME_EXTRA_SHOCK_COST
#undef SLIME_EXTRA_SHOCK_THRESHOLD
#undef SLIME_BASE_SHOCK_PERCENTAGE
#undef SLIME_SHOCK_PERCENTAGE_PER_LEVEL
