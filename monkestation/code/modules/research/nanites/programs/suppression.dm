/datum/nanite_program/sleepy
	name = "Sleep Induction"
	desc = "The nanites cause rapid narcolepsy when triggered."
	can_trigger = TRUE
	trigger_cost = 15
	trigger_cooldown = 1200
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/sleepy/on_trigger(comm_message)
	to_chat(host_mob, span_warning("You start to feel very sleepy..."))
	host_mob.adjust_drowsiness(2 SECONDS)
	addtimer(CALLBACK(host_mob, TYPE_PROC_REF(/mob/living, Sleeping), 200), rand(60,200))

/datum/nanite_program/paralyzing
	name = "Paralysis"
	desc = "The nanites force muscle contraction, effectively paralyzing the host."
	use_rate = 3
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/paralyzing/active_effect()
	host_mob.Stun(40)

/datum/nanite_program/paralyzing/enable_passive_effect()
	. = ..()
	to_chat(host_mob, span_warning("Your muscles seize! You can't move!"))

/datum/nanite_program/paralyzing/disable_passive_effect()
	. = ..()
	to_chat(host_mob, span_notice("Your muscles relax, and you can move again."))

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
	desc = "The nanites pulse the host's nerves when triggered, inapacitating them for a short period."
	can_trigger = TRUE
	trigger_cost = 4
	trigger_cooldown = 300
	rogue_types = list(/datum/nanite_program/shocking, /datum/nanite_program/nerve_decay)

/datum/nanite_program/stun/on_trigger(comm_message)
	playsound(host_mob, "sparks", 75, TRUE, -1, SHORT_RANGE_SOUND_EXTRARANGE)
	host_mob.Paralyze(80)

/datum/nanite_program/pacifying
	name = "Pacification"
	desc = "The nanites suppress the aggression center of the brain, preventing the host from causing direct harm to others."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/pacifying/enable_passive_effect()
	. = ..()
	ADD_TRAIT(host_mob, TRAIT_PACIFISM, TRAIT_NANITES)

/datum/nanite_program/pacifying/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_PACIFISM, TRAIT_NANITES)

/datum/nanite_program/blinding
	name = "Blindness"
	desc = "The nanites suppress the host's ocular nerves, blinding them while they're active."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/blinding/enable_passive_effect()
	. = ..()
	host_mob.become_blind(TRAIT_NANITES)

/datum/nanite_program/blinding/disable_passive_effect()
	. = ..()
	host_mob.cure_blind(TRAIT_NANITES)

/datum/nanite_program/mute
	name = "Mute"
	desc = "The nanites suppress the host's speech, making them mute while they're active."
	use_rate = 0.75
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)

/datum/nanite_program/mute/enable_passive_effect()
	. = ..()
	ADD_TRAIT(host_mob, TRAIT_MUTE, TRAIT_NANITES)

/datum/nanite_program/mute/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_MUTE, TRAIT_NANITES)

/datum/nanite_program/fake_death
	name = "Death Simulation"
	desc = "The nanites induce a death-like coma into the host, able to fool most medical scans."
	use_rate = 3.5
	rogue_types = list(/datum/nanite_program/nerve_decay, /datum/nanite_program/necrotic, /datum/nanite_program/brain_decay)

/datum/nanite_program/fake_death/enable_passive_effect()
	. = ..()
	host_mob.emote("deathgasp")
	host_mob.fakedeath("nanites")

/datum/nanite_program/fake_death/disable_passive_effect()
	. = ..()
	host_mob.cure_fakedeath("nanites")

/datum/nanite_program/comm
	can_trigger = TRUE
	var/comm_message = ""

/datum/nanite_program/comm/register_extra_settings()
	extra_settings[NES_COMM_CODE] = new /datum/nanite_extra_setting/number(0, 0, 9999)

/datum/nanite_program/comm/proc/receive_comm_signal(signal_comm_code, comm_message, comm_source)
	var/datum/nanite_extra_setting/comm_code = extra_settings[NES_COMM_CODE]
	if(!activated || !comm_code)
		return
	if(signal_comm_code == comm_code)
		log_game("[host_mob]'s [name] nanite program was messaged by [comm_source] with comm code [signal_comm_code] and message '[comm_message]'.")
		trigger(comm_message)

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
	to_chat(host_mob, "<i>You hear a strange, robotic voice in your head...</i> \"<span class='robot'>[sent_message]</span>\"")

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
