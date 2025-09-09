//Immune to ash storms and lava
/datum/species/golem/plastitanium
	name = "Plastitanium Golem"
	id = SPECIES_GOLEM_PLASTITANIUM
	fixed_mut_color = "#888888"
	meat = /obj/item/stack/ore/titanium
	info_text = "As a <span class='danger'>Plastitanium Golem</span>, you are immune to both ash storms and lava, and slightly more resistant to burn damage."
	burnmod = 0.8
	prefix = "Plastitanium"
	special_names = null
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/plastitanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE), SPECIES_TRAIT)

/datum/species/golem/plastitanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.remove_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE), SPECIES_TRAIT)
