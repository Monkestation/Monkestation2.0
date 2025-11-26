
/datum/species/golem/mhydrogen //Effectively most other metal-based golem types rolled into one - immune to all weather, lava, flashes, and magic, while being just as hardened as diamond golems.
	name = "Metallic Hydrogen Golem"
	id = SPECIES_GOLEM_HYDROGEN
	fixed_mut_color = "#535469"
	armor = 70 //equal to a diamond golem
	info_text = "As a <span class='danger'>Metallic Hydrogen Golem</span>, you were forged in the highest pressures and the highest heats. Your unique material makeup makes you immune to magic and most environmental damage, while helping you resist most other attacks."
	prefix = "Metallic Hydrogen"
	special_names = list("Pressure","Crush")
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_GENELESS,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_NOFLASH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBLOOD,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_WEATHER_IMMUNE,
		TRAIT_LAVA_IMMUNE,
	)
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/mhydrogen/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	ADD_TRAIT(C, TRAIT_ANTIMAGIC, SPECIES_TRAIT)

/datum/species/golem/mhydrogen/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_ANTIMAGIC, SPECIES_TRAIT)
	return ..()
