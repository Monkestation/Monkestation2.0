// Vox limbs are not greyscale: every skin tone has its own icon file, picked in vox_update_limb().
// The procs live on the base type so that they can reach its protected icon vars.

/obj/item/bodypart
	/// Name of the vox body marking drawn on this limb, if it is a vox limb.
	var/vox_markings
	/// Color of the vox body marking.
	var/vox_markings_color

/// Returns the verb for a single unarmed attack with this limb. Lets a limb pick from several verbs, like Yogstation's attack_verbs.
/obj/item/bodypart/proc/get_unarmed_attack_verb()
	return unarmed_attack_verb

/obj/item/bodypart/arm/left/vox/get_unarmed_attack_verb()
	return pick("scratch", "claw")

/obj/item/bodypart/arm/right/vox/get_unarmed_attack_verb()
	return pick("scratch", "claw")

/// Takes skin tone and markings from the owner, if they are a vox.
/obj/item/bodypart/proc/vox_update_limb(is_creating)
	if(!owner?.dna || !isvox(owner))
		return
	// Quill colors and gradients are hair colors and gradients, as on Yogstation, so they follow the head on every update (dye and all).
	for(var/datum/bodypart_overlay/mutant/vox_quills/quills_overlay in bodypart_overlays)
		quills_overlay.update_from_head(src)
	if(!is_creating)
		return
	var/list/features = owner.dna.features
	icon_static = GLOB.vox_skin_tones[features["vox_skin_tone"]] || initial(icon_static)
	vox_markings = features["vox_body_markings"]
	vox_markings_color = features["vox_body_markings_color"]
	// Our tail and quills follow the owner's features too, which is what lets the character preview show changes to them.
	for(var/datum/bodypart_overlay/mutant/overlay in bodypart_overlays)
		var/datum/bodypart_overlay/mutant/tail/vox/tail_overlay = overlay
		var/datum/bodypart_overlay/mutant/vox_quills/quills_overlay = overlay
		if(istype(tail_overlay))
			tail_overlay.update_from_owner(owner) // does nothing for a transplanted tail
			continue
		if(!istype(quills_overlay))
			continue
		var/feature_name = features[overlay.feature_key]
		if(feature_name in overlay.get_global_feature_list())
			overlay.set_appearance_from_name(feature_name)
		else
			overlay.cache_key = jointext(overlay.generate_icon_cache(), "_")

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
	head_flags = HEAD_EYESPRITES | HEAD_EYECOLOR | HEAD_EYEHOLES | HEAD_DEBRAIN

/obj/item/bodypart/head/vox/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	vox_update_limb(is_creating)

/obj/item/bodypart/head/vox/get_limb_icon(dropped, mob/living/carbon/update_on)
	. = ..()
	// A dropped eyeless head also gets the human empty sockets drawn by head.dm. Ours come from get_eyeless_overlay().
	if(dropped)
		for(var/image/overlay in .)
			if(overlay.icon == 'icons/mob/species/human/human_face.dmi' && overlay.icon_state == "eyes_missing")
				. -= overlay
	. += vox_marking_overlays(dropped)

/// Vox empty eye sockets, like on Yogstation. They also cover the eye static drawn into the head sprite.
/obj/item/bodypart/head/vox/get_eyeless_overlay(can_rotate = TRUE)
	var/image/eyeless_overlay = ..()
	eyeless_overlay.icon = 'icons/mob/human/species/vox/eyes.dmi'
	return eyeless_overlay

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
