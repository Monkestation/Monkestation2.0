/datum/mutation/human/biotechcompat
	power_coeff = 1

/datum/mutation/human/biotechcompat/modify()
	. = ..()
	if(owner && GET_MUTATION_POWER(src) > 1)
		owner.adjust_skillchip_complexity_modifier(floor(GET_MUTATION_POWER(src)))

/datum/mutation/human/biotechcompat/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	if(GET_MUTATION_POWER(src) > 1)
		owner.adjust_skillchip_complexity_modifier(-floor(GET_MUTATION_POWER(src)))

/datum/mutation/human/clever
	power_coeff = 1

/datum/mutation/human/clever/modify()
	. = ..()
	if(owner && GET_MUTATION_POWER(src) > 1)
		owner.add_actionspeed_modifier(/datum/actionspeed_modifier/clever)

/datum/mutation/human/clever/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	if(GET_MUTATION_POWER(src) > 1)
		owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/clever)

/datum/actionspeed_modifier/clever
	multiplicative_slowdown = -0.1
