/obj/item/organ/internal/lungs/clockwork
	name = "clockwork diaphragm"
	desc = "A utilitarian bellows which serves to pump oxygen into an automaton's body."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "lungs-clock"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC

/obj/item/organ/internal/lungs/cetanoid
	name = "cetanoid lungs"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "lungs"
	var/suffocating = TRUE //cetanoids require their cybernetic suit to breath

/obj/item/organ/internal/lungs/cetanoid/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/breather)
	if(suffocating == TRUE)
		..(null, breather)
	else
		..(breath, breather)
