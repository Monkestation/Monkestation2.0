/datum/action/innate/slime
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	transparent_when_unavailable = FALSE
	///Does the ability require a specific slime lifestage?
	var/life_stage_required
	///Does the ability requires the slime to hit max growth?
	var/needs_growth = FALSE
	///Does the ability cost nutrition?
	var/nutrition_cost = 0

/datum/action/innate/slime/create_button()
	var/atom/movable/screen/movable/action_button/button = ..()
	button.maptext_x = 2
	return button

/datum/action/innate/slime/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/basic/slime/slime_owner = owner

	if(!isnull(life_stage_required) && slime_owner.life_stage != life_stage_required)
		return FALSE

	if(slime_owner.nutrition < nutrition_cost)
		return FALSE

	if(needs_growth && slime_owner.amount_grown < SLIME_EVOLUTION_THRESHOLD)
		return FALSE
	return TRUE

/datum/action/innate/slime/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	. = ..()
	var/mob/living/basic/slime/slime_owner = owner
	if(!isnull(life_stage_required) && slime_owner.life_stage != life_stage_required)
		button.maptext = ""
		return
	button.maptext = MAPTEXT_TINY_UNICODE("[slime_owner.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]")

/datum/action/innate/slime/evolve
	name = "Evolve"
	button_icon_state = "slimegrow"
	desc = "This will let you evolve from baby to adult slime."
	life_stage_required = SLIME_LIFE_STAGE_BABY
	needs_growth = TRUE
	nutrition_cost = SLIME_EVOLUTION_COST

///Turns a baby slime into an adult slime
/datum/action/innate/slime/evolve/Activate()
	if(owner.stat != CONSCIOUS)
		owner.balloon_alert(owner, owner.stat == DEAD ? "dead!" : "not conscious!")
		return FALSE

	var/mob/living/basic/slime/slime_owner = owner
	if(slime_owner.life_stage == SLIME_LIFE_STAGE_ADULT)
		slime_owner.balloon_alert(slime_owner, "already adult!")
		return
	if(slime_owner.amount_grown < SLIME_EVOLUTION_THRESHOLD)
		slime_owner.balloon_alert(slime_owner, "need to grow!")
		return
	if(slime_owner.nutrition < nutrition_cost)
		slime_owner.balloon_alert(slime_owner, "need food!")
		return

	slime_owner.adjust_nutrition(-nutrition_cost)

	slime_owner.set_life_stage(SLIME_LIFE_STAGE_ADULT)
	slime_owner.update_name()
	slime_owner.regenerate_icons()

	slime_owner.amount_grown = 0

/datum/action/innate/slime/reproduce
	name = "Reproduce"
	button_icon_state = "slimesplit"
	desc = "This will make you split in two, once you've fed enough."
	life_stage_required = SLIME_LIFE_STAGE_ADULT
	needs_growth = TRUE

/datum/action/innate/slime/reproduce/IsAvailable(feedback = FALSE)
	var/mob/living/basic/slime/slime_owner = owner
	return ..() && !slime_owner.blocks_reproduction && !owner.has_status_effect(/datum/status_effect/slime_reproducing)

/datum/action/innate/slime/reproduce/Activate()
	var/mob/living/basic/slime/slime_owner = owner
	slime_owner.reproduce()

///Starts the split wind-up if we're able to. Quiet when feedback is off, for automatic retries.
/mob/living/basic/slime/proc/reproduce(feedback = TRUE)
	if(stat != CONSCIOUS)
		if(feedback)
			balloon_alert(src, stat == DEAD ? "dead!" : "not conscious!")
		return FALSE

	if(life_stage != SLIME_LIFE_STAGE_ADULT)
		if(feedback)
			balloon_alert(src, "not adult!")
		return FALSE

	if(blocks_reproduction)
		if(feedback)
			balloon_alert(src, "can't split!")
		return FALSE

	if(amount_grown < SLIME_EVOLUTION_THRESHOLD)
		if(feedback)
			balloon_alert(src, "need growth!")
		return FALSE

	var/list/friends_list = list()
	for(var/mob/living/basic/slime/friend in loc)
		if(QDELETED(friend))
			continue
		if(friend == src)
			continue
		friends_list += friend

	overcrowded = length(friends_list) >= SLIME_OVERCROWD_AMOUNT
	if(overcrowded)
		if(feedback)
			balloon_alert(src, "overcrowded!")
		return FALSE

	if(!isopenturf(loc))
		if(feedback)
			balloon_alert(src, "not here!")
		return FALSE

	// splitting never changes color, mutating is ranching's job (see try_ranch_outcome in slime_ranching.dm)
	queued_mutation = slime_type.type
	apply_status_effect(/datum/status_effect/slime_reproducing, SLIME_SPLIT_WINDUP)
	return TRUE

///Does the actual splitting or recoloring, once the wind-up has run its course
/mob/living/basic/slime/proc/finish_reproduce()
	var/mutation_target = queued_mutation
	queued_mutation = null

	pending_ranch_mutation = null
	if(primed_split_cost)
		primed_split_cost = 0
		balloon_alert_to_viewers("back to extracts")
		refresh_wanted_targets()
	else if(mutation_target != slime_type.type) // a ranch mutation, not a wild-slime split
		ranch_progress = max(ranch_progress - SLIME_RANCH_EXTRACT_COST, 0)
	// deliberately not calling set_primed_split_cost/try_ranch_outcome here - this runs inside
	// slime_reproducing/on_remove, so starting a second windup would stomp the one that's finishing

	if(life_stage != SLIME_LIFE_STAGE_ADULT)
		return

	if(mutation_target != slime_type.type)
		set_slime_type(mutation_target)
		set_life_stage(SLIME_LIFE_STAGE_BABY)
		set_nutrition(SLIME_STARTING_NUTRITION)
		update_name()
		regenerate_icons()
		amount_grown = 0
		mutator_used = FALSE
		return

	var/new_nutrition = floor(nutrition * 0.9)
	var/new_powerlevel = floor(powerlevel * 0.25)
	var/turf/drop_loc = drop_location()

	var/list/slime_friends = list()
	for(var/faction_member in faction)
		var/mob/living/possible_friend = locate(faction_member) in GLOB.mob_living_list
		if(QDELETED(possible_friend))
			continue
		slime_friends += possible_friend

	var/list/mob/living/basic/slime/family = list(src)
	for(var/i in 1 to 1 + extra_babies)
		var/mob/living/basic/slime/baby = new(drop_loc, slime_type.type)
		// befriend first, it bails on friends whose ref is already in our faction
		for(var/mob/living/slime_friend as anything in slime_friends)
			baby.befriend(slime_friend)
		baby.faction |= faction
		baby.cores = max(cores, baby.cores)
		SEND_SIGNAL(src, COMSIG_SLIME_SPLIT, baby)
		SSblackbox.record_feedback("tally", "slime_babies_born", 1, baby.slime_type.color)
		step_away(baby, src)
		family += baby

	set_nutrition(SLIME_STARTING_NUTRITION)
	for(var/mob/living/basic/slime/slime as anything in family)
		if(ckey) // Player slimes are more robust at spliting. Once an oversight of poor copypasta, now a feature!
			slime.set_nutrition(new_nutrition)
		slime.powerlevel = new_powerlevel
		slime.mutation_chance = mutation_chance ? clamp(mutation_chance + rand(-5, 5), 0, 100) : 0

	if(!keeps_parent_adult)
		set_life_stage(SLIME_LIFE_STAGE_BABY)
		update_name()
		regenerate_icons()
	amount_grown = 0
	mutator_used = FALSE
