#define WRIST_FEED "wrist"
#define NECK_FEED "neck"

/datum/action/cooldown/vampire/feed
	name = "Feed"
	desc = "Drink the blood of a victim, a more aggressive grab feeds directly from the carotid artery and allows you to enthrall your victim if they remain alive."
	button_icon_state = "power_feed"
	toggleable = TRUE
	works_in_masquerade = TRUE

	/// If we're currently feeding, used for sanity.
	var/is_feeding = FALSE

	/// Last blood alert threshold met, used to avoid alert spam.
	var/last_threshold = BLOOD_VOLUME_MAX_LETHAL

	/// Whether the feed was started with a passive (wrist feed) or aggressive (neck feed) grab.
	var/feed_type = WRIST_FEED

	/// Bodypart zone we bit into.
	var/target_zone

	/// Weakref to the victim.
	var/datum/weakref/victim_ref

/datum/action/cooldown/vampire/feed/New(Target)
	. = ..()
	RegisterSignal(vampire, COMSIG_VAMPIRE_STAT_CHANGED_MOD, PROC_REF(on_stat_changed))
	update_brutality_scaling(vampire.get_stat_modified(VAMPIRE_STAT_BRUTALITY))

/datum/action/cooldown/vampire/feed/Destroy()
	UnregisterSignal(vampire, COMSIG_VAMPIRE_STAT_CHANGED_MOD)
	victim_ref = null
	return ..()

/datum/action/cooldown/vampire/feed/Grant(mob/granted_to)
	RegisterSignal(granted_to, COMSIG_LIVING_START_PULL, PROC_REF(update_button))
	RegisterSignal(granted_to, COMSIG_ATOM_NO_LONGER_PULLING, PROC_REF(on_stop_pulling))
	return ..()

/datum/action/cooldown/vampire/feed/Remove(mob/removed_from)
	UnregisterSignal(removed_from, list(COMSIG_LIVING_START_PULL, COMSIG_ATOM_NO_LONGER_PULLING))
	if(is_feeding)
		stop_feeding(victim_ref.resolve(), forced = TRUE) // victim_ref should never be null if is_feeding is true
	return ..()

/datum/action/cooldown/vampire/feed/is_active()
	return is_feeding

/datum/action/cooldown/vampire/feed/can_toggle_on(feedback)
	. = ..()

	if(DOING_INTERACTION(owner, REF(src))) // you can only attempt one feed at a time
		return FALSE

	var/mob/living/carbon/victim = owner.pulling

	if(!istype(victim))
		if(feedback)
			owner.balloon_alert(owner, "needs grab!")
		return FALSE

	if(user.is_mouth_covered() && !isplasmaman(owner))
		if(feedback)
			owner.balloon_alert(owner, "mouth covered!")
		return FALSE

	if(victim.blood_volume <= 0 || victim.get_blood_type(FALSE) != /datum/reagent/blood) // this makes mobs with exotic blood or no blood immune to feeding
		if(feedback)
			owner.balloon_alert(owner, "no blood!")
		return FALSE

	if(victim.stat == DEAD && victim.timeofdeath + 30 SECONDS < world.time) // succumbing doesn't stop the vampire from getting a meal, only from enthralling you
		if(feedback)
			owner.balloon_alert(owner, "too decayed!")
		return FALSE

	/*if(!victim.key && (!victim.lastclienttime || victim.lastclienttime + 30 SECONDS < world.time)) // same goes for ghosting
		if(feedback)
			owner.balloon_alert(owner, "mindless!")
		return FALSE*/

	feed_type = owner.grab_state == GRAB_PASSIVE ? WRIST_FEED : NECK_FEED

	if(!get_suitable_limb(victim))
		if(feedback)
			owner.balloon_alert(owner, "no suitable [feed_type]!")
		return FALSE

	return TRUE

/datum/action/cooldown/vampire/feed/on_toggle_on()
	var/mob/living/carbon/victim = owner.pulling

	if(feed_type == WRIST_FEED)
		to_chat(victim, span_danger("You feel [owner] tug at your wrist."))
	else
		to_chat(victim, span_bolddanger("[owner] opens [owner.p_their()] mouth and closes in on your neck!"))

	if(!do_after(owner, 2 SECONDS, victim, extra_checks = CALLBACK(src, PROC_REF(check_grab)), interaction_key = REF(src)))
		return

	if(feed_type == NECK_FEED)
		var/target_grab_state = (vampire.current_abilities[/datum/vampire_ability/strong_grip] && (owner.istate & ISTATE_HARM)) ? GRAB_KILL : GRAB_NECK
		if(owner.grab_state < target_grab_state)
			owner.setGrabState(target_grab_state)
			if(!victim.buckled && !victim.density)
				victim.Move(owner.loc) // GET OVER HERE

	is_feeding = TRUE // you've secured the meal, nice
	victim_ref = WEAKREF(victim)

	last_threshold = initial(last_threshold) // used for warnings so it needs to be reset

	ADD_TRAIT(owner, TRAIT_MUTE, REF(src)) // feeding covers your mouth, making you unable to talk

	ADD_TRAIT(victim, TRAIT_NODEATH, REF(src)) // uses a ref since you can get fed on by several vampires at once

	RegisterSignal(victim, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(victim, COMSIG_QDELETING, PROC_REF(on_victim_qdel))
	RegisterSignal(victim, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(check_removed_limb))
	RegisterSignal(owner, COMSIG_MOVABLE_SET_GRAB_STATE, PROC_REF(check_grab)) // how this specific line causes a signal override is byond me considering both are unregistered afaik

	if(feed_type == WRIST_FEED)
		owner.visible_message(
			message = span_danger("[owner] lifts [victim]'s wrist to [owner.p_their()] mouth and bites into it!"),
			self_message = span_notice("You lift [victim]'s wrist up to your mouth and bite into it."),
			ignored_mobs = victim
			)
		to_chat(victim, span_danger("[owner] lifts your wrist up to [owner.p_their()] mouth and bites into it!"))

		playsound(victim, 'sound/effects/wounds/blood1.ogg', vol = 20, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE) // the sound from having your fangs ripped out is also on the victim as it's a wound, so this is consistent

		if(!HAS_TRAIT(victim, TRAIT_ANALGESIA))
			victim.emote(/datum/emote/living/flinch::key)
	else
		owner.visible_message(
			message = span_bolddanger("[owner] bites into [victim]'s neck!"),
			self_message = span_boldnotice("You bite into [victim]'s neck!"),
			ignored_mobs = victim
		)
		to_chat(victim, span_userdanger("[owner] bites into your neck!"))

		playsound(victim, 'sound/effects/wounds/blood2.ogg', vol = 30, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

		if(!HAS_TRAIT(victim, TRAIT_ANALGESIA))
			victim.emote(/datum/emote/living/scream::key)

	build_all_button_icons()

/datum/action/cooldown/vampire/feed/on_toggle_off()
	stop_feeding(victim_ref.resolve(), forced = FALSE) // if is_feeding is true victim_ref should never be null

/datum/action/cooldown/vampire/feed/proc/on_stop_pulling(datum/source)
	SIGNAL_HANDLER
	update_button()
	if (is_feeding)
		check_grab(source)

/datum/action/cooldown/vampire/feed/proc/on_victim_qdel(mob/living/carbon/victim)
	SIGNAL_HANDLER
	stop_feeding(victim, forced = TRUE)

/datum/action/cooldown/vampire/feed/proc/stop_feeding(mob/living/carbon/victim, forced = FALSE, bodypart_override = null)
	if(!is_feeding)
		return

	is_feeding = FALSE
	target_zone = null
	victim_ref = null

	REMOVE_TRAIT(owner, TRAIT_MUTE, REF(src))

	REMOVE_TRAIT(victim, TRAIT_NODEATH, REF(src))

	UnregisterSignal(victim, list(COMSIG_LIVING_LIFE, COMSIG_QDELETING, COMSIG_CARBON_REMOVE_LIMB))
	UnregisterSignal(owner, COMSIG_MOVABLE_SET_GRAB_STATE)

	var/obj/item/bodypart/target_limb = bodypart_override ? bodypart_override : (is_suitable_limb(victim, target_zone) ? victim.get_bodypart(target_zone) : null)

	if(forced)
		owner.visible_message(
			message = span_danger("[owner]'s fangs are ripped out of [victim]'s [feed_type]!"),
			self_message = span_danger("Your fangs are ripped out of [victim]'s [feed_type]!"),
			ignored_mobs = victim
		)
		to_chat(victim, span_danger("[owner]'s fangs are ripped out of your [feed_type]!"))

		if(!HAS_TRAIT(victim, TRAIT_ANALGESIA))
			INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob, emote), /datum/emote/living/scream::key)

		if(target_limb)
			target_limb.force_wound_upwards(/datum/wound/pierce/bleed/moderate, wound_source = "vampire fangs") // the wound makes a fitting sound, no need to play one manually
			target_limb.receive_damage(brute = 10, wound_bonus = CANT_WOUND)
	else
		owner.visible_message(
			message = span_notice("[owner] releases [owner.p_their()] bite on [victim]'s [feed_type]."),
			self_message = span_notice("You release your bite on [victim]'s [feed_type]."),
			ignored_mobs = victim
		)
		to_chat(victim, span_notice("[owner] releases [owner.p_their()] bite on your [feed_type]."))

		playsound(victim, 'sound/effects/wounds/pierce1.ogg', vol = 20, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)

	build_all_button_icons()

/datum/action/cooldown/vampire/feed/proc/on_life(mob/living/carbon/victim, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(!check_grab()) // handles its own balloon alert and stop_feeding
		return

	if(victim.get_blood_type(FALSE) != /datum/reagent/blood)
		owner.balloon_alert(owner, "incompatible blood!")
		stop_feeding(victim, forced = FALSE)
		return

	if(!is_suitable_limb(victim, target_zone))
		owner.balloon_alert(owner, "limb gone!")
		stop_feeding(victim, forced = TRUE)
		return

	if(victim.blood_volume <= 0)
		INVOKE_ASYNC(src, PROC_REF(attempt_enthrall), victim)
		return

	var/base_feed_rate = vampire.feed_rate_modifier.get_base_value()
	var/feed_rate = vampire.feed_rate_modifier.get_value()

	if(feed_type == NECK_FEED)
		victim.adjustOxyLoss(5 * feed_rate / base_feed_rate)

	var/blood_to_drain = min(victim.blood_volume, (feed_type == WRIST_FEED ? base_feed_rate : feed_rate * 2) * seconds_per_tick)

	victim.blood_volume -= blood_to_drain
	vampire.adjust_lifeforce(blood_to_drain * BLOOD_TO_LIFEFORCE) // finally some good fucking food

	if(victim.blood_volume > 0)
		handle_warnings(victim.blood_volume)

	owner.playsound_local(soundin = 'sound/effects/singlebeat.ogg', vol = 40, vary = TRUE)
	victim.playsound_local(soundin = 'sound/effects/singlebeat.ogg', vol = 40, vary = TRUE)

	if(victim.blood_volume <= 0) // otherwise the blood regen of the victim will make their blood volume just a tad bit above 0
		INVOKE_ASYNC(src, PROC_REF(attempt_enthrall), victim)
		return

/datum/action/cooldown/vampire/feed/proc/handle_warnings(blood_volume)
	var/threshold = BLOOD_VOLUME_MAXIMUM
	var/message

	switch(blood_volume)
		if(BLOOD_VOLUME_SAFE to INFINITY)
			threshold = BLOOD_VOLUME_MAXIMUM
		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
			threshold = BLOOD_VOLUME_SAFE
			message = "blood level unsafe"
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			threshold = BLOOD_VOLUME_OKAY
			message = "blood level low"
		if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
			threshold = BLOOD_VOLUME_BAD
			message = "blood level critical"
		if(-INFINITY to BLOOD_VOLUME_SURVIVE)
			threshold = BLOOD_VOLUME_SURVIVE
			message = "blood level fatal"

	if(threshold >= last_threshold)
		return
	last_threshold = threshold

	if(message)
		owner.balloon_alert(owner, message)

/datum/action/cooldown/vampire/feed/proc/is_suitable_limb(mob/living/carbon/victim, zone)
	var/obj/item/bodypart/limb = victim.get_bodypart(zone)
	return limb && (limb.biological_state & BIO_BLOODED)

/datum/action/cooldown/vampire/feed/proc/get_suitable_limb(mob/living/carbon/victim)
	if(feed_type == WRIST_FEED)
		if(is_suitable_limb(victim, BODY_ZONE_R_ARM))
			target_zone = BODY_ZONE_R_ARM
			return TRUE
		if(is_suitable_limb(victim, BODY_ZONE_L_ARM))
			target_zone = BODY_ZONE_L_ARM
			return TRUE
	else
		if(is_suitable_limb(victim, BODY_ZONE_HEAD)) // results in your feed getting canceled if someone decapitates your victim, which is funny
			target_zone = BODY_ZONE_HEAD
			return TRUE
		if(is_suitable_limb(victim, BODY_ZONE_CHEST)) // but you can still feed straight from a neck stub, might add a mood event for this later
			target_zone = BODY_ZONE_CHEST
			return TRUE
	return FALSE

/datum/action/cooldown/vampire/feed/proc/check_grab(datum/source)
	SIGNAL_HANDLER

	if(!owner.pulling || owner.grab_state < (feed_type == WRIST_FEED ? GRAB_PASSIVE : (is_feeding ? GRAB_NECK : GRAB_AGGRESSIVE)))
		owner.balloon_alert(owner, "grab lost!")
		stop_feeding(victim_ref?.resolve(), forced = TRUE)
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/feed/proc/check_removed_limb(mob/living/carbon/victim, obj/item/bodypart/limb, dismembered)
	if(limb.body_zone != target_zone)
		return
	if(!is_suitable_limb(victim, target_zone))
		owner.balloon_alert(owner, "limb gone!")
		stop_feeding(victim, forced = TRUE, bodypart_override = limb)
		return

/datum/action/cooldown/vampire/feed/proc/attempt_enthrall(mob/living/carbon/human/victim)
	if(vampire.vampire_rank == 0 || !istype(victim) || victim.stat == DEAD)
		owner.balloon_alert(owner, "out of blood!")
		stop_feeding(victim, forced = FALSE)
		return

	if(!can_enthrall(victim))
		stop_feeding(victim, forced = FALSE)
		return

	UnregisterSignal(victim, COMSIG_LIVING_LIFE)
	owner.balloon_alert(owner, "enthralling...")

	to_chat(victim, span_hypnophrase("You feel a foreign presence seep into your mind..."))

	if(!do_after(owner, 8 SECONDS, victim, timed_action_flags = IGNORE_SLOWDOWNS | IGNORE_HELD_ITEM, extra_checks = CALLBACK(src, PROC_REF(enthrall_extra_check))))
		stop_feeding(victim, forced = FALSE)
		return

	vampire.enthrall(victim)
	vampire.adjust_lifeforce(-LIFEFORCE_THRALL)

	victim.setOxyLoss(0) // if they don't wake up from this, it's the vampire's problem

	stop_feeding(victim, forced = FALSE)

/datum/action/cooldown/vampire/feed/proc/can_enthrall(mob/living/carbon/victim)
	if(!victim)
		return FALSE
	if(vampire.lifeforce < LIFEFORCE_THRALL)
		owner.balloon_alert(owner, "needs [LIFEFORCE_THRALL] lifeforce!")
		return FALSE
	if(victim.stat == DEAD)
		owner.balloon_alert(owner, "dead!")
		return FALSE
	if(victim.health - victim.getOxyLoss() < HEALTH_THRESHOLD_DEAD && HAS_TRAIT_FROM_ONLY(victim, TRAIT_NODEATH, REF(src))) // cancel if they'd die right after
		owner.balloon_alert(owner, "too weak!")
		return FALSE
	if(!victim.key)
		owner.balloon_alert(owner, "mindless!")
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_MINDSHIELD))
		owner.balloon_alert(owner, "mindshielded!")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/feed/proc/enthrall_extra_check()
	return can_enthrall(victim_ref?.resolve())

/datum/action/cooldown/vampire/feed/proc/on_stat_changed(datum/source, stat, old_amount, new_amount)
	SIGNAL_HANDLER
	if(stat != VAMPIRE_STAT_BRUTALITY)
		return
	update_brutality_scaling(new_amount)

/datum/action/cooldown/vampire/feed/proc/update_brutality_scaling(brutality)
	vampire.feed_rate_modifier.set_multiplicative(VAMPIRE_STAT_BRUTALITY, 1 + brutality / VAMPIRE_SP_MAXIMUM) // 2x feed rate at max brutality (even more with frenzy)

#undef WRIST_FEED
#undef NECK_FEED
