
/// The number of influences spawned per heretic
#define NUM_INFLUENCES_PER_HERETIC 5

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

/datum/reality_smash_tracker/Destroy(force)
	if(GLOB.reality_smash_track == src)
		stack_trace("[type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
		message_admins("The [type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
	QDEL_LIST(smashes)
	tracked_heretics.Cut()
	return ..()

/**
 * Generates a set amount of reality smashes
 * based on the number of already existing smashes
 * and the number of minds we're tracking.
 */
/datum/reality_smash_tracker/proc/generate_new_influences()
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

	var/how_many_can_we_make = 0
	for(var/heretic_number in 1 to length(tracked_heretics))
		how_many_can_we_make += max(NUM_INFLUENCES_PER_HERETIC - heretic_number + 1, 1)

	var/list/turf_groups = noise_turfs_station_equal_weight(6, forbidden_area_typecache)
	main_loop:
		while((length(smashes) + num_drained) < how_many_can_we_make && length(turf_groups))
			var/idx = rand(1, length(turf_groups))
			var/list/chosen_group = turf_groups[idx]
			var/turf/chosen_location = pick_n_take(chosen_group)
			if(!length(chosen_group))
				turf_groups.Cut(idx, idx + 1)

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
			testing("Generated heretic influence at [AREACOORD(chosen_location)]")
			new /obj/effect/heretic_influence(chosen_location)

	var/num_smashes = length(smashes) + num_drained
	if(num_smashes < how_many_can_we_make)
		message_admins("WARNING: there may not be enough heretic influences (there should be [how_many_can_we_make], but there's only [num_smashes])")
		CRASH("WARNING: there may not be enough heretic influences (there should be [how_many_can_we_make], but there's only [num_smashes])")

/**
 * Adds a mind to the list of people that can see the reality smashes
 *
 * Use this whenever you want to add someone to the list
 */
/datum/reality_smash_tracker/proc/add_tracked_mind(datum/mind/heretic)
	tracked_heretics |= heretic

	// If our heretic's on station, generate some new influences
	if(ishuman(heretic.current) && !is_centcom_level(heretic.current.z))
		addtimer(CALLBACK(src, PROC_REF(generate_new_influences)), 1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE) // we use a 1 second overriding timer here, so we only run the proc once when multiple heretics are created in succession

/**
 * Removes a mind from the list of people that can see the reality smashes
 *
 * Use this whenever you want to remove someone from the list
 */
/datum/reality_smash_tracker/proc/remove_tracked_mind(datum/mind/heretic)
	tracked_heretics -= heretic

/obj/effect/visible_heretic_influence
	name = "pierced reality"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "pierced_illusion"
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND|INTERACT_ATOM_NO_FINGERPRINT_INTERACT
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	alpha = 0

/obj/effect/visible_heretic_influence/Initialize(mapload)
	. = ..()
	SetInvisibility(INVISIBILITY_ABSTRACT, id = type)
	addtimer(CALLBACK(src, PROC_REF(show_presence)), 1 MINUTES)
	QDEL_IN(src, 10 MINUTES)

	var/image/silicon_image = image('icons/effects/eldritch.dmi', src, null, OBJ_LAYER)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "pierced_reality", silicon_image)

/*
 * Makes the influence fade in after 15 seconds.
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
	if(prob(25))
		// monke edit: TRAIT_NODISMEMBER means you just get your arm fucked the hell up instead
		// while in theory it should atomize your arm anyways, a dismemberment fail and then qdeling the still-attached limb causes Weird Things to happen.
		if(HAS_TRAIT(human_user, TRAIT_NODISMEMBER))
			to_chat(human_user, span_userdanger("An otherwordly presence lashes out and violently mangles your [their_poor_arm.name] as you try to touch the hole in the very fabric of reality!"))
			their_poor_arm.receive_damage(brute = 50, wound_bonus = 100) // guaranteed to wound
		else
			to_chat(human_user, span_userdanger("An otherwordly presence tears and atomizes your [their_poor_arm.name] as you try to touch the hole in the very fabric of reality!"))
			their_poor_arm.dismember()
			qdel(their_poor_arm)
	else
		to_chat(human_user,span_danger("You pull your hand away from the hole as the eldritch energy flails, trying to latch onto existance itself!"))
	return TRUE

/obj/effect/visible_heretic_influence/attack_tk(mob/user)
	if(!ishuman(user))
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN

	if(IS_HERETIC(user))
		to_chat(user, span_boldwarning("You know better than to tempt forces out of your control!"))
		return

	var/mob/living/carbon/human/human_user = user

	// A very elaborate way to suicide
	to_chat(human_user, span_userdanger("Eldritch energy lashes out, piercing your fragile mind, tearing it to pieces!"))
	human_user.ghostize()
	var/obj/item/bodypart/head/head = locate() in human_user.bodyparts
	if(head)
		head.dismember()
		qdel(head)
	else
		human_user.gib()
	human_user.investigate_log("has died from using telekinesis on a heretic influence.", INVESTIGATE_DEATHS)
	var/datum/effect_system/reagents_explosion/explosion = new()
	explosion.set_up(1, get_turf(human_user), TRUE, 0)
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

/obj/effect/heretic_influence/Initialize(mapload)
	. = ..()
	GLOB.reality_smash_track.smashes += src
	generate_name()

	var/image/heretic_image = image(icon, src, real_icon_state, OBJ_LAYER)
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/has_antagonist/heretic, "reality_smash", heretic_image)

	AddElement(/datum/element/block_turf_fingerprints)
	AddComponent(/datum/component/redirect_attack_hand_from_turf, interact_check = CALLBACK(src, PROC_REF(verify_user_can_see)))

	if(isnull(loc))
		message_admins("WARNING: heretic influence spawned in nullspace, this almost certainly should not happen!!!")
		CRASH("Heretic influence spawned in nullspace, this almost certainly should not happen!!!")

/obj/effect/heretic_influence/proc/verify_user_can_see(mob/user)
	return (user.mind in GLOB.reality_smash_track.tracked_heretics)

/obj/effect/heretic_influence/Destroy()
	GLOB.reality_smash_track.smashes -= src
	return ..()

/obj/effect/heretic_influence/attack_hand_secondary(mob/user, list/modifiers)
	if(!IS_HERETIC(user)) // Shouldn't be able to do this, but just in case
		return SECONDARY_ATTACK_CALL_NORMAL

	if(being_drained)
		loc.balloon_alert(user, "already being drained!")
	else
		INVOKE_ASYNC(src, PROC_REF(drain_influence), user, 1)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/effect/heretic_influence/attackby(obj/item/weapon, mob/user, params)
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
	INVOKE_ASYNC(src, PROC_REF(drain_influence), user, 2)
	return TRUE

/**
 * Begin to drain the influence, setting being_drained,
 * registering an examine signal, and beginning a do_after.
 *
 * If successful, the influence is drained and deleted.
 */
/obj/effect/heretic_influence/proc/drain_influence(mob/living/user, knowledge_to_gain)

	being_drained = TRUE
	loc.balloon_alert(user, "draining influence...")

	if(!do_after(user, 10 SECONDS, src, hidden = TRUE))
		being_drained = FALSE
		loc.balloon_alert(user, "interrupted!")
		return

	// We don't need to set being_drained back since we delete after anyways
	loc.balloon_alert(user, "influence drained")

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	heretic_datum.knowledge_points += knowledge_to_gain
	SStgui.update_uis(heretic_datum)

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

/// Hud used for heretics to see influences
/datum/atom_hud/alternate_appearance/basic/has_antagonist/heretic
	antag_datum_type = /datum/antagonist/heretic
	add_ghost_version = TRUE

#undef NUM_INFLUENCES_PER_HERETIC
