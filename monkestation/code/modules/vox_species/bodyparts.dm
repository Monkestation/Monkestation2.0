// Vox limbs are not greyscale: every skin tone has its own icon file, picked in vox_update_limb().
// The procs live on the base type so that they can reach its protected icon vars.

/obj/item/bodypart
	/// Name of the vox body marking drawn on this limb, if it is a vox limb.
	var/vox_markings
	/// Color of the vox body marking.
	var/vox_markings_color

/// Takes skin tone and markings from the owner, if they are a vox.
/obj/item/bodypart/proc/vox_update_limb(is_creating)
	if(!is_creating || !owner?.dna || !isvox(owner))
		return
	var/list/features = owner.dna.features
	icon_static = GLOB.vox_skin_tones[features["vox_skin_tone"]] || initial(icon_static)
	vox_markings = features["vox_body_markings"]
	vox_markings_color = features["vox_body_markings_color"]

/// Returns a list with the body marking overlay of this limb.
/obj/item/bodypart/proc/vox_marking_overlays(dropped)
	. = list()
	if(is_husked || is_invisible || !vox_markings)
		return
	var/datum/sprite_accessory/vox_body_markings/markings = GLOB.vox_body_markings_list[vox_markings]
	if(!istype(markings) || !(body_zone in markings.body_slots))
		return
	var/image/overlay = image(markings.icon, "m_[body_zone]_[markings.icon_state]_ADJ", -BODY_ADJ_LAYER, dropped ? SOUTH : NONE)
	overlay.color = vox_additive_color(vox_markings_color)
	if(!dropped && !isnull(owner))
		owner.apply_height(overlay, ENTIRE_BODY)
	. += overlay

/obj/item/bodypart/proc/vox_icon_key()
	return "-[vox_markings]-[vox_markings_color]"

/obj/item/bodypart/head/vox
	icon_static = 'icons/mob/human/species/vox/bodyparts_lime.dmi'
	limb_id = SPECIES_VOX
	icon_husk = 'icons/mob/human/species/vox/husk.dmi'
	husk_type = "vox"
	husk_color = null
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_CUSTOM
	head_flags = HEAD_EYESPRITES | HEAD_EYECOLOR | HEAD_DEBRAIN

/obj/item/bodypart/head/vox/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	vox_update_limb(is_creating)

/obj/item/bodypart/head/vox/get_limb_icon(dropped, mob/living/carbon/update_on)
	. = ..()
	. += vox_marking_overlays(dropped)

/obj/item/bodypart/head/vox/generate_icon_key()
	. = ..()
	. += vox_icon_key()

/obj/item/bodypart/chest/vox
	icon_static = 'icons/mob/human/species/vox/bodyparts_lime.dmi'
	limb_id = SPECIES_VOX
	icon_husk = 'icons/mob/human/species/vox/husk.dmi'
	husk_type = "vox"
	husk_color = null
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_CUSTOM
	ass_image = 'icons/ass/assvox.png'

/obj/item/bodypart/chest/vox/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	vox_update_limb(is_creating)

/obj/item/bodypart/chest/vox/get_limb_icon(dropped, mob/living/carbon/update_on)
	. = ..()
	. += vox_marking_overlays(dropped)

/obj/item/bodypart/chest/vox/generate_icon_key()
	. = ..()
	. += vox_icon_key()

/obj/item/bodypart/arm/left/vox
	icon_static = 'icons/mob/human/species/vox/bodyparts_lime.dmi'
	limb_id = SPECIES_VOX
	icon_husk = 'icons/mob/human/species/vox/husk.dmi'
	husk_type = "vox"
	husk_color = null
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_CUSTOM
	unarmed_attack_verb = "scratch"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/left/vox/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	vox_update_limb(is_creating)

/obj/item/bodypart/arm/left/vox/get_limb_icon(dropped, mob/living/carbon/update_on)
	. = ..()
	. += vox_marking_overlays(dropped)

/obj/item/bodypart/arm/left/vox/generate_icon_key()
	. = ..()
	. += vox_icon_key()

/obj/item/bodypart/arm/right/vox
	icon_static = 'icons/mob/human/species/vox/bodyparts_lime.dmi'
	limb_id = SPECIES_VOX
	icon_husk = 'icons/mob/human/species/vox/husk.dmi'
	husk_type = "vox"
	husk_color = null
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_CUSTOM
	unarmed_attack_verb = "scratch"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/vox/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	vox_update_limb(is_creating)

/obj/item/bodypart/arm/right/vox/get_limb_icon(dropped, mob/living/carbon/update_on)
	. = ..()
	. += vox_marking_overlays(dropped)

/obj/item/bodypart/arm/right/vox/generate_icon_key()
	. = ..()
	. += vox_icon_key()

/obj/item/bodypart/leg/left/vox
	icon_static = 'icons/mob/human/species/vox/bodyparts_lime.dmi'
	limb_id = SPECIES_VOX
	icon_husk = 'icons/mob/human/species/vox/husk.dmi'
	husk_type = "vox"
	husk_color = null
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_CUSTOM
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS

/obj/item/bodypart/leg/left/vox/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	vox_update_limb(is_creating)

/obj/item/bodypart/leg/left/vox/get_limb_icon(dropped, mob/living/carbon/update_on)
	. = ..()
	. += vox_marking_overlays(dropped)

/obj/item/bodypart/leg/left/vox/generate_icon_key()
	. = ..()
	. += vox_icon_key()

/obj/item/bodypart/leg/right/vox
	icon_static = 'icons/mob/human/species/vox/bodyparts_lime.dmi'
	limb_id = SPECIES_VOX
	icon_husk = 'icons/mob/human/species/vox/husk.dmi'
	husk_type = "vox"
	husk_color = null
	should_draw_greyscale = FALSE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_CUSTOM
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS

/obj/item/bodypart/leg/right/vox/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	vox_update_limb(is_creating)

/obj/item/bodypart/leg/right/vox/get_limb_icon(dropped, mob/living/carbon/update_on)
	. = ..()
	. += vox_marking_overlays(dropped)

/obj/item/bodypart/leg/right/vox/generate_icon_key()
	. = ..()
	. += vox_icon_key()
