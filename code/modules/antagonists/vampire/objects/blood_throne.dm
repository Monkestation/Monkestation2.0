/// Blood Throne - Allows Vampires to remotely speak with their vassals. - Code (Mostly) stolen from comfy chairs (armrests) and chairs (layers)
/obj/structure/vampire/bloodthrone
	name = "blood throne"
	desc = "Twisted metal shards jut from the arm rests. Very uncomfortable looking. It would take a masochistic sort to sit on this jagged piece of furniture."
	icon = 'icons/vampires/vamp_obj_64.dmi'
	icon_state = "throne"
	buckle_lying = 0
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	ghost_desc = "This is a blood throne. Any vampire sitting on it can remotely speak to all other vampires by attempting to speak aloud."
	vampire_desc = "This is a blood throne. Sitting on it will allow you to communicate telepathically to all other vampires by simply speaking."
	vassal_desc = "This is a blood throne. It allows your master to telepathically speak to all other vampires."
	curator_desc = "This is a chair that hurts those who try to buckle themselves onto it, though the undead have no problem latching on.\n\
		While buckled, monsters can use this to telepathically communicate with each other."

// Add rotating and armrest
/obj/structure/vampire/bloodthrone/Initialize(mapload)
	AddComponent(/datum/component/simple_rotation)
	return ..()

// Rotating
/obj/structure/vampire/bloodthrone/setDir(newdir)
	. = ..()
	for(var/mob/living/buckled in buckled_mobs)
		buckled.setDir(newdir)

	if(has_buckled_mobs() && dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

/obj/structure/vampire/bloodthrone/update_overlays()
	. = ..()
	if(has_buckled_mobs())
		var/mutable_appearance/armrest = mutable_appearance('icons/vampires/vamp_obj_64.dmi', "thronearm")
		armrest.layer = ABOVE_MOB_LAYER
		. += armrest

// Buckling
/obj/structure/vampire/bloodthrone/buckle_mob(mob/living/user, force = FALSE, check_loc = TRUE)
	if(!anchored)
		to_chat(user, span_announce("[src] is not bolted to the ground!"))
		return
	set_density(FALSE)
	. = ..()
	set_density(TRUE)
	user.visible_message(
		span_notice("[user] sits down on \the [src]."),
		span_boldnotice("You sit down onto [src]."),
	)
	if(IS_VAMPIRE(user))
		RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		unbuckle_mob(user)
		user.Paralyze(10 SECONDS)
		to_chat(user, span_cult("The power of the blood throne overwhelms you!"))

/obj/structure/vampire/bloodthrone/post_buckle_mob(mob/living/target)
	update_appearance(UPDATE_OVERLAYS)
	target.pixel_z += 2

// Unbuckling
/obj/structure/vampire/bloodthrone/unbuckle_mob(mob/living/user, force = FALSE, can_fall = TRUE)
	visible_message(span_danger("[user] unbuckles [user.p_them()]self from \the [src]."))
	if(IS_VAMPIRE(user))
		UnregisterSignal(user, COMSIG_MOB_SAY)
	return ..()

/obj/structure/vampire/bloodthrone/post_unbuckle_mob(mob/living/target)
	target.pixel_z -= 2
	update_appearance(UPDATE_OVERLAYS)

// The speech itself
/obj/structure/vampire/bloodthrone/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(speech_args[SPEECH_FORCED])
		return

	var/message = speech_args[SPEECH_MESSAGE]
	var/mob/living/carbon/human/user = source
	var/rendered = span_cultlarge("<b>[user.real_name]:</b> [message]")
	user.log_talk(message, LOG_SAY, tag = ROLE_VAMPIRE)

	for(var/datum/antagonist/vampire/receiver as anything in GLOB.all_vampires)
		if(!receiver.owner.current)
			continue
		var/mob/receiver_mob = receiver.owner.current
		to_chat(receiver_mob, rendered, type = MESSAGE_TYPE_RADIO, avoid_highlighting = receiver_mob == user)

	var/datum/antagonist/vampire/vampire_datum = IS_VAMPIRE(user)

	for(var/datum/antagonist/vassal/vassal as anything in vampire_datum.vassals)
		if(!vassal.owner.current)
			continue
		var/mob/receiver_mob = vassal.owner.current
		to_chat(receiver_mob, rendered, type = MESSAGE_TYPE_RADIO)

	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, user)
		to_chat(dead_mob, "[link] [rendered]", type = MESSAGE_TYPE_RADIO)

	speech_args[SPEECH_MESSAGE] = ""
