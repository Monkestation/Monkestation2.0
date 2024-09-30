// Parts used by tundra moths
/obj/item/bodypart/head/tmoth
	icon = 'icons/mob/species/tundra_moth/bodyparts.dmi'
	icon_state = "tmoth_head"
	icon_static = 'icons/mob/species/tundra_moth/bodyparts.dmi'
	limb_id = SPECIES_TMOTH
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	head_flags = HEAD_LIPS |HEAD_EYESPRITES |HEAD_EYEHOLES | HEAD_DEBRAIN | HEAD_HAIR

/obj/item/bodypart/chest/tmoth
	icon = 'icons/mob/species/tundra_moth/bodyparts.dmi'
	icon_state = "tmoth_chest_m"
	icon_static = 'icons/mob/species/tundra_moth/bodyparts.dmi'
	limb_id = SPECIES_MOTH
	is_dimorphic = TRUE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/tmoth
	icon = 'icons/mob/species/tundra_moth/bodyparts.dmi'
	icon_state = "tmoth_l_arm"
	icon_static = 'icons/mob/species/tundra_moth/bodyparts.dmi'
	limb_id = SPECIES_TMOTH
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/tmoth
	icon = 'icons/mob/species/tundra_moth/bodyparts.dmi'
	icon_state = "tmoth_r_arm"
	icon_static = 'icons/mob/species/tundra_moth/bodyparts.dmi'
	limb_id = SPECIES_TMOTH
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/tmoth
	icon = 'icons/mob/species/tundra_moth/bodyparts.dmi'
	icon_state = "tmoth_l_leg"
	icon_static = 'icons/mob/species/tundra_moth/bodyparts.dmi'
	limb_id = SPECIES_TMOTH
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/tmoth
	icon = 'icons/mob/species/tundra_moth/bodyparts.dmi'
	icon_state = "tmoth_r_leg"
	icon_static = 'icons/mob/species/tundra_moth/bodyparts.dmi'
	limb_id = SPECIES_TMOTH
	should_draw_greyscale = FALSE
