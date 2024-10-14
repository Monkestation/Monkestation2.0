/datum/species/moth/tundra
	name = "\improper Tundra Moth"
	plural_form = "Tundra Moths"
	id = SPECIES_TUNDRA
	mutanteyes = /obj/item/organ/internal/eyes/moth/tundra
	external_organs = list(/obj/item/organ/external/wings/moth = "Tundra", /obj/item/organ/external/antennae = "Tundra")

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/tundramoth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/tundramoth,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/tundramoth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/tundramoth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/tundramoth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/tundramoth,
	)

	coldmod = 0.67
	heatmod = 1.5


//Body parts
/obj/item/bodypart/head/tundramoth
	icon = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	icon_state = "tundra_moth_head"
	icon_static = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	limb_id = SPECIES_TUNDRA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	head_flags = HEAD_LIPS |HEAD_EYESPRITES |HEAD_EYEHOLES | HEAD_DEBRAIN | HEAD_HAIR

/obj/item/bodypart/chest/tundramoth
	icon = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	icon_state = "tundra_moth_chest_m"
	icon_static = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	limb_id = SPECIES_TUNDRA
	is_dimorphic = TRUE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/tundramoth
	icon = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	icon_state = "tundra_moth_l_arm"
	icon_static = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	limb_id = SPECIES_TUNDRA
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/tundramoth
	icon = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	icon_state = "tundra_moth_r_arm"
	icon_static = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	limb_id = SPECIES_TUNDRA
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/tundramoth
	icon = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	icon_state = "tundra_moth_l_leg"
	icon_static = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	limb_id = SPECIES_TUNDRA
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/tundramoth
	icon = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	icon_state = "tundra_moth_r_leg"
	icon_static = 'monkestation/icons/mob/species/tundramoths/bodyparts.dmi'
	limb_id = SPECIES_TUNDRA
	should_draw_greyscale = FALSE

// Eyes
/obj/item/organ/internal/eyes/moth/tundra
	name = "tundra moth eyes"
	desc = "These eyes seem to have increased sensitivity to bright light, with no improvement to low light vision."
	eye_icon_state = "tundramotheyes"
	icon_state = "eyeballs-tundramoth"

// Wings, Antennae, and Markings

// Tundra
/datum/sprite_accessory/moth_wings/tundra
	name = "Tundra"
	icon = 'monkestation/icons/mob/species/tundramoths/moth_wings.dmi'
	icon_state = "tundra"

/datum/sprite_accessory/moth_antennae/tundra
	name = "Tundra"
	icon = 'monkestation/icons/mob/species/tundramoths/moth_antennae.dmi'
	icon_state = "tundra"

/datum/sprite_accessory/moth_markings/tundra
	name = "Tundra"
	icon = 'monkestation/icons/mob/species/tundramoths/moth_markings.dmi'
	icon_state = "tundra"

// Bluespace
/datum/sprite_accessory/moth_wings/bluespace
	icon = 'monkestation/icons/mob/species/tundramoths/moth_wings.dmi'
	name = "Bluespace"
	icon_state = "bluespace"

/datum/sprite_accessory/moth_antennae/bluespace
	name = "Bluespace"
	icon = 'monkestation/icons/mob/species/tundramoths/moth_antennae.dmi'
	icon_state = "bluespace"

// Twilight
/datum/sprite_accessory/moth_antennae/twilight
	name = "Twilight"
	icon = 'monkestation/icons/mob/species/tundramoths/moth_antennae.dmi'
	icon_state = "twilight"
