/obj/item/organ/external/antennae/ipc
	name = "IPC antennae"
	desc = "An IPC's antennae. What is it telling them? What are they sensing?"
	icon_state = "antennae"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANTENNAE

	preference = "feature_ipc_antenna"

	bodypart_overlay = /datum/bodypart_overlay/mutant/antennae_ipc

/obj/item/organ/external/antennae/ipc/try_burn_antennae(mob/living/carbon/human/human)
	return

/datum/bodypart_overlay/mutant/antennae_ipc
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "ipc_antenna"
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR_SECONDARY
	color_source = ORGAN_COLOR_MUTSECONDARY

/datum/bodypart_overlay/mutant/antennae_ipc/get_global_feature_list()
	return GLOB.ipc_antennas_list

/datum/bodypart_overlay/mutant/antennae_ipc/get_base_icon_state()
	return sprite_datum.icon_state

/obj/item/organ/external/ipc_screen
	name = "IPC screen"
	desc = "An IPC's screen, can it run doom?"
	icon_state = "ipc_screen"
	icon = 'icons/obj/medical/organs/organs.dmi'

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SCREEN

	dna_block = DNA_IPC_SCREEN_BLOCK // dont question it

	preference = "feature_ipc_screen"

	bodypart_overlay = /datum/bodypart_overlay/mutant/ipc_screen

	/// The innate action that IPCs receive while this screen is installed.
	var/datum/action/innate/change_screen/change_screen
	/// The display restored after the IPC finishes rebooting.
	var/saved_screen = "Blue"
	/// Pending timer which blanks the display after death.
	var/blank_screen_timer
	/// Pending timer which restores the saved display after revival.
	var/restore_screen_timer

/datum/bodypart_overlay/mutant/ipc_screen
	layers = EXTERNAL_ADJACENT
	feature_key = "ipc_screen"
	palette = /datum/color_palette/generic_colors

/datum/bodypart_overlay/mutant/ipc_screen/get_global_feature_list()
	return GLOB.ipc_screens_list

/datum/bodypart_overlay/mutant/ipc_screen/get_base_icon_state()
	return sprite_datum.icon_state

/obj/item/organ/external/ipc_screen/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	if(!.)
		return
	RegisterSignal(receiver, COMSIG_LIVING_DEATH, PROC_REF(bsod_death))
	RegisterSignal(receiver, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	change_screen = new
	change_screen.Grant(receiver)
	var/datum/bodypart_overlay/mutant/ipc_screen/screen_overlay = bodypart_overlay
	if(screen_overlay?.sprite_datum?.name)
		saved_screen = screen_overlay.sprite_datum.name

/obj/item/organ/external/ipc_screen/Remove(mob/living/carbon/organ_owner, special, moving)
	. = ..()
	cancel_screen_timers()
	UnregisterSignal(organ_owner, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE))
	if(change_screen)
		change_screen.Remove(organ_owner)
		QDEL_NULL(change_screen)

/obj/item/organ/external/ipc_screen/Destroy()
	cancel_screen_timers()
	QDEL_NULL(change_screen)
	return ..()

/// Returns whether this organ is still the installed screen belonging to screen_owner.
/obj/item/organ/external/ipc_screen/proc/valid_screen_owner(mob/living/carbon/human/screen_owner)
	return !QDELETED(src) && !QDELETED(screen_owner) && owner == screen_owner && screen_owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_SCREEN) == src

/// Cancels any delayed screen transition owned by this organ.
/obj/item/organ/external/ipc_screen/proc/cancel_screen_timers()
	if(blank_screen_timer)
		deltimer(blank_screen_timer)
		blank_screen_timer = null
	if(restore_screen_timer)
		deltimer(restore_screen_timer)
		restore_screen_timer = null

/**
 * Makes the IPC screen switch to BSOD followed by a blank screen.
 *
 * Arguments:
 * * transformer - The IPC whose display is changing.
 * * gibbed - Whether the death was caused by gibbing. The screen behavior is the same either way.
 */
/obj/item/organ/external/ipc_screen/proc/bsod_death(mob/living/carbon/human/transformer, gibbed)
	SIGNAL_HANDLER
	if(!valid_screen_owner(transformer))
		return
	var/was_rebooting = !!restore_screen_timer
	cancel_screen_timers()
	var/datum/bodypart_overlay/mutant/ipc_screen/screen_overlay = bodypart_overlay
	if(!was_rebooting && screen_overlay?.sprite_datum?.name)
		saved_screen = screen_overlay.sprite_datum.name
	switch_to_screen(transformer, "BSOD")
	blank_screen_timer = addtimer(CALLBACK(src, PROC_REF(blank_dead_screen), transformer), 5 SECONDS, TIMER_STOPPABLE)

/// Blanks a dead IPC's screen if this organ is still installed when the timer fires.
/obj/item/organ/external/ipc_screen/proc/blank_dead_screen(mob/living/carbon/human/transformer)
	blank_screen_timer = null
	if(!valid_screen_owner(transformer) || transformer.stat != DEAD)
		return
	switch_to_screen(transformer, "Blank Canvas")

/// Starts the IPC's display reboot sequence after revival.
/obj/item/organ/external/ipc_screen/proc/on_revive(mob/living/carbon/human/transformer, full_heal, admin_revive)
	SIGNAL_HANDLER
	if(!valid_screen_owner(transformer))
		return
	cancel_screen_timers()
	switch_to_screen(transformer, "BSOD")
	restore_screen_timer = addtimer(CALLBACK(src, PROC_REF(restore_saved_screen), transformer), 9 SECONDS, TIMER_STOPPABLE)

/// Restores the display which was active before death.
/obj/item/organ/external/ipc_screen/proc/restore_saved_screen(mob/living/carbon/human/transformer)
	restore_screen_timer = null
	if(!valid_screen_owner(transformer) || transformer.stat == DEAD)
		return
	switch_to_screen(transformer, saved_screen)
	transformer.visible_message(
		span_notice("[transformer]'s monitor lights up!"),
		span_notice("You're back online!"),
	)

/datum/action/innate/change_screen
	name = "Change Display"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"

/datum/action/innate/change_screen/Activate()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/screen_owner = owner
	var/screen_choice = tgui_input_list(screen_owner, "Which screen do you want to use?", "Screen Change", GLOB.ipc_screens_list)
	if(!screen_choice || QDELETED(screen_owner) || owner != screen_owner)
		return
	var/color_choice = tgui_color_picker(screen_owner, "Which color do you want your screen to be", "Color Change")
	if(!color_choice || QDELETED(screen_owner) || owner != screen_owner)
		return
	var/obj/item/organ/external/ipc_screen/screen = screen_owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_SCREEN)
	if(!screen)
		return
	screen.cancel_screen_timers()
	screen.saved_screen = screen_choice
	screen.switch_to_screen(screen_owner, screen_choice, color_choice)

/**
 * Switches an installed IPC screen and updates the owner's appearance.
 *
 * Arguments:
 * * transformer - The IPC whose display will be changed.
 * * screen_name - The sprite-accessory name to display.
 * * color_choice - Optional new display color. Null preserves the existing color.
 */
/obj/item/organ/external/ipc_screen/proc/switch_to_screen(mob/living/carbon/human/transformer, screen_name, color_choice)
	if(!valid_screen_owner(transformer) || !(screen_name in GLOB.ipc_screens_list))
		return FALSE
	var/datum/bodypart_overlay/mutant/ipc_screen/screen_overlay = bodypart_overlay
	if(!screen_overlay)
		return FALSE
	screen_overlay.set_appearance_from_name(screen_name)
	if(transformer.dna)
		transformer.dna.features["ipc_screen"] = screen_name
	if(!isnull(color_choice))
		transformer.eye_color_left = sanitize_hexcolor(color_choice)
	transformer.update_body()
	return TRUE
