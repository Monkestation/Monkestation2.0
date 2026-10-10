/// Runs when we drain a meal, adults save up the amount as ranch_progress
/mob/living/basic/slime/proc/on_ranch_drain(datum/source, mob/living/meal, drained)
	SIGNAL_HANDLER
	set_temporary_mood(SLIME_MOOD_SMILE) // a mouthful of someone is still a mouthful, even for babies
	for(var/datum/slime_mutation/mutation as anything in mutation_progress)
		mutation.on_latch_drained(meal, drained)
	if(life_stage != SLIME_LIFE_STAGE_ADULT)
		return
	ranch_progress += drained
	try_ranch_outcome()

/// checks whether we've banked enough to split, mutate, or pop out an extract
/mob/living/basic/slime/proc/try_ranch_outcome()
	if(has_status_effect(/datum/status_effect/slime_reproducing))
		return

	if(primed_split_cost)
		if(ranch_progress < primed_split_cost || !COOLDOWN_FINISHED(src, ranch_retry_cooldown))
			return
		reproduce(feedback = FALSE)
		return

	if(pending_ranch_mutation) // handle_ranching picks it back up once we've let go of lunch
		return

	if(ranch_progress < SLIME_RANCH_EXTRACT_COST)
		return

	var/mutation_target = get_unlocked_mutation_type(weight_new_types = TRUE)
	if(mutation_target && !blocks_reproduction && prob(mutation_chance))
		pending_ranch_mutation = mutation_target
		start_ranch_mutation()
		return

	ranch_progress -= SLIME_RANCH_EXTRACT_COST
	squish_out_extract()
	for(var/i in 1 to cores)
		var/obj/item/slime_extract/extract = new slime_type.core_type(drop_location())
		extract.fresh_from_slime = TRUE
		extract.pixel_x = extract.base_pixel_x + rand(-6, 6)
		extract.pixel_y = extract.base_pixel_y + rand(-6, 6)
	balloon_alert_to_viewers("produces an extract!")
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)

/// Ranch progress from something other than a meal, like a grey slimic pylon. Never feeds a primed split.
/mob/living/basic/slime/proc/feed_passive_ranch_progress(amount)
	if(stat == DEAD || life_stage != SLIME_LIFE_STAGE_ADULT)
		return
	if(primed_split_cost || pending_ranch_mutation)
		return
	ranch_progress += amount
	try_ranch_outcome()

/// Starts the wind-up for the mutation we already rolled.
/mob/living/basic/slime/proc/start_ranch_mutation()
	queued_mutation = pending_ranch_mutation
	apply_status_effect(/datum/status_effect/slime_reproducing, SLIME_MUTATE_WINDUP)

/// Whether the stored mutation could wind up right now, ignoring whether we're still latched onto lunch.
/mob/living/basic/slime/proc/ranch_mutation_ready()
	// only ever gates stored mutations, never primed splits - a growth-blocked split that can't eat never grows, so it'd never unblock
	if(isnull(pending_ranch_mutation))
		return FALSE
	if(stat != CONSCIOUS || HAS_TRAIT(src, TRAIT_STASIS))
		return FALSE
	if(has_status_effect(/datum/status_effect/slime_reproducing))
		return FALSE
	return COOLDOWN_FINISHED(src, ranch_retry_cooldown)

/// Called every Life tick: resumes a stored mutation once we're off lunch, and retries primed splits.
/mob/living/basic/slime/proc/handle_ranching()
	if(pending_ranch_mutation)
		if(ranch_mutation_ready() && !isliving(buckled))
			start_ranch_mutation()
		return

	if(primed_split_cost && !HAS_TRAIT(src, TRAIT_STASIS))
		try_ranch_outcome()

/// Gets us ready to split once we've saved up this much ranch_progress, 0 means go back to making extracts
/mob/living/basic/slime/proc/set_primed_split_cost(new_cost)
	if(new_cost && blocks_reproduction)
		balloon_alert_to_viewers("can't split!")
		return
	primed_split_cost = new_cost
	if(new_cost)
		pending_ranch_mutation = null
	balloon_alert_to_viewers(new_cost ? "ready to split!" : "back to extracts")
	do_jitter_animation()
	refresh_wanted_targets() // so the AI starts (or stops) hunting down breeding pellets
	try_ranch_outcome() // if we already banked enough, split right away instead of waiting on the next drain

/// Makes us want breeding pellets, unless we're already gonna split
/mob/living/basic/slime/proc/on_check_wanted_pellet(mob/living/basic/slime/source, obj/item/meal)
	SIGNAL_HANDLER
	if(!primed_split_cost && !blocks_reproduction && istype(meal, /obj/item/slime_breeding_pellet))
		return COMPONENT_SLIME_WANTS_ITEM

/// Pet command that tells the slime to split next (or to nvm that)
/datum/pet_command/slime_split
	command_name = "Split"
	command_desc = "Prime (or unprime) your slime to split the next time it's fed enough."
	radial_icon = 'icons/mob/actions/actions_slime.dmi'
	radial_icon_state = "slimesplit"

// deliberately skips set_command_active - toggling the split prime shouldn't cancel an active Follow/Stay
/datum/pet_command/slime_split/try_activate_command(mob/living/commander)
	var/mob/living/basic/slime/parent = weak_parent.resolve()
	if(!istype(parent) || IS_DEAD_OR_INCAP(parent))
		return
	parent.set_primed_split_cost(parent.primed_split_cost ? 0 : SLIME_RANCH_COMMAND_SPLIT_COST)

/// Feed it to a slime and it'll split next
/obj/item/slime_breeding_pellet
	name = "slime breeding pellet"
	desc = "A biomass pellet slimes go nuts for. Feed it to a slime, and it'll split the next time it's fed enough!"
	icon = 'icons/obj/xenobiology/slime_rancher/biomass.dmi'
	icon_state = "pellet"
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
