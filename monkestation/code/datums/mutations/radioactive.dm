/datum/mutation/human/radioactive
	synchronizer_coeff = 1

/datum/mutation/human/radioactive/modify()
	. = ..()
	if(owner && GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.update_mutations_overlay()

/datum/mutation/human/radioactive/get_visual_indicator()
	if(GET_MUTATION_SYNCHRONIZER(src) < 1) // Stealth
		return FALSE
	return visual_indicators[type][1]
