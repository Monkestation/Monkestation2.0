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

/**
	* Toggle Death Signal simply adds and removes the trait required for slimepeople to transmit a GPS signal upon core ejection.
	*/
/datum/action/innate/core_signal
	name = "Toggle Core Signal"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "alter_form"
	button_icon = SLIME_ACTIONS_ICON_FILE
	background_icon_state = "bg_alien"

/datum/action/innate/core_signal/Activate()
	var/mob/living/carbon/human/slime = owner
	var/obj/item/organ/internal/brain/slime/core = astype(slime.get_organ_slot(ORGAN_SLOT_BRAIN))
	if(!core)
		return
	if(core.gps_active)
		to_chat(owner,span_notice("You tune out the electromagnetic signals from your core so they are ignored by GPS receivers upon it's rejection."))
		core.gps_active = FALSE
	else
		to_chat(owner, span_notice("You fine-tune the electromagnetic signals from your core to be picked up by GPS receivers upon it's rejection."))
		core.gps_active = TRUE

///////
/// MEMBRANE MURMUR SPELL
/// Use your core to attempt to call out for help or attention.
/datum/action/cooldown/membrane_murmur
	name = "Membrane Murmur"
	desc = "Force your core to pass gasses to make noticable sounds."
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "gel_cocoon"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

	cooldown_time = 25 SECONDS
	check_flags = NONE

	var/static/list/possible_cries = list(
		"Blorp... glub... help...",
		"Glooop... save me...",
		"Alone... burbble too quiet...",
		"What's left... of me...?",
		"Can't feel... can't... think...",
		"Plasma... need... plasma...",
		"It's so... quiet...",
	)

/datum/action/cooldown/membrane_murmur/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/brain/brainmob = astype(owner)
	if(!istype(brainmob?.loc, /obj/item/organ/internal/brain/slime))
		return FALSE

/datum/action/cooldown/membrane_murmur/Activate()
	. = ..()
	var/mob/living/brain/brainmob = owner
	if(!istype(brainmob))
		CRASH("[src] cast by non-brainmob [owner?.type || "(null)"]")
	var/obj/item/organ/internal/brain/slime/brainitem = brainmob.loc
	var/final_cry = brainmob.Ellipsis(pick(possible_cries), chance = 30)
	brainitem.say(final_cry, "slime", forced = "[src]", message_range = 2)
