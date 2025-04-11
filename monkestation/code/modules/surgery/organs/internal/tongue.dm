/obj/item/organ/internal/tongue/robot/clockwork
	name = "dynamic micro-phonograph"
	desc = "An old-timey looking device connected to an odd, shifting cylinder."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "tongueclock"

/obj/item/organ/internal/tongue/robot/clockwork/better
	name = "amplified dynamic micro-phonograph"

/obj/item/organ/internal/tongue/robot/clockwork/better/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT
	//speech_args[SPEECH_SPANS] |= SPAN_REALLYBIG  //i disabled this, its abnoxious and makes their chat take 3 times as much space in chat

/obj/item/organ/internal/tongue/arachnid
	name = "arachnid tongue"
	desc = "The tongue of an Arachnid. Mostly used for lying."
	say_mod = "chitters"
	modifies_speech = TRUE
	disliked_foodtypes = NONE // Okay listen, i don't actually know what irl spiders don't like to eat and i'm pretty tired of looking for answers.
	liked_foodtypes = GORE | MEAT | BUGS | GROSS

/obj/item/organ/internal/tongue/arachnid/get_scream_sound()
	return 'monkestation/sound/voice/screams/arachnid/arachnid_scream.ogg'

/obj/item/organ/internal/tongue/arachnid/get_laugh_sound()
	return 'monkestation/sound/voice/laugh/arachnid/arachnid_laugh.ogg'

/obj/item/organ/internal/tongue/arachnid/modify_speech(datum/source, list/speech_args) //This is flypeople speech
	var/static/regex/fly_buzz = new("z+", "g")
	var/static/regex/fly_buZZ = new("Z+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = fly_buzz.Replace(message, "zzz")
		message = fly_buZZ.Replace(message, "ZZZ")
		message = replacetext(message, "s", "z")
		message = replacetext(message, "S", "Z")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/internal/tongue/arachnid/get_possible_languages()
	return ..() + /datum/language/buzzwords

/obj/item/organ/internal/tongue/jelly
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/internal/tongue/jelly/get_possible_languages()
	return ..() + /datum/language/slime

/obj/item/organ/internal/tongue/synth
	name = "synthetic voicebox"
	desc = "A fully-functional synthetic tongue, encased in soft silicone. Features include high-resolution vocals and taste receptors."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "cybertongue"
	say_mod = "beeps"
	attack_verb_continuous = list("beeps", "boops")
	attack_verb_simple = list("beep", "boop")
	modifies_speech = TRUE
	liked_foodtypes = NONE
	disliked_foodtypes = NONE
	toxic_foodtypes = NONE
	taste_sensitivity = 25 // not as good as an organic tongue
	organ_traits = list(TRAIT_SILICON_EMOTES_ALLOWED)
	maxHealth = 100 //RoboTongue!
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_TONGUE
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES

/obj/item/organ/internal/tongue/synth/get_scream_sound()
	return 'monkestation/sound/voice/screams/silicon/scream_silicon.ogg'

/obj/item/organ/internal/tongue/synth/get_laugh_sound()
	if(owner.gender == FEMALE)
		return pick(
			'monkestation/sound/voice/laugh/silicon/laugh_siliconF0.ogg',
			'monkestation/sound/voice/laugh/silicon/laugh_siliconF1.ogg',
			'monkestation/sound/voice/laugh/silicon/laugh_siliconF2.ogg',
		)
	if(owner.gender == MALE)
		return pick(
			'monkestation/sound/voice/laugh/silicon/laugh_siliconE1M0.ogg',
			'monkestation/sound/voice/laugh/silicon/laugh_siliconE1M1.ogg',
			'monkestation/sound/voice/laugh/silicon/laugh_siliconM2.ogg',
		)
	else
		return pick(
			'monkestation/sound/voice/laugh/silicon/laugh_siliconE1M0.ogg',
			'monkestation/sound/voice/laugh/silicon/laugh_siliconE1M1.ogg',
			'monkestation/sound/voice/laugh/silicon/laugh_siliconM2.ogg',
			'monkestation/sound/voice/laugh/silicon/laugh_siliconF0.ogg',
			'monkestation/sound/voice/laugh/silicon/laugh_siliconF1.ogg',
			'monkestation/sound/voice/laugh/silicon/laugh_siliconF2.ogg',
		)

/obj/item/organ/internal/tongue/synth/can_speak_language(language)
	return TRUE

/obj/item/organ/internal/tongue/synth/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT

/datum/design/synth_tongue
	name = "Synthetic Tongue"
	desc = "A fully-functional synthetic tongue, encased in soft silicone. Features include high-resolution vocals and taste receptors."
	id = "synth_tongue"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/tongue/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_SYNTHETIC_ORGANS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/obj/item/organ/internal/tongue/polyglot_voicebox
	name = "polyglot voicebox"
	desc = "A voice synthesizer that allows you to emulate the tongues of other species."
	say_mod = "beeps"
	icon_state = "tonguerobot"
	status = ORGAN_ROBOTIC
	//The current tongue being emulated.
	var/current_tongue = "Synth"
	var/datum/action/innate/select_tongue/select_tongue
	var/draw_length = 3
	var/chattering = FALSE
	var/phomeme_type = "sans"
	var/static/list/phomeme_types = list("sans", "papyrus")

/obj/item/organ/internal/tongue/polyglot_voicebox/Initialize(mapload)
	. = ..()
	select_tongue = new(src)

/obj/item/organ/internal/tongue/polyglot_voicebox/Destroy(force)
	QDEL_NULL(select_tongue)
	return ..()

/obj/item/organ/internal/tongue/polyglot_voicebox/modify_speech(datum/source, list/speech_args)
	switch(current_tongue)
		if("Synth")
			speech_args[SPEECH_SPANS] |= SPAN_ROBOT
		if("Arachnid")
			var/static/regex/fly_buzz = new("z+", "g")
			var/static/regex/fly_buZZ = new("Z+", "g")
			var/message = speech_args[SPEECH_MESSAGE]
			if(message[1] != "*")
				message = fly_buzz.Replace(message, "zzz")
				message = fly_buZZ.Replace(message, "ZZZ")
				message = replacetext(message, "s", "z")
				message = replacetext(message, "S", "Z")
			speech_args[SPEECH_MESSAGE] = message
		if("Lizard")
			var/static/regex/lizard_hiss = new("s+", "g")
			var/static/regex/lizard_hiSS = new("S+", "g")
			var/static/regex/lizard_kss = new(@"(\w)x", "g")
			var/static/regex/lizard_kSS = new(@"(\w)X", "g")
			var/static/regex/lizard_ecks = new(@"\bx([\-|r|R]|\b)", "g")
			var/static/regex/lizard_eckS = new(@"\bX([\-|r|R]|\b)", "g")
			var/message = speech_args[SPEECH_MESSAGE]
			if(message[1] != "*")
				message = lizard_hiss.Replace(message, repeat_string(draw_length, "s"))
				message = lizard_hiSS.Replace(message, repeat_string(draw_length, "S"))
				message = lizard_kss.Replace(message, "$1k[repeat_string(max(draw_length - 1, 1), "s")]")
				message = lizard_kSS.Replace(message, "$1K[repeat_string(max(draw_length - 1, 1), "S")]")
				message = lizard_ecks.Replace(message, "eck[repeat_string(max(draw_length - 2, 1), "s")]$1")
				message = lizard_eckS.Replace(message, "ECK[repeat_string(max(draw_length - 2, 1), "S")]$1")
			speech_args[SPEECH_MESSAGE] = message
		if("Snail")
			var/new_message
			var/message = speech_args[SPEECH_MESSAGE]
			for(var/i in 1 to length(message))
				if(findtext("ABCDEFGHIJKLMNOPWRSTUVWXYZabcdefghijklmnopqrstuvwxyz", message[i]))
					new_message += message[i] + message[i] + message[i]
				else
					new_message += message[i]
			speech_args[SPEECH_MESSAGE] = new_message
		if("Zombie")
			var/message = speech_args[SPEECH_MESSAGE]
			if(message[1] != "*")
				if(!length(GLOB.english_to_zombie))
					load_zombie_translations()

			var/list/message_word_list = splittext(message, " ")
			var/list/translated_word_list = list()
			for(var/word in message_word_list)
				word = GLOB.english_to_zombie[lowertext(word)]
				translated_word_list += word ? word : FALSE

			message = replacetext(message, regex(@"[eiou]", "ig"), "r")
			message = replacetext(message, regex(@"[^zhrgbmna.!?-\s]", "ig"), "")
			message = replacetext(message, regex(@"(\s+)", "g"), " ")

			var/list/old_words = splittext(message, " ")
			var/list/new_words = list()
			for(var/word in old_words)
				word = replacetext(word, regex(@"\lr\b"), "rh")
				word = replacetext(word, regex(@"\b[Aa]\b"), "hra")
				new_words += word

			for(var/i in 1 to length(new_words))
				new_words[i] = translated_word_list[i] ? translated_word_list[i] : new_words[i]

			message = new_words.Join(" ")
			message = capitalize(message)
			speech_args[SPEECH_MESSAGE] = message
		if("Alien")
			var/datum/saymode/xeno/hivemind = speech_args[SPEECH_SAYMODE]
			if(hivemind)
				return

			playsound(owner, SFX_HISS, 25, TRUE, TRUE)
		if("Bone")
			if(chattering)
				chatter(speech_args[SPEECH_MESSAGE], phomeme_type, source)
			switch(phomeme_type)
				if("sans")
					speech_args[SPEECH_SPANS] |= SPAN_SANS
				if("papyrus")
					speech_args[SPEECH_SPANS] |= SPAN_PAPYRUS
		if("Fly")
			var/static/regex/fly_buzz = new("z+", "g")
			var/static/regex/fly_buZZ = new("Z+", "g")
			var/message = speech_args[SPEECH_MESSAGE]
			if(message[1] != "*")
				message = fly_buzz.Replace(message, "zzz")
				message = fly_buZZ.Replace(message, "ZZZ")
				message = replacetext(message, "s", "z")
				message = replacetext(message, "S", "Z")
			speech_args[SPEECH_MESSAGE] = message
		else
			return speech_args[SPEECH_MESSAGE]

/obj/item/organ/internal/tongue/polyglot_voicebox/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	if(!QDELETED(select_tongue))
		select_tongue.Grant(organ_owner)

/obj/item/organ/internal/tongue/polyglot_voicebox/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	if(!QDELETED(select_tongue))
		select_tongue.Remove(organ_owner)

/obj/item/organ/internal/tongue/polyglot_voicebox/proc/add_word_to_translations(english_word, zombie_word)
	GLOB.english_to_zombie[english_word] = zombie_word
	GLOB.english_to_zombie[english_word + plural_s(english_word)] = zombie_word
	GLOB.english_to_zombie[english_word + "ing"] = zombie_word
	GLOB.english_to_zombie[english_word + "ed"] = zombie_word

/obj/item/organ/internal/tongue/polyglot_voicebox/proc/load_zombie_translations()
	var/list/zombie_translation = strings("zombie_replacement.json", "zombie")
	for(var/zombie_word in zombie_translation)
		var/list/data = islist(zombie_translation[zombie_word]) ? zombie_translation[zombie_word] : list(zombie_translation[zombie_word])
		for(var/english_word in data)
			add_word_to_translations(english_word, zombie_word)
	GLOB.english_to_zombie = sort_list(GLOB.english_to_zombie)

/datum/action/innate/select_tongue
	name = "Select tongue"
	desc = "Select a tongue to emulate with your polyglot voicebox"
	button_icon = 'icons/obj/medical/organs/organs.dmi'
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	button_icon_state = "tongue"

/datum/action/innate/select_tongue/Activate()
	//All possible tongues that can be emulated.
	var/static/list/possible_tongues = list(
		"Synth" = image(icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi', icon_state = "cybertongue"),
		"Arachnid" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "tongue"),
		"Jelly" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "tongue"),
		"Ethereal" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "electrotongue"),
		"Monkey" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "tongue"),
		"Moth" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "tongue"),
		"Human" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "tongue"),
		"Lizard" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "tonguelizard"),
		"Snail" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "tongue"),
		"Cat" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "tongue"),
		"Zombie" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "tonguezombie"),
		"Alien" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "tonguexeno"),
		"Bone" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "tonguebone"),
		"Bananium" = image(icon = 'icons/obj/weapons/horn.dmi', icon_state = "gold_horn"),
		"Mush" = image(icon = 'icons/obj/hydroponics/seeds.dmi', icon_state = "mycelium-angel"),
		"Fly" = image(icon = 'icons/obj/medical/organs/fly_organs.dmi', icon_state = "tongue")
	)
	var/obj/item/organ/internal/tongue/polyglot_voicebox/polyglot_voicebox = owner.get_organ_slot(ORGAN_SLOT_TONGUE)
	var/picked_tongue = show_radial_menu(owner, owner, possible_tongues, radius = 50, require_near = TRUE, tooltips = TRUE)
	if(!picked_tongue)
		return
	polyglot_voicebox.current_tongue = picked_tongue
	switch(picked_tongue)
		if("Synth")
			polyglot_voicebox.say_mod = "beeps"
		if("Arachnid")
			polyglot_voicebox.say_mod = "chitters"
		if("Jelly")
			polyglot_voicebox.say_mod = "chirps"
		if("Ethereal")
			polyglot_voicebox.say_mod = "crackles"
		if("Monkey")
			polyglot_voicebox.say_mod = "chimpers"
		if("Moth")
			polyglot_voicebox.say_mod = "flutters"
		if("Human")
			polyglot_voicebox.say_mod = "says"
		if("Lizard")
			polyglot_voicebox.draw_length = rand(2, 6)
			if(prob(10))
				polyglot_voicebox.draw_length += 2
			polyglot_voicebox.say_mod = "hisses"
		if("Snail")
			polyglot_voicebox.say_mod = "says"
		if("Cat")
			polyglot_voicebox.say_mod = "meows"
		if("Zombie")
			polyglot_voicebox.say_mod = "moans"
		if("Alien")
			polyglot_voicebox.say_mod = "hisses"
		if("Bone")
			polyglot_voicebox.phomeme_type = pick(polyglot_voicebox.phomeme_types)
			polyglot_voicebox.say_mod = "rattles"
		if("Bananium")
			polyglot_voicebox.say_mod = "honks"
		if("Mush")
			polyglot_voicebox.say_mod = "poofs"
		if("Fly")
			polyglot_voicebox.say_mod = "buzzes"

/obj/item/organ/internal/tongue/ornithid
	name = "avian tongue"
	desc = "A seemingly normal looking tongue which causes ones voice to caw. However that works."
	say_mod = "caws"
	///Birds like these but they're still human-mutans, so they dislike the same stuff.
	liked_foodtypes = VEGETABLES | FRUIT | NUTS | GRAIN
	disliked_foodtypes = RAW | GORE | DAIRY

	/// Our song datum.
	var/datum/song/organ/song
	/// How far away our song datum can be heard.
	var/instrument_range = 12
	///our music ability
	var/datum/action/innate/singing/sing
	///static list of instruments we can play
	var/list/static/allowed_instrument_ids = list("mothscream", "honk", "violin", "guitar", "piano", "recorder", "banjo", "r3grand","r3harpsi","crharpsi","crgrand1","crbright1", "crichugan", "crihamgan")
	///this is our spewer component
	var/datum/component/particle_spewer/music_notes/music

/obj/item/organ/internal/tongue/ornithid/Initialize(mapload)
	. = ..()
	song = new(src, allowed_instrument_ids, instrument_range)
	RegisterSignal(src, COMSIG_INSTRUMENT_START, PROC_REF(start_sound_particles))
	RegisterSignal(src, COMSIG_INSTRUMENT_END, PROC_REF(stop_sound_particles))

/obj/item/organ/internal/tongue/ornithid/Destroy()
	QDEL_NULL(song)
	UnregisterSignal(src, list(COMSIG_INSTRUMENT_START, COMSIG_INSTRUMENT_END))
	return ..()

/obj/item/organ/internal/tongue/ornithid/Insert(mob/living/carbon/tongue_owner, special, drop_if_replaced)
	. = ..()
	if(QDELETED(sing))
		sing = new
	sing.Grant(tongue_owner)

/obj/item/organ/internal/tongue/ornithid/Remove(mob/living/carbon/tongue_owner, special)
	. = ..()
	sing?.Remove(tongue_owner)
	song?.stop_playing()
	stop_sound_particles()

/obj/item/organ/internal/tongue/ornithid/proc/start_sound_particles()
	music ||= owner.AddComponent(/datum/component/particle_spewer/music_notes)

/obj/item/organ/internal/tongue/ornithid/proc/stop_sound_particles()
	QDEL_NULL(music)
