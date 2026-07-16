/datum/species/vox
	name = "\improper Vox"
	plural_form = "Voces"
	id = SPECIES_VOX
	changesource_flags = NONE
	visual_gender = FALSE
	sexes = FALSE // its a bird looking... thing?

	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_AUGMENTS,
		TRAIT_FEATHERED,
		TRAIT_BADDNA,
		TRAIT_EASILY_WOUNDED,
		TRAIT_GENELESS,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_TRANSFORMATION_STING,
		TRAIT_NO_ZOMBIFY,
	)
	// external_organs = list(
	// 	/obj/item/organ/external/quills = "long",
	// 	/obj/item/organ/external/quills/lower = "basic")
	death_sound = 'sound/voice/vox/vox_DeathGasp.ogg'
	meat = /obj/item/food/meat/slab/chicken
	species_language_holder = /datum/language_holder/vox
	mutanttongue = /obj/item/organ/internal/tongue/vox
	mutanteyes = /obj/item/organ/internal/eyes/vox
	mutantlungs = /obj/item/organ/internal/lungs/vox
	exotic_bloodtype = BLOOD_TYPE_HEMOLYMPH
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/vox,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/vox,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/vox,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/vox,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/vox,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/vox,
	)

/datum/species/arachnid/get_species_description()
	return "The Vox are a race of spacefaring avians. They have a penchant for capitalism and goods peddling, deep space salvage, and sometimes interstellar crime. They speak in outlandish accents and are widely considered a nomadic pest in the eyes of the average human. The presence of these ruthless and irritating space vultures is mostly tolerated because of CentComm policy and the technology the Vox gather."

/obj/item/bodypart/head/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	is_dimorphic = FALSE
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	lip_style = NONE

	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	is_dimorphic = FALSE
	ass_image = 'icons/ass/asslizard.png'
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)

	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)

	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)

	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
	)

	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
	)

	should_draw_greyscale = FALSE
