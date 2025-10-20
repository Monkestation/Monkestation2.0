///////
/// SLIME CLEANING ABILITY
/// Makes it so slimes clean themselves.

/datum/action/cooldown/slime_washing
	name = "Toggle Slime Cleaning"
	desc = "Filter grime through your outer membrane, cleaning yourself and your equipment for sustenance. Also cleans the floor, providing your feet are uncovered. For sustenance."
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "activate_wash"
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
	owner.visible_message(span_purple("[owner]'s outer membrane starts to develop a roiling film on the outside, absorbing grime into their inner layer!"), span_purple("Your outer membrane develops a roiling film on the outside, absorbing grime off yourself and your clothes; as well as the floor beneath you."))
	return TRUE

/datum/status_effect/slime_washing/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	owner.visible_message(span_notice("[owner]'s outer membrane returns to normal, no longer cleaning [owner.p_their()] surroundings."), span_notice("Your outer membrane returns to normal, filth no longer being cleansed."))

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
	return span_notice("[owner.p_Their()] outer layer is pulling in grime, filth sinking inside of their body and vanishing.")

///////
/// HYDROPHOBIA SPELL
/// Makes it so that slimes are waterproof, but slower, and they don't regenerate.

/datum/action/cooldown/slime_hydrophobia
	name = "Toggle Hydrophobia"
	desc = "Develop an oily layer on your outer membrane, repelling water at the cost of lower viscosity."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "nanite_shield"
	cooldown_time = 1 MINUTES

/datum/action/cooldown/slime_hydrophobia/Remove(mob/living/remove_from) // If we lose the spell make sure to remove its effects
	. = ..()
	remove_from.remove_status_effect(/datum/status_effect/slime_hydrophobia)

/datum/action/cooldown/slime_hydrophobia/Activate()
	. = ..()
	var/mob/living/carbon/human/user = owner
	if(!ishuman(user))
		CRASH("Non-human somehow had [name] action")

	if(user.has_status_effect(/datum/status_effect/slime_hydrophobia))
		slime_hydrophobia_deactivate(user)
		return

	user.apply_status_effect(/datum/status_effect/slime_hydrophobia)
	user.visible_message(span_purple("[user]'s outer membrane starts to ooze out an oily coating, [owner.p_their()] body becoming more viscous!"), span_purple("Your outer membrane starts to ooze out an oily coating, protecting you from water but making your body more viscous."))

/datum/action/cooldown/slime_hydrophobia/proc/slime_hydrophobia_deactivate(mob/living/carbon/human/user)
	user.remove_status_effect(/datum/status_effect/slime_hydrophobia)
	user.visible_message(span_purple("[user]'s outer membrane returns to normal, [owner.p_their()] body drawing the oily coat back inside!"), span_purple("Your outer membrane returns to normal, water being dangerous to you again."))

/datum/movespeed_modifier/status_effect/slime_hydrophobia
	multiplicative_slowdown = 1.5

/datum/status_effect/slime_hydrophobia
	id = "slime_hydrophobia"
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null

/datum/status_effect/slime_hydrophobia/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/slime_hydrophobia, update = TRUE)
	ADD_TRAIT(owner, TRAIT_SLIME_HYDROPHOBIA, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/slime_hydrophobia/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/slime_hydrophobia, update = TRUE)
	REMOVE_TRAIT(owner, TRAIT_SLIME_HYDROPHOBIA, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/slime_hydrophobia/get_examine_text()
	return span_notice("[owner.p_They()] [owner.p_are()] oozing out an oily coating onto [owner.p_their()] outer membrane, water rolling right off.")
