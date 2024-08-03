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

/obj/item/organ/internal/tongue/oozeling
	name = "oozeling tongue"
	desc = "A goopy organ that mimics the tongues of other carbon beings."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "tongue_oozeling"
	say_mod = "blurbles"
	alpha = 200

// Oozeling tongues can speak all default + slime
/obj/item/organ/internal/tongue/oozeling/get_possible_languages()
	return ..() + /datum/language/slime

/obj/item/organ/internal/tongue/robot/polyglot_voicebox
	name = "polyglot voicebox"
	desc = "A voice synthesizer that allows you to emulate the tongues of other species."
	say_mod = "beeps"
	//The current tongue being emulated.
	var/current_tongue = "Synth"
	var/datum/action/innate/select_tongue/select_tongue
	var/draw_length = 3
	var/chattering = FALSE
	var/phomeme_type = "sans"
	var/list/phomeme_types = list("sans", "papyrus")

/obj/item/organ/internal/tongue/robot/polyglot_voicebox/can_speak_language(language)
	return ..()

/obj/item/organ/internal/tongue/robot/polyglot_voicebox/modify_speech(datum/source, list/speech_args)
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

/obj/item/organ/internal/tongue/robot/polyglot_voicebox/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	select_tongue = new
	select_tongue.Grant(organ_owner)

/obj/item/organ/internal/tongue/robot/polyglot_voicebox/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	select_tongue.Remove(organ_owner)

/obj/item/organ/internal/tongue/robot/polyglot_voicebox/proc/add_word_to_translations(english_word, zombie_word)
	GLOB.english_to_zombie[english_word] = zombie_word
	GLOB.english_to_zombie[english_word + plural_s(english_word)] = zombie_word
	GLOB.english_to_zombie[english_word + "ing"] = zombie_word
	GLOB.english_to_zombie[english_word + "ed"] = zombie_word

/obj/item/organ/internal/tongue/robot/polyglot_voicebox/proc/load_zombie_translations()
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
	var/list/possible_tongues = list(
		"Synth" = image(icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi', icon_state = "cybertongue"),
		"Arachnid" = image(icon = 'icons/obj/medical/organs/organs.dmi', icon_state = "tongue"),
		"Oozeling" = image(icon = 'monkestation/icons/obj/medical/organs/organs.dmi', icon_state = "tongue_oozeling"),
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
	var/obj/item/organ/internal/tongue/robot/polyglot_voicebox/polyglot_voicebox = owner.get_organ_slot(ORGAN_SLOT_TONGUE)
	var/picked_tongue = show_radial_menu(owner, owner, possible_tongues, radius = 50, require_near = TRUE, tooltips = TRUE)
	if(!picked_tongue)
		return
	polyglot_voicebox.current_tongue = picked_tongue
	switch(picked_tongue)
		if("Synth")
			polyglot_voicebox.say_mod = "beeps"
		if("Arachnid")
			polyglot_voicebox.say_mod = "chitters"
		if("Oozeling")
			polyglot_voicebox.say_mod = "blurbles"
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
