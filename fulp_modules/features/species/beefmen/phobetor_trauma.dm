/**
 * # Phobetor Brain Trauma
 *
 * Beefmen's Brain trauma, causing phobetor tears to traverse through.
 */

/datum/brain_trauma/special/bluespace_prophet/phobetor
	name = "Sleepless Dreamer"
	desc = "The patient (having undergone untold psychological hardship), believes they can travel between metaphysical dreamscapes."
	scan_desc = "awoken sleeper"
	gain_text = span_notice("Your mind snaps and you wake up. You <i>really</i> wake up.")
	lose_text = span_warning("You succumb once more to the sleepless dream of the unawakened.")

	///Created tears, only checking the FIRST one, not the one it's created to link to.
	var/list/created_firsts = list()
	///If true the tears we create will be semi-transparent and inactive.
	var/burnt_out = FALSE

///When the trauma is added to a mob.
/datum/brain_trauma/special/bluespace_prophet/phobetor/on_gain()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_REVIVE, PROC_REF(on_revive)) // We want to heal burn-out when we're ahealed and such and such.

///When the trauma is removed from a mob.
/datum/brain_trauma/special/bluespace_prophet/phobetor/on_lose(silent)
	. = ..()
	for(var/obj/effect/client_image_holder/phobetor/phobetor_tears as anything in created_firsts)
		qdel(phobetor_tears)
	UnregisterSignal(owner, COMSIG_LIVING_REVIVE)

/datum/brain_trauma/special/bluespace_prophet/phobetor/on_life(seconds_per_tick, times_fired)
	if(!COOLDOWN_FINISHED(src, portal_cooldown))
		return
	COOLDOWN_START(src, portal_cooldown, 10 SECONDS)
	var/list/turf/possible_tears = list()
	for(var/turf/nearby_turfs as anything in RANGE_TURFS(8, owner))
		if(nearby_turfs.density)
			continue
		possible_tears += nearby_turfs
	if(!LAZYLEN(possible_tears))
		return

	var/turf/first_tear
	var/turf/second_tear
	first_tear = return_valid_floor_in_range(owner, 6, 0, TRUE)
	if(!first_tear)
		return
	second_tear = return_valid_floor_in_range(first_tear, 20, 6, TRUE)
	if(!second_tear)
		return

	var/obj/effect/client_image_holder/phobetor/first = new(first_tear, owner)
	var/obj/effect/client_image_holder/phobetor/second = new(second_tear, owner)

	first.linked_to = second
	first.seer = owner
	first.desc += " This one leads to [get_area(second)]."
	first.name += " ([get_area(second)])"
	created_firsts += first

	second.linked_to = first
	second.seer = owner
	second.desc += " This one leads to [get_area(first)]."
	second.name += " ([get_area(first)])"

	if(burnt_out)
		first.deactivate()
		second.deactivate()

	// Delete Next Portal if it's time (it will remove its partner)
	var/obj/effect/client_image_holder/phobetor/first_on_the_stack = created_firsts[1]
	if(created_firsts.len && world.time >= first_on_the_stack.created_on + first_on_the_stack.exist_length)
		var/targetGate = first_on_the_stack
		created_firsts -= targetGate
		qdel(targetGate)

/datum/brain_trauma/special/bluespace_prophet/phobetor/proc/return_valid_floor_in_range(atom/targeted_atom, checkRange = 8, minRange = 0, check_floor = TRUE)
	// FAIL: Atom doesn't exist. Aren't you real?
	if(!istype(targeted_atom))
		return FALSE
	var/delta_x = rand(minRange,checkRange)*pick(-1,1)
	var/delta_y = rand(minRange,checkRange)*pick(-1,1)
	var/turf/center = get_turf(targeted_atom)

	var/target = locate((center.x + delta_x),(center.y + delta_y), center.z)
	if(check_turf_is_valid(target, check_floor))
		return target
	return FALSE

/datum/brain_trauma/special/bluespace_prophet/phobetor/proc/burn_out(timer = 5 MINUTES)
	burnt_out = TRUE

	to_chat(owner, span_warning("You feel yourself slipping back into the sleepless dream..."))

	for(var/obj/effect/client_image_holder/phobetor/tear in created_firsts)
		tear.deactivate()

	if(timer)
		addtimer(CALLBACK(src, PROC_REF(restore)), timer)

/datum/brain_trauma/special/bluespace_prophet/phobetor/proc/restore()
	burnt_out = FALSE

	to_chat(owner, span_hypnophrase("Your eyes open in tandem with unseen pathways."))

	for(var/obj/effect/client_image_holder/phobetor/tear in created_firsts)
		tear.activate()

/datum/brain_trauma/special/bluespace_prophet/phobetor/proc/on_revive(full_heal_flags)
	SIGNAL_HANDLER
	if(full_heal_flags & HEAL_TRAUMAS)
		restore()

/**
 * Used as a helper that checks if you can successfully teleport to a turf.
 * Returns a boolean, and checks for if the turf has density, if the turf's area has the NOTELEPORT flag,
 * and if the objects in the turf have density.
 * If check_floor is TRUE in the argument, it will return FALSE if it's not a type of [/turf/open/floor].
 * Arguments:
 * * turf/open_turf - The turf being checked for validity.
 * * check_floor - Checks if it's a type of [/turf/open/floor]. If this is FALSE, lava/chasms will be able to be selected.
 */
/datum/brain_trauma/special/bluespace_prophet/phobetor/proc/check_turf_is_valid(turf/open_turf, check_floor = TRUE)
	if(check_floor && !istype(open_turf, /turf/open/floor))
		return FALSE
	if(open_turf.density)
		return FALSE
	var/area/turf_area = get_area(open_turf)
	if(turf_area.area_flags & NOTELEPORT)
		return FALSE
	// Checking for Objects...
	for(var/obj/object in open_turf)
		if(object.density)
			return FALSE
	return TRUE

/**
 * # Phobetor Tears
 *
 * The phobetor tears created by the Brain trauma.
 */

/obj/effect/client_image_holder/phobetor
	name = "phobetor tear"
	desc = "A subdimensional rip in reality which gives extra-spatial passage to those who have awoken from the sleepless dream."
	image_icon = 'fulp_modules/icons/species/phobetor_tear.dmi'
	image_state = "phobetor_tear"
	// Place this above shadows so it always glows.
	image_layer = ABOVE_MOB_LAYER

	/// How long this will exist for
	var/exist_length = 50 SECONDS
	/// The time of this tear's creation
	var/created_on
	/// The phobetor tear this is linked to
	var/obj/effect/client_image_holder/phobetor/linked_to
	/// The person able to see this tear.
	var/mob/living/carbon/seer
	/// Whether we're interactable or not.
	var/active = TRUE

/obj/effect/client_image_holder/phobetor/Initialize()
	. = ..()
	created_on = world.time

	AddElement(/datum/element/contextual_screentip_bare_hands, lmb_text = "Traverse")
	AddComponent(/datum/component/redirect_attack_hand_from_turf)

/obj/effect/client_image_holder/phobetor/Destroy()
	if(linked_to)
		linked_to.linked_to = null
		QDEL_NULL(linked_to)
	return ..()

/obj/effect/client_image_holder/phobetor/proc/check_location_seen(atom/subject, turf/target_turf)
	if(!target_turf)
		return FALSE
	if(!isturf(target_turf))
		return FALSE
	if(!target_turf.lighting_object || !target_turf.get_lumcount() >= 0.1)
		return FALSE
	for(var/mob/living/nearby_viewers in viewers(target_turf))
		if(nearby_viewers == subject)
			continue
		if(!isliving(nearby_viewers) || !nearby_viewers.mind)
			continue
		if(issilicon(nearby_viewers) || isdrone(nearby_viewers) || isbot(nearby_viewers) || nearby_viewers.is_blind())
			continue
		return TRUE
	return FALSE

/obj/effect/client_image_holder/phobetor/proc/activate()
	active = TRUE
	animate(src, alpha = 255, time = 1 SECONDS)
	if(!linked_to.active)
		linked_to.activate()


/obj/effect/client_image_holder/phobetor/proc/deactivate()
	active = FALSE
	animate(src, alpha = 128, time = 1 SECONDS)
	if(linked_to.active)
		linked_to.deactivate()

/obj/effect/client_image_holder/phobetor/attack_hand(mob/living/user, list/modifiers)
	if(user != seer || !linked_to)
		return
	if(!active)
		user.balloon_alert(user, "the tear is too faint!")
		return
	if(!in_range(usr, src))
		return
	for(var/obj/item/implant/tracking/imp in user.implants)
		if(imp)
			user.balloon_alert(user, "something is watching you from inside!")
			return
	// Is this, or linked, stream being watched?
	if(check_location_seen(user, get_turf(user)))
		user.balloon_alert(user, "not while you're being watched!")
		return
	if(check_location_seen(user, get_turf(linked_to)))
		user.balloon_alert(user, "the other side is being watched!")
		return
	user.balloon_alert(user, "slip into the tear")

	var/mob/living/carbon/carbon_user = user
	var/user_sanity = user.mob_mood.sanity
	var/datum/brain_trauma/special/bluespace_prophet/phobetor/trauma = carbon_user.has_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor)
	switch(user_sanity)
		if(SANITY_INSANE to SANITY_CRAZY)
			to_chat(user, span_notice("...but [span_bold("someone else")] crosses [src] too."))
			playsound(user, 'sound/effects/hallucinations/i_see_you1.ogg', 50, TRUE)
			user.adjust_hallucinations(5 MINUTES)
			user.add_mood_event("phobetor_tear", /datum/mood_event/phobetor_crash)
			to_chat(user, span_userdanger("Foreign memories invade your mind!"))
			trauma.burn_out()
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			if(prob(40))
				to_chat(user, span_smallnoticeital("You feel like something followed you through [src]."))
				user.add_mood_event("phobetor_tear", /datum/mood_event/phobetor_major)
				user.adjust_hallucinations(2 MINUTES)
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			if(prob(33))
				to_chat(user, span_smallnoticeital("...was that a person inside [src]?"))
				user.add_mood_event("phobetor_tear", /datum/mood_event/phobetor_major)
				user.adjust_hallucinations(1 MINUTES)
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			if(prob(25))
				to_chat(user, span_smallnoticeital("You notice a shadow flicker in the corner of your eye."))
				user.add_mood_event("phobetor_tear", /datum/mood_event/phobetor_minor)
				user.adjust_hallucinations(30 SECONDS)
		if(SANITY_NEUTRAL to SANITY_GREAT)
			if(prob(10))
				to_chat(user, span_smallnoticeital("The trip is never pleasant."))
				user.add_mood_event("phobetor_tear", /datum/mood_event/phobetor_minor)
	if(prob(5))
		playsound(user, pick(GLOB.creepy_ambience), 50, TRUE)
	user.playsound_local(null, 'sound/effects/magic/wand_teleport.ogg', 30, FALSE, pressure_affected = FALSE)
	user.forceMove(get_turf(linked_to))


/datum/mood_event/phobetor_minor
	description = "There's something offputting about the tears."
	mood_change = -2
	timeout = 1 MINUTES

/datum/mood_event/phobetor_minor/add_effects()
	var/choice = rand(1, 3)
	switch(choice)
		if(1)
			description = "The dreamscape seems gloomy today."
		if(2)
			description = "I've never liked the texture of the dream."
		if(3)
			description = "There's something offputting about the tears."

/datum/mood_event/phobetor_major
	description = "Something is stalking me through the tears."
	mood_change = -6
	timeout = 3 MINUTES

/datum/mood_event/phobetor_major/add_effects()
	var/choice = rand(1, 3)
	switch(choice)
		if(1)
			description = "I wasn't alone in the dreamscape, I'm sure of it."
		if(2)
			description = "I'm being hunted. I can hear it crawl."
		if(3)
			description = "Something is stalking me through the tears."

/datum/mood_event/phobetor_crash
	description = "I can't close my eyes..."
	mood_change = -10
	timeout = 5 MINUTES

/datum/mood_event/phobetor_crash/add_effects()
	var/choice = rand(1, 5)
	switch(choice)
		if(1)
			description = "They didn't bring food today..."
		if(2)
			description = "The sleep gas keeps rising... I can't breathe."
		if(3)
			description = "I can't close my eyes..."
		if(4)
			description = "The doctor keeps murmuring. I don't like it."
		if(5)
			description = "[random_unique_beefman_name()] hasn't woken up today. Or yesterday."
