// Unique broadcast camera given to the first Curator
// Only one should exist ideally, if other types are created they must have different camera_networks
// Broadcasts its surroundings to entertainment monitors and its audio to entertainment radio channel
/obj/item/broadcast_camera
	name = "broadcast camera"
	desc = "A large camera that streams its live feed and audio to entertainment monitors across the station, allowing everyone to watch the broadcast."
	desc_controls = "Right-click to change the broadcast name. Alt-click to toggle microphone."
	icon = 'icons/obj/service/broadcast.dmi'
	icon_state = "broadcast_cam0"
	base_icon_state = "broadcast_cam"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	force = 8
	throwforce = 12
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	slot_flags = NONE
	light_system = OVERLAY_LIGHT
	light_color = COLOR_SOFT_RED
	light_outer_range = 1
	light_power = 0.3
	light_on = FALSE
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

/obj/item/broadcast_camera/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/item/broadcast_camera/Destroy(force)
	QDEL_NULL(internal_radio)
	QDEL_NULL(internal_camera)
	return ..()

/obj/item/broadcast_camera/update_icon_state()
	icon_state = "[base_icon_state][active]"
	return ..()

/obj/item/broadcast_camera/attack_self(mob/living/user, modifiers)
	. = ..()
	active = !active
	if(active)
		on_activating()
	else
		user.remove_status_effect(/datum/status_effect/streamer, internal_camera)
		on_deactivating()

/obj/item/broadcast_camera/attack_self_secondary(mob/user, modifiers)
	. = ..()
	broadcast_name = tgui_input_text(user = user, title = "Broadcast Name", message = "What will be the name of your broadcast?", default = "[broadcast_name]", max_length = MAX_CHARTER_LEN, encode = FALSE)

/obj/item/broadcast_camera/examine(mob/user)
	. = ..()
	. += span_notice("Broadcast name is <b>[html_encode(broadcast_name)]</b>")
	. += span_notice("The microphone is <b>[active_microphone ? "On" : "Off"]</b>")

/obj/item/broadcast_camera/on_enter_storage(datum/storage/master_storage)
	. = ..()
	if(active)
		on_deactivating()

/obj/item/broadcast_camera/dropped(mob/living/user, silent)
	. = ..()
	if(active)
		user?.remove_status_effect(/datum/status_effect/streamer, internal_camera)
		on_deactivating()

/// When activating the camera
/obj/item/broadcast_camera/proc/on_activating()
	if(!isliving(loc))
		return
	/// The mob who wielded the camera, allegedly
	var/mob/living/wielder = loc
	if(!wielder.is_holding(src))
		return
	active = TRUE
	update_icon_state()

	// INTERNAL CAMERA
	internal_camera = new(wielder) // Cameras for some reason do not work inside of obj's
	internal_camera.internal_light = FALSE
	internal_camera.network = camera_networks
	internal_camera.c_tag = "LIVE: [broadcast_name]"
	wielder.apply_status_effect(/datum/status_effect/streamer, internal_camera, CALLBACK(src, PROC_REF(ensure_still_active)))
	wielder.log_message("started a Spess.tv stream named \"[broadcast_name]\" at [loc_name(wielder)]", LOG_GAME)
	start_broadcasting_network(camera_networks, "[broadcast_name] is now LIVE!")

	// INTERNAL RADIO
	internal_radio = new(src)
	/// Sets the state of the microphone
	set_microphone_state()

	set_light_on(TRUE)
	playsound(source = src, soundin = 'sound/machines/terminal_processing.ogg', vol = 20, vary = FALSE, ignore_walls = FALSE)
	balloon_alert_to_viewers("live!")

/// When deactivating the camera
/obj/item/broadcast_camera/proc/on_deactivating()
	active = FALSE
	update_icon_state()
	QDEL_NULL(internal_camera)
	QDEL_NULL(internal_radio)

	stop_broadcasting_network(camera_networks)

	set_light_on(FALSE)
	playsound(source = src, soundin = 'sound/machines/terminal_prompt_deny.ogg', vol = 20, vary = FALSE, ignore_walls = FALSE)
	balloon_alert_to_viewers("offline")

/obj/item/broadcast_camera/proc/ensure_still_active()
	if(!active)
		return FALSE
	if(!isliving(loc))
		return FALSE
	var/mob/living/wielder = loc
	if(!wielder.is_holding(src))
		return FALSE
	return TRUE

/obj/item/broadcast_camera/click_alt(mob/user)
	active_microphone = !active_microphone

	/// Text popup for letting the user know that the microphone has changed state
	balloon_alert(user, "microphone [active_microphone ? "" : "de"]activated")

	///If the radio exists as an object, set its state accordingly
	if(active)
		set_microphone_state()

	return CLICK_ACTION_SUCCESS

/obj/item/broadcast_camera/proc/set_microphone_state()
	internal_radio.set_broadcasting(active_microphone)

/datum/status_effect/streamer
	id = "streamer"
	alert_type = null
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	/// How many people are currently watching the stream.
	var/viewers = 0
	/// The camera being used to stream.
	var/obj/machinery/camera/camera
	/// Simple screen element used to hold the maptext for the viewer counter.
	var/atom/movable/screen/stream_viewers/viewer_display
	/// Callback to see if the stream is still valid.
	var/datum/callback/extra_checks

/datum/status_effect/streamer/Destroy()
	extra_checks = null
	camera = null
	return ..()

/datum/status_effect/streamer/on_creation(mob/living/new_owner, obj/machinery/camera/camera, datum/callback/extra_checks)
	src.camera = camera
	src.extra_checks = extra_checks
	return ..()

/datum/status_effect/streamer/on_apply()
	if(QDELETED(camera))
		return FALSE
	else if(!istype(camera))
		CRASH("Invalid camera ([camera]) passed to [type] (expected an /obj/machinery/camera)")
	if(extra_checks && !extra_checks.Invoke(src))
		return FALSE
	give_hud()
	RegisterSignal(owner, COMSIG_MOB_LOGIN, PROC_REF(give_hud))
	RegisterSignal(owner, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))
	RegisterSignal(camera, COMSIG_QDELETING, PROC_REF(hamburger_time))
	return TRUE

/datum/status_effect/streamer/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOB_LOGIN, COMSIG_MOB_GET_STATUS_TAB_ITEMS))
	UnregisterSignal(camera, COMSIG_QDELETING)
	if(!isnull(viewer_display))
		owner.client?.screen -= viewer_display
		QDEL_NULL(viewer_display)

/datum/status_effect/streamer/before_remove(source)
	if(!isnull(source) && !QDELETED(camera) && source == camera)
		return FALSE
	return ..()

/datum/status_effect/streamer/tick(seconds_between_ticks, times_fired)
	if(extra_checks && !extra_checks.Invoke(src))
		qdel(src)
		return
	viewers = camera.count_spesstv_viewers()
	viewer_display?.update_maptext(camera.count_spesstv_viewers())

/datum/status_effect/streamer/proc/give_hud()
	SIGNAL_HANDLER
	if(QDELETED(viewer_display))
		viewer_display = new
	viewers = camera.count_spesstv_viewers()
	viewer_display.update_maptext(viewers)
	owner.client?.screen |= viewer_display

/datum/status_effect/streamer/proc/get_status_tab_item(mob/living/source, list/items)
	SIGNAL_HANDLER
	items += "Stream Viewers: [viewers]"

/datum/status_effect/streamer/proc/hamburger_time()
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/stream_viewers
	screen_loc = ui_more_under_health_and_to_the_left
	maptext_width = 84
	maptext_height = 24

/atom/movable/screen/stream_viewers/proc/update_maptext(amt)
	maptext = "<div align='left' valign='top' style='position: relative; top: 0px; left: 6px'>Viewers: <font color='#33FF33'>[amt]</font></div>"
