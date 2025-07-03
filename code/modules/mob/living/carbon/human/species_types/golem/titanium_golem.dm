//Immune to ash storms
/datum/species/golem/titanium
	name = "Titanium Golem"
	id = SPECIES_GOLEM_TITANIUM
	fixed_mut_color = "#ffffff"
	meat = /obj/item/stack/ore/titanium
	info_text = "As a <span class='danger'>Titanium Golem</span>, you are immune to ash storms, and slightly more resistant to burn damage."
	burnmod = 0.9
	prefix = "Titanium"
	special_names = list("Dioxide")
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/titanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	ADD_TRAIT(C, TRAIT_ASHSTORM_IMMUNE, SPECIES_TRAIT)

/datum/species/golem/titanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	REMOVE_TRAIT(C, TRAIT_ASHSTORM_IMMUNE, SPECIES_TRAIT)
