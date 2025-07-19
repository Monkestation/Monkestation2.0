/datum/wound_pregen_data/cranial_fissure
	wound_path_to_generate = /datum/wound/cranial_fissure
	required_limb_biostate = BIO_BONE

	required_wounding_types = list(WOUND_ALL)

	wound_series = WOUND_SERIES_CRANIAL_FISSURE

	threshold_minimum = 150
	weight = 10

	viable_zones = list(BODY_ZONE_HEAD)

/datum/wound_pregen_data/cranial_fissure/get_weight(obj/item/bodypart/limb, woundtype, damage, attack_direction, damage_source)
	if (isnull(limb.owner))
		return ..()

	if (HAS_TRAIT(limb.owner, TRAIT_CURSED) && (limb.get_mangled_state() & BODYPART_MANGLED_INTERIOR))
		return ..()

	if (limb.owner.stat >= HARD_CRIT)
		return ..()

	return 0

/// A wound applied when receiving significant enough damage to the head.
/// Will allow other players to take your eyes out of your head, and slipping
/// will cause your brain to fall out of your head.
/datum/wound/cranial_fissure
	name = "Cranial Fissure"
	desc = "Patient's crown is agape, revealing severe damage to the skull."
	treat_text = "Immediate surgical reconstruction of the skull."
	examine_desc = "is split open"
	occur_text = "is split into two separated chunks"

	simple_desc = "Patient's skull is split open."
	threshold_penalty = 40

	severity = WOUND_SEVERITY_CRITICAL
	sound_effect = 'sound/effects/dismember.ogg'

#define CRANIAL_FISSURE_FILTER_DISPLACEMENT "cranial_fissure_displacement"

/datum/wound/cranial_fissure/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	ADD_TRAIT(limb, TRAIT_IMMUNE_TO_CRANIAL_FISSURE, type)
	ADD_TRAIT(victim, TRAIT_HAS_CRANIAL_FISSURE, type)

	victim.add_filter(CRANIAL_FISSURE_FILTER_DISPLACEMENT, 2, displacement_map_filter(icon('icons/effects/cranial_fissure.dmi', "displacement"), size = 3))

	RegisterSignal(victim, COMSIG_MOB_SLIPPED, PROC_REF(on_owner_slipped))

/datum/wound/cranial_fissure/remove_wound(ignore_limb, replaced)
	REMOVE_TRAIT(limb, TRAIT_IMMUNE_TO_CRANIAL_FISSURE, type)
	if (!isnull(victim))
		REMOVE_TRAIT(victim, TRAIT_HAS_CRANIAL_FISSURE, type)
		victim.remove_filter(CRANIAL_FISSURE_FILTER_DISPLACEMENT)
		UnregisterSignal(victim, COMSIG_MOB_SLIPPED)
	return ..()

/datum/wound/cranial_fissure/proc/on_owner_slipped(mob/source)
	SIGNAL_HANDLER

	if (source.stat == DEAD)
		return

	var/obj/item/organ/internal/brain/brain = source.get_organ_by_type(/obj/item/organ/internal/brain)
	if (isnull(brain))
		return

	brain.Remove(source)

	var/turf/source_turf = get_turf(source)
	brain.forceMove(source_turf)
	brain.throw_at(get_step(source_turf, source.dir), 1, 1)

	source.visible_message(
		span_boldwarning("[source]'s brain spills right out of [source.p_their()] head!"),
		span_userdanger("Your brain spills right out of your head!"),
	)

/datum/wound/cranial_fissure/try_handling(mob/living/user)
	if (user.usable_hands <= 0 || (user.istate & ISTATE_HARM))
		return FALSE

	if(!isnull(user.hud_used?.zone_select) && (user.zone_selected != BODY_ZONE_HEAD && user.zone_selected != BODY_ZONE_PRECISE_EYES))
		return FALSE

	if (victim.body_position != LYING_DOWN)
		return FALSE

	var/obj/item/organ/internal/eyes/eyes = victim.get_organ_by_type(/obj/item/organ/internal/eyes)
	if (isnull(eyes))
		victim.balloon_alert(user, "no eyes to take!")
		return TRUE

	playsound(victim, 'sound/surgery/organ2.ogg', 50, TRUE)
	victim.balloon_alert(user, "pulling out eyes...")
	user.visible_message(
		span_boldwarning("[user] reaches inside [victim]'s skull..."),
		ignored_mobs = user
	)
	victim.show_message(
		span_userdanger("[victim] starts to pull out your eyes!"),
		MSG_VISUAL,
		span_userdanger("An arm reaches inside your brain, and starts pulling on your eyes!"),
	)

	if (!do_after(user, 10 SECONDS, victim, extra_checks = CALLBACK(src, PROC_REF(still_has_eyes), eyes)))
		return TRUE

	eyes.Remove(victim)
	user.put_in_hands(eyes)

	log_combat(user, victim, "pulled out the eyes of")

	playsound(victim, 'sound/surgery/organ1.ogg', 75, TRUE)
	user.visible_message(
		span_boldwarning("[user] rips out [victim]'s eyes!"),
		span_boldwarning("You rip out [victim]'s eyes!"),
		ignored_mobs = victim,
	)

	victim.show_message(
		span_userdanger("[user] rips out your eyes!"),
		MSG_VISUAL,
		span_userdanger("You feel an arm yank from inside your head, as you feel something very important is missing!"),
	)

	return TRUE

/datum/wound/cranial_fissure/proc/still_has_eyes(obj/item/organ/internal/eyes/eyes)
	PRIVATE_PROC(TRUE)

	return victim?.get_organ_by_type(/obj/item/organ/internal/eyes) == eyes

/datum/wound/cranial_fissure/item_can_treat(obj/item/potential_treater, mob/user)
	if(!(user.istate & ISTATE_SECONDARY) || HAS_TRAIT(user, TRAIT_PACIFISM))
		return FALSE
	if(victim.stat != DEAD)
		return FALSE
	if(!can_behead_with(potential_treater))
		return FALSE
	return TRUE

/datum/wound/cranial_fissure/treat(obj/item/item, mob/user)
	// victim will be null once we dismember, so we need to go ahead and grab this
	var/mob/living/victim = src.victim
	var/limb_name = limb.plaintext_zone

	if((limb.bodypart_flags & BODYPART_UNREMOVABLE) || HAS_TRAIT(victim, TRAIT_GODMODE) || HAS_TRAIT(victim, TRAIT_NODISMEMBER))
		victim.balloon_alert(user, "cannot decapitate!")
		return

	var/decap_time
	switch(item.force)
		if(15 to 24)
			decap_time = 7.5 SECONDS
		if(25 to 30)
			decap_time = 5 SECONDS
		if(31 to INFINITY)
			decap_time = 3 SECONDS

	log_combat(user, victim, "attempted to behead", item)
	user.visible_message(span_warning("[user] begins slicing [victim]'s [limb_name] off with \the [item]!"), span_notice("You begin to slice [victim]'s [limb_name] off using [item]..."))
	playsound(get_turf(user), 'sound/weapons/slice.ogg', vol = 45, vary = TRUE)
	// shitty custom do_after thing so we can do a funny attack animation while you're decapping
	var/datum/progressbar/progress = new(user, decap_time, victim)
	var/next_attack_animation = 0
	var/start_time = world.time
	var/datum/callback/extra_checks = CALLBACK(src, PROC_REF(behead_progress_checks), item, user)
	while(TRUE)
		if(!do_after(user, 0.1 SECONDS, victim, progress = FALSE, extra_checks = extra_checks))
			progress.end_progress()
			return TRUE
		if(world.time >= next_attack_animation)
			if(item.hitsound)
				playsound(get_turf(user), item.hitsound, vol = item.get_clamped_volume(), vary = TRUE, extrarange = -1, falloff_distance = 0)
			user.do_attack_animation(victim, used_item = item)
			next_attack_animation = world.time + item.attack_speed
		var/time_since = world.time - start_time
		progress.update(time_since)
		if(time_since >= decap_time)
			break
	progress.end_progress()
	if(!limb.dismember(dam_type = item.damtype))
		user.visible_message(span_danger("[user] fails to slice through [victim]'s [limb_name] with \the [item]!"), span_boldnotice("You fail to slice through [victim]'s [limb_name] with \the [item]!"))
		return TRUE
	log_combat(user, victim, "beheaded", item)
	user.visible_message(span_danger("[user] slices [victim]'s [limb_name] off with \the [item]!"), span_boldnotice("You slice [victim]'s [limb_name] off with \the [item]!"))
	playsound(get_turf(user), 'sound/items/unsheath.ogg', vol = 75, vary = TRUE) // SHING!
	return TRUE

/datum/wound/cranial_fissure/proc/can_behead_with(obj/item/tool)
	return tool?.get_sharpness() && tool.force >= 15

/datum/wound/cranial_fissure/proc/behead_progress_checks(obj/item/tool, mob/user)
	PRIVATE_PROC(TRUE)

	return !QDELETED(src) && victim.stat == DEAD && can_behead_with(tool) // ensure the victim is still dead, still has the cranial fissure, and the tool is still sharp

/datum/wound/cranial_fissure/get_examine_description(mob/user)
	. = ..()
	if(victim.stat == DEAD && (get_dist(user, victim) <= 2 || isobserver(user)))
		. += span_smallnoticeital("\n[FOURSPACES]You could perhaps behead [victim.p_them()] by <b>right-clicking</b> [victim.p_them()] with a sharp weapon while targeting [victim.p_their()] head.")

#undef CRANIAL_FISSURE_FILTER_DISPLACEMENT
