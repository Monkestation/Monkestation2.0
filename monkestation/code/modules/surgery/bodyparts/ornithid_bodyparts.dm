
// defines limbs/bodyparts.
/obj/item/bodypart/head/ornithid
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE

/obj/item/bodypart/arm/left/ornithid
	limb_id = SPECIES_ORNITHID
	icon_greyscale = 'monkestation/code/modules/the_bird_inside_of_me/icons/ornithid_parts_greyscale.dmi'
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE


/obj/item/bodypart/arm/right/ornithid
	limb_id = SPECIES_ORNITHID
	icon_greyscale = 'monkestation/code/modules/the_bird_inside_of_me/icons/ornithid_parts_greyscale.dmi'
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slice.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE

/obj/item/bodypart/chest/ornithid
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE
	acceptable_bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE

/obj/item/bodypart/leg/left/ornithid
	limb_id = SPECIES_ORNITHID
	digitigrade_id = SPECIES_ORNITHID
	icon_greyscale = 'monkestation/code/modules/the_bird_inside_of_me/icons/ornithid_parts_greyscale.dmi'
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE
	bodypart_traits = list(TRAIT_HARD_SOLES, TRAIT_NON_IMPORTANT_SHOE_BLOCK)
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
		'sound/effects/footstep/hardclaw1.ogg',
	)

/obj/item/bodypart/leg/right/ornithid
	limb_id = SPECIES_ORNITHID
	digitigrade_id = SPECIES_ORNITHID
	icon_greyscale = 'monkestation/code/modules/the_bird_inside_of_me/icons/ornithid_parts_greyscale.dmi'
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_DIGITIGRADE
	bodypart_traits = list(TRAIT_HARD_SOLES, TRAIT_NON_IMPORTANT_SHOE_BLOCK)
	step_sounds = list(
		'sound/effects/footstep/hardclaw1.ogg',
		'sound/effects/footstep/hardclaw2.ogg',
		'sound/effects/footstep/hardclaw3.ogg',
		'sound/effects/footstep/hardclaw4.ogg',
		'sound/effects/footstep/hardclaw1.ogg',
	)
