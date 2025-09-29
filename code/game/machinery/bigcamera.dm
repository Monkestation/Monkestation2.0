//broadcast camera but big
/obj/machinery/big_broadcast_camera
	name = "big broadcast camera"
	desc = "A very large camera that streams its live feed and audio to entertainment monitors across the station, allowing everyone to watch the broadcast."
	density = TRUE
	desc_controls = "Right-click to change the broadcast name. Alt-click to toggle microphone."
	icon = 'icons/obj/service/broadcast.dmi'
	icon_state = "big_broadcast_cam"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = FALSE
	/// Is camera streaming
	var/active = FALSE
	/// Is the microphone turned on
	var/active_microphone = TRUE
	/// The name of the broadcast
	var/broadcast_name = "Curator News"
	/// The networks it broadcasts to, default is CAMERANET_NETWORK_CURATOR
	var/list/camera_networks = list(CAMERANET_NETWORK_CURATOR)
	/// The "virtual" security camera inside of the physical camera
	var/obj/machinery/camera/internal_camera
	/// The "virtual" radio inside of the the physical camera, a la microphone
	var/obj/item/radio/entertainment/microphone/internal_radio
	/// Camera offset.
	var/camera_offset = 8
	/// Do we apply the offset or not.
	var/do_offset = FALSE

/obj/machinery/big_broadcast_camera/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/machinery/big_broadcast_camera/Destroy(force)
	QDEL_NULL(internal_radio)
	QDEL_NULL(internal_camera)
	return ..()

/obj/machinery/big_broadcast_camera/attack_hand(mob/user, list/modifiers)
	. = ..()
	active = !active
	if(active)
		on_activating(user)
	else
		on_deactivating()

/obj/machinery/big_broadcast_camera/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	broadcast_name = tgui_input_text(user = user, title = "Broadcast Name", message = "What will be the name of your broadcast?", default = "[broadcast_name]", max_length = MAX_CHARTER_LEN, encode = FALSE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/big_broadcast_camera/examine(mob/user)
	. = ..()
	. += span_notice("Broadcast name is <b>[html_encode(broadcast_name)]</b>")
	. += span_notice("The microphone is <b>[active_microphone ? "On" : "Off"]</b>")
	. += span_notice("You can adjust the [src]'s focus using a <b>multitool</b>.")
	. += span_notice("[src] is <b>[anchored ? "anchored" : "not anchored"]</b>.")

/// When activating the camera
/obj/machinery/big_broadcast_camera/proc/on_activating(mob/living/user)
	active = TRUE

	// INTERNAL CAMERA
	internal_camera = new(src)
	internal_camera.internal_light = FALSE
	internal_camera.network = camera_networks
	internal_camera.c_tag = "LIVE: [broadcast_name]"
	user.log_message("started a Spess.tv stream named \"[broadcast_name]\" at [loc_name(user)]", LOG_GAME)
	start_broadcasting_network(camera_networks, "[broadcast_name] is now LIVE!")

	// INTERNAL RADIO
	internal_radio = new(src)
	/// Sets the state of the microphone
	set_microphone_state()

	set_light_on(TRUE)
	playsound(source = src, soundin = 'sound/machines/terminal_processing.ogg', vol = 20, vary = FALSE, ignore_walls = FALSE)
	balloon_alert_to_viewers("live!")

/// When deactivating the camera
/obj/machinery/big_broadcast_camera/proc/on_deactivating()
	active = FALSE
	QDEL_NULL(internal_camera)
	QDEL_NULL(internal_radio)

	stop_broadcasting_network(camera_networks)

	set_light_on(FALSE)
	playsound(source = src, soundin = 'sound/machines/terminal_prompt_deny.ogg', vol = 20, vary = FALSE, ignore_walls = FALSE)
	balloon_alert_to_viewers("offline")

/obj/machinery/big_broadcast_camera/click_alt(mob/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		return CLICK_ACTION_BLOCKING
	active_microphone = !active_microphone

	/// Text popup for letting the user know that the microphone has changed state
	balloon_alert(user, "turned [active_microphone ? "on" : "off"] the microphone.")

	///If the radio exists as an object, set its state accordingly
	if(active)
		set_microphone_state()
	return CLICK_ACTION_SUCCESS

/obj/machinery/big_broadcast_camera/proc/set_microphone_state()
	internal_radio.set_broadcasting(active_microphone)

/obj/machinery/big_broadcast_camera/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/big_broadcast_camera/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	do_offset = !do_offset
	balloon_alert(user, "adjusted the camera [do_offset ? "to focus on distant objects" : "focus back to normal"].")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/big_broadcast_camera/process(seconds_per_tick)
	if(internal_camera)
		internal_camera.view_offset_x = 0
		internal_camera.view_offset_y = 0
		if(do_offset && internal_camera)
			switch(dir)
				if(NORTH)
					internal_camera.view_offset_y = camera_offset
				if(SOUTH)
					internal_camera.view_offset_y = -camera_offset
				if(EAST)
					internal_camera.view_offset_x = camera_offset
				if(WEST)
					internal_camera.view_offset_x = -camera_offset

/datum/crafting_recipe/big_broadcast_camera
	name = "big broadcast camera"
	result = /obj/machinery/big_broadcast_camera
	reqs = list(/obj/item/broadcast_camera = 1, /obj/item/stack/rods = 16, /obj/item/stack/conveyor = 1)
	time = 50
	tool_behaviors = list(TOOL_WELDER, TOOL_WRENCH)
