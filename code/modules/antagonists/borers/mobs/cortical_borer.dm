/// This divisor controls how fast body temperature changes to match the environment
#define BODYTEMP_DIVISOR 16
/// The maximum amount of points borers can have
#define BORER_POINT_LIMIT 10

//we need a way of buffing leg speed
/datum/movespeed_modifier/focus_speed
	multiplicative_slowdown = -0.4

/datum/movespeed_modifier/borer_speed
	multiplicative_slowdown = -0.5

/datum/movespeed_modifier/borer_speed_bonus
	multiplicative_slowdown = -0.4

/datum/actionspeed_modifier/focus_speed
	multiplicative_slowdown = -0.3
	id = ACTIONSPEED_ID_BORER

//this allows borers to slide under/through a door
/obj/machinery/door/Bumped(atom/movable/AM)
	if(iscorticalborer(AM) && density)
		var/mob/living/basic/cortical_borer/borer = AM
		if(!do_after(borer, ((borer.upgrade_flags & BORER_ENERGIC) ? 2.5 SECONDS : 5 SECONDS), src, hidden = TRUE))
			return ..()
		borer.forceMove(drop_location())
		to_chat(borer, span_notice("You squeeze through [src]."))
		return
	return ..()

//so if a person is debrained, the borer is removed
/obj/item/organ/internal/brain/Remove(mob/living/carbon/target, special = 0, no_id_transfer = FALSE)
	. = ..()
	var/mob/living/basic/cortical_borer/borer = has_borer(target)
	if(borer)
		borer.leave_host()

//borers also create an organ, so you dont need to debrain someone
/obj/item/organ/internal/borer_body
	name = "engorged cortical borer"
	desc = "the body of a cortical borer, full of human viscera, blood, and more."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_BORER_ORGAN
	organ_flags = parent_type::organ_flags | ORGAN_PROMINENT
	/// Ref to the borer who this organ belongs to
	var/mob/living/basic/cortical_borer/borer

/obj/item/organ/internal/borer_body/get_status_text(advanced, add_tooltips)
	if(advanced && !(borer.upgrade_flags & BORER_STEALTH_MODE))
		return conditional_tooltip("<font color='#ff9933'>Parasitic infection</font>", "Administer sugar and remove surgically.", add_tooltips)
	return ..()

/obj/item/organ/internal/borer_body/Destroy()
	borer = null
	return ..()

/obj/item/organ/internal/borer_body/Insert(mob/living/carbon/carbon_target, special, drop_if_replaced)
	. = ..()
	for(var/datum/borer_focus/body_focus as anything in borer.body_focuses)
		body_focus.on_add(carbon_target, borer)
	carbon_target.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	if(HAS_MIND_TRAIT(carbon_target, TRAIT_WILLING_HOST))
		carbon_target.add_mood_event("borer", /datum/mood_event/willing_borer)

	var/image/holder = carbon_target.hud_list[BORER_HUD]
	var/mutable_appearance/MA = new /mutable_appearance(holder)
	MA.icon_state = "virus_infected"
	MA.layer = BELOW_MOB_LAYER
	if(HAS_TRAIT(borer, TRAIT_NEUTERED))
		MA.color = COLOR_RED_GRAY
	else
		MA.color = COLOR_PURPLE_GRAY
	MA.alpha = 200
	holder.appearance = MA
	var/datum/atom_hud/my_hud = GLOB.huds[DATA_HUD_BORER]
	my_hud.add_atom_to_hud(carbon_target)

// On removal, force the borer out
/obj/item/organ/internal/borer_body/Remove(mob/living/carbon/carbon_target, special)
	. = ..()
	var/mob/living/basic/cortical_borer/cb_inside = has_borer(carbon_target)
	if(cb_inside)
		for(var/datum/borer_focus/body_focus as anything in cb_inside.body_focuses)
			body_focus.on_remove(carbon_target, borer)
		cb_inside.leave_host()
	carbon_target.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	if(HAS_MIND_TRAIT(carbon_target, TRAIT_WILLING_HOST))
		carbon_target.add_mood_event("borer", /datum/mood_event/no_borer)
	var/datum/atom_hud/borer/hud = GLOB.huds[DATA_HUD_BORER]
	hud.remove_atom_from_hud(carbon_target)
	qdel(src)

/obj/item/organ/internal/borer_body/on_life(seconds_per_tick, times_fired)
	if(!iscarbon(owner) || !owner.reagents)
		return

	if(organ_flags & ORGAN_FAILING)
		organ_failure(seconds_per_tick)
		return

	if(HAS_MIND_TRAIT(owner, TRAIT_WILLING_HOST))
		owner.reagents.metabolize(owner, seconds_per_tick, 0, can_overdose=TRUE)

/obj/item/organ/internal/borer_body/organ_failure(seconds_per_tick, times_fired)
	if(SPT_PROB(1, seconds_per_tick))
		to_chat(owner, span_danger("You feel as if your brain was decaying."))
	owner.adjustToxLoss(0.2 * seconds_per_tick, forced = TRUE)
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2 * seconds_per_tick)

/obj/item/reagent_containers/borer
	volume = 200
	reagent_flags = NO_REACT

/mob/living/basic/cortical_borer
	name = "cortical borer"
	desc = "A slimy creature that is known to go into the ear canal of unsuspecting victims."
	icon = 'icons/mob/borer/borer.dmi'
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	maxHealth = 25
	health = 25
	// Allows them to understand any language their current host can.
	initial_language_holder = /datum/language_holder/borer
	// They need to be able to pass tables and mobs
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	// They are below mobs, or below tables
	layer = BELOW_MOB_LAYER
	// Corticals are tiny
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	// Because they are small, why can't they be held?
	can_be_held = TRUE
	/// How much time we need to get the next point, what one it is depends on "should_get_evolution"
	var/maturation_speed = 30 SECONDS
	/// How old the borer is, starting from zero. Goes up only when inside a host and resets when a point is gained.
	var/maturity_age = 0 SECONDS
	/// Should the next given point
	var/should_get_evolution = FALSE

	/// How many times you've levelled up over all
	var/level = 0

	/// The amount of "evolution" points a borer has for chemicals. Start with one
	var/chemical_evolution = 1
	/// The amount of "evolution" points a borer has for stats
	var/stat_evolution = 0

	/// How many chemical points the borer can have. Can be upgraded
	var/max_chemical_storage = 50
	/// How many chemical points the borer has
	var/chemical_storage = 50
	/// How fast chemicals are gained. Goes up only when inside a host
	var/chemical_regen = 0.5

	/// How much health you gain per level
	var/health_per_level = 2.5
	/// How much health regen you gain per level. Before further upgrades brings borers up to 170 seconds to full heal at level 100, limit is 208 seconds
	var/health_regen_per_level = 0.012

	/// How much more chemical storage you gain per level
	var/chem_storage_per_level = 20
	/// Chemical regen you gain per level
	var/chem_regen_per_level = 0.5

	/// The list of initial actions that the borer has
	var/list/known_abilities = list(
		/datum/action/cooldown/borer/toggle_hiding,
		/datum/action/cooldown/borer/choosing_host,
		/datum/action/cooldown/borer/evolution_tree,
		/datum/action/cooldown/borer/inject_chemical,
		/datum/action/cooldown/borer/upgrade_chemical,
		/datum/action/cooldown/borer/learn_focus,
		/datum/action/cooldown/borer/upgrade_stat,
		/datum/action/cooldown/borer/force_speak,
		/datum/action/cooldown/borer/fear_human,
		/datum/action/cooldown/borer/check_blood,
	)

	/// The host
	var/mob/living/carbon/human_host

	/// How much health we regen per second while in a host. Starts at a 60 seconds to fully to heal. A complete organ manipulation surgery takes 19.8 seconds to compelte with perfect timing to remove a borer
	var/health_regen = 0.415
	/// Holds the chems right before injection
	var/obj/item/reagent_containers/reagent_holder
	/// Lust a flavor kind of thing
	var/generation = 0
	/// What focuses the borer has unlocked
	var/list/body_focuses = list()
	/// How many children the borer has produced
	var/children_produced = 0
	/// Bitflag of upgrades and effects the borer has
	var/upgrade_flags = 0
	/// Multiplier for a borer's negative effects to their host
	var/host_harm_multiplier = 1
	/// The total amount of hivequeens that were created
	var/static/hivequeen_amount

/mob/living/basic/cortical_borer/can_track(mob/living/user)
	return FALSE // The validhunt box machines are onto us, we cannot let them track us

/mob/living/basic/cortical_borer/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT) //they need to be able to move around

	var/matrix/borer_matrix = matrix(transform)
	borer_matrix.Scale(0.75, 0.75)
	transform = borer_matrix
	reagent_holder = new /obj/item/reagent_containers/borer(src)

	for(var/action_type in known_abilities)
		var/datum/action/action = new action_type(src)
		action.Grant(src)

	var/datum/atom_hud/borer_hud = GLOB.huds[DATA_HUD_BORER]
	borer_hud.show_to(src)

/mob/living/basic/cortical_borer/Destroy()
	QDEL_NULL(reagent_holder)
	if(human_host)
		leave_host()
	return ..()

/mob/living/basic/cortical_borer/mind_initialize()
	if(!mind) // This proc is used for both new and recycled (when someone ghosts and another takes over) minds. Make sure we do dis once
		if(generation == 0)
			hivequeen_amount++
		create_name()
	. = ..()
	if(!mind.has_antag_datum(/datum/antagonist/cortical_borer))
		mind.add_antag_datum(/datum/antagonist/cortical_borer)

/mob/living/basic/cortical_borer/death(gibbed)
	if(mind)
		var/datum/antagonist/cortical_borer/antag = mind.has_antag_datum(/datum/antagonist/cortical_borer)
		if(antag?.team)
			for(var/datum/mind/member as anything in antag.team.members)
				if(member.current?.stat != DEAD)
					to_chat(member.current, span_boldwarning("You feel [real_name]'s connection to the hivemind dissapear!"))

	if(human_host && !gibbed)
		var/obj/item/organ/internal/borer_body/borer_organ = locate() in human_host.organs
		if(borer_organ)
			borer_organ.name = "rotting [borer_organ.name]"
			borer_organ.apply_organ_damage(borer_organ.maxHealth)

	return ..()

//so we can add some stuff to status, making it easier to read... maybe some hud some day
/mob/living/basic/cortical_borer/get_status_tab_items()
	. = ..()
	. += "Chemical Storage: [chemical_storage]/[max_chemical_storage]"
	. += "Chemical Evolution Points: [chemical_evolution]"
	. += "Stat Evolution Points: [stat_evolution]"
	. += ""
	var/datum/antagonist/cortical_borer/antag = mind.has_antag_datum(/datum/antagonist/cortical_borer)
	if(isnull(antag))
		return
	. += "OBJECTIVES:"

	var/objective_number = 0
	for(var/datum/objective/borer/objective in antag.objectives)
		objective_number++
		. += "[objective_number]) [objective.status_text]"

/mob/living/basic/cortical_borer/Life(seconds_per_tick, times_fired)
	. = ..()
	if(isnull(human_host))
		return

	if(host_sugar())
		if(!has_status_effect(/datum/status_effect/borer_sugar))
			apply_status_effect(/datum/status_effect/borer_sugar)
	else
		if(has_status_effect(/datum/status_effect/borer_sugar))
			remove_status_effect(/datum/status_effect/borer_sugar)

	if(human_host.stat == DEAD) // Can only do stuff when we are inside a LIVING human
		return

	// There needs to be a negative to having a borer
	if(prob(5 * host_harm_multiplier * ((upgrade_flags & BORER_STEALTH_MODE) ? 0.1 : 1)) && human_host.getToxLoss() <= (80 * host_harm_multiplier))
		human_host.adjustToxLoss(2.5 * seconds_per_tick * host_harm_multiplier, TRUE, TRUE)

	if(upgrade_flags & BORER_STEALTH_MODE)
		return

	if(chemical_storage < max_chemical_storage)	// This is regenerating chemical_storage
		chemical_storage = min(chemical_storage + chemical_regen * seconds_per_tick, max_chemical_storage)

	if(health < maxHealth) // This is regenerating health
		adjustBruteLoss(-health_regen * seconds_per_tick)

	mature()

//if it doesnt have a ckey, let ghosts have it
/mob/living/basic/cortical_borer/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(ckey || key)
		return
	if(stat == DEAD)
		return
	var/choice = tgui_input_list(usr, "Do you want to control [src]?", "Confirmation", list("Yes", "No"))
	if(choice != "Yes")
		return
	if(!istype(user) || ckey || key)
		return
	to_chat(user, span_warning("As a borer, you have the option to be friendly or not. Note that how you act will determine how a host responds!"))
	to_chat(user, span_warning("You are a cortical borer! You can fear someone to make them stop moving, but make sure to inhabit them! You only grow/heal/talk when inside a host!"))
	PossessByPlayer(user.ckey)

/// Creates a random (probably unique) name for the borer
/mob/living/basic/cortical_borer/proc/create_name()
	name = initial(name)
	if(prob(99))
		name = "[pick(GLOB.adjectives)] [name]"
	else
		name = "[pick(GLOB.gross_adjectives)] [name]"

	if(generation == 0)
		real_name = "[name] (Queen [hivequeen_amount])"
	else
		real_name = "[name] ([generation]-[rand(100,999)])"

//check if the host has sugar
/mob/living/basic/cortical_borer/proc/host_sugar()
	if(upgrade_flags & BORER_SUGAR_IMMUNE)
		return FALSE
	if(human_host?.reagents?.has_reagent(/datum/reagent/consumable/sugar))
		if(HAS_MIND_TRAIT(human_host, TRAIT_WILLING_HOST))
			human_host.ForceContractDisease(new /datum/disease/anaphylaxis(), make_copy = FALSE, del_on_fail = TRUE)
		return TRUE
	return FALSE

/// Base mob environment handler for body temperature, overridden to take into consideration being inside a host
/mob/living/basic/cortical_borer/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	var/loc_temp
	if(human_host)
		loc_temp = human_host.bodytemperature // set the local temp to that of the host's core temp
	else
		loc_temp = get_temperature(environment)
	var/temp_delta = loc_temp - bodytemperature

	if(isnull(human_host) && ismovable(loc))
		var/atom/movable/occupied_space = loc
		temp_delta *= (1 - occupied_space.contents_thermal_insulation)

	if(temp_delta < 0) // it is cold here
		if(!on_fire) // do not reduce body temp when on fire
			adjust_bodytemperature(max(max(temp_delta / BODYTEMP_DIVISOR, BODYTEMP_HOMEOSTASIS_COOLING_MAX) * seconds_per_tick, temp_delta))
	else // this is a hot place
		adjust_bodytemperature(min(min(temp_delta / BODYTEMP_DIVISOR, BODYTEMP_HOMEOSTASIS_HEATING_MAX) * seconds_per_tick, temp_delta))

//leave the host, forced or not
/mob/living/basic/cortical_borer/proc/leave_host()
	if(!human_host)
		return
	forceMove(human_host.drop_location())
	var/obj/item/organ/internal/borer_body/borer_organ = locate() in human_host.organs
	if(borer_organ)
		borer_organ.Remove(human_host)

	REMOVE_TRAIT(src, TRAIT_WEATHER_IMMUNE, "borer_in_host")
	bodytemp_heat_damage_limit = initial(bodytemp_heat_damage_limit) //reset body tempature
	bodytemp_cold_damage_limit = initial(bodytemp_cold_damage_limit)
	human_host = null
	SEND_SIGNAL(src, COMSIG_HOST_CHANGED)

//borers shouldnt be able to whisper...
/mob/living/basic/cortical_borer/whisper(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced, filterproof)
	to_chat(src, span_warning("You are not able to whisper!"))
	return FALSE

//borers should not be talking without a host at least
/mob/living/basic/cortical_borer/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	if(isnull(human_host))
		to_chat(src, span_warning("You are not able to speak without a host!"))
		return
	if(host_sugar())
		message = scramble_message_replace_chars(message, 10)
	message = sanitize(message)

	/// Contains the fancy version of our message
	var/text

	//this is so they can talk in hivemind
	if(message[1] == ";")
		var/datum/antagonist/cortical_borer/antag = mind.has_antag_datum(/datum/antagonist/cortical_borer)
		if(isnull(antag) || isnull(antag.team))
			to_chat(src, span_warning("You aren't connected to a hivemind!"))
			return

		message = copytext(message, 2)
		message = capitalize(message)
		if(HAS_TRAIT(src, TRAIT_NEUTERED)) // Neutered sound offtune.
			text = span_red("<b>Cortical Hivemind: [real_name] croons, \"[message]\"</b>")
		else if (generation == 0) // Hivequeens have larger text
			text = span_purplelarge("<b>Cortical Hivemind: [real_name] choruses, \"[message]\"</b>")
		else
			text = span_purple("<b>Cortical Hivemind: [real_name] sings, \"[message]\"</b>")

		for(var/datum/mind/mind as anything in antag.team.members)
			if(mind.current)
				to_chat(mind.current, text, type = MESSAGE_TYPE_RADIO)

		for(var/mob/dead/dead_mob as anything in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(dead_mob, src)
			to_chat(dead_mob, "[link] [message]", type = MESSAGE_TYPE_RADIO)

		log_talk("[key_name(src)] spoke into the Borer hivemind: [message]", LOG_SAY)
		return

	// This is when they speak normally
	message = capitalize(message)

	if(HAS_TRAIT(src, TRAIT_NEUTERED))
		text = span_red("Cortical Link: [name] croons, \"[message]\"")
	else if(HAS_MIND_TRAIT(human_host, TRAIT_WILLING_HOST))
		text = span_purplelarge("Cortical Link: [name] choruses, \"[message]\"")
	else
		text = span_purple("Cortical Link: [name] sings, \"[message]\"")

	to_chat(human_host, text)
	to_chat(src, text)
	human_host.balloon_alert(human_host, "you hear a voice")
	log_talk("[key_name(src)] spoke to [key_name(human_host)]: [message]", LOG_SAY)

	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, src)
		if(HAS_TRAIT(src, TRAIT_NEUTERED))
			to_chat(dead_mob, span_red("[link] Cortical Hivemind: [src] croons to [human_host], \"[message]\""))
		else
			to_chat(dead_mob, span_purple("[link] Cortical Hivemind: [src] sings to [human_host], \"[message]\""))



//borers should not be able to pull anything
/mob/living/basic/cortical_borer/start_pulling(atom/movable/AM, state, force, supress_message)
	to_chat(src, span_warning("You cannot pull things!"))
	return

/// Called on Life() for the borer to age a bit
/mob/living/basic/cortical_borer/proc/mature()
	maturity_age += DELTA_WORLD_TIME(SSclient_mobs) SECONDS
	if(maturity_age < maturation_speed)
		return

	maturity_age -= maturation_speed
	if(should_get_evolution)
		if(stat_evolution < BORER_POINT_LIMIT)
			stat_evolution++
			to_chat(src, span_notice("You gain a stat evolution point. Spend it to become stronger!"))
		else
			to_chat(src, span_warning("You were unable to gain a stat evolution point due to having the max!"))
	else
		if(chemical_evolution < BORER_POINT_LIMIT)
			chemical_evolution++
			to_chat(src, span_notice("You gain a chemical evolution point. Spend it to learn a new chemical!"))
		else
			to_chat(src, span_warning("You were unable to gain a chemical evolution point due to having the max!"))

	should_get_evolution = !should_get_evolution

/// Use to recalculate a borer's health and chemical stats when something retroactively affects them
/mob/living/basic/cortical_borer/proc/recalculate_stats()
	var/old_health = health
	maxHealth = initial(maxHealth) + (level * health_per_level)
	health_regen = initial(health_regen) + (level * health_regen_per_level)
	max_chemical_storage = initial(max_chemical_storage) + (level * chem_storage_per_level)
	chemical_regen = initial(chemical_regen) + (level * chem_regen_per_level)
	health = clamp(old_health, 1, maxHealth)

/// Recalculates how often the borer grows
/mob/living/basic/cortical_borer/proc/calculate_maturation_speed()
	. = initial(maturation_speed)
	var/datum/antagonist/cortical_borer/antag = mind.has_antag_datum(/datum/antagonist/cortical_borer)
	if(!antag)
		return
	for(var/datum/objective/borer/objective as anything in antag.objectives)
		if(objective.completed)
			. -= objective.maturation_boost

	maturation_speed = .

#undef BODYTEMP_DIVISOR
#undef BORER_POINT_LIMIT
