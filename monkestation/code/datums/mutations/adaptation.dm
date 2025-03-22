/datum/mutation/human/temperature_adaptation
	synchronizer_coeff = 1

/datum/mutation/human/temperature_adaptation/modify()
	. = ..()
	if(owner && GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.update_mutations_overlay()

/datum/mutation/human/temperature_adaptation/get_visual_indicator()
	if(GET_MUTATION_SYNCHRONIZER(src) < 1) // Stealth
		return FALSE
	return visual_indicators[type][1]

/datum/mutation/human/pressure_adaptation
	synchronizer_coeff = 1

/datum/mutation/human/pressure_adaptation/modify()
	. = ..()
	if(owner && GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.update_mutations_overlay()

/datum/mutation/human/pressure_adaptation/get_visual_indicator()
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		return FALSE
	return visual_indicators[type][1]
