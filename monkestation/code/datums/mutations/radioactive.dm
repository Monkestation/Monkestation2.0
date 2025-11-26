/datum/mutation/radioactive
	synchronizer_coeff = 1

/datum/mutation/radioactive/setup()
	. = ..()
	if(owner && GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.update_mutations_overlay()

/datum/mutation/radioactive/get_visual_indicator()
	if(GET_MUTATION_SYNCHRONIZER(src) < 1) // Stealth
		return FALSE
	return visual_indicators[type][1]
