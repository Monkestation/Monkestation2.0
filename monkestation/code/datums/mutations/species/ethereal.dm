/datum/mutation/human/overload
	name = "Overload"
	desc = "Allows a host to overload their skin to cause a bright flash."
	locked = TRUE
	quality = POSITIVE
	text_gain_indication = span_notice("You feel your skin energetically tingle.")
	instability = 30
	power_path = /datum/action/cooldown/overload
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/human/overload/modify()
	. = ..()
	if(!.)
		return

	var/datum/action/cooldown/overload/to_modify = .
	to_modify.distance *= GET_MUTATION_POWER(src)

/datum/action/cooldown/overload
	name = "Overload"
	desc = "Concentrate to make your skin energize and emit a bright flash."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "funk"

	cooldown_time = 40 SECONDS
	check_flags = AB_CHECK_CONSCIOUS

	var/distance = 4

/datum/action/cooldown/overload/Activate(mob/living/carbon/cast_on)
	. = ..()
	var/list/mob/targets = oviewers(distance, get_turf(cast_on))
	cast_on.visible_message(span_userdanger("[cast_on] emits a blinding light!"))
	for(var/mob/living/carbon/target in targets)
		if(target.flash_act(1))
			var/target_distance = get_dist(cast_on, target)
			target.Paralyze((distance / target_distance) SECONDS)

	return TRUE
