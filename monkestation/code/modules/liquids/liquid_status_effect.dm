/datum/status_effect/water_affected
	id = "wateraffected"
	alert_type = null
	duration = STATUS_EFFECT_PERMANENT

/datum/status_effect/water_affected/on_apply()
	//We should be inside a liquid turf if this is applied
	return calculate_water_slow()

/datum/status_effect/water_affected/proc/calculate_water_slow()
	//Factor in swimming skill here?
	var/turf/owner_turf = get_turf(owner)
	if(!owner_turf || QDELETED(owner_turf.liquids) || QDELETED(owner_turf.liquids.liquid_group) || owner_turf.liquids.liquid_group.group_overlay_state == LIQUID_STATE_PUDDLE)
		return FALSE
	var/slowdown_amount = owner_turf.liquids.liquid_group.group_overlay_state * 0.5
	owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/liquids, multiplicative_slowdown = slowdown_amount)
	return TRUE

/datum/status_effect/water_affected/tick()
	var/turf/owner_turf = get_turf(owner)
	if(!calculate_water_slow())
		qdel(src)
		return
	//Make the reagents touch the person

	var/fraction = SUBMERGEMENT_PERCENT(owner, owner_turf.liquids)
	owner_turf.liquids.liquid_group.expose_members_turf(owner_turf.liquids)
	owner_turf.liquids.liquid_group.transfer_to_atom(owner_turf.liquids, ((SUBMERGEMENT_REAGENTS_TOUCH_AMOUNT * fraction / 20)), owner)

/datum/status_effect/water_affected/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/liquids)

/datum/movespeed_modifier/liquids
	variable = TRUE
	blacklisted_movetypes = FLOATING | FLYING

/datum/status_effect/ocean_affected
	id = "ocean_affected"
	duration = STATUS_EFFECT_PERMANENT
	alert_type = null

/datum/status_effect/ocean_affected/on_apply()
	if(!isoceanturf(get_turf(owner)))
		return FALSE
	return TRUE

/datum/status_effect/ocean_affected/tick()
	var/turf/ocean_turf = get_turf(owner)
	if(!isoceanturf(ocean_turf))
		qdel(src)
		return

	if(ishuman(owner))
		var/mob/living/carbon/human/arrived = owner
		if(isipc(arrived))
			if(!(arrived.wear_suit?.clothing_flags & STOPSPRESSUREDAMAGE))
				arrived.take_overall_damage(burn = 5)
		else if(isoozeling(arrived) && !HAS_TRAIT(arrived, TRAIT_SLIME_HYDROPHOBIA))
			var/datum/species/oozeling/oozeling = arrived.dna.species
			oozeling.water_exposure(arrived, check_clothes = TRUE, quiet_if_protected = TRUE)
