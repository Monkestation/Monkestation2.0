/obj/item/organ/external/antennae/ipc
	name = "IPC antennae"
	desc = "An IPC's antennae. What is it telling them? What are they sensing?"
	icon_state = "antennae"

	zone = BODY_ZONE_HEAD

	preference = "feature_ipc_antenna"

	bodypart_overlay = /datum/bodypart_overlay/mutant/antennae/ipc


/obj/item/organ/external/antennae/ipc/try_burn_antennae(mob/living/carbon/human/human)
	return

/datum/bodypart_overlay/mutant/antennae/ipc
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "ipc_antenna"
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR_SECONDARY
	color_source = ORGAN_COLOR_MUTSECONDARY

/datum/bodypart_overlay/mutant/antennae/ipc/get_global_feature_list()
	return GLOB.ipc_antennas_list

/datum/bodypart_overlay/mutant/antennae/ipc/get_base_icon_state()
	return sprite_datum.icon_state

/obj/item/organ/external/ipc_screen
	name = "IPC screen"
	desc = "An IPC's screen."
	icon_state = "antennae" // place holder

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SCREEN
	dna_block = DNA_IPC_SCREEN_BLOCK

	preference = "feature_ipc_screen"

	bodypart_overlay = /datum/bodypart_overlay/mutant/ipc_screen

	/// The innate action that ipcs get, if they've got a screen selected on species being set.
	var/datum/action/innate/change_screen/change_screen
	/// This is the screen that is given to the user after they get revived. On death, their screen is temporarily set to BSOD before it turns off, hence the need for this var.
	var/saved_screen = "Blue"

/datum/bodypart_overlay/mutant/ipc_screen
	layers = EXTERNAL_ADJACENT
	feature_key = "ipc_screen"
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR_SECONDARY
	color_source = ORGAN_COLOR_MUTSECONDARY

/datum/bodypart_overlay/mutant/ipc_screen/get_global_feature_list()
	return GLOB.ipc_screens_list

/datum/bodypart_overlay/mutant/ipc_screen/get_base_icon_state()
	return sprite_datum.icon_state

/obj/item/organ/external/ipc_screen/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	if(!.)
		return
	RegisterSignal(receiver, COMSIG_LIVING_DEATH, PROC_REF(bsod_death)) // screen displays bsod on death
	change_screen = new
	change_screen.Grant(receiver)


/obj/item/organ/external/ipc_screen/Remove(mob/living/carbon/organ_owner, special, moving)
	. = ..()
	UnregisterSignal(organ_owner, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE))
	change_screen.Remove(organ_owner)

/*
	* Makes the IPC screen switch to BSOD followed by a blank screen
	*
	* Arguments:
	* * transformer - The human that will be affected by the screen change (read: IPC).
	* * screen_name - The name of the screen to switch the ipc_screen mutant bodypart to. Defaults to BSOD.
*/
/obj/item/organ/external/ipc_screen/proc/bsod_death(mob/living/carbon/human/transformer, screen_name = "BSOD")
	if(!transformer.get_organ_slot(ORGAN_SLOT_EXTERNAL_SCREEN)) // I dont know where your screen is for this to be called but ok man
		return
	saved_screen = change_screen // remember the old screen in case of revival
	switch_to_screen(transformer, screen_name)
	addtimer(CALLBACK(src, PROC_REF(switch_to_screen), transformer, "Blank"), 5 SECONDS)

/datum/action/innate/change_screen
	name = "Change Display"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"

/datum/action/innate/change_screen/Activate()
	var/screen_choice = tgui_input_list(usr, "Which screen do you want to use?", "Screen Change", GLOB.ipc_screens_list)
	var/color_choice = tgui_color_picker(usr, "Which color do you want your screen to be", "Color Change")
	if(!screen_choice)
		return
	if(!color_choice)
		return
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/screen_owner = owner
	screen_owner.dna.features["ipc_screen"] = screen_choice
	screen_owner.eye_color_left = sanitize_hexcolor(color_choice)
	screen_owner.update_body()

/**
	* Simple proc to switch the screen of a monitor-enabled synth, while updating their appearance.
	*
	* Arguments:
	* * transformer - The human that will be affected by the screen change (read: IPC).
	* * screen_name - The name of the screen to switch the ipc_screen mutant bodypart to.
	*/
/obj/item/organ/external/ipc_screen/proc/switch_to_screen(mob/living/carbon/human/transformer, screen_name)
	if(!change_screen)
		return

	transformer.dna.features["ipc_screen"] = screen_name
	transformer.update_body()

