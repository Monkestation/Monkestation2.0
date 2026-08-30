#define IPC_CORE_OFF_SCREEN "blank"
#define IPC_CORE_UNCONNECTED_SCREEN "blue"
#define IPC_CORE_UNCONNECTED_SCREEN_COLOR "#3399ff"

/// IPC Building
/obj/item/ipc_core
	name = "ipc core"
	desc = "An incomplete IPC chassis. Install synthetic organs, attach IPC limbs plus a secured head assembly, install an IPC screen, then finish the shell with a multitool."
	icon = 'icons/mob/species/ipc/bodyparts.dmi'
	icon_state = "synth_chest"
	w_class = WEIGHT_CLASS_GIGANTIC
	interaction_flags_item = NONE

	/// Left arm part of the IPC assembly.
	var/obj/item/bodypart/arm/left/ipc/left_arm = null
	/// Right arm part of the IPC assembly.
	var/obj/item/bodypart/arm/right/ipc/right_arm = null
	/// Left leg part of the IPC assembly.
	var/obj/item/bodypart/leg/left/ipc/left_leg = null
	/// Right leg part of the IPC assembly.
	var/obj/item/bodypart/leg/right/ipc/right_leg = null
	/// Head part of the IPC assembly.
	var/obj/item/bodypart/head/ipc/head = null
	/// IPC chest cavity parts are stored directly in the core until the completed chassis becomes a mob.
	var/obj/item/organ/internal/stomach/synth/stomach = null
	/// Heatsink stored in the IPC core during construction.
	var/obj/item/organ/internal/lungs/synth/lungs = null
	/// Hydraulic pump engine stored in the IPC core during construction.
	var/obj/item/organ/internal/heart/synth/heart = null
	/// Reagent processing unit stored in the IPC core during construction.
	var/obj/item/organ/internal/liver/synth/liver = null
	/// Current construction state of the core chest cavity.
	var/core_state = IPC_CONSTRUCTION_UNWIRED
	/// Screen installed after the chassis body is fully assembled.
	var/obj/item/organ/external/ipc_screen/screen = null
	/// Current construction state of the installed screen.
	var/screen_state = IPC_CONSTRUCTION_UNWIRED

/obj/item/ipc_core/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/ipc_core/Destroy()
	QDEL_NULL(left_arm)
	QDEL_NULL(right_arm)
	QDEL_NULL(left_leg)
	QDEL_NULL(right_leg)
	QDEL_NULL(head)
	QDEL_NULL(stomach)
	QDEL_NULL(lungs)
	QDEL_NULL(heart)
	QDEL_NULL(liver)
	QDEL_NULL(screen)
	return ..()

/obj/item/ipc_core/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == left_arm)
		left_arm = null
	if(gone == right_arm)
		right_arm = null
	if(gone == left_leg)
		left_leg = null
	if(gone == right_leg)
		right_leg = null
	if(gone == head)
		head = null
	if(gone == stomach)
		stomach = null
	if(gone == lungs)
		lungs = null
	if(gone == heart)
		heart = null
	if(gone == liver)
		liver = null
	if(gone == screen)
		screen = null
		screen_state = IPC_CONSTRUCTION_UNWIRED

/obj/item/ipc_core/examine(mob/user)
	. = ..()
	. += span_info("Its chest cavity has [stomach ? "a synthetic bio-reactor" : "no synthetic bio-reactor"], [lungs ? "a heatsink" : "no heatsink"], [heart ? "a hydraulic pump engine" : "no hydraulic pump engine"], and [liver ? "a reagent processing unit" : "no reagent processing unit"] installed.")
	. += span_info("The chest cavity is [core_state >= IPC_CONSTRUCTION_WIRED ? "wired" : "unwired"] and [core_state == IPC_CONSTRUCTION_SECURED ? "secured" : "unsecured"].")
	. += span_info("It has [head ? "an attached head" : "no attached head"], [left_arm ? "an attached left arm" : "no attached left arm"], [right_arm ? "an attached right arm" : "no attached right arm"], [left_leg ? "an attached left leg" : "no attached left leg"], [right_leg ? "an attached right leg" : "no attached right leg"], and [screen ? "an installed screen" : "no installed screen"].")
	if(screen)
		. += span_info("The screen is [screen_state >= IPC_CONSTRUCTION_WIRED ? "wired" : "unwired"] and [screen_state == IPC_CONSTRUCTION_SECURED ? "secured" : "unsecured"].")
	if(check_completion())
	. += span_info("It is ready to be finalized with a <b>multitool</b>.")
	return
if(core_state != IPC_CONSTRUCTION_SECURED)
	. += span_info("Install each chest component, add <b>cable</b>, then use a <b>screwdriver</b> to secure the chest cavity.")
	return
if(check_body_completion() && !screen)
	. += span_info("Install an <b>IPC screen</b>, then wire and secure it before finalizing the chassis with a <b>multitool</b>.")
	return
if(screen && screen_state == IPC_CONSTRUCTION_UNWIRED)
	. += span_info("Use <b>cable</b> to wire the installed screen.")
	return
if(screen && screen_state != IPC_CONSTRUCTION_SECURED)
	. += span_info("Use a <b>screwdriver</b> to secure the wired screen.")
	return
. += span_info("Attach all IPC limbs plus a secured head before installing the screen and finalizing the chassis.")

/obj/item/ipc_core/update_overlays()
	. = ..()
	var/list/attached_bodyparts = list(left_leg, right_leg, left_arm, right_arm, head)
	for(var/obj/item/bodypart/bodypart as anything in attached_bodyparts)
		var/mutable_appearance/bodypart_overlay = build_bodypart_overlay(bodypart)
		if(bodypart_overlay)
			. += bodypart_overlay
	if(screen)
		. += mutable_appearance(screen.screen_icon, screen_state == IPC_CONSTRUCTION_SECURED ? IPC_CORE_UNCONNECTED_SCREEN : IPC_CORE_OFF_SCREEN)

/// Builds construction overlays from the attached IPC bodypart's visible item sprite.
/// This intentionally avoids get_limb_icon(), since that mutates the attached part's dropped icon state.
/obj/item/ipc_core/proc/build_bodypart_overlay(obj/item/bodypart/bodypart)
	if(!bodypart)
		return null

	var/bodypart_icon_state = bodypart.icon_state || initial(bodypart.icon_state)
	if(!bodypart_icon_state)
		return null

	var/mutable_appearance/bodypart_overlay = mutable_appearance(bodypart.icon, bodypart_icon_state)
	bodypart_overlay.color = bodypart.color
	bodypart_overlay.dir = bodypart.dir
	bodypart_overlay.pixel_x = bodypart.pixel_x
	bodypart_overlay.pixel_y = bodypart.pixel_y
	bodypart_overlay.transform = bodypart.transform
	return bodypart_overlay

/// Returns whether the IPC core contains every required chest component and wiring.
/obj/item/ipc_core/proc/check_core_completion()
	return stomach && lungs && heart && liver && core_state >= IPC_CONSTRUCTION_WIRED

/// Returns whether the IPC core has a secured chest, head, and complete set of limbs.
/obj/item/ipc_core/proc/check_body_completion()
	return check_core_completion() && core_state == IPC_CONSTRUCTION_SECURED && left_arm && right_arm && left_leg && right_leg && head && head.secured && head.check_completion()

/// Returns whether the IPC chassis is ready to be finalized.
/obj/item/ipc_core/proc/check_completion()
	return check_body_completion() && screen && screen_state == IPC_CONSTRUCTION_SECURED

/// Drops all organs currently installed directly into this IPC core.
/obj/item/ipc_core/proc/drop_stored_parts(atom/drop_to = drop_location())
	stomach?.forceMove(drop_to)
	lungs?.forceMove(drop_to)
	heart?.forceMove(drop_to)
	liver?.forceMove(drop_to)
	stomach = null
	lungs = null
	heart = null
	liver = null

/// Installs all organs stored directly in this IPC core into the completed IPC shell.
/obj/item/ipc_core/proc/install_stored_organs(mob/living/carbon/receiver)
	if(stomach && !stomach.Insert(receiver, TRUE, FALSE))
		return FALSE
	stomach = null
	if(lungs && !lungs.Insert(receiver, TRUE, FALSE))
		return FALSE
	lungs = null
	if(heart && !heart.Insert(receiver, TRUE, FALSE))
		return FALSE
	heart = null
	if(liver && !liver.Insert(receiver, TRUE, FALSE))
		return FALSE
	liver = null
	return TRUE

/// Drops all bodyparts currently attached to this IPC core.
/obj/item/ipc_core/proc/drop_all_parts(atom/drop_to = drop_location())
	left_arm?.forceMove(drop_to)
	right_arm?.forceMove(drop_to)
	left_leg?.forceMove(drop_to)
	right_leg?.forceMove(drop_to)
	head?.forceMove(drop_to)
	screen?.forceMove(drop_to)
	drop_stored_parts(drop_to)
	if(core_state >= IPC_CONSTRUCTION_WIRED)
		new /obj/item/stack/cable_coil(drop_to, 1)
		core_state = IPC_CONSTRUCTION_UNWIRED
	if(screen_state >= IPC_CONSTRUCTION_WIRED)
		new /obj/item/stack/cable_coil(drop_to, 1)
		screen_state = IPC_CONSTRUCTION_UNWIRED

/obj/item/ipc_core/wrench_act(mob/living/user, obj/item/tool)
	if(!left_arm && !right_arm && !left_leg && !right_leg && !head && !screen && !stomach && !lungs && !heart && !liver && core_state == IPC_CONSTRUCTION_UNWIRED && screen_state == IPC_CONSTRUCTION_UNWIRED)
		to_chat(user, span_warning("There is nothing to remove from [src]!"))
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 0.5 SECONDS, volume = 50))
		return ITEM_INTERACT_BLOCKING
	drop_all_parts(get_turf(src))
	user.balloon_alert(user, "disassembled!")
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/ipc_core/screwdriver_act(mob/living/user, obj/item/tool)
	if(screen)
		if(screen_state == IPC_CONSTRUCTION_SECURED)
			if(!tool.use_tool(src, user, 0.5 SECONDS, volume = 50))
				return ITEM_INTERACT_BLOCKING
			screen_state = IPC_CONSTRUCTION_WIRED
			to_chat(user, span_notice("You unsecure [screen] from [src]."))
			update_appearance()
			return ITEM_INTERACT_SUCCESS
		if(screen_state != IPC_CONSTRUCTION_WIRED)
			to_chat(user, span_warning("[screen] needs to be wired into [src] before it can be secured."))
			return ITEM_INTERACT_BLOCKING
		if(!tool.use_tool(src, user, 0.5 SECONDS, volume = 50))
			return ITEM_INTERACT_BLOCKING
		screen_state = IPC_CONSTRUCTION_SECURED
		to_chat(user, span_notice("You secure [screen] into [src]. Its display comes online."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(core_state == IPC_CONSTRUCTION_SECURED)
		if(!tool.use_tool(src, user, 0.5 SECONDS, volume = 50))
			return ITEM_INTERACT_BLOCKING
		core_state = IPC_CONSTRUCTION_WIRED
		to_chat(user, span_notice("You unsecure [src]'s chest cavity."))
		return ITEM_INTERACT_SUCCESS
	if(!check_core_completion())
		to_chat(user, span_warning("[src] needs a synthetic bio-reactor, heatsink, hydraulic pump engine, reagent processing unit, and wiring before its chest cavity can be secured."))
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 0.5 SECONDS, volume = 50))
		return ITEM_INTERACT_BLOCKING
	core_state = IPC_CONSTRUCTION_SECURED
	to_chat(user, span_notice("You secure [src]'s chest cavity."))
	return ITEM_INTERACT_SUCCESS

/obj/item/ipc_core/wirecutter_act(mob/living/user, obj/item/cutter)
	. = ..()
	if(screen && screen_state >= IPC_CONSTRUCTION_WIRED)
		if(screen_state == IPC_CONSTRUCTION_SECURED)
			to_chat(user, span_warning("You need to unsecure [screen] first!"))
			return TRUE
		. = TRUE
		cutter.play_tool_sound(src)
		to_chat(user, span_notice("You cut [screen]'s wiring out of [src]."))
		new /obj/item/stack/cable_coil(drop_location(), 1)
		screen_state = IPC_CONSTRUCTION_UNWIRED
		update_appearance()
		return
	if(core_state == IPC_CONSTRUCTION_UNWIRED)
		return
	if(core_state == IPC_CONSTRUCTION_SECURED)
		to_chat(user, span_warning("You need to unsecure [src]'s chest cavity first!"))
		return TRUE
	. = TRUE
	cutter.play_tool_sound(src)
	to_chat(user, span_notice("You cut the wires out of [src]'s chest cavity."))
	new /obj/item/stack/cable_coil(drop_location(), 1)
	core_state = IPC_CONSTRUCTION_UNWIRED

/obj/item/ipc_core/crowbar_act(mob/living/user, obj/item/prytool)
	. = ..()
	if(core_state == IPC_CONSTRUCTION_SECURED)
		to_chat(user, span_warning("You need to unsecure [src]'s chest cavity first!"))
		return TRUE
	if(!stomach && !lungs && !heart && !liver)
		to_chat(user, span_warning("There are no chest components to remove from [src]."))
		return TRUE
	prytool.play_tool_sound(src)
	to_chat(user, span_notice("You pry the chest components out of [src]."))
	drop_stored_parts()
	update_appearance()
	return TRUE

/obj/item/ipc_core/multitool_act(mob/living/user, obj/item/tool)
	if(!check_core_completion())
		to_chat(user, span_warning("The IPC core must have a synthetic bio-reactor, heatsink, hydraulic pump engine, reagent processing unit, and wiring before it can be finalized."))
		return ITEM_INTERACT_BLOCKING
	if(core_state != IPC_CONSTRUCTION_SECURED)
		to_chat(user, span_warning("The IPC core's chest cavity must be secured before it can be finalized."))
		return ITEM_INTERACT_BLOCKING
	if(!head || !head.secured || !head.check_completion() || !left_arm || !right_arm || !left_leg || !right_leg)
		to_chat(user, span_warning("The IPC core must have a secured head assembly plus both arms and legs before it can be finalized."))
		return ITEM_INTERACT_BLOCKING
	if(!screen)
		to_chat(user, span_warning("The IPC core needs an IPC screen installed before it can be finalized."))
		return ITEM_INTERACT_BLOCKING
	if(screen_state == IPC_CONSTRUCTION_UNWIRED)
		to_chat(user, span_warning("The IPC screen needs to be wired before the core can be finalized."))
		return ITEM_INTERACT_BLOCKING
	if(screen_state != IPC_CONSTRUCTION_SECURED)
		to_chat(user, span_warning("The IPC screen needs to be secured before the core can be finalized."))
		return ITEM_INTERACT_BLOCKING
	if(!isturf(loc))
		to_chat(user, span_warning("You need to place [src] on the floor before finalizing the chassis."))
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 0.5 SECONDS, volume = 50))
		return ITEM_INTERACT_BLOCKING
	if(!build_ipc_body(user))
		to_chat(user, span_warning("The IPC chassis fails to come together."))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

/obj/item/ipc_core/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/organ/internal/stomach/synth))
		if(core_state == IPC_CONSTRUCTION_SECURED)
			to_chat(user, span_warning("You need to unsecure [src]'s chest cavity first!"))
			return ITEM_INTERACT_BLOCKING
		if(stomach)
			to_chat(user, span_warning("[src] already has a synthetic bio-reactor installed!"))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		stomach = tool
		to_chat(user, span_notice("You install [tool] into [src]."))
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/organ/internal/lungs/synth))
		if(core_state == IPC_CONSTRUCTION_SECURED)
			to_chat(user, span_warning("You need to unsecure [src]'s chest cavity first!"))
			return ITEM_INTERACT_BLOCKING
		if(lungs)
			to_chat(user, span_warning("[src] already has a heatsink installed!"))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		lungs = tool
		to_chat(user, span_notice("You install [tool] into [src]."))
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/organ/internal/heart/synth))
		if(core_state == IPC_CONSTRUCTION_SECURED)
			to_chat(user, span_warning("You need to unsecure [src]'s chest cavity first!"))
			return ITEM_INTERACT_BLOCKING
		if(heart)
			to_chat(user, span_warning("[src] already has a hydraulic pump engine installed!"))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		heart = tool
		to_chat(user, span_notice("You install [tool] into [src]."))
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/organ/internal/liver/synth))
		if(core_state == IPC_CONSTRUCTION_SECURED)
			to_chat(user, span_warning("You need to unsecure [src]'s chest cavity first!"))
			return ITEM_INTERACT_BLOCKING
		if(liver)
			to_chat(user, span_warning("[src] already has a reagent processing unit installed!"))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		liver = tool
		to_chat(user, span_notice("You install [tool] into [src]."))
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/bodypart/head/ipc))
		if(head)
			user.balloon_alert(user, "head already present!")
			return ITEM_INTERACT_BLOCKING
		var/obj/item/bodypart/head/ipc/ipc_head = tool
		if(!ipc_head.secured || !ipc_head.check_completion())
			to_chat(user, span_warning("The IPC head has to be fully assembled and secured before it can be attached."))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		head = tool
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/bodypart/arm/left/ipc))
		if(left_arm)
			user.balloon_alert(user, "left arm already present!")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		left_arm = tool
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/bodypart/arm/right/ipc))
		if(right_arm)
			user.balloon_alert(user, "right arm already present!")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		right_arm = tool
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/bodypart/leg/left/ipc))
		if(left_leg)
			user.balloon_alert(user, "left leg already present!")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		left_leg = tool
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/bodypart/leg/right/ipc))
		if(right_leg)
			user.balloon_alert(user, "right leg already present!")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		right_leg = tool
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/organ/external/ipc_screen))
		if(screen)
			user.balloon_alert(user, "screen already present!")
			return ITEM_INTERACT_BLOCKING
		if(!check_body_completion())
			to_chat(user, span_warning("The chassis body must be fully assembled and secured before the screen can be installed."))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		screen = tool
		screen_state = IPC_CONSTRUCTION_UNWIRED
		to_chat(user, span_notice("You install [tool] into [src]."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = tool
		if(screen)
			if(screen_state >= IPC_CONSTRUCTION_WIRED)
				to_chat(user, span_warning("[screen] is already wired into [src]!"))
				return ITEM_INTERACT_BLOCKING
			if(coil.use(1))
				screen_state = IPC_CONSTRUCTION_WIRED
				to_chat(user, span_notice("You wire [screen] into [src]."))
				return ITEM_INTERACT_SUCCESS
			to_chat(user, span_warning("You need one length of cable to wire [screen]!"))
			return ITEM_INTERACT_BLOCKING
		if(core_state >= IPC_CONSTRUCTION_WIRED)
			to_chat(user, span_warning("[src]'s chest cavity is already wired!"))
			return ITEM_INTERACT_BLOCKING
		if(coil.use(1))
			core_state = IPC_CONSTRUCTION_WIRED
			to_chat(user, span_notice("You wire [src]'s chest cavity."))
			return ITEM_INTERACT_SUCCESS
		to_chat(user, span_warning("You need one length of cable to wire [src]'s chest cavity!"))
		return ITEM_INTERACT_BLOCKING

	return NONE

/// Moves stored head organs out of the bodypart contents before try_attach_limb() auto-inserts contents.
/obj/item/ipc_core/proc/stage_stored_head_organs_for_assembly(obj/item/bodypart/head/ipc/assembled_head)
	var/obj/item/organ/internal/eyes/synth/staged_eyes = assembled_head.ipc_eyes
	var/obj/item/organ/internal/ears/synth/staged_ears = assembled_head.ipc_ears
	var/obj/item/organ/internal/tongue/robot/synth/staged_tongue = assembled_head.ipc_tongue
	var/obj/item/organ/external/antennae/ipc/staged_antennae = assembled_head.antennae

	var/list/stored_organs = list(staged_eyes, staged_ears, staged_tongue, staged_antennae)
	for(var/obj/item/organ/stored_organ as anything in stored_organs)
		if(stored_organ)
			stored_organ.moveToNullspace()

	assembled_head.ipc_eyes = staged_eyes
	assembled_head.ipc_ears = staged_ears
	assembled_head.ipc_tongue = staged_tongue
	assembled_head.antennae = staged_antennae

/// Converts the completed construction core into an inert IPC body.
/obj/item/ipc_core/proc/build_ipc_body(mob/living/user)
	var/turf/build_turf = get_turf(src)
	if(!build_turf)
		return FALSE

	var/mob/living/carbon/human/species/ipc/ipc_body = new(build_turf)
	if(!ipc_body)
		return FALSE
	// Keep the roundstart augment policy on normal IPCs, but prevent organ regeneration from restoring it on this constructed shell.
	ipc_body.dna.species.mutant_organs = ipc_body.dna.species.mutant_organs.Copy()
	ipc_body.dna.species.mutant_organs -= /obj/item/organ/internal/cyberimp/arm/item_set/power_cord

	// Remove default IPC organs so the shell only uses fabricated components.
	// The iron butt is initialized with the shell and can still be replaced later through augmentation.
	for(var/obj/item/organ/existing_organ as anything in ipc_body.organs.Copy())
		if(istype(existing_organ, /obj/item/organ/internal/butt/iron))
			continue
		existing_organ.Remove(ipc_body, TRUE)
		qdel(existing_organ)

	var/obj/item/organ/internal/brain/brain = ipc_body.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		brain.Remove(ipc_body, TRUE)
		qdel(brain)

	for(var/obj/item/bodypart/bodypart as anything in ipc_body.bodyparts.Copy())
		qdel(bodypart)

	var/obj/item/bodypart/chest/ipc/installed_chest = new /obj/item/bodypart/chest/ipc
	var/obj/item/bodypart/head/ipc/installed_head = head
	var/obj/item/organ/external/ipc_screen/installed_screen = screen
	stage_stored_head_organs_for_assembly(installed_head)

	var/list/attached_parts = list(installed_chest, installed_head, left_arm, right_arm, left_leg, right_leg)
	for(var/obj/item/bodypart/bodypart as anything in attached_parts)
		if(!bodypart.try_attach_limb(ipc_body, TRUE))
			qdel(ipc_body)
			return FALSE

	if(!install_stored_organs(ipc_body) || !installed_head.install_stored_organs(ipc_body))
		qdel(ipc_body)
		return FALSE

	// Roundstart IPCs receive a charging cord from their species, but constructed shells must have it installed later through augmentation surgery.
	var/obj/item/organ/internal/cyberimp/arm/item_set/power_cord/power_cord = ipc_body.get_organ_by_type(/obj/item/organ/internal/cyberimp/arm/item_set/power_cord)
	if(power_cord)
		power_cord.Remove(ipc_body, TRUE)
		qdel(power_cord)

	head = null
	left_arm = null
	right_arm = null
	left_leg = null
	right_leg = null
	core_state = IPC_CONSTRUCTION_UNWIRED

	// Remove clothes, facial hair, and features.
	ipc_body.undershirt = null
	ipc_body.underwear = null
	ipc_body.socks = null
	ipc_body.facial_hairstyle = null
	ipc_body.hairstyle = null
	// Suppress emotes while creating the inert shell.
	ADD_TRAIT(ipc_body, TRAIT_EMOTEMUTE, type)
	ipc_body.death()
	REMOVE_TRAIT(ipc_body, TRAIT_EMOTEMUTE, type)

	// The new shell may have randomized to no screen, so establish a valid display feature before inserting the fabricated screen.
	ipc_body.dna.features["ipc_screen"] = "Blue"
	if(!installed_screen.Insert(ipc_body, TRUE, FALSE))
		qdel(ipc_body)
		return FALSE
	installed_screen.switch_to_screen(ipc_body, "Blue", IPC_CORE_UNCONNECTED_SCREEN_COLOR)
	screen = null
	screen_state = IPC_CONSTRUCTION_UNWIRED

	ipc_body.regenerate_icons()
	user.visible_message(span_notice("[user] finishes [src] into an inert IPC shell."), span_notice("You finish [src] into an inert IPC shell."))
	qdel(src)
	return TRUE

#undef IPC_CORE_OFF_SCREEN
#undef IPC_CORE_UNCONNECTED_SCREEN
#undef IPC_CORE_UNCONNECTED_SCREEN_COLOR
