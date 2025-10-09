#define FEED_NOTICE_RANGE 5
#define FEED_DEFAULT_TIMER (10 SECONDS)

/datum/action/cooldown/bloodsucker/feed
	name = "Feed"
	desc = "Feed blood off of a living creature."
	button_icon_state = "power_feed"
	power_explanation = "Feed:\n\
		Activate Feed while next to someone and you will begin to feed blood off of them.\n\
		The time needed before you start feeding speeds up the higher level you are.\n\
		Feeding off of someone while you have them aggressively grabbed will put them to sleep.\n\
		While feeding, you can't speak, as your mouth is covered.\n\
		Feeding while nearby (2 tiles away from) a mortal who is unaware of Bloodsuckers' existence, will cause a Masquerade Infraction\n\
		If you get too many Masquerade Infractions, you will break the Masquerade.\n\
		If you are in desperate need of blood, mice can be fed off of, at a cost.\n\
		You can drink more blood than your capacity, doing so increases your health regeneration and gives some minor instant healing.\n\
		However, healing whilst above blood capacity cost more blood and your blood loss over time is drastically increased."
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY | BLOODSUCKER_DEFAULT_POWER
	bloodcost = 0
	cooldown_time = 15 SECONDS
	///Amount of blood taken, reset after each Feed. Used for logging.
	var/blood_taken = 0
	///The amount of Blood a target has since our last feed, this loops and lets us not spam alerts of low blood.
	var/warning_target_bloodvol = BLOOD_VOLUME_MAX_LETHAL
	///Reference to the target we've fed off of
	var/datum/weakref/target_ref
	/// Whether the target was alive or not when we started feeding.
	var/started_alive = TRUE
	/// Whether we were in frenzy or not when we started feeding.
	var/started_frenzied = FALSE
	///Are we feeding with passive grab or not?
	var/silent_feed = TRUE
	///Have we notified you already that you are at maximum blood?
	var/notified_overfeeding = FALSE
	var/datum/looping_sound/zucc/soundloop

/datum/action/cooldown/bloodsucker/feed/can_use(mob/living/carbon/user, trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	if(target_ref) //already sucking blood.
		return FALSE
	if(user.is_mouth_covered() && !isplasmaman(user))
		owner.balloon_alert(owner, "mouth covered!")
		return FALSE
	//Find target, it will alert what the problem is, if any.
	if(!find_target())
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/feed/ContinueActive(mob/living/user, mob/living/target)
	if(QDELETED(user) || QDELETED(target))
		return FALSE
	if(!user.Adjacent(target))
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/feed/DeactivatePower()
	var/mob/living/user = owner
	var/mob/living/feed_target = target_ref?.resolve()
	if(feed_target)
		if(!started_frenzied && !bloodsuckerdatum_power.frenzied)
			feed_target.apply_status_effect(/datum/status_effect/feed_regen)
		log_combat(user, feed_target, "fed on blood", addition="(and took [blood_taken] blood)")
		to_chat(user, span_notice("You slowly release [feed_target]."))
		if(feed_target.stat == DEAD && !started_alive)
			user.add_mood_event("drankkilled", /datum/mood_event/drankkilled)
			bloodsuckerdatum_power.AddHumanityLost(10)

	target_ref = null
	started_alive = TRUE
	started_frenzied = FALSE
	warning_target_bloodvol = BLOOD_VOLUME_MAX_LETHAL
	blood_taken = 0
	notified_overfeeding = initial(notified_overfeeding)
	REMOVE_TRAITS_IN(user, FEED_TRAIT)
	if(soundloop?.loop_started)
		soundloop.stop()
	return ..()

/datum/action/cooldown/bloodsucker/feed/ActivatePower(trigger_flags)
	var/mob/living/feed_target = target_ref.resolve()
	if(istype(feed_target, /mob/living/basic/mouse))
		to_chat(owner, span_notice("You recoil at the taste of a lesser lifeform."))
		if(bloodsuckerdatum_power.my_clan && bloodsuckerdatum_power.my_clan.blood_drink_type != BLOODSUCKER_DRINK_INHUMANELY)
			var/mob/living/user = owner
			user.add_mood_event("drankblood", /datum/mood_event/drankblood_bad)
			bloodsuckerdatum_power.AddHumanityLost(1)
		bloodsuckerdatum_power.AddBloodVolume(25)
		DeactivatePower()
		feed_target.death()
		return
	var/feed_timer = clamp(round(FEED_DEFAULT_TIMER / (1.25 * (level_current || 1))), 1, FEED_DEFAULT_TIMER)
	if(bloodsuckerdatum_power.frenzied)
		feed_timer = 2 SECONDS
		started_frenzied = TRUE

	owner.balloon_alert(owner, "feeding off [feed_target]...")
	started_alive = (feed_target.stat < HARD_CRIT)
	to_chat(feed_target, span_userdanger("[owner] begins slipping [owner.p_their()] fangs into you!"))
	if(!do_after(owner, feed_timer, feed_target, NONE, TRUE, hidden = TRUE))
		owner.balloon_alert(owner, "feed stopped")
		DeactivatePower()
		return
	if(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE)
		if(!HAS_MIND_TRAIT(feed_target, TRAIT_BLOODSUCKER_ALIGNED) && !IS_MONSTERHUNTER(feed_target))
			feed_target.Unconscious((5 + level_current) SECONDS)
		if(!feed_target.density)
			feed_target.Move(owner.loc)
		owner.visible_message(
			span_warning("[owner] closes [owner.p_their()] mouth around [feed_target]'s neck!"),
			span_warning("You sink your fangs into [feed_target]'s neck."))
		silent_feed = FALSE //no more mr nice guy
	else
		// Only people who AREN'T the target will notice this action.
		var/dead_message = feed_target.stat != DEAD ? " <i>[feed_target.p_They()] look[feed_target.p_s()] dazed, and will not remember this.</i>" : ""
		owner.visible_message(
			span_notice("[owner] puts [feed_target]'s wrist up to [owner.p_their()] mouth."), \
			span_notice("You slip your fangs into [feed_target]'s wrist.[dead_message]"), \
			vision_distance = FEED_NOTICE_RANGE, ignored_mobs = feed_target)

	//check if we were seen
	var/noticed = FALSE
	for(var/mob/living/viewer in oviewers(FEED_NOTICE_RANGE, owner) - feed_target)
		if(check_for_masquerade_infraction(viewer))
			viewer.balloon_alert(owner, "!!!") // only the bloodsucker actually sees this balloon alert - this is just so it's not confusing if you get noticed when nobody is seemingly nearby
			noticed = TRUE

	if(noticed)
		owner.balloon_alert(owner, "feed noticed!")
		bloodsuckerdatum_power.give_masquerade_infraction()

	if(!HAS_MIND_TRAIT(feed_target, TRAIT_BLOODSUCKER_ALIGNED) && !IS_MONSTERHUNTER(feed_target))
		to_chat(feed_target, span_reallybig(span_hypnophrase("Huh? What just happened? You don't remember the last few moments")))
	feed_target.Immobilize(2 SECONDS)
	feed_target.remove_status_effect(/datum/status_effect/feed_regen)
	owner.add_traits(list(TRAIT_MUTE, TRAIT_IMMOBILIZED), FEED_TRAIT)
	return ..()

/datum/action/cooldown/bloodsucker/feed/proc/check_for_masquerade_infraction(mob/living/viewer, recursed = FALSE)
	if(QDELETED(viewer) || !viewer.ckey || QDELETED(viewer.client) || viewer.client?.is_afk())
		return FALSE
	if(HAS_SILICON_ACCESS(viewer))
		return FALSE
	if(viewer.stat >= DEAD)
		return FALSE
	if(viewer.invisibility)
		return FALSE
	if(viewer.is_blind() || viewer.is_nearsighted_currently())
		return FALSE
	if(HAS_MIND_TRAIT(viewer, TRAIT_BLOODSUCKER_ALIGNED) || HAS_MIND_TRAIT(viewer, TRAIT_OCCULTIST) || HAS_TRAIT(viewer, TRAIT_GHOST_CRITTER))
		return FALSE
	if(isvampire(viewer)) // this checks for the species - i mean, they're not the same kind of vampire, but they're still a VAMPIRE, so, yeah
		return FALSE
	if(!recursed)
		if(isguardian(viewer))
			var/mob/living/basic/guardian/stando = viewer
			return check_for_masquerade_infraction(stando.summoner, recursed = TRUE)
		var/mob/living/master = viewer.mind?.enslaved_to?.resolve()
		if(!isnull(master))
			return check_for_masquerade_infraction(master, recursed = TRUE)
	return TRUE

/datum/action/cooldown/bloodsucker/feed/process(seconds_per_tick)
	if(!active) //If we aren't active (running on SSfastprocess)
		return ..() //Manage our cooldown timers
	var/mob/living/user = owner
	var/mob/living/feed_target = target_ref?.resolve()
	if(!soundloop)
		soundloop = new(owner, FALSE)
	if(QDELETED(feed_target))
		DeactivatePower()
		return PROCESS_KILL
	if(!ContinueActive(user, feed_target))
		if(!silent_feed)
			user.visible_message(
				span_warning("[user] is ripped from [feed_target]'s throat. [feed_target.p_their(TRUE)] blood sprays everywhere!"),
				span_warning("Your teeth are ripped from [feed_target]'s throat. [feed_target.p_their(TRUE)] blood sprays everywhere!"))
			// Deal Damage to Target (should have been more careful!)
			if(iscarbon(feed_target))
				var/mob/living/carbon/carbon_target = feed_target
				carbon_target.bleed(15)
			playsound(get_turf(feed_target), 'sound/effects/splat.ogg', 40, TRUE)
			if(ishuman(feed_target))
				var/mob/living/carbon/human/target_user = feed_target
				var/obj/item/bodypart/head_part = target_user.get_bodypart(BODY_ZONE_HEAD)
				if(head_part)
					head_part.generic_bleedstacks += 5
			feed_target.add_splatter_floor(get_turf(feed_target))
			user.add_mob_blood(feed_target) // Put target's blood on us. The donor goes in the ( )
			feed_target.add_mob_blood(feed_target)
			feed_target.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = CANT_WOUND)
			INVOKE_ASYNC(feed_target, TYPE_PROC_REF(/mob, emote), "scream")
		DeactivatePower()
		return PROCESS_KILL

	var/feed_strength_mult = 0
	if(bloodsuckerdatum_power.frenzied)
		feed_strength_mult = 2
	else if(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE)
		feed_strength_mult = 1
	else
		feed_strength_mult = 0.3
	var/obj/item/comically_large_straw/held = owner.get_active_held_item()
	if(istype(held))
		feed_strength_mult *= held.suck_power
		soundloop.start()
	else
		soundloop.stop()
	blood_taken += bloodsuckerdatum_power.handle_feeding(feed_target, feed_strength_mult, level_current)

	if(feed_strength_mult >= 1 && feed_target.stat < DEAD)
		user.add_mood_event("drankblood", /datum/mood_event/drankblood)
	// Drank mindless as Ventrue? - BAD
	if(bloodsuckerdatum_power.my_clan?.blood_drink_type == BLOODSUCKER_DRINK_SNOBBY && QDELETED(feed_target.mind))
		user.add_mood_event("drankblood", /datum/mood_event/drankblood_bad)
	if(feed_target.stat >= DEAD && !started_alive)
		user.add_mood_event("drankblood", /datum/mood_event/drankblood_dead)

	if(!IS_BLOODSUCKER(feed_target))
		if(feed_target.blood_volume <= BLOOD_VOLUME_BAD && warning_target_bloodvol > BLOOD_VOLUME_BAD)
			owner.balloon_alert(owner, "your victim's blood is fatally low!")
		else if(feed_target.blood_volume <= BLOOD_VOLUME_OKAY && warning_target_bloodvol > BLOOD_VOLUME_OKAY)
			owner.balloon_alert(owner, "your victim's blood is dangerously low.")
		else if(feed_target.blood_volume <= BLOOD_VOLUME_SAFE && warning_target_bloodvol > BLOOD_VOLUME_SAFE)
			owner.balloon_alert(owner, "your victim's blood is at an unsafe level.")
		warning_target_bloodvol = feed_target.blood_volume

	if(bloodsuckerdatum_power.bloodsucker_blood_volume >= bloodsuckerdatum_power.max_blood_volume && !notified_overfeeding)
		user.balloon_alert(owner, "full on blood! Anything more we drink now will be burnt on quicker healing")
		notified_overfeeding = TRUE
	if(feed_target.blood_volume <= 0)
		user.balloon_alert(owner, "no blood left!")
		DeactivatePower()
		return PROCESS_KILL
	owner.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)
	//play sound to target to show they're dying.
	if(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE)
		feed_target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)

/datum/action/cooldown/bloodsucker/feed/proc/find_target()
	if(isliving(owner.pulling) && !QDELING(owner.pulling))
		if(!can_feed_from(owner.pulling, give_warnings = TRUE))
			return FALSE
		target_ref = WEAKREF(owner.pulling)
		return TRUE

	var/list/close_living_mobs = list()
	var/list/close_dead_mobs = list()
	for(var/mob/living/near_targets in oview(1, owner))
		if(!owner.Adjacent(near_targets))
			continue
		if(near_targets.stat < DEAD)
			close_living_mobs |= near_targets
		else
			close_dead_mobs |= near_targets
	//Check living first
	for(var/mob/living/suckers in close_living_mobs)
		if(can_feed_from(suckers))
			target_ref = WEAKREF(suckers)
			return TRUE
	//If not, check dead
	for(var/mob/living/suckers in close_dead_mobs)
		if(can_feed_from(suckers))
			target_ref = WEAKREF(suckers)
			return TRUE
	//No one to suck blood from.
	return FALSE

/datum/action/cooldown/bloodsucker/feed/proc/can_feed_from(mob/living/target, give_warnings = FALSE)
	if(istype(target, /mob/living/basic/mouse))
		if(bloodsuckerdatum_power.my_clan?.blood_drink_type == BLOODSUCKER_DRINK_SNOBBY)
			if(give_warnings)
				owner.balloon_alert(owner, "too disgusting!")
			return FALSE
		return TRUE
	//Mice check done, only humans are otherwise allowed
	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/target_user = target
	if(!(target_user.dna?.species) || !(target_user.mob_biotypes & MOB_ORGANIC))
		if(give_warnings)
			owner.balloon_alert(owner, "no blood!")
		return FALSE
	if(!target_user.can_inject(owner, BODY_ZONE_HEAD, INJECT_CHECK_PENETRATE_THICK))
		if(give_warnings)
			owner.balloon_alert(owner, "suit too thick!")
		return FALSE
	if(bloodsuckerdatum_power.my_clan?.blood_drink_type == BLOODSUCKER_DRINK_SNOBBY && QDELETED(target_user.mind) && !bloodsuckerdatum_power.frenzied)
		if(give_warnings)
			owner.balloon_alert(owner, "cant drink from mindless!")
		return FALSE
	return TRUE

// Status effect given to (still living) mobs after a bloodsucker feeds on them
/datum/status_effect/feed_regen
	id = "feed_regen"
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	processing_speed = STATUS_EFFECT_PRIORITY

/datum/status_effect/feed_regen/on_apply()
	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_NOBLOOD) || owner.blood_volume > BLOOD_VOLUME_SAFE)
		return FALSE
	return TRUE

/datum/status_effect/feed_regen/tick(seconds_between_ticks)
	if(owner.stat == DEAD || owner.blood_volume > BLOOD_VOLUME_SAFE)
		qdel(src)
		return
	if(owner.stat != CONSCIOUS || owner.getOxyLoss() >= 40)
		if(owner.health <= owner.crit_threshold)
			owner.adjustOxyLoss(-5 * seconds_between_ticks)
		else
			owner.adjustOxyLoss(-2 * seconds_between_ticks)
	owner.blood_volume += 2 * seconds_between_ticks

#undef FEED_NOTICE_RANGE
#undef FEED_DEFAULT_TIMER
