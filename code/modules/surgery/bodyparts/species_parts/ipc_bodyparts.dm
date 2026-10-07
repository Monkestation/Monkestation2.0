/obj/item/bodypart/head/ipc
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_greyscale = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_static = 'icons/mob/species/ipc/bodyparts.dmi'
	limb_id = "synth" //Overridden in /species/ipc/replace_body()
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

	body_damage_coeff = 0.75 //IPC's Head can dismember
	max_damage = 70	//Keep in mind that this value is used in the
	dmg_overlay_type = "synth"

	disabling_threshold_percentage = 1

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)

	/// IPC antennae stored in the head during construction or after beheading.
	var/obj/item/organ/external/antennae/ipc/antennae = null
	/// Screen stored in a detached IPC head.
	var/obj/item/organ/external/ipc_screen/screen = null
	/// Whether the IPC head assembly has been wired.
	var/wired = FALSE
	/// Whether the IPC head assembly has been secured.
	var/secured = FALSE

/obj/item/bodypart/head/ipc/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/organ/external/antennae/ipc))
		antennae = arrived
	if(istype(arrived, /obj/item/organ/external/ipc_screen))
		screen = arrived

/obj/item/bodypart/head/ipc/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == antennae)
		antennae = null
	if(gone == screen)
		screen = null
	if(secured && !check_completion())
		secured = FALSE

/obj/item/bodypart/head/ipc/Destroy()
	QDEL_NULL(antennae)
	QDEL_NULL(screen)
	return ..()

/obj/item/bodypart/head/ipc/examine(mob/user)
	. = ..()
	. += span_info("It has [eyes ? "optical sensors" : "no optical sensors"], [ears ? "synthetic ears" : "no synthetic ears"], [tongue ? "a synthetic tongue" : "no synthetic tongue"], and [antennae ? "IPC antennae" : "no IPC antennae"] installed. [screen ? "Its monitor is installed." : "Its monitor is installed after the head is mounted onto a chassis."]")
	. += span_info("It is [wired ? "wired" : "unwired"] and [secured ? "secured" : "unsecured"].")
	if(!secured)
		. += span_info("Install each head component, add " + EXAMINE_HINT("cable") + ", then use a " + EXAMINE_HINT("screwdriver") + " to secure it.")

/// Returns whether the IPC head contains every required component and wiring.
/obj/item/bodypart/head/ipc/proc/check_completion()
	return eyes && ears && tongue && antennae && wired

/// Drops every component stored in the IPC head assembly.
/obj/item/bodypart/head/ipc/proc/drop_stored_parts(atom/drop_to = drop_location())
	eyes?.forceMove(drop_to)
	ears?.forceMove(drop_to)
	tongue?.forceMove(drop_to)
	antennae?.forceMove(drop_to)
	screen?.forceMove(drop_to)
	eyes = null
	ears = null
	tongue = null
	antennae = null
	secured = FALSE

/// Installs every stored head component into the completed IPC body.
/obj/item/bodypart/head/ipc/proc/install_stored_organs(mob/living/carbon/receiver)
	. = TRUE
	if(eyes && !eyes.Insert(receiver, TRUE, FALSE))
		. = FALSE
	eyes = null
	if(ears && !ears.Insert(receiver, TRUE, FALSE))
		. = FALSE
	ears = null
	if(tongue && !tongue.Insert(receiver, TRUE, FALSE))
		. = FALSE
	tongue = null
	if(antennae)
		var/datum/bodypart_overlay/mutant/antennae_ipc/antennae_overlay = antennae.bodypart_overlay
		var/antennae_style = antennae_overlay?.sprite_datum?.name
		if(!antennae_style || antennae_style == SPRITE_ACCESSORY_NONE)
			antennae_style = "Angled"
			antennae_overlay?.set_appearance_from_name(antennae_style)
		receiver.dna.features["ipc_antenna"] = antennae_style
		if(!antennae.Insert(receiver, TRUE, FALSE))
			. = FALSE
	antennae = null
	return .

/obj/item/bodypart/head/ipc/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(secured)
		return ..()

	if(istype(tool, /obj/item/organ/internal/eyes/synth))
		if(eyes)
			to_chat(user, span_warning("[src] already has optical sensors installed!"))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		eyes = tool
		to_chat(user, span_notice("You install [tool] into [src]."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/organ/internal/ears/synth))
		if(ears)
			to_chat(user, span_warning("[src] already has synthetic ears installed!"))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		ears = tool
		to_chat(user, span_notice("You install [tool] into [src]."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/organ/internal/tongue/robot/synth))
		if(tongue)
			to_chat(user, span_warning("[src] already has a synthetic tongue installed!"))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		tongue = tool
		to_chat(user, span_notice("You install [tool] into [src]."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/organ/external/ipc_screen))
		to_chat(user, span_warning("The IPC screen is installed into the completed chassis last."))
		return ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/organ/external/antennae/ipc))
		if(antennae)
			to_chat(user, span_warning("[src] already has IPC antennae installed!"))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		antennae = tool
		to_chat(user, span_notice("You install [tool] into [src]."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/stack/cable_coil))
		if(wired)
			to_chat(user, span_warning("[src] is already wired!"))
			return ITEM_INTERACT_BLOCKING
		var/obj/item/stack/cable_coil/coil = tool
		if(coil.use(1))
			wired = TRUE
			to_chat(user, span_notice("You wire [src]."))
			return ITEM_INTERACT_SUCCESS
		to_chat(user, span_warning("You need one length of cable to wire [src]!"))
		return ITEM_INTERACT_BLOCKING

	return ..()

/obj/item/bodypart/head/ipc/screwdriver_act(mob/living/user, obj/item/screwtool)
	if(secured)
		if(!screwtool.use_tool(src, user, 0.5 SECONDS, volume = 50))
			return ITEM_INTERACT_BLOCKING
		secured = FALSE
		to_chat(user, span_notice("You unsecure [src]."))
		return ITEM_INTERACT_SUCCESS

	if(!check_completion())
		to_chat(user, span_warning("[src] needs optical sensors, synthetic ears, a synthetic tongue, IPC antennae, and wiring before it can be secured."))
		return ITEM_INTERACT_BLOCKING
	if(!screwtool.use_tool(src, user, 0.5 SECONDS, volume = 50))
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
	if(!eyes && !ears && !tongue && !antennae)
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

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)

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

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)
