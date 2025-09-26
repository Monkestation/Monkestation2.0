/obj/item/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	actions_types = null

	has_surgical_warning = TRUE

	///for how many deciseconds after user death will the implant work?
	var/lifespan_postmortem = 6000
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
	var/lifespan = 3000 //how many deciseconds does the implant last?
	///The id of the timer that's qdeleting us
	var/timerid
	allow_teleport = FALSE

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
	return ..()

/obj/item/implanter/tracking
	imp_type = /obj/item/implant/tracking

/obj/item/implanter/tracking/gps
	imp_type = /obj/item/gps/mining/internal

/obj/item/implant/tracking/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Tracking Beacon<BR>
				<b>Life:</b> 10 minutes after death of host.<BR>
				<b>Important Notes:</b> Implant [allow_teleport ? "also works" : "does not work"] as a teleporter beacon.<BR>
				<HR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Continuously transmits low power signal. Useful for tracking.<BR>
				<b>Special Features:</b><BR>
				<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
				a malfunction occurs thereby securing safety of subject. The implant will melt and
				disintegrate into bio-safe elements.<BR>
				<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
				circuitry. As a result neurotoxins can cause massive damage."}
	return dat
