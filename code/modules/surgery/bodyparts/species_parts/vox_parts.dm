/obj/item/bodypart/head/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	is_dimorphic = FALSE
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	lip_style = NONE
	head_flags = null
	should_draw_greyscale = FALSE

/obj/item/bodypart/head/vox/Initialize(mapload)
	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_x = list(
			"east" = 5,
			"west" = -5,
		),
		offset_y = list(
			"north" = -2,
			"south" = -2,
			"east" = -1,
			"west" = -1,
		),
	)
	worn_ears_offset = new(
		attached_part = src,
		feature_key = OFFSET_EARS,
		offset_x = list(
			"east" = 2,
			"west" = -2,
		),
		offset_y = list(
			"north" = -1,
			"south" = -1,
			"east" = -1,
			"west" = -1,
		),
	)
	worn_glasses_offset = new(
		attached_part = src,
		feature_key = OFFSET_GLASSES,
		offset_x = list(
			"east" = 3,
			"west" = -3,
		),
		offset_y = list(
			"north" = -1,
			"south" = -1,
			"east" = -1,
			"west" = -1,
		),
	)
	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_x = list(
			"east" = 3,
			"west" = -3,
		),
	)
	return ..()

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
	bodypart_traits = list(TRAIT_QUICKER_CARRY)
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/vox/Initialize(mapload)
	held_hand_offset = new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list(
			"north" = -1,
			"south" = 1,
			"east" = 2,
			"west" = -2,
		),
		offset_y = list(
			"north" = -2,
			"south" = -2,
			"east" = -2,
			"west" = -2,
		),
	)
	return ..()

/obj/item/bodypart/arm/right/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	bodypart_traits = list(TRAIT_QUICKER_CARRY)
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/vox/Initialize(mapload)
	held_hand_offset = new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list(
			"north" = 1,
			"south" = -1,
			"east" = 2,
			"west" = -2,
		),
		offset_y = list(
			"north" = -2,
			"south" = -2,
			"east" = -2,
			"west" = -2,
		),
	)
	return ..()

/obj/item/bodypart/leg/left/vox
	icon_static = 'icons/mob/species/vox/bodyparts_voxazu.dmi'
	limb_id = SPECIES_VOX
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	composition_effects = list(TRAIT_COLD_BLOODED = 0.5)
	bodypart_traits = list(TRAIT_HARD_SOLES)
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
	bodypart_traits = list(TRAIT_HARD_SOLES)
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
	)

	should_draw_greyscale = FALSE
