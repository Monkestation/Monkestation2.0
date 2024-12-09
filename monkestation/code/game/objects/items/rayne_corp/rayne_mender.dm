#define RAYNE_MENDER_SPEECH "monkey_companies/rayne_mender.json"
/// How long the gun should wait between speaking to lessen spam
#define RAYNE_MENDER_SPEECH_COOLDOWN 5 SECONDS
/// What color is the default kill mode for these guns, used to make sure the chat colors are right at roundstart
#define DEFAULT_RUNECHAT_COLOR "#06507a"


/obj/item/storage/medkit/rayne
	name = "Rayne Corp Health Analyzer Kit"
	icon = 'icons/obj/device.dmi'
	item_flags = NOBLUDGEON
	var/speech_json_file = RAYNE_MENDER_SPEECH
	COOLDOWN_DECLARE(last_speech)

/obj/item/storage/medkit/rayne/attack(mob/living/M, mob/living/carbon/human/user)
	if(!user.can_read(src) || user.is_blind())
		return

	flick("[icon_state]-scan", src) //makes it so that it plays the scan animation upon scanning, including clumsy scanning

	if(ispodperson(M))
		speak_up("podnerd")
		return

	user.visible_message(span_notice("[user] analyzes [M]'s vitals."))
	playsound(user.loc, 'sound/items/healthanalyzer.ogg', 50)
	healthscan(user, M, 0, FALSE)
	add_fingerprint(user)
	judge_health(M)


//This proc controls what the medkit says when scanning a person, and recommends a best course of treatment (barely)
/obj/item/storage/medkit/rayne/proc/judge_health(mob/living/judged)

	var/brain

	if(judged.on_fire)
		speak_up("onfire")
		return
	if(ishuman(judged))
		if(!judged.get_organ_slot(ORGAN_SLOT_BRAIN))
			speak_up("nobrain")
			return
		else
			brain = judged.get_organ_slot(ORGAN_SLOT_BRAIN).damage
			if(brain > 150)
				speak_up("braindamage")
				return

		if((judged?.blood_volume <= BLOOD_VOLUME_SAFE) && !HAS_TRAIT(judged, TRAIT_NOBLOOD))
			speak_up("lowblood")
			return

	var/brute = judged.bruteloss
	var/oxy = judged.oxyloss
	var/tox = judged.toxloss
	var/burn = judged.fireloss
	var/big = max(brute,oxy,burn,tox)
	if((brute + burn) >= 350)
		speak_up("fuckedup")
		return
	//cant do non constants in a switch, sad
	if(brute == big)
		speak_up("brute")
		return
	if(burn == big)
		speak_up("burn")
		return
	if(tox == big)
		speak_up("tox")
		return
	if(oxy == big)
		speak_up("oxy")
		return

	speak_up("fine")
	return



/obj/item/storage/medkit/rayne/proc/speak_up(json_string, ignores_cooldown = FALSE)
	if(!json_string)
		return
	if(!ignores_cooldown && !COOLDOWN_FINISHED(src, last_speech))
		return
	say(pick_list_replacements(speech_json_file, json_string))
	playsound(src, 'sound/creatures/tourist/tourist_talk.ogg', 15, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = rand(3.5))
	Shake(2, 2, 1 SECONDS)
	COOLDOWN_START(src, last_speech, RAYNE_MENDER_SPEECH)
