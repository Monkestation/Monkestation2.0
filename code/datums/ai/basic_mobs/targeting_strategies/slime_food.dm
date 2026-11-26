/// What a slime will chase down and drain. Grudges count too, but only if they're actually edible.
/datum/targeting_strategy/slime_food

/datum/targeting_strategy/slime_food/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	var/mob/living/basic/slime/hunter = living_mob
	controller ||= hunter.ai_controller
	if(!isslime(hunter) || isnull(controller) || !isliving(target) || QDELETED(target))
		return FALSE

	if(target in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST])
		var/datum/targeting_strategy/grudge_strategy = GET_TARGETING_STRATEGY(/datum/targeting_strategy/basic/not_friends)
		if(!grudge_strategy.is_valid_target(living_mob, target, vision_range, controller))
			return FALSE
		return hunter.buckled == target || hunter.can_feed_on(target, silent = TRUE)

	var/mob/living/candidate = target
	// checked before the latched-meal line, so flipping either on mid-meal makes us let go
	if(hunter.cleaner_slime)
		return FALSE
	if(hunter.cat_slime && candidate.mob_size >= hunter.mob_size)
		return FALSE
	// don't invalidate the meal we're already latched onto
	if(hunter.buckled == candidate)
		return TRUE
	if((FACTION_SLIME in candidate.faction) || (REF(candidate) in hunter.faction))
		return FALSE
	if(!hunter.can_feed_on(candidate, silent = TRUE))
		return FALSE
	if(!can_see(hunter, candidate, vision_range))
		return FALSE

	if(candidate == controller.blackboard[BB_CURRENT_TARGET])
		return TRUE
	if(controller.blackboard[BB_SLIME_HUNGER_LEVEL] == SLIME_HUNGER_STARVING && controller.blackboard[BB_SLIME_RABID])
		return TRUE
	// monkeys are humans here, so they're always on the menu
	if(ishuman(candidate) || isalien(candidate))
		return TRUE
	var/static/list/livestock = typecacheof(list(
		/mob/living/basic/cow,
		/mob/living/basic/pig,
		/mob/living/basic/sheep,
		/mob/living/basic/goat,
		/mob/living/basic/chicken,
		/mob/living/basic/rabbit,
	))
	if(livestock[candidate.type])
		return TRUE
	// critters we still owe a mutation stay food even after their quota's done - a critter-only pen still has to feed us
	var/list/wanted_mobs = controller.blackboard[BB_SLIME_WANTED_MOBS]
	return !!wanted_mobs?[candidate.type]
