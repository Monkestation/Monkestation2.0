/obj/item/bodypart/head/ipc
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth" //Overriden in /species/ipc/replace_body()
	icon_state = "synth_head"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	biological_state = BIO_ROBOTIC | BIO_BLOODED
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	head_flags = HEAD_HAIR |  HEAD_LIPS | HEAD_EYECOLOR | HEAD_LIPS
	brute_modifier = 1.2
	burn_modifier = 1.2

	body_damage_coeff = 0.75	//IPC's Head can dismember
	max_damage = 70	//Keep in mind that this value is used in the
	dmg_overlay_type = "synth"

	disabling_threshold_percentage = 1

	biological_state = (BIO_ROBOTIC|BIO_JOINTED)

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)

/obj/item/bodypart/chest/ipc
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	icon_state = "synth_chest"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	biological_state = BIO_ROBOTIC | BIO_BLOODED
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	bodypart_traits = list(TRAIT_LIMBATTACHMENT)
	wing_types = list(/obj/item/organ/external/wings/functional/robotic)
	body_damage_coeff = 1	//IPC Chest at default
	max_damage = 340	//Default: 200
	brute_modifier = 1.2
	burn_modifier = 1.2

	dmg_overlay_type = "synth"

	disabling_threshold_percentage = 1

	biological_state = (BIO_ROBOTIC)

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)

/obj/item/bodypart/arm/left/ipc
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	icon_state = "synth_l_arm"
	flags_1 = CONDUCT_1
	should_draw_greyscale = FALSE
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	biological_state = BIO_ROBOTIC | BIO_JOINTED | BIO_BLOODED
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	brute_modifier = 1.2
	burn_modifier = 1.2

	hp_percent_to_dismemberable = 0.6

	dmg_overlay_type = "synth"

	disabling_threshold_percentage = 1

	biological_state = (BIO_ROBOTIC|BIO_JOINTED)

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)

/obj/item/bodypart/arm/right/ipc
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	icon_state = "synth_r_arm"
	flags_1 = CONDUCT_1
	should_draw_greyscale = FALSE
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	biological_state = BIO_ROBOTIC | BIO_JOINTED | BIO_BLOODED
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	brute_modifier = 1.2
	burn_modifier = 1.2

	hp_percent_to_dismemberable = 0.6

	dmg_overlay_type = "synth"

	disabling_threshold_percentage = 1

	biological_state = (BIO_ROBOTIC|BIO_JOINTED)

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)

/obj/item/bodypart/leg/left/ipc
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	icon_state = "synth_l_leg"
	flags_1 = CONDUCT_1
	should_draw_greyscale = FALSE
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	biological_state = BIO_ROBOTIC | BIO_JOINTED | BIO_BLOODED
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	brute_modifier = 1.2
	burn_modifier = 1.2

	dmg_overlay_type = "synth"
	step_sounds = list('sound/effects/servostep.ogg')

	disabling_threshold_percentage = 1

	biological_state = (BIO_ROBOTIC|BIO_JOINTED)

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)

/obj/item/bodypart/leg/right/ipc
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth"
	icon_state = "synth_r_leg"
	flags_1 = CONDUCT_1
	should_draw_greyscale = FALSE
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR
	biological_state = BIO_ROBOTIC | BIO_JOINTED | BIO_BLOODED
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	brute_modifier = 1.2
	burn_modifier = 1.2


	dmg_overlay_type = "synth"
	step_sounds = list('sound/effects/servostep.ogg')

	disabling_threshold_percentage = 1

	biological_state = (BIO_ROBOTIC|BIO_JOINTED)

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)
