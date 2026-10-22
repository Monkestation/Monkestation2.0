/datum/species/golem/leather
	name = "Leather Golem"
	id = SPECIES_GOLEM_LEATHER
	special_names = list("Face", "Man", "Belt") //Ah dude 4 strength 4 stam leather belt AHHH
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_STRONG_GRABBER,
	)
	prefix = "Leather"
	fixed_mut_color = "#624a2e"
	info_text = "As a <span class='danger'>Leather Golem</span>, you are flammable, but you can grab things with incredible ease, allowing all your grabs to start at a strong level."
	grab_sound = 'sound/weapons/whipgrab.ogg'
	examine_limb_id = SPECIES_GOLEM
