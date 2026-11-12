/datum/action/cooldown/slime_washing
	name = "Toggle Slime Cleaning"
	desc = "Filter grime through your outer membrane, cleaning yourself and your equipment for sustenance. Also cleans the floor, providing your feet are uncovered. For sustenance."
	button_icon = SLIME_ACTIONS_ICON_FILE
	button_icon_state = "slime_washing"
	cooldown_time = 1 SECONDS

/datum/action/cooldown/slime_washing/Remove(mob/living/remove_from)
	. = ..()
	remove_from.remove_status_effect(/datum/status_effect/slime_washing)

/datum/action/cooldown/slime_washing/Activate()
	. = ..()
	var/mob/living/carbon/human/user = owner
	if(!ishuman(user))
		CRASH("Non-human somehow had [name] action")

	if(user.has_status_effect(/datum/status_effect/slime_washing))
		user.remove_status_effect(/datum/status_effect/slime_washing)
	else
		user.apply_status_effect(/datum/status_effect/slime_washing)

/datum/status_effect/slime_washing
	id = "slime_washing"
	alert_type = null
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/slime_washing/on_apply()
	if(!ishuman(owner))
		return FALSE
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(clean_floor))
	owner.visible_message(
		span_purple("[owner]'s outer membrane starts to develop a roiling film on the outside, absorbing grime into [owner.p_their()] inner layer!"),
		span_purple("Your outer membrane develops a roiling film on the outside, absorbing grime off yourself and your clothes; as well as the floor beneath you.")
	)
	owner.balloon_alert_to_viewers("begins absorbing grime")
	return TRUE

/datum/status_effect/slime_washing/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	owner.visible_message(
		span_notice("[owner]'s outer membrane returns to normal, no longer cleaning [owner.p_their()] surroundings."),
		span_notice("Your outer membrane returns to normal, filth no longer being cleansed.")
	)
	owner.balloon_alert_to_viewers("stops absorbing grime")

/datum/status_effect/slime_washing/tick(seconds_between_ticks, seconds_per_tick)
	if(owner.stat == DEAD)
		qdel(src)
		return
	owner.wash(CLEAN_WASH)
	clean_floor()

/datum/status_effect/slime_washing/proc/clean_floor()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/slime = owner
	if(slime.body_position != LYING_DOWN && ((slime.wear_suit?.body_parts_covered | slime.w_uniform?.body_parts_covered | slime.shoes?.body_parts_covered) & FEET))
		return
	var/turf/open/open_turf = get_turf(slime)
	if(!istype(open_turf))
		return
	if(open_turf.wash(CLEAN_WASH) && slime.nutrition <= NUTRITION_LEVEL_FED)
		slime.adjust_nutrition(rand(5, 25))
	return TRUE

/datum/status_effect/slime_washing/get_examine_text()
	return span_purple("[owner.p_Their()] outer layer is pulling in grime, filth sinking inside of their body and vanishing.")
