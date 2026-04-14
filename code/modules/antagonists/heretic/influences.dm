/// How often the tracker attempts to create a new influence.
#define INFLUENCE_SPAWN_INTERVAL (8 MINUTES)

/**
 * #Reality smash tracker
 *
 * A global singleton data that tracks all the heretic
 * influences ("reality smashes") that we've created,
 * and all of the heretics (minds) that can see them.
 *
 * Handles ensuring all minds can see influences, generating
 * new influences for new heretic minds, and allowing heretics
 * to see new influences that are created.
 */
/datum/reality_smash_tracker
	/// The total number of influences that have been drained, for tracking.
	var/num_drained = 0
	/// List of tracked influences (reality smashes)
	var/list/obj/effect/heretic_influence/smashes = list()
	/// List of minds with the ability to see influences
	var/list/datum/mind/tracked_heretics = list()
	/// Shared timer for periodic influence spawning.
	var/spawn_timer_id

/datum/reality_smash_tracker/Destroy(force)
	if(GLOB.reality_smash_track == src)
		stack_trace("[type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
		message_admins("The [type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
	if(spawn_timer_id)
		deltimer(spawn_timer_id)
		spawn_timer_id = null
	QDEL_LIST(smashes)
	tracked_heretics.Cut()
	return ..()

/// Calculates how many influences this tracker should support at most.
/datum/reality_smash_tracker/proc/get_influence_cap()
	var/heretic_count = length(tracked_heretics)
	switch(heretic_count)
		if(0)
			return 0
		if(1)
			return 4
		if(2)
			return 10
		if(3)
			return 14
		else
			return 17

/// Tries to create one influence at a safe station location.
/datum/reality_smash_tracker/proc/try_generate_influence(amount = 1)
	var/static/list/forbidden_area_typecache
	if(isnull(forbidden_area_typecache))
		forbidden_area_typecache = typecacheof(list(
			/area/graveyard,
			/area/station/ai_monitored,
			/area/station/command/secure_bunker,
			/area/station/engineering/atmospherics_engine,
			/area/station/engineering/shipbreaker_hut,
			/area/station/engineering/supermatter,
			/area/station/maintenance,
			/area/station/science/ordnance/bomb,
			/area/station/science/ordnance/burnchamber,
			/area/station/science/ordnance/freezerchamber,
			/area/station/science/xenobiology/cell,
			/area/station/solars,
		))

	var/influence_cap = get_influence_cap()

	var/amount_to_make = min(amount, influence_cap - total_influences())
	if(amount_to_make <= 0)
		return

	var/generated = 0
	var/list/turf_groups = noise_turfs_station_equal_weight(6, forbidden_area_typecache)
	main_loop:
		while(generated < amount_to_make && length(turf_groups))
			var/idx = rand(1, length(turf_groups))
			var/list/chosen_group = turf_groups[idx]
			var/turf/chosen_location = pick_n_take(chosen_group)
			if(!length(chosen_group))
				turf_groups.Cut(idx, idx + 1)

			if(chosen_location.initial_gas_mix != OPENTURF_DEFAULT_ATMOS) // no
				continue

			// gotta make sure we're an open, floor turf
			if(chosen_location.density || isgroundlessturf(chosen_location))
				continue

			// make sure it's got at least 3x3 open space
			for(var/turf/nearby_turf as anything in RANGE_TURFS(1, chosen_location))
				if(!isopenturf(nearby_turf))
					continue main_loop

			// ensure there's no dense objects on the turf
			for(var/obj/checked_object in chosen_location)
				if(checked_object.density)
					continue main_loop

			// We don't want them close to each other - at least 1 tile of seperation
			var/list/nearby_things = range(1, chosen_location)
			var/obj/effect/heretic_influence/what_if_i_have_one = locate() in nearby_things
			var/obj/effect/visible_heretic_influence/what_if_i_had_one_but_its_used = locate() in nearby_things
			if(what_if_i_have_one || what_if_i_had_one_but_its_used)
				continue

			log_game("Generated heretic influence at [AREACOORD(chosen_location)]")
			new /obj/effect/heretic_influence(chosen_location)
			generated++

/// Returns true if any tracked heretic is currently eligible for influence spawning.
/datum/reality_smash_tracker/proc/has_spawn_eligible_heretic()
	for(var/datum/mind/heretic as anything in tracked_heretics)
		if(ishuman(heretic.current) && !is_centcom_level(heretic.current.z))
			return TRUE
	return FALSE

/datum/reality_smash_tracker/proc/handle_spawn_tick()
	if(!has_spawn_eligible_heretic())
		return
	try_generate_influence(1)

/datum/reality_smash_tracker/proc/total_influences()
	return length(smashes) + num_drained

/**
 * Adds a mind to the list of people that can see the reality smashes
 *
 * Use this whenever you want to add someone to the list
 */
/datum/reality_smash_tracker/proc/add_tracked_mind(datum/mind/heretic)
	if(heretic in tracked_heretics)
		return
	tracked_heretics |= heretic
	if(!spawn_timer_id)
		spawn_timer_id = addtimer(CALLBACK(src, PROC_REF(handle_spawn_tick)), INFLUENCE_SPAWN_INTERVAL, TIMER_LOOP|TIMER_STOPPABLE)

/**
 * Removes a mind from the list of people that can see the reality smashes
 *
 * Use this whenever you want to remove someone from the list
 */
/datum/reality_smash_tracker/proc/remove_tracked_mind(datum/mind/heretic)
	tracked_heretics -= heretic
	if(!length(tracked_heretics) && spawn_timer_id)
		deltimer(spawn_timer_id)
		spawn_timer_id = null

/obj/effect/visible_heretic_influence
	name = "pierced reality"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "pierced_illusion"
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND | INTERACT_ATOM_NO_FINGERPRINT_INTERACT
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	alpha = 0

/obj/effect/visible_heretic_influence/Initialize(mapload)
	. = ..()
	SetInvisibility(INVISIBILITY_ABSTRACT, id = type)
	addtimer(CALLBACK(src, PROC_REF(show_presence)), 1 MINUTES)
	/* AddComponent(/datum/component/fishing_spot, GLOB.preset_fish_sources[/datum/fish_source/dimensional_rift]) */

	var/image/silicon_image = image('icons/effects/eldritch.dmi', src, null, OBJ_LAYER)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "pierced_reality", silicon_image)

/*
 * Makes the influence fade in after a minute.
 */
/obj/effect/visible_heretic_influence/proc/show_presence()
	RemoveInvisibility(type)
	animate(src, alpha = 255, time = 15 SECONDS)

/obj/effect/visible_heretic_influence/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return

	if(IS_HERETIC(user))
		to_chat(user, span_boldwarning("You know better than to tempt forces out of your control!"))
		return TRUE

	var/mob/living/carbon/human/human_user = user
	var/obj/item/bodypart/their_poor_arm = human_user.get_active_hand()
	if (!their_poor_arm)
		return TRUE

	if(prob(25))
		// while in theory it should atomize your arm anyways, a dismemberment fail and then qdeling the still-attached limb causes Weird Things to happen.
		if(HAS_TRAIT(human_user, TRAIT_NODISMEMBER) || (their_poor_arm.bodypart_flags & BODYPART_UNREMOVABLE))
			to_chat(human_user, span_userdanger("An otherwordly presence lashes out and violently mangles your [their_poor_arm.name] as you try to touch the hole in the very fabric of reality!"))
			their_poor_arm.receive_damage(brute = 50, wound_bonus = 100) // guaranteed to wound
		else
			to_chat(human_user, span_userdanger("An otherwordly presence tears and atomizes your [their_poor_arm.name] as you try to touch the hole in the very fabric of reality!"))
			their_poor_arm.dismember()
			qdel(their_poor_arm)
	else
		to_chat(human_user,span_danger("You pull your hand away from the hole as the eldritch energy flails, trying to latch onto existence itself!"))
	return TRUE

/obj/effect/visible_heretic_influence/attack_tk(mob/user)
	if(!ishuman(user))
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN

	if(IS_HERETIC(user))
		to_chat(user, span_boldwarning("You know better than to tempt forces out of your control!"))
		return

	var/mob/living/carbon/human/human_user = user

	// You see, these tendrils are psychic. That's why you can't see them. Definitely not laziness. Just psychic. The character can feel but not see them.
	// Because they're psychic. Yeah.
	if(human_user.can_block_magic(MAGIC_RESISTANCE_MIND))
		visible_message(span_danger("Psychic tendrils lash out from [src], batting ineffectively at [user]'s head."))
		return

	// A very elaborate way to suicide
	visible_message(span_userdanger("Psychic tendrils lash out from [src], psychically grabbing onto [user]'s psychically sensitive mind and tearing [user.p_their()] head off!"))
	var/obj/item/bodypart/head/head = human_user.get_bodypart(BODY_ZONE_HEAD)
	if(!head?.dismember())
		human_user.gib(/* DROP_ALL_REMAINS */)
	human_user.investigate_log("has died from using telekinesis on a heretic influence.", INVESTIGATE_DEATHS)
	var/datum/effect_system/reagents_explosion/explosion = new(get_turf(human_user), 1, 1, 1)
	explosion.start(src)

/obj/effect/visible_heretic_influence/examine(mob/living/user)
	. = ..()
	. += span_hypnophrase(pick_list(HERETIC_INFLUENCE_FILE, "examine"))
	if(IS_HERETIC(user) || !ishuman(user) || IS_MONSTERHUNTER(user))
		return

	. += span_userdanger("Your mind burns as you stare at the tear!")
	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 190)
	user.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)

/obj/effect/heretic_influence
	name = "reality smash"
	icon = 'icons/effects/eldritch.dmi'
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND|INTERACT_ATOM_NO_FINGERPRINT_INTERACT
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_OBSERVER
	/// Whether we're currently being drained or not.
	var/being_drained = FALSE
	/// The icon state applied to the image created for this influence.
	var/real_icon_state = "reality_smash"
	/// Proximity monitor that gives any nearby heretics x-ray vision
	var/datum/proximity_monitor/influence_monitor/monitor

/obj/effect/heretic_influence/Initialize(mapload)
	. = ..()
	GLOB.reality_smash_track.smashes += src
	generate_name()

	var/image/heretic_image = image(icon, src, real_icon_state, OBJ_LAYER)
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/has_antagonist/heretic, "reality_smash", heretic_image)

	AddElement(/datum/element/block_turf_fingerprints)
	AddComponent(/datum/component/redirect_attack_hand_from_turf, interact_check = CALLBACK(src, PROC_REF(verify_user_can_see)))
	/* AddComponent(/datum/component/fishing_spot, GLOB.preset_fish_sources[/datum/fish_source/dimensional_rift]) */
	monitor = new(src, 7)

	if(isnull(loc))
		message_admins("WARNING: heretic influence spawned in nullspace, this almost certainly should not happen!!!")
		CRASH("Heretic influence spawned in nullspace, this almost certainly should not happen!!!")

/obj/effect/heretic_influence/proc/verify_user_can_see(mob/user)
	return (user.mind in GLOB.reality_smash_track.tracked_heretics)

/obj/effect/heretic_influence/Destroy()
	GLOB.reality_smash_track.smashes -= src
	QDEL_NULL(monitor)
	return ..()

/obj/effect/heretic_influence/attack_hand_secondary(mob/user, list/modifiers)
	if(!IS_HERETIC(user)) // Shouldn't be able to do this, but just in case
		return SECONDARY_ATTACK_CALL_NORMAL

	if(being_drained)
		loc.balloon_alert(user, "already being drained!")
	else
		INVOKE_ASYNC(src, PROC_REF(drain_influence), user, 1)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/effect/heretic_influence/attackby(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(.)
		return

	// Using a codex will give you two knowledge points for draining.
	if(drain_influence_with_codex(user, weapon))
		return TRUE

/obj/effect/heretic_influence/proc/drain_influence_with_codex(mob/user, obj/item/codex_cicatrix/codex)
	if(!istype(codex) || being_drained)
		return FALSE
	if(!codex.book_open)
		codex.attack_self(user) // open booke
	INVOKE_ASYNC(src, PROC_REF(drain_influence), user, 2, codex.drain_speed)
	return TRUE

/**
 * Begin to drain the influence, setting being_drained,
 * registering an examine signal, and beginning a do_after.
 *
 * If successful, the influence is drained and deleted.
 */
/obj/effect/heretic_influence/proc/drain_influence(mob/living/user, knowledge_to_gain, drain_speed = HERETIC_RIFT_DEFAULT_DRAIN_SPEED)
	if(user.has_status_effect(/datum/status_effect/heretic_sated))
		loc.balloon_alert(user, "sated, must complete sacrifice!")
		return

	being_drained = TRUE
	loc.balloon_alert(user, "draining influence...")

	if(!do_after(user, drain_speed, src, hidden = TRUE))
		being_drained = FALSE
		loc.balloon_alert(user, "interrupted!")
		return

	// We don't need to set being_drained back since we delete after anyways
	loc.balloon_alert(user, "influence drained")

	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	heretic_datum.adjust_knowledge_points(knowledge_to_gain)
	heretic_datum.essences_siphoned++
	if(heretic_datum.total_sacrifices < heretic_datum.essences_siphoned)
		var/duration = heretic_datum.feast_of_owls ? 10 MINUTES : 20 MINUTES
		user.apply_status_effect(/datum/status_effect/heretic_sated, duration)

	// Aaand now we delete it
	after_drain(user)


/**
 * Handle the effects of the drain.
 */
/obj/effect/heretic_influence/proc/after_drain(mob/living/user)
	if(user)
		to_chat(user, span_hypnophrase(pick_list(HERETIC_INFLUENCE_FILE, "drain_message")))
		to_chat(user, span_warning("[src] begins to fade into reality!"))

	var/obj/effect/visible_heretic_influence/illusion = new /obj/effect/visible_heretic_influence(drop_location())
	illusion.name = "\improper" + pick_list(HERETIC_INFLUENCE_FILE, "drained") + " " + format_text(name)

	GLOB.reality_smash_track.num_drained++
	qdel(src)

/**
 * Generates a random name for the influence.
 */
/obj/effect/heretic_influence/proc/generate_name()
	name = "\improper" + pick_list(HERETIC_INFLUENCE_FILE, "prefix") + " " + pick_list(HERETIC_INFLUENCE_FILE, "postfix")

#undef INFLUENCE_SPAWN_INTERVAL

/// Hud used for heretics to see influences
/datum/atom_hud/alternate_appearance/basic/has_antagonist/heretic
	antag_datum_type = /datum/antagonist/heretic
	add_ghost_version = TRUE

/datum/proximity_monitor/influence_monitor
	/// Cooldown before we can give another heretic xray
	COOLDOWN_DECLARE(xray_cooldown)

/datum/proximity_monitor/influence_monitor/on_entered(atom/source, atom/movable/arrived, turf/old_loc)
	. = ..()
	if(!isliving(arrived))
		return
	if(!COOLDOWN_FINISHED(src, xray_cooldown))
		return
	var/mob/living/arrived_living = arrived
	if(!IS_HERETIC(arrived_living))
		return
	arrived_living.apply_status_effect(/datum/status_effect/temporary_xray/eldritch)
	COOLDOWN_START(src, xray_cooldown, 3 MINUTES)
