/datum/species/golem/durathread
	name = "Durathread Golem"
	id = SPECIES_GOLEM_DURATHREAD
	prefix = "Durathread"
	special_names = list("Boll","Weave")
	fixed_mut_color = null
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_NO_UNDERWEAR,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFLASH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBLOOD,
	)
	info_text = "As a <span class='danger'>Durathread Golem</span>, your strikes will cause those your targets to start choking, but your woven body won't withstand fire as well."
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/durathread,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/durathread,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/durathread,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/durathread,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/durathread,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/durathread,
	)

/datum/species/golem/durathread/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	target.apply_status_effect(/datum/status_effect/strandling)
