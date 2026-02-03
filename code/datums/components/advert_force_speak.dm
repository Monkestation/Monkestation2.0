/datum/component/advert_force_speak
	dupe_mode = COMPONENT_DUPE_SOURCES
	COOLDOWN_DECLARE(message_cooldown)
	var/mob/living/speaker_implant/speaker_implant

/datum/component/advert_force_speak/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/advert_force_speak/on_source_add(source, delay=0)
	. = ..()
	if (COOLDOWN_FINISHED(src, message_cooldown) || COOLDOWN_TIMELEFT(src, message_cooldown) > delay)
		COOLDOWN_START(src, message_cooldown, delay)

/datum/component/advert_force_speak/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/component/advert_force_speak/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_LIFE))

/datum/component/advert_force_speak/Destroy(force)
	QDEL_NULL(speaker_implant)
	return ..()

/datum/component/advert_force_speak/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(COOLDOWN_FINISHED(src, message_cooldown) && source.stat < UNCONSCIOUS)
		var/delay = rand(4 MINUTES, 6 MINUTES)
		// if (HAS_TRAIT(source, TRAIT_SPONSOR_IMPLANT_SYNDI))  TODO: implement
		// 	delay *= 2
		COOLDOWN_START(src, message_cooldown, delay)
		INVOKE_ASYNC(src, PROC_REF(speak), source)

/datum/component/advert_force_speak/proc/speak(mob/living/source)
	// var/syndi = HAS_TRAIT(source, TRAIT_SPONSOR_IMPLANT_SYNDI) TODO: implement
	var/syndi = FALSE
	var/implanted = syndi || HAS_TRAIT(source, TRAIT_SPONSOR_IMPLANT)
	var/bad_speak = !source.can_speak() || HAS_TRAIT(source, TRAIT_ANXIOUS) || HAS_TRAIT(source, TRAIT_SOFTSPOKEN)
	if (!source.can_speak_language(/datum/language/common))
		bad_speak = TRUE

	var/list/ad_list = syndi ? GLOB.advertisements.syndi_ads : GLOB.advertisements.nt_ads
	var/ad_idx = rand(1, length(ad_list) / 2) * 2
	var/sponsor = ad_list[ad_idx - 1]
	var/message = ad_list[ad_idx]
	var/spans = syndi ? list("red", "syndi-propaganda") : list()

	message = replacetext(message, "%name%", source.real_name || source.name)

	if(implanted && bad_speak)
		speaker_implant_say(source, message, sponsor)
	else
		source.say(message, language=/datum/language/common, forced="sponsorship ([sponsor])", spans=spans)

	if(implanted)
		var/datum/bank_account/bank_account = source.get_bank_account()
		if(bank_account)
			var/revenue = syndi ? -40 : 5
			bank_account.adjust_money(revenue, "[sponsor]: Sponsorship Payment")
			bank_account.bank_card_talk("Sponsorship Payment: [revenue] credits received from [sponsor].")

/datum/component/advert_force_speak/proc/speaker_implant_say(mob/living/source, message, sponsor, spans)
	if(QDELETED(speaker_implant))
		speaker_implant = new(source)

	speaker_implant.body_maptext_height_offset = source.body_maptext_height_offset
	speaker_implant.say(message, language=/datum/language/common, forced="sponsorship ([sponsor])", spans=spans)

/mob/living/speaker_implant
	name = "speaker implant"
	var/mob/living/owner

/mob/living/speaker_implant/New(mob/living/owner)
	src.owner = owner
	src.bubble_icon = "machine"

/mob/living/speaker_implant/GetVoice()
	if(owner == src)
		return ""
	return owner.GetVoice()

/mob/living/speaker_implant/get_alt_name()
	return "'s Implant"

/mob/living/speaker_implant/Destroy()
	owner = null
	return ..()

GLOBAL_DATUM_INIT(advertisements, /datum/advertisements, new)

/datum/advertisements
	var/list/nt_ads
	var/list/syndi_ads

/datum/advertisements/New()
	nt_ads = load_file("strings/advertisements.txt")
	// syndi_ads = load_file("monkestation/strings/advertisements_syndi.txt") TODO: implement

/datum/advertisements/proc/load_file(file_name)
	var/list/advertisements = list()
	var/list/lines = world.file2list(file_name)
	var/name = "Unknown"
	for (var/line in lines)
		if (length(line) == 0)
			continue
		if (line[1] == "-")
			continue
		if (line[1] == "\t")
			var/delimiter_idx = findtext(line, ":", 2)
			if (delimiter_idx == 0)
				stack_trace("No delimiter in line '[line]' in [file_name]")
				continue
			var/key = copytext(line, 2, delimiter_idx)
			var/value = trim(copytext(line, delimiter_idx+1))
			if (key == "name")
				name = value
				continue
			if (key == "desc")
				continue
			stack_trace("Unknown key '[key]' in [file_name]")
			continue
		advertisements.Add(name)
		advertisements.Add(trim(line))
	return advertisements
