



/datum/rune_spell/communication
	name = "Communication"
	desc = "Speak so that every cultists may hear your voice. Can be used even when there is no spire nearby."
	desc_talisman = "Use it to write and send a message to all followers of Nar-Sie. When in the middle of a ritual, use it again to transmit a message that will be remembered by all."
	invocation = "O bidai nabora se'sma!"
	rune_flags = RUNE_STAND
	talisman_uses = 10
	var/obj/effect/cult_ritual/cult_communication/comms = null
	word1 = /datum/rune_word/self
	word2 = /datum/rune_word/other
	word3 = /datum/rune_word/technology
	page = "By standing on top of the rune and touching it, everyone in the cult will then be able to hear what you say or whisper. \
		You will also systematically speak in the language of the cult when using it.\
		<br><br>Talismans imbued with this rune can be used 10 times to send messages to the rest of the cult.\
		<br><br>Lastly touching the rune a second time while you are already using it lets you set cult reminders that will be heard by newly converts and added to their notes.\
		<br><br>This rune persists upon use, allowing repeated usage."

/datum/rune_spell/communication/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()
	var/mob/living/user = activator
	comms = new /obj/effect/cult_ritual/cult_communication(spell_holder.loc, user, src)

/datum/rune_spell/communication/midcast(mob/living/user)
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (!istype(cult))
		return
	if (!istype(user)) // Ghosts
		return
	var/reminder = input("Write the reminder.", text("Cult reminder")) as null | message
	if (!reminder)
		return
	reminder = strip_html(reminder) // No weird HTML
	var/number = cult.cult_reminders.len
	var/text = "[number + 1]) [reminder], by [user.real_name]."
	cult.cult_reminders += text
	for(var/datum/mind/mind in cult.members)
		if (IS_CULTIST(mind.current))//failsafe for cultist brains put in MMIs
			to_chat(mind.current, span_cult("<b>[user.real_name]</b>'s voice echoes in your head, [span_cultbold(reminder)]"))

	for(var/mob/living/basic/astral_projection/astral in GLOB.astral_projections)
		to_chat(astral, span_cult("<b>[user.real_name]</b>'s voice echoes in your head, [span_cultbold(reminder)]"))

	for(var/mob/dead/observer/observer in GLOB.player_list)
		to_chat(observer, span_cult("<b>[user.real_name]</b>'s voice echoes in your head, [span_cultbold(reminder)]"))

	//log_cultspeak("[key_name(user)] Cult reminder: [reminder]")

/datum/rune_spell/communication/cast_talisman()//we write our message on the talisman, like in previous versions.
	var/message = sanitize(input("Write a message to send to your acolytes.", "Blood Letter", "") as null|message, MAX_MESSAGE_LEN)
	if(!message)
		return

	var/datum/antagonist/cult/team = activator.mind?.has_antag_datum(/datum/antagonist/cult)
	var/datum/team/cult = team.cult_team
	for (var/datum/mind/mind in cult.members)
		if (IS_CULTIST(mind.current))//failsafe for cultist brains put in MMIs
			to_chat(mind.current, span_cult("<b>[activator.real_name]</b>'s voice echoes in your head, [span_cultbold(message)]"))

	for(var/mob/living/basic/astral_projection/astral in GLOB.astral_projections)
		to_chat(astral, span_cult("<b>[activator.real_name]</b>'s voice echoes in your head, [span_cultbold(message)]"))

	for(var/mob/dead/observer/observer in GLOB.player_list)
		to_chat(observer, span_cult("<b>[activator.real_name]</b>'s voice echoes in your head, [span_cultbold(message)]"))

	//log_cultspeak("[key_name(activator)] Cult Communicate Talisman: [message]")

	qdel(src)

/datum/rune_spell/communication/Destroy()
	destroying_self = 1
	if (comms)
		qdel(comms)
	comms = null
	..()

/obj/effect/cult_ritual/cult_communication
	anchored = 1
	icon_state = "rune_communication"
	pixel_y = 8
	alpha = 200
	layer = ABOVE_OBJ_LAYER
	plane = GAME_PLANE
	mouse_opacity = 0
	var/mob/living/caster = null
	var/datum/rune_spell/communication/source = null


/obj/effect/cult_ritual/cult_communication/New(turf/loc, mob/living/user, datum/rune_spell/communication/runespell)
	..()
	caster = user
	source = runespell

/obj/effect/cult_ritual/cult_communication/Destroy()
	caster = null
	source = null
	..()

/obj/effect/cult_ritual/cult_communication/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	if(speaker && speaker.loc == loc)
		var/speaker_name = speaker.name
		var/mob/living/L
		if (isliving(speaker))
			L = speaker
			if (!IS_CULTIST(L))//geez we don't want that now do we
				return
		if (ishuman(speaker))
			var/mob/living/carbon/human/human = speaker
			speaker_name = human.real_name
			L = speaker

		//var/rendered_message =  compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mods)
		var/datum/antagonist/cult/user = L?.mind?.has_antag_datum(/datum/antagonist/cult)
		var/datum/team/cult/cult = user.cult_team
		for (var/datum/mind/mind in cult.members)
			if (mind.current == speaker)//echoes are annoying
				continue
			if (IS_CULTIST(mind.current))//failsafe for cultist brains put in MMIs
				to_chat(mind.current, "<span class = 'game say'><b>[speaker_name]</b>'s voice echoes in your head, <B><span class = 'sinisterbig'>[raw_message]</span></B></span>")

		for(var/mob/living/basic/astral_projection/astral in GLOB.astral_projections)
			to_chat(astral, "<span class = 'game say'><b>[speaker_name]</b> communicates, <span class = 'sinisterbig'>[raw_message]</span></span>")

		for(var/mob/dead/observer/observer in GLOB.player_list)
			to_chat(observer, "<span class = 'game say'><b>[speaker_name]</b> communicates, <span class = 'sinisterbig'>[raw_message]</span></span>")
		//log_cultspeak("[key_name(speech.speaker)] Cult Communicate Rune: [rendered_message]")

/obj/effect/cult_ritual/cult_communication/HasProximity(atom/movable/AM)
	if (!caster || caster.loc != loc)
		if (source)
			source.abort(RITUALABORT_GONE)
		qdel(src)
