/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = SPECIES_GOLEM_ADAMANTINE
	meat = /obj/item/food/meat/slab/human/mutant/golem/adamantine
	mutant_organs = list(/obj/item/organ/internal/adamantine_resonator, /obj/item/organ/internal/vocal_cords/adamantine)
	fixed_mut_color = "#44eedd"
	info_text = "As an <span class='danger'>Adamantine Golem</span>, you possess special vocal cords allowing you to \"resonate\" messages to all golems. Your unique mineral makeup makes you immune to most types of magic."
	prefix = "Adamantine"
	special_names = null
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/adamantine/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_ANTIMAGIC, SPECIES_TRAIT)

/datum/species/golem/adamantine/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_ANTIMAGIC, SPECIES_TRAIT)
	..()
