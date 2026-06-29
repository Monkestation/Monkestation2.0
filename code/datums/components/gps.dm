///Global GPS_list. All  GPS components get saved in here for easy reference.
GLOBAL_LIST_EMPTY(GPS_list)
///GPS component. Atoms that have this show up on gps. Pretty simple stuff.
/datum/component/gps
	var/gpstag = "COM0"
	var/tracking = TRUE
	var/emped = FALSE

/datum/component/gps/Initialize(_gpstag = "COM0")
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	gpstag = _gpstag
	GLOB.GPS_list += src

/datum/component/gps/Destroy()
	GLOB.GPS_list -= src
	return ..()

/datum/component/gps/kheiral_cuffs

/datum/component/gps/kheiral_cuffs/Initialize(_gpstag = "COM0")
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(deactivate_kheiral_cuffs))

/datum/component/gps/kheiral_cuffs/proc/deactivate_kheiral_cuffs(datum/source)
	SIGNAL_HANDLER
	qdel(src)

///GPS component subtype. Only gps/item's can be used to open the UI.
/datum/component/gps/item
	var/updating = TRUE //Automatic updating of GPS list. Can be set to manual by user.
	var/global_mode = TRUE //If disabled, only GPS signals of the same Z level are shown
	/// UI state of GPS, altering when it can be used.
	var/datum/ui_state/state = null
	var/uses_overlays = TRUE

/datum/component/gps/item/proc/handle_overlay()
	if(!uses_overlays)
		return
	var/atom/A = parent
	A.cut_overlay("working")
	A.cut_overlay("emp")
	if(emped)
		A.add_overlay("emp")
		return
	if(tracking)
		A.add_overlay("working")
		return

/datum/component/gps/item/Initialize(_gpstag = "COM0", emp_proof = FALSE, state = null, requires_z_calibration, list/calibrate_zs, uses_overlays = TRUE)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE || !isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(isnull(state))
		state = GLOB.default_state
	src.state = state

	src.uses_overlays = uses_overlays

	var/obj/item/parent_item = parent
	parent_item.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	handle_overlay()
	parent_item.name = "[initial(parent_item.name)] ([gpstag])"
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(interact))
	if(!emp_proof)
		RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_AltClick))
	RegisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

	if(!isnull(requires_z_calibration))
		src.requires_z_calibration = requires_z_calibration
	if(islist(calibrate_zs))
		src.calibrated_zs = calibrate_zs

///Called on COMSIG_ITEM_ATTACK_SELF
/datum/component/gps/item/proc/interact(datum/source, mob/user)
	SIGNAL_HANDLER

	if(user)
		INVOKE_ASYNC(src, PROC_REF(ui_interact), user)

///Called on COMSIG_ATOM_EXAMINE
/datum/component/gps/item/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("Alt-click to switch it [tracking ? "off":"on"].")

///Called on COMSIG_ATOM_EMP_ACT
/datum/component/gps/item/proc/on_emp_act(datum/source, severity)
	SIGNAL_HANDLER

	emped = TRUE
	handle_overlay()
	addtimer(CALLBACK(src, PROC_REF(reboot)), 30 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //if a new EMP happens, remove the old timer so it doesn't reactivate early
	SStgui.close_uis(src) //Close the UI control if it is open.

///Restarts the GPS after getting turned off by an EMP.
/datum/component/gps/item/proc/reboot()
	emped = FALSE
	handle_overlay()

/datum/component/gps/item/proc/on_requesting_context_from_item(atom/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	context[SCREENTIP_CONTEXT_ALT_LMB] = tracking ? "Turn off" : "Turn on"
	return CONTEXTUAL_SCREENTIP_SET

///Calls toggletracking
/datum/component/gps/item/proc/on_AltClick(datum/source, mob/user)
	SIGNAL_HANDLER

	toggletracking(user)
	return COMPONENT_CANCEL_CLICK_ALT

///Toggles the tracking for the gps
/datum/component/gps/item/proc/toggletracking(mob/user)
	if(user && !user?.can_perform_action(parent, ALLOW_RESTING|ALLOW_PAI))
		return //user not valid to use gps
	if(emped)
		if(user)
			to_chat(user, span_warning("It's busted!"))
		return
	if(tracking)
		if(user)
			to_chat(user, span_notice("[parent] is no longer tracking, or visible to other GPS devices."))
		tracking = FALSE
	else
		if(user)
			to_chat(user, span_notice("[parent] is now tracking, and visible to other GPS devices."))
		tracking = TRUE
	SEND_SIGNAL(parent, COMSIG_GPS_TOGGLED_TRACKING, tracking)
	handle_overlay()

/datum/component/gps/item/ui_interact(mob/user, datum/tgui/ui)
	if(emped)
		to_chat(user, span_hear("[parent] fizzles weakly."))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Gps")
		ui.open()
	ui.set_autoupdate(updating)

/datum/component/gps/item/ui_state(mob/user)
	return state

/datum/component/gps/item/ui_data(mob/user)
	var/list/data = list()
	data["power"] = tracking
	data["tag"] = gpstag
	data["updating"] = updating
	data["globalmode"] = global_mode
	if(!tracking || emped) //Do not bother scanning if the GPS is off or EMPed
		return data

	var/turf/curr = get_turf(parent)
	data["currentArea"] = "[get_area_name(curr, TRUE)]"
	data["currentCoords"] = "[curr.x], [curr.y], [curr.z]"

	var/list/signals = list()
	data["signals"] = list()

	for(var/datum/component/gps/gps as anything in GLOB.GPS_list)
		if(gps == src || gps.emped || !gps.tracking)
			continue
		var/turf/pos = get_turf(gps.parent)
		if(!pos || (!global_mode && pos.z != curr.z))
			continue
		var/list/signal = list()
		signal["entrytag"] = gps.gpstag //Name or 'tag' of the GPS
		signal["coords"] = "[pos.x], [pos.y], [pos.z]"
		// Distance is calculated for the same z-level only, and direction is calculated for crosslinked/neighboring and same z-levels.
		if(pos.z == curr.z)
			signal["dist"] = max(get_dist(curr, pos), 0) //Distance between the src and remote GPS turfs
			signal["degrees"] = round(get_angle(curr, pos)) //0-360 degree directional bearing, for more precision.
		else if(can_point_to_z_level(pos.z)) // monkestation edit: require calibration to point to remove z-levels
			var/angle = get_linked_z_angle(curr.z, pos.z)
			if(!isnull(angle))
				signal["degrees"] = angle
		signals += list(signal) //Add this signal to the list of signals
	data["signals"] = signals
	return data

/datum/component/gps/item/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("rename")
			var/atom/parentasatom = parent
			var/a = tgui_input_text(usr, "Enter the desired tag", "GPS Tag", gpstag, 20)

			if (!a)
				return

			gpstag = a
			. = TRUE
			usr.log_message("renamed [parentasatom] to \"[initial(parentasatom.name)] ([gpstag])\".", LOG_GAME)
			parentasatom.name = "[initial(parentasatom.name)] ([gpstag])"

		if("power")
			toggletracking(usr)
			. = TRUE
		if("updating")
			updating = !updating
			. = TRUE
		if("globalmode")
			global_mode = !global_mode
			. = TRUE

/datum/component/gps/item/security_gps
	tracking = FALSE // start turned off
	var/jammed = FALSE

/datum/component/gps/item/security_gps/Initialize(_gpstag = "COM0", emp_proof = FALSE, state = null, requires_z_calibration, list/calibrate_zs)
	. = ..()
	RegisterSignal(parent, COMSIG_SEC_GPS_ALERT, PROC_REF(send_alert))

/datum/component/gps/item/security_gps/handle_overlay()
	var/atom/A = parent
	A.cut_overlay("working")
	A.cut_overlay("emp")
	A.cut_overlay("broken")
	if(jammed)
		A.add_overlay("broken")
		return
	if(emped)
		A.add_overlay("emp")
		return
	if(tracking)
		A.add_overlay("working")
		return

/datum/component/gps/item/security_gps/proc/get_gps_list_to_alert()
	var/list/gps_to_alert = list()
	var/turf/curr = get_turf(parent)
	for(var/datum/component/gps/item/security_gps/other_gps as anything in GLOB.GPS_list)
		if(other_gps == src || other_gps.emped || !other_gps.tracking)
			continue
		var/turf/pos = get_turf(other_gps.parent)
		if(!pos || (!global_mode && pos.z != curr.z))
			continue
		gps_to_alert += other_gps
	return gps_to_alert

/datum/component/gps/item/security_gps/proc/get_jammed_gps()
	var/list/jammed_gps = list()
	for(var/datum/component/gps/item/security_gps/other_gps in get_gps_list_to_alert())
		if(!other_gps.jammed)
			continue
		jammed_gps += other_gps
	return jammed_gps.len ? pick(jammed_gps) : 0

/datum/component/gps/item/security_gps/proc/send_alert(atom/source, alert_text)
	SIGNAL_HANDLER

	var/obj/item/gps/security/our_gps_device = parent

	playsound(our_gps_device, 'sound/items/gps/four_ping.ogg', 50, TRUE)
	our_gps_device.say("Transmitting distress signal...")

	addtimer(CALLBACK(src, PROC_REF(attempt_to_send_signal), alert_text), 8 SECONDS)

/datum/component/gps/item/security_gps/proc/attempt_to_send_signal(alert_text)
	if(!tracking || emped || jammed)
		return

	var/obj/item/gps/security/our_gps_device = parent

	our_gps_device.say("Signal sent.")
	playsound(our_gps_device, 'sound/items/gps/one_ping.ogg', 35, TRUE)

	var/jammed_signal = FALSE
	for(var/datum/component/gps/item/security_gps/other_gps in get_gps_list_to_alert())
		if(other_gps.jammed || other_gps.emped)
			continue
		var/obj/item/gps/security/original_alerting_gps_device = other_gps.parent
		if(is_within_radio_jammer_range(original_alerting_gps_device))
			continue
		var/datum/component/gps/item/security_gps/jamming_gps = get_jammed_gps()
		if(jamming_gps)
			var/turf/actual_gps_turf = get_turf(our_gps_device)
			our_gps_device = jamming_gps.parent
			if(our_gps_device.can_play_jam_sound)
				playsound(our_gps_device, 'sound/items/gps/radio_jammer.ogg', 35, TRUE)
				our_gps_device.say("[Gibberish("///%<SIGNAL INTERCEPTED>{SEND}source.create_feedback_loop", TRUE, 50)] ([get_area_name(actual_gps_turf, TRUE)]) ([actual_gps_turf.x], [actual_gps_turf.y], [actual_gps_turf.z])")
				our_gps_device.can_play_jam_sound = FALSE
				addtimer(CALLBACK(src, PROC_REF(reset_jam_sound), our_gps_device), 1 SECOND)
			jammed_signal = TRUE
		var/turf/gps_turf = get_turf(our_gps_device)
		var/full_alert_text = "Alert. [gpstag]: [alert_text] ([get_area_name(gps_turf, TRUE)]) ([gps_turf.x], [gps_turf.y], [gps_turf.z])"
		// if(jammed_signal)
		// 	full_alert_text = "Alert. [Gibberish("[gpstag]: [alert_text]", TRUE, 75)] ([gps_turf.x], [gps_turf.y], [gps_turf.z])"
		original_alerting_gps_device.say(full_alert_text)
		playsound(original_alerting_gps_device, 'sound/items/gps/one_ping.ogg', 35, TRUE)

	if(tracking && jammed_signal)
		toggletracking()

/datum/component/gps/item/security_gps/proc/reset_jam_sound(obj/item/gps/security/gps_device)
	gps_device.can_play_jam_sound = TRUE
