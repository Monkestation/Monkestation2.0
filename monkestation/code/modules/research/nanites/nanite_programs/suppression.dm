//Programs that are generally useful for population control and non-harmful suppression.

/datum/nanite_program/sleepy
	name = "Sleep Induction"
	desc = "The nanites induce rapid narcolepsy when triggered, putting the host to sleep for around 20 seconds after a random delay." //the "around" is an ass-covering manuever and i do not apologize
	can_trigger = TRUE
	trigger_cost = 15
	trigger_cooldown = 1200
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/sleepy/on_trigger(comm_message)
	to_chat(host_mob, span_warning("You start to feel very sleepy..."))
	host_mob.adjust_drowsiness(1 SECONDS)
	addtimer(CALLBACK(host_mob, TYPE_PROC_REF(/mob/living, Sleeping), 200), rand(60,200))

/datum/nanite_program/slow
	name = "Muscle Impairment"
	desc = "The nanites force muscle contraction, slowing the host down."
	use_rate = 2
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/movespeed_modifier/nanite_paralyze
	multiplicative_slowdown = 1				//Might need to balance how much this is?

/datum/nanite_program/slow/enable_passive_effect()
	. = ..()
	to_chat(host_mob, span_warning("Your muscles seize! Moving becomes hard!"))
	host_mob.add_movespeed_modifier(/datum/movespeed_modifier/nanite_paralyze)
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.stun_mod *= 1.25

/datum/nanite_program/slow/disable_passive_effect()
	. = ..()
	to_chat(host_mob, span_notice("Your muscles relax, and you can move easily again."))
	host_mob.remove_movespeed_modifier(/datum/movespeed_modifier/nanite_paralyze)
	if(ishuman(host_mob) && !QDELING(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.stun_mod *= 0.8

/datum/nanite_program/shocking
	name = "Electric Shock"
	desc = "The nanites shock the host when triggered. Destroys a large amount of nanites!"
	can_trigger = TRUE
	trigger_cost = 10
	trigger_cooldown = 300
	program_flags = NANITE_SHOCK_IMMUNE
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/shocking/on_trigger(comm_message)
	host_mob.electrocute_act(rand(5,10), "shock nanites", 1, SHOCK_NOGLOVES)

/datum/nanite_program/stun
	name = "Neural Shock"
	desc = "The nanites pulse the host's nerves when triggered, incapacitating them for about 4 seconds."
	can_trigger = TRUE
	trigger_cost = 4
	trigger_cooldown = 300
	rogue_types = list(/datum/nanite_program/shocking, /datum/nanite_program/nerve_decay)

/datum/nanite_program/stun/on_trigger(comm_message)
	playsound(host_mob, "sparks", 75, TRUE, -1, SHORT_RANGE_SOUND_EXTRARANGE)
	host_mob.Paralyze(80)

/datum/nanite_program/pacifying		//Extremely powerful in a fight, but you can still at least run away.
	name = "Pacification"
	desc = "The nanites suppress the aggression center of the brain, preventing the host from causing direct harm to others."
	use_rate = 2
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/pacifying/enable_passive_effect()
	. = ..()
	ADD_TRAIT(host_mob, TRAIT_PACIFISM, NANITES_TRAIT)

/datum/nanite_program/pacifying/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_PACIFISM, NANITES_TRAIT)

/datum/nanite_program/blinding
	name = "Optical Disruption"
	desc = "The nanites suppress the host's ocular nerves, making them nearsighted and making it harder to aim guns."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/blinding/enable_passive_effect()
	. = ..()
	host_mob.become_nearsighted(NANITES_TRAIT)
	ADD_TRAIT(host_mob, TRAIT_POOR_AIM, NANITES_TRAIT)

/datum/nanite_program/blinding/disable_passive_effect()
	. = ..()
	host_mob.cure_nearsighted(NANITES_TRAIT)
	REMOVE_TRAIT(host_mob, TRAIT_POOR_AIM, NANITES_TRAIT)

/datum/nanite_program/mute
	name = "Mute"
	desc = "The nanites suppress the host's speech, making them mute while they're active."
	use_rate = 0.75
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)

/datum/nanite_program/mute/enable_passive_effect()
	. = ..()
	ADD_TRAIT(host_mob, TRAIT_MUTE, NANITES_TRAIT)

/datum/nanite_program/mute/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_MUTE, NANITES_TRAIT)

/datum/nanite_program/fake_death
	name = "Death Simulation"
	desc = "The nanites induce a death-like coma into the host, able to fool most medical scans."
	use_rate = 4
	rogue_types = list(/datum/nanite_program/nerve_decay, /datum/nanite_program/necrotic, /datum/nanite_program/brain_decay)

/datum/nanite_program/fake_death/enable_passive_effect()
	. = ..()
	host_mob.emote("deathgasp")
	host_mob.fakedeath("nanites")

/datum/nanite_program/fake_death/disable_passive_effect()
	. = ..()
	host_mob.cure_fakedeath("nanites")

//Can receive transmissions from a nanite communication remote for customized messages
/datum/nanite_program/comm
	can_trigger = TRUE
	var/comm_message = ""

/datum/nanite_program/comm/register_extra_settings()
	extra_settings[NES_COMM_CODE] = new /datum/nanite_extra_setting/number(0, 0, 9999)

/datum/nanite_program/comm/proc/receive_comm_signal(signal_comm_code, comm_message, comm_source)
	var/datum/nanite_extra_setting/comm_code = extra_settings[NES_COMM_CODE]
	if(!activated || !comm_code.get_value())
		return
	if(signal_comm_code == comm_code.get_value())
		host_mob.investigate_log("'s [name] nanite program was messaged by [comm_source] with comm code [signal_comm_code] and message '[comm_message]'.", INVESTIGATE_NANITES)
		trigger(FALSE, comm_message)

/datum/nanite_program/comm/speech
	name = "Forced Speech"
	desc = "The nanites force the host to say a pre-programmed sentence when triggered."
	unique = FALSE
	trigger_cost = 3
	trigger_cooldown = 20
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)
	var/static/list/blacklist = list(
		"*surrender",
		"*collapse",
		"*faint",
	)

/datum/nanite_program/comm/speech/register_extra_settings()
	. = ..()
	extra_settings[NES_SENTENCE] = new /datum/nanite_extra_setting/text("")

/datum/nanite_program/comm/speech/on_trigger(comm_message)
	var/sent_message = comm_message
	if(!comm_message)
		var/datum/nanite_extra_setting/sentence = extra_settings[NES_SENTENCE]
		sent_message = sentence.get_value()
	if(sent_message in blacklist)
		return
	if(host_mob.stat == DEAD)
		return
	to_chat(host_mob, span_warning("You feel compelled to speak..."))
	host_mob.say(sent_message, forced = "nanite speech")

/datum/nanite_program/comm/voice
	name = "Skull Echo"
	desc = "The nanites echo a synthesized message inside the host's skull."
	unique = FALSE
	trigger_cost = 1
	trigger_cooldown = 20
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/comm/voice/register_extra_settings()
	. = ..()
	extra_settings[NES_MESSAGE] = new /datum/nanite_extra_setting/text("")

/datum/nanite_program/comm/voice/on_trigger(comm_message)
	var/sent_message = comm_message
	if(!comm_message)
		var/datum/nanite_extra_setting/message_setting = extra_settings[NES_MESSAGE]
		sent_message = message_setting.get_value()
	if(host_mob.stat == DEAD)
		return
	to_chat(host_mob, "<i>You hear a strange, robotic voice in your head...</i> \"[span_robot("[html_encode(sent_message)]")]\"")

/datum/nanite_program/comm/hallucination
	name = "Hallucination"
	desc = "The nanites make the host hallucinate something when triggered."
	trigger_cost = 4
	trigger_cooldown = 80
	unique = FALSE
	rogue_types = list(/datum/nanite_program/brain_misfire)

/datum/nanite_program/comm/hallucination/register_extra_settings()
	. = ..()
	var/list/options = list(
		"Random"
	)
	extra_settings[NES_HALLUCINATION_TYPE] = new /datum/nanite_extra_setting/type("Message", options)
	extra_settings[NES_HALLUCINATION_DETAIL] = new /datum/nanite_extra_setting/text("")

/datum/nanite_program/comm/hallucination/on_trigger(comm_message)
	var/datum/nanite_extra_setting/hal_setting = extra_settings[NES_HALLUCINATION_TYPE]
	var/hal_type = hal_setting.get_value()
	var/datum/nanite_extra_setting/hal_detail_setting = extra_settings[NES_HALLUCINATION_DETAIL]
	var/hal_details = hal_detail_setting.get_value()
	if(comm_message && (hal_type != "Message")) //Triggered via comm remote, but not set to a message hallucination
		return
	var/sent_message = comm_message //Comm remotes can send custom hallucination messages for the chat hallucination
	if(!sent_message)
		sent_message = hal_details

	if(!iscarbon(host_mob))
		return
	var/mob/living/carbon/C = host_mob
	if(hal_details == "random")
		hal_details = null
	if(hal_type == "Random")
		C.adjust_hallucinations(1.5 SECONDS)

/datum/nanite_program/comm/hallucination/set_extra_setting(setting, value)
	. = ..()
	if(setting == NES_HALLUCINATION_TYPE)
		switch(value)
			if("Message")
				extra_settings[NES_HALLUCINATION_DETAIL] = new /datum/nanite_extra_setting/text("")
			if("Battle")
				extra_settings[NES_HALLUCINATION_DETAIL] = new /datum/nanite_extra_setting/type("random", list("random","laser","disabler","esword","gun","stunprod","harmbaton","bomb"))
			if("Sound")
				extra_settings[NES_HALLUCINATION_DETAIL] = new /datum/nanite_extra_setting/type("random", list("random","airlock","airlock pry","console","explosion","far explosion","mech","glass","alarm","beepsky","mech","wall decon","door hack"))
			if("Weird Sound")
				extra_settings[NES_HALLUCINATION_DETAIL] = new /datum/nanite_extra_setting/type("random", list("random","phone","hallelujah","highlander","laughter","hyperspace","game over","creepy","tesla"))
			if("Station Message")
				extra_settings[NES_HALLUCINATION_DETAIL] = new /datum/nanite_extra_setting/type("random", list("random","ratvar","shuttle dock","blob alert","malf ai","meteors","supermatter"))
			if("Health")
				extra_settings[NES_HALLUCINATION_DETAIL] = new /datum/nanite_extra_setting/type("random", list("random","critical","dead","healthy"))
			if("Alert")
				extra_settings[NES_HALLUCINATION_DETAIL] = new /datum/nanite_extra_setting/type("random", list("random","not_enough_oxy","not_enough_tox","not_enough_co2","too_much_oxy","too_much_co2","too_much_tox","newlaw","nutrition","charge","gravity","fire","locked","hacked","temphot","tempcold","pressure"))
			else
				extra_settings.Remove(NES_HALLUCINATION_DETAIL)

/datum/nanite_program/good_mood
	name = "Happiness Enhancer"
	desc = "The nanites synthesize serotonin inside the host's brain, creating an artificial sense of happiness."
	use_rate = 0.1
	rogue_types = list(/datum/nanite_program/brain_decay)

/datum/nanite_program/good_mood/register_extra_settings()
	. = ..()
	extra_settings[NES_MOOD_MESSAGE] = new /datum/nanite_extra_setting/text("HAPPINESS ENHANCEMENT")

/datum/nanite_program/good_mood/enable_passive_effect()
	. = ..()
	host_mob.add_mood_event("nanite_happy", /datum/mood_event/nanite_happiness, get_extra_setting_value(NES_MOOD_MESSAGE))

/datum/nanite_program/good_mood/disable_passive_effect()
	. = ..()
	host_mob.clear_mood_event("nanite_happy")

/datum/nanite_program/bad_mood
	name = "Happiness Suppressor"
	desc = "The nanites suppress the production of serotonin inside the host's brain, creating an artificial state of depression."
	use_rate = 0.1
	rogue_types = list(/datum/nanite_program/brain_decay)

/datum/nanite_program/bad_mood/register_extra_settings()
	. = ..()
	extra_settings[NES_MOOD_MESSAGE] = new /datum/nanite_extra_setting/text("HAPPINESS SUPPRESSION")

/datum/nanite_program/bad_mood/enable_passive_effect()
	. = ..()
	host_mob.add_mood_event("nanite_sadness", /datum/mood_event/nanite_sadness, get_extra_setting_value(NES_MOOD_MESSAGE))

/datum/nanite_program/bad_mood/disable_passive_effect()
	. = ..()
	host_mob.clear_mood_event("nanite_sadness")

/datum/nanite_program/conversation_filter
	name = "Conversation Filter"
	desc = "The nanites pre-process words, granting the ability to filter out certain phrases."
	use_rate = 0.1
	unique = FALSE
	rogue_types = list(/datum/nanite_program/brain_misfire)

/datum/nanite_program/conversation_filter/register_extra_settings()
	. = ..()
	extra_settings[NES_INVALID_PHRASE] = new /datum/nanite_extra_setting/text("")
	extra_settings[NES_PHRASE_REPLACEMENT] = new /datum/nanite_extra_setting/text("\[Invalid Phrase Detected.\]")
	extra_settings[NES_REPLACEMENT_MODE] = new /datum/nanite_extra_setting/boolean(TRUE, "Whole Sentence", "Phrase Only")

/datum/nanite_program/conversation_filter/on_mob_add()
	. = ..()
	RegisterSignal(host_mob, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))

/datum/nanite_program/conversation_filter/on_mob_remove()
	UnregisterSignal(host_mob, COMSIG_MOVABLE_HEAR)

/datum/nanite_program/conversation_filter/proc/on_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	if(!activated)
		return

	var/datum/nanite_extra_setting/phrase = extra_settings[NES_INVALID_PHRASE]
	var/datum/nanite_extra_setting/replacement_mode = extra_settings[NES_REPLACEMENT_MODE]
	var/datum/nanite_extra_setting/replacement_setting = extra_settings[NES_PHRASE_REPLACEMENT]
	var/replacement_phrase = replacement_setting.get_value()

	if(!phrase.get_value())
		return

	if(!replacement_phrase)
		replacement_phrase = ""

	if(findtext(hearing_args[HEARING_RAW_MESSAGE], phrase.get_value()))
		if (replacement_mode.get_value())
			hearing_args[HEARING_RAW_MESSAGE] = replacement_phrase
		else
			var/message = hearing_args[HEARING_RAW_MESSAGE]
			message = replacetext(message, phrase.get_value(), replacement_phrase)
			hearing_args[HEARING_RAW_MESSAGE] = message

#define NES_GRAVITY "Gravity Field"
#define NANITE_GRAV_NORMAL "1G"
#define NANITE_GRAV_HIGH "2G"

/datum/nanite_program/gravity
	name = "Gravito-Kinetic Field Conduction"
	desc = "The nanites channel an artifical gravitational field through the host."
	use_rate = 3
	rogue_types = list(/datum/nanite_program/glitch)
	var/gravitymod = 0
	var/current_mode
	unique = FALSE

/datum/nanite_program/gravity/register_extra_settings()
	. = ..()
	extra_settings[NES_GRAVITY] = new /datum/nanite_extra_setting/type(NANITE_GRAV_NORMAL, list(NANITE_GRAV_NORMAL, NANITE_GRAV_HIGH))

/datum/nanite_program/gravity/active_effect()
	. = ..()
	var/datum/nanite_extra_setting/mode = extra_settings[NES_GRAVITY]

	if (current_mode != mode.get_value() && passive_enabled)
		disable_passive_effect() // toggles it so that it updates
		enable_passive_effect()

/datum/nanite_program/gravity/enable_passive_effect()
	. = ..()
	var/datum/nanite_extra_setting/mode = extra_settings[NES_GRAVITY]
	current_mode = mode.get_value()
	switch(current_mode)
		if(NANITE_GRAV_NORMAL)
			gravitymod = 1

		if(NANITE_GRAV_HIGH)
			gravitymod = 2

	to_chat(host_mob, span_warning("Gravity starts warping around you!"))
	host_mob.AddElement(/datum/element/forced_gravity, gravitymod, can_override = TRUE)

/datum/nanite_program/gravity/disable_passive_effect()
	. = ..()
	to_chat(host_mob, span_notice("The non-newtonian nonsense is no more, thankfully."))
	host_mob.RemoveElement(/datum/element/forced_gravity, gravitymod, can_override = TRUE)

#undef NES_GRAVITY
#undef NANITE_GRAV_NORMAL
#undef NANITE_GRAV_HIGH
