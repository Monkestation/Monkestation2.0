// Vox limbs aren't greyscale: each skin tone is a limb style with its own icon file (GLOB.vox_skin_tones), picked by the "vox_skin_tone" DNA feature.

/obj/item/bodypart/head/vox
	icon_static = 'icons/mob/human/species/vox/bodyparts_lime.dmi'
	icon_husk = 'icons/mob/human/species/vox/husk.dmi'
	husk_type = "vox"
	husk_color = null
	limb_id = SPECIES_VOX
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_CUSTOM
	limb_style_feature = "vox_skin_tone"
	head_flags = HEAD_EYESPRITES | HEAD_EYECOLOR | HEAD_EYEHOLES | HEAD_DEBRAIN
	eyes_icon = 'icons/mob/human/species/vox/eyes.dmi'

/obj/item/bodypart/head/vox/Initialize(mapload)
	. = ..()
	style_icons = GLOB.vox_skin_tones
	add_bodypart_overlay(new /datum/bodypart_overlay/simple/vox_body_markings())

/obj/item/bodypart/head/vox/get_limb_icon(dropped, mob/living/carbon/update_on)
	. = ..()
	// Attached heads get this from the eyes organ
	if(dropped && eyes && (head_flags & HEAD_EYESPRITES))
		var/image/eye_static = image(eyes_icon, get_eye_static_state(), -BODY_LAYER, SOUTH)
		worn_face_offset?.apply_offset(eye_static)
		. += eye_static

/// Part of vox eyes is never colored: green, or blue for some skin tones
/obj/item/bodypart/head/vox/proc/get_eye_static_state()
	var/static/list/blue_static_skin_tones = list("crimson", "mossy")
	return "eyes_static_[(get_drawn_limb_style() in blue_static_skin_tones) ? "blue" : "green"]"

/obj/item/bodypart/chest/vox
	icon_static = 'icons/mob/human/species/vox/bodyparts_lime.dmi'
	icon_husk = 'icons/mob/human/species/vox/husk.dmi'
	husk_type = "vox"
	husk_color = null
	limb_id = SPECIES_VOX
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_CUSTOM
	limb_style_feature = "vox_skin_tone"
	ass_image = 'icons/ass/assvox.png'

/obj/item/bodypart/chest/vox/Initialize(mapload)
	. = ..()
	style_icons = GLOB.vox_skin_tones
	add_bodypart_overlay(new /datum/bodypart_overlay/simple/vox_body_markings())

/obj/item/bodypart/arm/left/vox
	icon_static = 'icons/mob/human/species/vox/bodyparts_lime.dmi'
	icon_husk = 'icons/mob/human/species/vox/husk.dmi'
	husk_type = "vox"
	husk_color = null
	limb_id = SPECIES_VOX
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_CUSTOM
	limb_style_feature = "vox_skin_tone"
	unarmed_attack_verb = "scratch"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/left/vox/Initialize(mapload)
	. = ..()
	style_icons = GLOB.vox_skin_tones
	add_bodypart_overlay(new /datum/bodypart_overlay/simple/vox_body_markings())

/obj/item/bodypart/arm/left/vox/get_unarmed_attack_verb()
	return pick("scratch", "claw")

/obj/item/bodypart/arm/right/vox
	icon_static = 'icons/mob/human/species/vox/bodyparts_lime.dmi'
	icon_husk = 'icons/mob/human/species/vox/husk.dmi'
	husk_type = "vox"
	husk_color = null
	limb_id = SPECIES_VOX
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_CUSTOM
	limb_style_feature = "vox_skin_tone"
	unarmed_attack_verb = "scratch"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/vox/Initialize(mapload)
	. = ..()
	style_icons = GLOB.vox_skin_tones
	add_bodypart_overlay(new /datum/bodypart_overlay/simple/vox_body_markings())

/obj/item/bodypart/arm/right/vox/get_unarmed_attack_verb()
	return pick("scratch", "claw")

/obj/item/bodypart/leg/left/vox
	icon_static = 'icons/mob/human/species/vox/bodyparts_lime.dmi'
	icon_husk = 'icons/mob/human/species/vox/husk.dmi'
	husk_type = "vox"
	husk_color = null
	limb_id = SPECIES_VOX
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_CUSTOM
	limb_style_feature = "vox_skin_tone"
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS

/obj/item/bodypart/leg/left/vox/Initialize(mapload)
	. = ..()
	style_icons = GLOB.vox_skin_tones
	add_bodypart_overlay(new /datum/bodypart_overlay/simple/vox_body_markings())

/obj/item/bodypart/leg/right/vox
	icon_static = 'icons/mob/human/species/vox/bodyparts_lime.dmi'
	icon_husk = 'icons/mob/human/species/vox/husk.dmi'
	husk_type = "vox"
	husk_color = null
	limb_id = SPECIES_VOX
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_CUSTOM
	limb_style_feature = "vox_skin_tone"
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS

/obj/item/bodypart/leg/right/vox/Initialize(mapload)
	. = ..()
	style_icons = GLOB.vox_skin_tones
	add_bodypart_overlay(new /datum/bodypart_overlay/simple/vox_body_markings())

/// Vox body markings. Every vox limb has one of these, which draws the part of the markings on that limb.
/// The sprites are dark, the mutant color gets added to them.
/datum/bodypart_overlay/simple/vox_body_markings
	icon = 'icons/mob/human/species/vox/body_markings.dmi'
	icon_state = null
	layers = list(EXTERNAL_ADJACENT = BODY_ADJ_LAYER)

/datum/bodypart_overlay/simple/vox_body_markings/added_to_limb(obj/item/bodypart/limb)
	RegisterSignal(limb, COMSIG_BODYPART_UPDATED, PROC_REF(on_limb_updated))

/datum/bodypart_overlay/simple/vox_body_markings/removed_from_limb(obj/item/bodypart/limb)
	UnregisterSignal(limb, COMSIG_BODYPART_UPDATED)

/// Takes the markings and their color from the limb's owner when their looks get applied. A severed limb keeps its markings.
/datum/bodypart_overlay/simple/vox_body_markings/proc/on_limb_updated(obj/item/bodypart/limb, dropping_limb, is_creating)
	SIGNAL_HANDLER
	if(!is_creating || !ishuman(limb.owner))
		return
	var/mob/living/carbon/human/human_owner = limb.owner
	var/datum/sprite_accessory/vox_body_markings/markings = GLOB.vox_body_markings_list[human_owner.dna.features["vox_body_markings"]]
	if(!istype(markings) || !(limb.body_zone in markings.body_slots))
		icon_state = null
		return
	icon_state = "m_[limb.body_zone]_[markings.icon_state]_ADJ"
	var/datum/color_palette/generic_colors/palette = human_owner.dna.color_palettes[/datum/color_palette/generic_colors]
	draw_color = palette?.return_color(MUTANT_COLOR)

/datum/bodypart_overlay/simple/vox_body_markings/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	return !isnull(icon_state) && !bodypart_owner.is_invisible

/datum/bodypart_overlay/simple/vox_body_markings/color_image(image/overlay, obj/item/bodypart/limb, layer_index)
	overlay.color = color_matrix_additive(draw_color)

/datum/bodypart_overlay/simple/vox_body_markings/generate_icon_cache()
	. = ..()
	. += "[draw_color]"
