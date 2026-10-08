/datum/antagonist/clock_cultist/clockmob
	show_in_antagpanel = FALSE
	///Our warp action
	var/datum/action/cooldown/clock_cult/clockmob_warp/warp_action = new
	///A ref to our area bound component
	var/datum/component/multi_area_bound/area_bound_component

/datum/antagonist/clock_cultist/clockmob/Destroy()
	QDEL_NULL(warp_action)
	return ..()

/datum/antagonist/clock_cultist/clockmob/apply_innate_effects(mob/living/mob_override)
	. = ..()
	warp_action.Grant(owner.current)
	if(area_bound_component)
		QDEL_NULL(area_bound_component)
		stack_trace("[src.type] calling apply_innate_effects while still having an old area_bound_component.")
	area_bound_component = owner.current.AddComponent(/datum/component/multi_area_bound, _valid_areas = SSthe_ark.marked_areas + SSthe_ark.reebe_areas, _use_instances = TRUE)

/datum/antagonist/clock_cultist/clockmob/remove_innate_effects(mob/living/mob_override)
	. = ..()
	warp_action.Remove(owner.current)
	QDEL_NULL(area_bound_component)
