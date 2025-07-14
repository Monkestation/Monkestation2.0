/datum/mutation/human/wings
	name = "Strengthened Wings"
	desc = "Subject's wing muscle volume rapidly increases, effect only observed in naturally winged subjects."
	locked = TRUE
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = span_notice("You feel your wing muscles expand!")
	species_allowed = list(SPECIES_MOTH, SPECIES_TUNDRA, SPECIES_APID, SPECIES_ORNITHID)
	instability = 15

/datum/mutation/human/wings/on_acquiring(mob/living/carbon/human/owner)
	if(!owner || !istype(owner)) // Parent checks this, but we want to be safe when doing get_organ_slot
		return TRUE

	var/obj/item/organ/external/wings/functional/external_wings = owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(external_wings && istype(external_wings))
		return TRUE // You dont need us

	. = ..()
	if(.)
		return

	var/datum/reagent/flightpotion/juice = new()
	juice.expose_mob(owner, INJECT, 5)

	if(external_wings) // These are the old wings, instead of being dropped onto the ground we store them
		external_wings.forceMove(owner)

/datum/mutation/human/wings/on_losing(mob/living/carbon/human/owner)
	if(!owner || !istype(owner)) // See above
		return TRUE

	var/obj/item/organ/external/wings/functional/external_wings = owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(!external_wings || !istype(external_wings))
		return TRUE // Cheater, you don't get to remove this mutation without having FUNCTIONAL wings

	. = ..()
	if(.)
		return TRUE

	external_wings.Remove(owner)

	var/obj/item/organ/external/wings/previous_wings = locate(/obj/item/organ/external/wings) in owner
	if(previous_wings)
		previous_wings.Insert(owner)
