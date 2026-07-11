/obj/item/bodypart/head/ipc
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/mob/species/ipc/bodyparts.dmi'
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

	/// IPC head assembly parts are stored here until the completed chassis becomes a mob.
	var/obj/item/organ/internal/eyes/synth/ipc_eyes = null
	var/obj/item/organ/internal/ears/synth/ipc_ears = null
	var/obj/item/organ/internal/tongue/robot/synth/ipc_tongue = null
	var/obj/item/organ/external/antennae/ipc/antennae = null
	var/wired = FALSE
	var/secured = FALSE

/obj/item/bodypart/head/ipc/update_overlays()
	return ..()

/obj/item/bodypart/head/ipc/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == ipc_eyes)
		ipc_eyes = null
	if(gone == ipc_ears)
		ipc_ears = null
	if(gone == ipc_tongue)
		ipc_tongue = null
	if(gone == antennae)
		antennae = null

/obj/item/bodypart/head/ipc/Destroy()
	QDEL_NULL(ipc_eyes)
	QDEL_NULL(ipc_ears)
	QDEL_NULL(ipc_tongue)
	QDEL_NULL(antennae)
	return ..()

/obj/item/bodypart/head/ipc/examine(mob/user)
	. = ..()
	. += span_info("It has [ipc_eyes ? "optical sensors" : "no optical sensors"], [ipc_ears ? "synthetic ears" : "no synthetic ears"], [ipc_tongue ? "a synthetic tongue" : "no synthetic tongue"], and [antennae ? "IPC antennae" : "no IPC antennae"] installed. Its monitor is installed after the head is mounted onto a chassis.")
	. += span_info("It is [wired ? "wired" : "unwired"] and [secured ? "secured" : "unsecured"].")
	if(!secured)
		. += span_info("Install each head component, add <b>cable</b>, then use a <b>screwdriver</b> to secure it.")

/obj/item/bodypart/head/ipc/proc/check_completion()
	return ipc_eyes && ipc_ears && ipc_tongue && antennae && wired

/obj/item/bodypart/head/ipc/proc/drop_stored_parts(atom/drop_to = drop_location())
	ipc_eyes?.forceMove(drop_to)
	ipc_ears?.forceMove(drop_to)
	ipc_tongue?.forceMove(drop_to)
	antennae?.forceMove(drop_to)
	ipc_eyes = null
	ipc_ears = null
	ipc_tongue = null
	antennae = null

/obj/item/bodypart/head/ipc/proc/install_stored_organs(mob/living/carbon/receiver)
	if(ipc_eyes && !ipc_eyes.Insert(receiver, TRUE, FALSE))
		return FALSE
	ipc_eyes = null
	if(ipc_ears && !ipc_ears.Insert(receiver, TRUE, FALSE))
		return FALSE
	ipc_ears = null
	if(ipc_tongue && !ipc_tongue.Insert(receiver, TRUE, FALSE))
		return FALSE
	ipc_tongue = null
	if(antennae && !antennae.Insert(receiver, TRUE, FALSE))
		return FALSE
	antennae = null
	return TRUE

/obj/item/bodypart/head/ipc/attackby(obj/item/weapon, mob/user, params)
	if(secured)
		return ..()

	if(istype(weapon, /obj/item/organ/internal/eyes/synth))
		if(ipc_eyes)
			to_chat(user, span_warning("[src] already has optical sensors installed!"))
			return
		if(!user.transferItemToLoc(weapon, src))
			return
		ipc_eyes = weapon
		to_chat(user, span_notice("You install [weapon] into [src]."))
		update_appearance()
		return

	if(istype(weapon, /obj/item/organ/internal/ears/synth))
		if(ipc_ears)
			to_chat(user, span_warning("[src] already has synthetic ears installed!"))
			return
		if(!user.transferItemToLoc(weapon, src))
			return
		ipc_ears = weapon
		to_chat(user, span_notice("You install [weapon] into [src]."))
		update_appearance()
		return

	if(istype(weapon, /obj/item/organ/internal/tongue/robot/synth))
		if(ipc_tongue)
			to_chat(user, span_warning("[src] already has a synthetic tongue installed!"))
			return
		if(!user.transferItemToLoc(weapon, src))
			return
		ipc_tongue = weapon
		to_chat(user, span_notice("You install [weapon] into [src]."))
		update_appearance()
		return

	if(istype(weapon, /obj/item/organ/external/ipc_screen))
		to_chat(user, span_warning("The IPC screen is installed into the completed chassis last."))
		return

	if(istype(weapon, /obj/item/organ/external/antennae/ipc))
		if(antennae)
			to_chat(user, span_warning("[src] already has IPC antennae installed!"))
			return
		if(!user.transferItemToLoc(weapon, src))
			return
		antennae = weapon
		to_chat(user, span_notice("You install [weapon] into [src]."))
		update_appearance()
		return

	if(istype(weapon, /obj/item/stack/cable_coil))
		if(wired)
			to_chat(user, span_warning("[src] is already wired!"))
			return
		var/obj/item/stack/cable_coil/coil = weapon
		if(coil.use(1))
			wired = TRUE
			to_chat(user, span_notice("You wire [src]."))
			return
		to_chat(user, span_warning("You need one length of cable to wire [src]!"))
		return

	return ..()

/obj/item/bodypart/head/ipc/screwdriver_act(mob/living/user, obj/item/screwtool)
	if(secured)
		if(!screwtool.use_tool(src, user, 5, volume = 50))
			return ITEM_INTERACT_BLOCKING
		secured = FALSE
		to_chat(user, span_notice("You unsecure [src]."))
		return ITEM_INTERACT_SUCCESS

	if(!check_completion())
		to_chat(user, span_warning("[src] needs optical sensors, synthetic ears, a synthetic tongue, IPC antennae, and wiring before it can be secured."))
		return ITEM_INTERACT_BLOCKING
	if(!screwtool.use_tool(src, user, 5, volume = 50))
		return ITEM_INTERACT_BLOCKING
	secured = TRUE
	to_chat(user, span_notice("You secure [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/item/bodypart/head/ipc/wirecutter_act(mob/living/user, obj/item/cutter)
	. = ..()
	if(!wired)
		return
	if(secured)
		to_chat(user, span_warning("You need to unsecure [src] first!"))
		return TRUE
	. = TRUE
	cutter.play_tool_sound(src)
	to_chat(user, span_notice("You cut the wires out of [src]."))
	new /obj/item/stack/cable_coil(drop_location(), 1)
	wired = FALSE

/obj/item/bodypart/head/ipc/crowbar_act(mob/living/user, obj/item/prytool)
	. = ..()
	if(secured)
		to_chat(user, span_warning("You need to unsecure [src] first!"))
		return TRUE
	if(!ipc_eyes && !ipc_ears && !ipc_tongue && !antennae)
		to_chat(user, span_warning("There are no components to remove from [src]."))
		return TRUE
	prytool.play_tool_sound(src)
	to_chat(user, span_notice("You pry the components out of [src]."))
	drop_stored_parts()
	update_appearance()
	return TRUE

/obj/item/bodypart/head/ipc/drop_organs(mob/user, violent_removal)
	var/atom/drop_loc = drop_location()
	drop_stored_parts(drop_loc)
	if(wired)
		new /obj/item/stack/cable_coil(drop_loc, 1)
		wired = FALSE
	return ..()

/obj/item/bodypart/chest/ipc
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/mob/species/ipc/bodyparts.dmi'
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

/obj/item/bodypart/chest/ipc/update_overlays()
	return ..()

/obj/item/bodypart/arm/left/ipc
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/mob/species/ipc/bodyparts.dmi'
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
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/mob/species/ipc/bodyparts.dmi'
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
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/mob/species/ipc/bodyparts.dmi'
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
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/mob/species/ipc/bodyparts.dmi'
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
