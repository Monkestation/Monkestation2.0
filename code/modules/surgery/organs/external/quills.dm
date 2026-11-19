/// Vox quills, which vox have instead of hair. They are restyled like hair, and hidden by whatever hides hair.
/obj/item/organ/external/vox_quills
	name = "vox quills"
	desc = "A bundle of quills, plucked from a vox's head."
	icon = 'icons/obj/species/vox/organs.dmi'
	icon_state = "quills"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_VOX_QUILLS
	preference = "feature_vox_quills"
	dna_block = DNA_VOX_QUILLS_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_HAIR
	bodypart_overlay = /datum/bodypart_overlay/mutant/vox_quills

/// The quill sprites are dark, their color gets added to them
/datum/bodypart_overlay/mutant/vox_quills
	layers = list(EXTERNAL_ADJACENT = HAIR_LAYER)
	feature_key = "vox_quills"
	palette = /datum/color_palette/generic_colors
	palette_key = "quill_color"
	offset_location = UPPER_BODY
	/// We aren't drawn if the owner has these slots obscured
	var/hidden_by = HIDEHAIR

/datum/bodypart_overlay/mutant/vox_quills/get_global_feature_list()
	return GLOB.vox_quills_list

/datum/bodypart_overlay/mutant/vox_quills/color_image(image/overlay, obj/item/bodypart/limb, layer_index, key_name)
	overlay.color = color_matrix_additive(draw_color)

/datum/bodypart_overlay/mutant/vox_quills/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	return !(human.obscured_slots & hidden_by)

/obj/item/organ/external/vox_quills/facial
	name = "vox facial quills"
	desc = "A bundle of quills, plucked from a vox's face."
	slot = ORGAN_SLOT_EXTERNAL_VOX_FACIAL_QUILLS
	preference = "feature_vox_facial_quills"
	dna_block = DNA_VOX_FACIAL_QUILLS_BLOCK
	bodypart_overlay = /datum/bodypart_overlay/mutant/vox_quills/facial

/datum/bodypart_overlay/mutant/vox_quills/facial
	feature_key = "vox_facial_quills"
	palette_key = "facial_quill_color"
	hidden_by = HIDEFACIALHAIR

/datum/bodypart_overlay/mutant/vox_quills/facial/get_global_feature_list()
	return GLOB.vox_facial_quills_list
