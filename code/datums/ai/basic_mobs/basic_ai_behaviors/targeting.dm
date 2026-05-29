/// List of objects that AIs will treat as targets
GLOBAL_ALIST_EMPTY(hostile_machines_by_z)
/// Static typecache list of things we are interested in
/// Consider this a union of the for loop and the hearers call from below
/// Must be kept up to date with the contents of hostile_machines
GLOBAL_LIST_INIT(target_interested_atoms, typecacheof(list(/mob, /obj/machinery/porta_turret, /obj/vehicle/sealed/mecha)))

/datum/ai_behavior/find_potential_targets
	action_cooldown = 2 SECONDS
	/// How far can we see stuff?
	var/vision_range = 9
	/// Blackboard key for aggro range, uses vision range if not specified
	var/aggro_range_key = BB_AGGRO_RANGE

/datum/ai_behavior/find_potential_targets/get_cooldown(datum/ai_controller/cooldown_for)
	if(cooldown_for.blackboard[BB_FIND_TARGETS_FIELD(type)])
		return 60 SECONDS
	return ..()

/datum/ai_behavior/find_potential_targets/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/mob/living/living_mob = controller.pawn
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])

	if(!targeting_strategy)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/atom/current_target = controller.blackboard[target_key]
	if (targeting_strategy.can_attack(living_mob, current_target, vision_range))
		finish_action(controller, succeeded = FALSE)
		return

	var/aggro_range = controller.blackboard[aggro_range_key] || vision_range

	controller.clear_blackboard_key(target_key)
	var/list/potential_targets = hearers(aggro_range, controller.pawn) - living_mob //Remove self, so we don't suicide

	// If we're using a field rn, just don't do anything yeah?
	if(controller.blackboard[BB_FIND_TARGETS_FIELD(type)])
		return

	var/turf/mob_turf = get_turf(living_mob)
	if(mob_turf?.z)
		for (var/atom/hostile_machine as anything in GLOB.hostile_machines_by_z[mob_turf.z])
			if (can_see(living_mob, hostile_machine, aggro_range))
				potential_targets += hostile_machine

	if(!potential_targets.len)
		failed_to_find_anyone(controller, target_key, targeting_strategy_key, hiding_location_key)
		finish_action(controller, succeeded = FALSE)
		return

	var/list/filtered_targets = list()

	for(var/atom/pot_target in potential_targets)
		if(SEND_SIGNAL(controller.pawn, COMSIG_FRIENDSHIP_CHECK_LEVEL, pot_target, FRIENDSHIP_FRIEND))
			continue
		if(targeting_strategy.can_attack(living_mob, pot_target))//Can we attack it?
			filtered_targets += pot_target
			continue

	if(!filtered_targets.len)
		failed_to_find_anyone(controller, target_key, targeting_strategy_key, hiding_location_key)
		finish_action(controller, succeeded = FALSE)
		return

	var/atom/target = pick_final_target(controller, filtered_targets)
	controller.set_blackboard_key(target_key, target)

	var/atom/potential_hiding_location = targeting_strategy.find_hidden_mobs(living_mob, target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.set_blackboard_key(hiding_location_key, potential_hiding_location)

	finish_action(controller, succeeded = TRUE)

/datum/ai_behavior/find_potential_targets/proc/failed_to_find_anyone(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	// takes the larger between our range() input and our implicit hearers() input (world.view)
	// aggro_range = max(aggro_range, ROUND_UP(max(getviewsize(world.view)) / 2)) MAPEXPANSION CHANGE: Stillcaps
	// Alright, here's the interesting bit
	// We're gonna use this max range to hook into a proximity field so we can just await someone interesting to come along
	// Rather then trying to check every few seconds
	// We're gonna store this field in our blackboard, so we can clear it away if we end up finishing successsfully

/datum/ai_behavior/find_potential_targets/proc/new_turf_found(turf/found, datum/ai_controller/controller, datum/targeting_strategy/strategy)
	// If we found any one thing we "could" attack, then run the full search again so we can select from the best possible canidate
	// Fire instantly, you should find something I hope

/datum/ai_behavior/find_potential_targets/proc/atom_allowed(atom/movable/checking, datum/targeting_strategy/strategy, mob/pawn)

/datum/ai_behavior/find_potential_targets/proc/new_atoms_found(list/atom/movable/found, datum/ai_controller/controller, target_key, datum/targeting_strategy/strategy, hiding_location_key)
		// Need to better handle viewers here

	// Alright, we found something acceptable, let's use it yeah?




/datum/ai_behavior/find_potential_targets/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if (succeeded)
		var/datum/proximity_monitor/field = controller.blackboard[BB_FIND_TARGETS_FIELD(type)]
		qdel(field) // autoclears so it's fine
		controller.CancelActions() // On retarget cancel any further queued actions so that they will setup again with new target
		controller.modify_cooldown(controller, get_cooldown(controller))

/// Returns the desired final target from the filtered list of targets
/datum/ai_behavior/find_potential_targets/proc/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
