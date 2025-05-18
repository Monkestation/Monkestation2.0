//Harder to stun, deals more damage, massively slowpokes, but gravproof and obstructive. Basically, The Wall.
/datum/species/golem/plasteel
	name = "Plasteel Golem"
	id = SPECIES_GOLEM_PLASTEEL
	fixed_mut_color = "#bbbbbb"
	stunmod = 0.4
	meat = /obj/item/stack/ore/iron
	info_text = "As a <span class='danger'>Plasteel Golem</span>, you are slower, but harder to stun, and hit very hard when punching. You also magnetically attach to surfaces and so don't float without gravity and cannot have positions swapped with other beings."
	prefix = "Plasteel"
	special_names = null
	examine_limb_id = SPECIES_GOLEM
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/plasteel,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/plasteel,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/plasteel,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/plasteel,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

/datum/species/golem/plasteel/negates_gravity(mob/living/carbon/human/H)
	return TRUE

/datum/species/golem/plasteel/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_NOMOBSWAP, SPECIES_TRAIT) //THE WALL THE WALL THE WALL

/datum/species/golem/plasteel/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_NOMOBSWAP, SPECIES_TRAIT) //NOTHING ON ERF CAN MAKE IT FALL
	..()
