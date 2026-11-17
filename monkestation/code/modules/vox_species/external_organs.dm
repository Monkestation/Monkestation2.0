GLOBAL_LIST_EMPTY(vox_quills_list)
GLOBAL_LIST_EMPTY(vox_facial_quills_list)
GLOBAL_LIST_EMPTY(tails_list_vox)
GLOBAL_LIST_EMPTY(vox_tail_markings_list)
GLOBAL_LIST_EMPTY(vox_body_markings_list)

// Tail. Its sprite follows the skin tone, and it can have (additively colored) markings on top.

/obj/item/organ/external/tail/vox
	name = "vox tail"
	desc = "A severed vox tail. Somewhere, no doubt, a vox hater is very pleased with themselves."
	icon = 'icons/mob/human/species/vox/tails.dmi'
	icon_state = "m_tail_vox_lime_BEHIND"
	preference = "feature_vox_skin_tone"
	dna_block = DNA_VOX_SKIN_TONE_BLOCK
	wag_flags = WAG_ABLE
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/vox

/obj/item/organ/external/tail/vox/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	var/datum/bodypart_overlay/mutant/tail/vox/overlay = bodypart_overlay
	if(receiver?.dna)
		// Like on Yogstation, the first one to wear a tail (or anyone, once they are gone) becomes its original owner.
		if(!overlay.original_owner?.resolve())
			overlay.original_owner = WEAKREF(receiver)
		overlay.update_from_owner(receiver)
		overlay.imprint_on_next_insertion = FALSE // the sprite comes from the skin tone, not a tail feature
	return ..()

/obj/item/organ/external/tail/vox/Initialize(mapload, accessory_type)
	. = ..()
	if(!accessory_type && loc) // spawned on its own (loot, limbgrower): lime until someone wears it, like on Yogstation
		bodypart_overlay.set_appearance_from_name("lime")
	update_appearance()

/obj/item/organ/external/tail/vox/Remove(mob/living/carbon/organ_owner, special, moving)
	. = ..()
	update_appearance()

/obj/item/organ/external/tail/vox/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	color = null // the sprite already has its colors, see update_overlays()

/// Like on Yogstation, a severed tail looks like the tail it was: skin tone and markings.
/obj/item/organ/external/tail/vox/update_icon_state()
	. = ..()
	var/datum/sprite_accessory/tail_sprite = bodypart_overlay.sprite_datum
	icon_state = "m_tail_vox_[tail_sprite?.icon_state || "lime"]_BEHIND"

/obj/item/organ/external/tail/vox/update_overlays()
	. = ..()
	var/datum/bodypart_overlay/mutant/tail/vox/overlay = bodypart_overlay
	var/datum/sprite_accessory/vox_tail_markings/markings_datum = GLOB.vox_tail_markings_list[overlay.markings]
	if(!istype(markings_datum) || markings_datum.name == SPRITE_ACCESSORY_NONE)
		return
	var/mutable_appearance/markings_overlay = mutable_appearance(markings_datum.icon, "m_vox_tail_markings_[markings_datum.icon_state]_BEHIND")
	markings_overlay.color = vox_additive_color(overlay.markings_color)
	. += markings_overlay

/obj/item/organ/external/tail/vox/mutate_feature(features, mob/living/carbon/human/human)
	var/datum/bodypart_overlay/mutant/tail/vox/overlay = bodypart_overlay
	if(overlay.original_owner?.resolve() != human)
		return // someone else's tail keeps looking like theirs
	. = ..()
	overlay.markings = human.dna.features["vox_tail_markings"]

/datum/bodypart_overlay/mutant/tail/vox
	feature_key = "tail_vox" // only names the icon states, the sprite is picked by the "vox_skin_tone" feature
	/// Name of the tail markings accessory drawn over the tail.
	var/markings
	/// Color of the tail markings.
	var/markings_color
	/// Weakref to the mob this tail grew on. The tail only follows the looks of its original owner, so a transplanted tail keeps its own (as on Yogstation).
	var/datum/weakref/original_owner

/// Takes skin tone and tail markings from the given mob, if this tail grew on them.
/datum/bodypart_overlay/mutant/tail/vox/proc/update_from_owner(mob/living/carbon/tail_owner)
	if(!tail_owner?.dna || original_owner?.resolve() != tail_owner)
		return FALSE
	var/list/features = tail_owner.dna.features
	var/skin_tone = features["vox_skin_tone"]
	if(!(skin_tone in GLOB.tails_list_vox))
		skin_tone = "lime" // a non-vox growing a vox tail
	markings = features["vox_tail_markings"]
	markings_color = features["vox_tail_markings_color"]
	set_appearance_from_name(skin_tone)
	return TRUE

/datum/bodypart_overlay/mutant/tail/vox/get_global_feature_list()
	return GLOB.tails_list_vox

/datum/bodypart_overlay/mutant/tail/vox/get_extended_overlay(obj/item/bodypart/limb, layer_index, layer_real)
	var/datum/sprite_accessory/vox_tail_markings/markings_datum = GLOB.vox_tail_markings_list[markings]
	if(!istype(markings_datum) || markings_datum.name == SPRITE_ACCESSORY_NONE)
		return null
	var/mutable_appearance/overlay = mutable_appearance(
		markings_datum.icon,
		"m_[wagging ? "wagging_" : ""]vox_tail_markings_[markings_datum.icon_state]_[layer_index]",
		layer = layer_real,
	)
	overlay.color = vox_additive_color(markings_color)
	return list(overlay)

/datum/bodypart_overlay/mutant/tail/vox/generate_icon_cache()
	. = ..()
	. += "[markings]"
	. += "[markings_color]"

/datum/sprite_accessory/tails/vox
	icon = 'icons/mob/human/species/vox/tails.dmi'
	color_src = null

/datum/sprite_accessory/tails/vox/azure
	name = "azure"
	icon_state = "azure"

/datum/sprite_accessory/tails/vox/brown
	name = "brown"
	icon_state = "brown"

/datum/sprite_accessory/tails/vox/crimson
	name = "crimson"
	icon_state = "crimson"

/datum/sprite_accessory/tails/vox/emerald
	name = "emerald"
	icon_state = "emerald"

/datum/sprite_accessory/tails/vox/grey
	name = "grey"
	icon_state = "grey"

/datum/sprite_accessory/tails/vox/lime
	name = "lime"
	icon_state = "lime"

/datum/sprite_accessory/tails/vox/mossy
	name = "mossy"
	icon_state = "mossy"

/datum/sprite_accessory/tails/vox/nebula
	name = "nebula"
	icon_state = "nebula"

/datum/sprite_accessory/tails/vox/plum
	name = "plum"
	icon_state = "plum"

/datum/sprite_accessory/vox_tail_markings
	icon = 'icons/mob/human/species/vox/tail_markings.dmi'

/datum/sprite_accessory/vox_tail_markings/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"

/datum/sprite_accessory/vox_tail_markings/bands
	name = "Bands"
	icon_state = "bands"

/datum/sprite_accessory/vox_tail_markings/tip
	name = "Tip"
	icon_state = "tip"

/datum/sprite_accessory/vox_tail_markings/stripe
	name = "Stripe"
	icon_state = "stripe"

// Body markings. Not an organ: vox limbs draw these themselves, see vox_marking_overlays().

/datum/sprite_accessory/vox_body_markings
	icon = 'icons/mob/human/species/vox/body_markings.dmi'

/datum/sprite_accessory/vox_body_markings/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"

/datum/sprite_accessory/vox_body_markings/heart
	name = "Heart"
	icon_state = "heart"
	body_slots = list(BODY_ZONE_R_ARM)

/datum/sprite_accessory/vox_body_markings/hive
	name = "Hive"
	icon_state = "hive"
	body_slots = list(BODY_ZONE_CHEST)

/datum/sprite_accessory/vox_body_markings/nightling
	name = "Nightling"
	icon_state = "nightling"
	body_slots = list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

/datum/sprite_accessory/vox_body_markings/tiger
	name = "Tiger-stripe"
	icon_state = "tiger"
	body_slots = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

// Quills, the vox equivalent of hair. Drawn on the hair layer and hidden by the same things that hide hair.

/obj/item/organ/external/vox_quills
	name = "vox quills"
	desc = "A bundle of quills, plucked from a vox's head."
	icon = 'icons/obj/species/vox/organs.dmi'
	icon_state = "quills"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_VOX_QUILLS
	preference = "feature_vox_quills"
	dna_block = DNA_VOX_QUILLS_BLOCK
	bodypart_overlay = /datum/bodypart_overlay/mutant/vox_quills

/datum/bodypart_overlay/mutant/vox_quills
	layers = list(EXTERNAL_ADJACENT = HAIR_LAYER)
	feature_key = "vox_quills"
	color_source = ORGAN_COLOR_OVERRIDE
	offset_location = UPPER_BODY
	/// If the owner has this slot obscured, we do not draw.
	var/hidden_by = HIDEHAIR
	/// Whether the hair gradient is drawn over us. Like on Yogstation, only the head quills get it.
	var/uses_gradient = TRUE
	/// Name of the hair gradient drawn over the quills.
	var/gradient_style
	/// Color of the gradient.
	var/gradient_color

/datum/bodypart_overlay/mutant/vox_quills/get_extended_overlay(obj/item/bodypart/limb, layer_index, layer_real)
	return null

/// The gradient is drawn inside the quills, the same way Yogstation does it: an inset overlay on top of the (additively colored) quills.
/datum/bodypart_overlay/mutant/vox_quills/get_overlay(obj/item/bodypart/limb, layer_index, layer_real)
	. = ..()
	var/datum/sprite_accessory/gradient = GLOB.hair_gradients_list[gradient_style]
	if(!istype(gradient) || gradient.name == SPRITE_ACCESSORY_NONE || !gradient.icon_state || !gradient_color)
		return
	var/mutable_appearance/quills_base = .
	if(!istype(quills_base))
		return
	var/mutable_appearance/quills_overlay = mutable_appearance(layer = layer_real)
	quills_overlay.appearance_flags |= KEEP_TOGETHER
	quills_base.layer = FLOAT_LAYER
	quills_overlay.overlays += quills_base
	var/mutable_appearance/gradient_quills = mutable_appearance(gradient.icon, gradient.icon_state)
	gradient_quills.color = list(COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, sanitize_hexcolor(gradient_color, include_crunch = TRUE))
	gradient_quills.blend_mode = BLEND_INSET_OVERLAY
	quills_overlay.overlays += gradient_quills
	return quills_overlay

/datum/bodypart_overlay/mutant/vox_quills/generate_icon_cache()
	. = ..()
	. += "[gradient_style]"
	. += "[gradient_color]"

/datum/bodypart_overlay/mutant/vox_quills/get_global_feature_list()
	return GLOB.vox_quills_list

/// Takes the hair color and hair gradient of the head we are drawn on.
/datum/bodypart_overlay/mutant/vox_quills/proc/update_from_head(obj/item/bodypart/head/head)
	var/old_color = draw_color
	inherit_color(head, force = TRUE)
	var/new_style
	var/new_color
	if(uses_gradient && istype(head))
		new_style = LAZYACCESS(head.gradient_styles, GRADIENT_HAIR_KEY)
		new_color = LAZYACCESS(head.gradient_colors, GRADIENT_HAIR_KEY)
	if(old_color == draw_color && new_style == gradient_style && new_color == gradient_color)
		return
	gradient_style = new_style
	gradient_color = new_color
	cache_key = jointext(generate_icon_cache(), "_")

/// Quills are colored by hair color, as on Yogstation, so hair dye, dye sprays and DNA all work on them.
/datum/bodypart_overlay/mutant/vox_quills/override_color(obj/item/bodypart/bodypart_owner)
	var/obj/item/bodypart/head/head = bodypart_owner
	if(!istype(head))
		return draw_color || COLOR_DARKER_BROWN
	return head.override_hair_color || head.fixed_hair_color || get_quill_color(head) || COLOR_DARKER_BROWN

/// The color of the hair these quills take after.
/datum/bodypart_overlay/mutant/vox_quills/proc/get_quill_color(obj/item/bodypart/head/head)
	return head.hair_color

/datum/bodypart_overlay/mutant/vox_quills/color_image(image/overlay, obj/item/bodypart/limb, layer_index, key_name)
	overlay.color = vox_additive_color(draw_color)

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
	uses_gradient = FALSE
	hidden_by = HIDEFACIALHAIR

/datum/bodypart_overlay/mutant/vox_quills/facial/get_quill_color(obj/item/bodypart/head/head)
	return head.facial_hair_color

/datum/bodypart_overlay/mutant/vox_quills/facial/get_global_feature_list()
	return GLOB.vox_facial_quills_list

/datum/sprite_accessory/vox_quills
	icon = 'icons/mob/human/species/vox/quills.dmi'

/datum/sprite_accessory/vox_quills/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"

/datum/sprite_accessory/vox_quills/crested
	name = "Crested"
	icon_state = "crested"

/datum/sprite_accessory/vox_quills/emperor
	name = "Emperor"
	icon_state = "emperor"

/datum/sprite_accessory/vox_quills/keel
	name = "Keel"
	icon_state = "keel"

/datum/sprite_accessory/vox_quills/keet
	name = "Keet"
	icon_state = "keet"

/datum/sprite_accessory/vox_quills/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/vox_quills/tiel
	name = "Tiel"
	icon_state = "tiel"

/datum/sprite_accessory/vox_quills/kingly
	name = "Kingly"
	icon_state = "kingly"

/datum/sprite_accessory/vox_quills/afro
	name = "Fluffy"
	icon_state = "afro"

/datum/sprite_accessory/vox_quills/yasuhiro
	name = "Long"
	icon_state = "yasuhiro"

/datum/sprite_accessory/vox_quills/razor
	name = "Razorback"
	icon_state = "razor"

/datum/sprite_accessory/vox_quills/razor_clipped
	name = "Clipped Razorback"
	icon_state = "razor_clipped"

/datum/sprite_accessory/vox_quills/long_braid
	name = "Long Braided"
	icon_state = "long_braid"

/datum/sprite_accessory/vox_quills/short_braid
	name = "Short Braided"
	icon_state = "short_braid"

/datum/sprite_accessory/vox_quills/mohawk
	name = "Mohawk"
	icon_state = "mohawk"

/datum/sprite_accessory/vox_quills/hawk
	name = "Hawk"
	icon_state = "hawk"

/datum/sprite_accessory/vox_quills/horns
	name = "Horns"
	icon_state = "horns"

/datum/sprite_accessory/vox_quills/mange
	name = "Mange"
	icon_state = "mange"

/datum/sprite_accessory/vox_quills/ponytail
	name = "Ponytail"
	icon_state = "ponytail"

/datum/sprite_accessory/vox_quills/rows
	name = "Rows"
	icon_state = "rows"

/datum/sprite_accessory/vox_quills/surf
	name = "Surf"
	icon_state = "surf"

/datum/sprite_accessory/vox_quills/flowing
	name = "Flowing"
	icon_state = "flowing"

/datum/sprite_accessory/vox_quills/nights
	name = "Nights"
	icon_state = "nights"

/datum/sprite_accessory/vox_quills/cropped
	name = "Cropped"
	icon_state = "cropped"

/datum/sprite_accessory/vox_facial_quills
	icon = 'icons/mob/human/species/vox/facial_quills.dmi'

/datum/sprite_accessory/vox_facial_quills/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"

/datum/sprite_accessory/vox_facial_quills/colonel
	name = "Colonel"
	icon_state = "colonel"

/datum/sprite_accessory/vox_facial_quills/fu
	name = "Fu"
	icon_state = "fu"

/datum/sprite_accessory/vox_facial_quills/neck
	name = "Neck"
	icon_state = "neck"

/datum/sprite_accessory/vox_facial_quills/beard
	name = "Beard"
	icon_state = "beard"

/datum/sprite_accessory/vox_facial_quills/ruff
	name = "Ruff"
	icon_state = "ruff"
