/obj/structure/desk_bell/departmental
	name = "department bell"
	desc = "The cornerstone of any customer service job. Ringing it sends an announcement to the relevant radio channel."

	ring_cooldown_length = 0.6 SECONDS // twice as slow
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF // Nothing stops the bell.
	var/announce_cooldown_length = 60 SECONDS // WHAT? I CANT HEAR YOU OVER THE RADIO BEING SPAMMED.
	/// The cooldown for announcing the bell
	COOLDOWN_DECLARE(announce_cooldown)
	///The machine's internal radio, used to broadcast alerts.
	var/obj/item/radio/radio
	var/radio_channel = FREQ_COMMON
	///Location of bell to be used in the announcement.
	var/bell_location = "Front Desk"
	// doesnt stop you from stealing the bell, just doesnt mean you can ring it every minute without consequence.
	var/antitheft = FALSE
	var/starting_location

/obj/structure/desk_bell/departmental/Initialize(mapload)
	. = ..()
	set_anchored(TRUE)
	radio = new(src)
	radio.canhear_range = 0
	radio.set_listening(FALSE)
	radio.set_frequency(radio_channel)
	radio.freerange = TRUE
	radio.freqlock = RADIO_FREQENCY_LOCKED
	radio.command = TRUE // >I think high volume but with a longer delay is a good idea. --Bounty OP
	radio.use_command = TRUE
	starting_location = get_area(loc)


/obj/structure/desk_bell/departmental/add_context(atom/source, list/context, obj/item/held_item, mob/user)

	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "Secure"
		return CONTEXTUAL_SCREENTIP_SET

	if(broken_ringer)
		if(held_item?.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "Fix"
	else
		var/click_context = "Ring"
		if(prob(1))
			click_context = "Annoy"
		context[SCREENTIP_CONTEXT_LMB] = click_context
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/desk_bell/departmental/wrench_act_secondary(mob/living/user, obj/item/tool)
	return FALSE

/obj/structure/desk_bell/departmental/check_clapper(mob/living/user)
	return //NOTHING.

/obj/structure/desk_bell/departmental/MouseDrop(obj/over_object, src_location, over_location)
	if(istype(over_object, /obj/vehicle/ridden/wheelchair))
		usr.balloon_alert(usr, "cannot use a department bell!")
		return // makes absolutely certain this cant be used for a wheelchair bell
	return ..()

/obj/structure/desk_bell/departmental/ring_bell(mob/living/user)
	. = ..()
	if(COOLDOWN_FINISHED(src, announce_cooldown) && announce_cooldown_length)
		COOLDOWN_START(src, announce_cooldown, announce_cooldown_length)
		balloon_alert(user, "department notified")
		var/message = "Assistance requested at [bell_location]."
		if(!antitheft && get_area(loc) != starting_location) //antitheft
			antitheft = TRUE
			src.visible_message(span_warning("[src] starts flashing red and blares an alarm!"))
			message += " Anti-Theft triggered, GPS signal established."
			AddComponent(/datum/component/gps, "DBELL-[radio_channel]")
		radio.talk_into(src, message, radio_channel)

/obj/structure/desk_bell/departmental/security
	radio_channel = FREQ_SECURITY

/obj/structure/desk_bell/departmental/engineering
	radio_channel = FREQ_ENGINEERING

/obj/structure/desk_bell/departmental/command
	radio_channel = FREQ_COMMAND

/obj/structure/desk_bell/departmental/command/hop
	bell_location = "Head of Personnel's Office"

/obj/structure/desk_bell/departmental/science
	radio_channel = FREQ_SCIENCE

/obj/structure/desk_bell/departmental/medical
	radio_channel = FREQ_MEDICAL

/obj/structure/desk_bell/departmental/supply
	radio_channel = FREQ_SUPPLY

/obj/structure/desk_bell/departmental/service
	radio_channel = FREQ_SERVICE
