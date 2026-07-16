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
		TRAIT_EASILY_WOUNDED,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_TRANSFORMATION_STING,
		TRAIT_NO_ZOMBIFY,
	)
	external_organs = list(
		/obj/item/organ/external/quills = "Ruff Hawk",
	)
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

/datum/species/vox/on_species_gain(mob/living/carbon/human/C, datum/species/old_species, pref_load)
	. = ..()
	C.set_voice_pack("misc.vox")

/datum/species/vox/get_species_description()
	return "The Vox are a race of spacefaring avians. They have a penchant for capitalism and goods peddling, deep space salvage, and sometimes interstellar crime. They speak in outlandish accents and are widely considered a nomadic pest in the eyes of the average human. The presence of these ruthless and irritating space vultures is mostly tolerated because of CentComm policy and the technology the Vox gather."

/obj/item/organ/external/quills
	name = "feathery quills"
	desc = "A bunch of feather quills."
	icon_state = "vox_ruff_hawk"
	icon = 'icons/mob/species/vox/vox_hair_vg.dmi'

	preference = "feature_head_quills"
	zone = BODY_ZONE_HEAD
	dna_block = DNA_VOX_HEAD_QUILLS_BLOCK
	use_mob_sprite_as_obj_sprite = TRUE

	bodypart_overlay = /datum/bodypart_overlay/mutant/head_quills

/datum/bodypart_overlay/mutant/head_quills
	layers = EXTERNAL_FRONT
	feature_key = "head_quills"

/datum/bodypart_overlay/mutant/head_quills/can_draw_on_bodypart(mob/living/carbon/human/human)
	if((human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return FALSE

	return TRUE

/datum/bodypart_overlay/mutant/head_quills/get_global_feature_list()
	return GLOB.head_quills_list


/datum/bodypart_overlay/mutant/head_quills/get_image(image_layer, obj/item/bodypart/limb, layer_name)
	if(!sprite_datum)
		CRASH("Trying to call get_image() on [type] while it didn't have a sprite_datum. This shouldn't happen, report it as soon as possible.")

	var/mutable_appearance/appearance = mutable_appearance(sprite_datum.icon, get_base_icon_state(), layer = image_layer)

	if(sprite_datum.center)
		center_image(appearance, sprite_datum.dimension_x, sprite_datum.dimension_y)

	return appearance

/datum/preference/choiced/head_quills
	savefile_key = "feature_head_quills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Hairstyle"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/quills

/datum/preference/choiced/head_quills/init_possible_values()
	return assoc_to_keys_features(GLOB.head_quills_list)

/datum/preference/choiced/head_quills/create_default_value()
	return pick(assoc_to_keys_features(GLOB.head_quills_list))

/datum/preference/choiced/head_quills/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["head_quills"] = value

/obj/item/bodypart/head/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	is_dimorphic = FALSE
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	lip_style = NONE
	head_flags = null
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
