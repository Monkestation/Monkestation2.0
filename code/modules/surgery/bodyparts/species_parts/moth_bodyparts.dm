/obj/item/bodypart/head/moth
	icon_greyscale = 'icons/mob/species/moth/bodyparts_greyscale.dmi'
	icon_static = 'icons/mob/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	head_flags = HEAD_LIPS |HEAD_EYESPRITES |HEAD_EYEHOLES | HEAD_DEBRAIN | HEAD_HAIR
	bodypart_traits = list(TRAIT_ANTENNAE)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/chest/moth
	icon_greyscale = 'icons/mob/species/moth/bodyparts_greyscale.dmi'
	icon_static = 'icons/mob/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	is_dimorphic = TRUE
	should_draw_greyscale = FALSE
	wing_types = list(/obj/item/organ/external/wings/functional/moth/megamoth, /obj/item/organ/external/wings/functional/moth/mothra)
	bodypart_traits = list(TRAIT_TACKLING_WINGED_ATTACKER)
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/arm/left/moth
	icon_greyscale = 'icons/mob/species/moth/bodyparts_greyscale.dmi'
	icon_static = 'icons/mob/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/arm/right/moth
	icon_greyscale = 'icons/mob/species/moth/bodyparts_greyscale.dmi'
	icon_static = 'icons/mob/species/moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/leg/left/moth
	icon_greyscale = 'icons/mob/species/moth/bodyparts_greyscale.dmi'
	icon_static = 'icons/mob/species/moth/bodyparts.dmi'
	should_draw_greyscale = FALSE
	limb_id = SPECIES_MOTH
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR

/obj/item/bodypart/leg/right/moth
	icon_greyscale = 'icons/mob/species/moth/bodyparts_greyscale.dmi'
	icon_static = 'icons/mob/species/moth/bodyparts.dmi'
	should_draw_greyscale = FALSE
	limb_id = SPECIES_MOTH
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
