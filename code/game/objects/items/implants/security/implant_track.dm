/obj/item/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	actions_types = null
	implant_flags = IMPLANT_TYPE_SECURITY
	hud_icon_state = "hud_imp_tracking"

	has_surgical_warning = TRUE

	///How long will the implant continue to function after death?
	var/lifespan_postmortem = 10 MINUTES
	///will people implanted with this act as teleporter beacons?
	var/allow_teleport = FALSE
	//internal radio used for broadcasting to security when the tracker is surgically removed
	var/obj/item/radio/internal_radio

/obj/item/radio/internal_tracker_radio
	keyslot = new /obj/item/encryptionkey/headset_sec
	subspace_transmission = TRUE
	canhear_range = 0
	ignores_radio_jammers = TRUE

/obj/item/radio/internal_tracker_radio/Initialize(mapload)
	. = ..()

	src.set_listening(FALSE)
	src.recalculateChannels()

/obj/item/implant/tracking/c38
	name = "TRAC implant"
	desc = "A smaller tracking implant that supplies power for only a few minutes."
	implant_flags = NONE
	///How long before this implant self-deletes?
	var/lifespan = 5 MINUTES
	///The id of the timer that's qdeleting us
	var/timerid

/obj/item/implant/tracking/c38/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	timerid = QDEL_IN_STOPPABLE(src, lifespan)

/obj/item/implant/tracking/c38/removed(mob/living/source, silent, special)
	. = ..()
	deltimer(timerid)
	timerid = null

/obj/item/implant/tracking/miner
	name = "miner tracking implant"
	desc = "A modified tracker implant with a built-in teleportation beacon to recover shaft miners."

	has_surgical_warning = FALSE
	allow_teleport = TRUE

/obj/item/implant/tracking/Initialize(mapload)
	. = ..()
	internal_radio = new /obj/item/radio/internal_tracker_radio(src)

/obj/item/implant/tracking/Destroy()
	QDEL_NULL(internal_radio)
	return ..()

/obj/item/implant/tracking/on_surgical_removal_attempt()
	say("Attention! You are removing a legally placed security implant. Please be warned this will notify the security department of your location.")
	return ..()

/obj/item/implant/tracking/on_surgical_removal_complete()
	var/area/location = get_area(src)
	internal_radio.talk_into(src, "Attention! Parolee [imp_in.get_visible_name(FALSE)] has had their tracking implant removed in [location]. Please monitor for anti-social behavior.", RADIO_CHANNEL_SECURITY)

/obj/item/implanter/tracking
	imp_type = /obj/item/implant/tracking

/obj/item/implanter/tracking/gps
	imp_type = /obj/item/gps/mining/internal

/obj/item/implant/tracking/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp EYE-5 Convict Parole Implant<BR>
				<b>Life:</b> 10 minutes after death of host.<BR>
				<HR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Continuously transmits low power signal. Can be tracked from a prisoner management console.<BR>
				<b>Special Features:</b><BR>
				<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
				a malfunction occurs thereby securing safety of subject. The implant will melt and
				disintegrate into bio-safe elements.<BR>"}
	return dat

/obj/item/implant/tracking/is_shown_on_console(obj/machinery/computer/prisoner/management/console)
	if(imp_in.stat == DEAD && imp_in.timeofdeath + lifespan_postmortem < world.time)
		return FALSE
	if(!is_valid_z_level(get_turf(console), get_turf(imp_in)))
		return FALSE
	return TRUE

/obj/item/implant/tracking/get_management_console_data()
	. = ..()
	.["Location"] = get_area_name(imp_in, format_text = TRUE) || "Unknown"

/obj/item/implant/tracking/get_management_console_buttons()
	var/list/buttons = ..()
	UNTYPED_LIST_ADD(buttons, list(
		"name" = "Warn",
		"color" = "average",
		"tooltip" = "Sends a message directly to the target's brain.",
		"action_key" = "warn",
	))
	return buttons

/obj/item/implant/tracking/handle_management_console_action(mob/user, list/params, obj/machinery/computer/prisoner/management/console)
	. = ..()
	if(.)
		return

	if(params["implant_action"] == "warn")
		var/warning = tgui_input_text(user, "What warning do you want to send to [imp_in.name]?", "Messaging")
		if(!warning || QDELETED(src) || QDELETED(user) || QDELETED(console) || isnull(imp_in))
			return TRUE
		if(!console.is_operational || !user.can_perform_action(console, NEED_DEXTERITY|ALLOW_SILICON_REACH))
			return TRUE

		to_chat(imp_in, span_hear("You hear a voice in your head saying: '[warning]'"))
		log_directed_talk(user, imp_in, warning, LOG_SAY, "implant message")
		return TRUE
