/// Vox quills, which vox have instead of hair. They take the hair color and gradient, are restyled and shaved like hair, and hidden by whatever hides hair.
/// Kept even when styled "None", like a bald head, so they can be grown back at a mirror or a barber.
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
	kept_without_style = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/vox_quills

/// TRUE if there are quills to show: styled, and not plucked for good
/obj/item/organ/external/vox_quills/proc/has_quills()
	if(!owner || HAS_TRAIT(owner, get_regrowth_blocker()))
		return FALSE
	return bodypart_overlay.sprite_datum && bodypart_overlay.sprite_datum.name != SPRITE_ACCESSORY_NONE

/// The quill sprites are dark, their color gets added to them
/datum/bodypart_overlay/mutant/vox_quills
	layers = list(EXTERNAL_ADJACENT = HAIR_LAYER)
	feature_key = "vox_quills"
	color_source = ORGAN_COLOR_OVERRIDE
	offset_location = UPPER_BODY
	/// We aren't drawn if the owner has these slots obscured
	var/hidden_by = HIDEHAIR
	/// Whether the hair gradient is drawn on us
	var/uses_gradient = TRUE

/datum/bodypart_overlay/mutant/vox_quills/get_global_feature_list()
	return GLOB.vox_quills_list

/datum/bodypart_overlay/mutant/vox_quills/get_overlay(obj/item/bodypart/limb, layer_index, layer_real)
	inherit_color(limb, force = TRUE) // follow hair dye and the like
	. = ..()
	var/obj/item/bodypart/head/head = limb
	if(!uses_gradient || !istype(head))
		return
	var/datum/sprite_accessory/gradient = GLOB.hair_gradients_list[LAZYACCESS(head.gradient_styles, GRADIENT_HAIR_KEY)]
	var/gradient_color = LAZYACCESS(head.gradient_colors, GRADIENT_HAIR_KEY)
	var/mutable_appearance/quills_base = .
	if(!istype(gradient) || gradient.name == SPRITE_ACCESSORY_NONE || !gradient.icon_state || !gradient_color || !istype(quills_base))
		return
	// The gradient is drawn inside the quills: an inset overlay on top of the additively colored quills
	var/mutable_appearance/quills_overlay = mutable_appearance(layer = layer_real)
	quills_overlay.appearance_flags |= KEEP_TOGETHER
	quills_base.layer = FLOAT_LAYER
	quills_overlay.overlays += quills_base
	var/mutable_appearance/gradient_quills = mutable_appearance(gradient.icon, gradient.icon_state)
	gradient_quills.color = list(COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, sanitize_hexcolor(gradient_color))
	gradient_quills.blend_mode = BLEND_INSET_OVERLAY
	quills_overlay.overlays += gradient_quills
	return quills_overlay

/datum/bodypart_overlay/mutant/vox_quills/override_color(obj/item/bodypart/bodypart_owner)
	var/obj/item/bodypart/head/head = bodypart_owner
	if(!istype(head))
		return draw_color || COLOR_DARKER_BROWN
	return head.override_hair_color || head.fixed_hair_color || get_quill_color(head) || COLOR_DARKER_BROWN

/// Returns the hair color of the head that these quills take
/datum/bodypart_overlay/mutant/vox_quills/proc/get_quill_color(obj/item/bodypart/head/head)
	return head.hair_color

/datum/bodypart_overlay/mutant/vox_quills/color_image(image/overlay, obj/item/bodypart/limb, layer_index, key_name)
	overlay.color = COLOR_MATRIX_ADD(draw_color)

/datum/bodypart_overlay/mutant/vox_quills/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	if(!sprite_datum || sprite_datum.name == SPRITE_ACCESSORY_NONE)
		return FALSE
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
	restyle_flags = EXTERNAL_RESTYLE_FACIAL_HAIR
	bodypart_overlay = /datum/bodypart_overlay/mutant/vox_quills/facial

/datum/bodypart_overlay/mutant/vox_quills/facial
	feature_key = "vox_facial_quills"
	hidden_by = HIDEFACIALHAIR
	uses_gradient = FALSE

/datum/bodypart_overlay/mutant/vox_quills/facial/get_quill_color(obj/item/bodypart/head/head)
	return head.facial_hair_color

/datum/bodypart_overlay/mutant/vox_quills/facial/get_global_feature_list()
	return GLOB.vox_facial_quills_list
