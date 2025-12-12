/obj/item/encryptionkey
	name = "standard encryption key"
	desc = "An encryption key for a radio headset."
	icon = 'icons/obj/radio.dmi'
	icon_state = "cypherkey_basic"
	w_class = WEIGHT_CLASS_TINY
	/// Can this radio key access the binary radio channel?
	var/translate_binary = FALSE
	/// Decrypts Syndicate radio transmissions.
	var/syndie = FALSE
	/// If true, the radio can say/hear on the special CentCom channel.
	var/independent = FALSE
	/// What channels does this encryption key grant to the parent headset.
	var/list/channels = list()
	/// Assoc list of language to how well understood it is. 0 is invalid, 100 is perfect.
	var/list/language_data

	greyscale_config = /datum/greyscale_config/encryptionkey_basic
	greyscale_colors = "#820a16#3758c4"

/obj/item/encryptionkey/examine(mob/user)
	. = ..()
	if(!LAZYLEN(channels) && !(translate_binary) && !LAZYLEN(language_data))
		. += span_warning("Has no special codes in it. You should probably tell a coder!")
		return

	var/list/examine_text_list = list()
	for(var/i in channels)
		examine_text_list += "[GLOB.channel_tokens[i]] - [LOWER_TEXT(i)]"

		if(translate_binary)
			examine_text_list += "[GLOB.channel_tokens[MODE_BINARY]] - [MODE_BINARY]"

	if(length(examine_text_list))
		. += span_notice("It can access the following channels; [jointext(examine_text_list, ", ")].")

	var/list/language_text_list = list()
	for(var/lang in language_data)
		var/langstring = "[GLOB.language_datum_instances[lang].name]"
		switch(language_data[lang])
			if(25 to 50)
				langstring += " (poor)"
			if(50 to 75)
				langstring += " (average)"
			if(75 to 100)
				langstring += " (good)"
		language_text_list += langstring

	if(length(language_text_list))
		. += span_notice("It can translate the following languages; [jointext(language_text_list, ", ")].")

/obj/item/encryptionkey/syndicate
	name = "syndicate encryption key"
	icon_state = "cypherkey_syndicate"
	channels = list(RADIO_CHANNEL_SYNDICATE = 1)
	syndie = TRUE
	greyscale_config = /datum/greyscale_config/encryptionkey_syndicate
	greyscale_colors = "#171717#990000"

/obj/item/encryptionkey/binary
	name = "binary translator key"
	icon_state = "cypherkey_basic"
	translate_binary = TRUE
	language_data = list(
		/datum/language/machine = 100,
	)
	greyscale_config = /datum/greyscale_config/encryptionkey_basic
	greyscale_colors = "#24a157#3758c4"

/obj/item/encryptionkey/headset_sec
	name = "security radio encryption key"
	icon_state = "cypherkey_security"
	channels = list(RADIO_CHANNEL_SECURITY = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_security
	greyscale_colors = "#820a16#280b1a"

/obj/item/encryptionkey/headset_eng
	name = "engineering radio encryption key"
	icon_state = "cypherkey_engineering"
	channels = list(RADIO_CHANNEL_ENGINEERING = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_engineering
	greyscale_colors = "#f8d860#dca01b"

/obj/item/encryptionkey/headset_rob
	name = "robotics radio encryption key"
	icon_state = "cypherkey_engineering"
	channels = list(RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_ENGINEERING = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_engineering
	greyscale_colors = "#793a80#dca01b"

/obj/item/encryptionkey/headset_med
	name = "medical radio encryption key"
	icon_state = "cypherkey_medical"
	channels = list(RADIO_CHANNEL_MEDICAL = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_medical
	greyscale_colors = "#ebebeb#69abd1"

/obj/item/encryptionkey/headset_sci
	name = "science radio encryption key"
	icon_state = "cypherkey_research"
	channels = list(RADIO_CHANNEL_SCIENCE = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_research
	greyscale_colors = "#793a80#bc4a9b"

/obj/item/encryptionkey/headset_medsci
	name = "medical research radio encryption key"
	icon_state = "cypherkey_medical"
	channels = list(RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_MEDICAL = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_medical
	greyscale_colors = "#ebebeb#9d1de8"

/obj/item/encryptionkey/headset_srvsec
	name = "law and order radio encryption key"
	icon_state = "cypherkey_service"
	channels = list(RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_SECURITY = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_service
	greyscale_colors = "#820a16#3bca5a"

/obj/item/encryptionkey/headset_srvmed
	name = "psychology radio encryption key"
	icon_state = "cypherkey_service"
	channels = list(RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_SERVICE = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_service
	greyscale_colors = "#ebebeb#3bca5a"

/obj/item/encryptionkey/headset_srvent
	name = "press radio encryption key"
	icon_state = "cypherkey_service"
	channels = list(RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_ENTERTAINMENT = 0)
	greyscale_config = /datum/greyscale_config/encryptionkey_service
	greyscale_colors = "#83eb8f#3bca5a"

/obj/item/encryptionkey/headset_com
	name = "command radio encryption key"
	icon_state = "cypherkey_cube"
	channels = list(RADIO_CHANNEL_COMMAND = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_cube
	greyscale_colors = "#2b2793#67a552"

/obj/item/encryptionkey/heads/captain
	name = "\proper the captain's encryption key"
	icon_state = "cypherkey_cube"
	channels = list(RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_ENGINEERING = 0, RADIO_CHANNEL_SCIENCE = 0, RADIO_CHANNEL_MEDICAL = 0, RADIO_CHANNEL_SUPPLY = 0, RADIO_CHANNEL_SERVICE = 0)
	greyscale_config = /datum/greyscale_config/encryptionkey_cube
	greyscale_colors = "#2b2793#dca01b"

/obj/item/encryptionkey/heads/rd
	name = "\proper the research director's encryption key"
	icon_state = "cypherkey_research"
	channels = list(RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_COMMAND = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_research
	greyscale_colors = "#bc4a9b#793a80"

/obj/item/encryptionkey/heads/hos
	name = "\proper the head of security's encryption key"
	icon_state = "cypherkey_security"
	channels = list(RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_COMMAND = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_security
	greyscale_colors = "#280b1a#820a16"

/obj/item/encryptionkey/heads/ce
	name = "\proper the chief engineer's encryption key"
	icon_state = "cypherkey_engineering"
	channels = list(RADIO_CHANNEL_ENGINEERING = 1, RADIO_CHANNEL_COMMAND = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_engineering
	greyscale_colors = "#dca01b#f8d860"

/obj/item/encryptionkey/heads/cmo
	name = "\proper the chief medical officer's encryption key"
	icon_state = "cypherkey_medical"
	channels = list(RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_COMMAND = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_medical
	greyscale_colors = "#ebebeb#2b2793"

/obj/item/encryptionkey/heads/hop
	name = "\proper the head of personnel's encryption key"
	icon_state = "cypherkey_cube"
	channels = list(RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_SUPPLY = 1) //monkestation edit: QM is not a fucking head, HOP requires access on the supply circuit.
	greyscale_config = /datum/greyscale_config/encryptionkey_cube
	greyscale_colors = "#2b2793#c2c1c9"

/obj/item/encryptionkey/heads/qm
	name = "\proper the quartermaster's encryption key"
	icon_state = "cypherkey_cargo"
	channels = list(RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_COMMAND = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_cargo
	greyscale_colors = "#49241a#dca01b"

/obj/item/encryptionkey/headset_cargo
	name = "supply radio encryption key"
	icon_state = "cypherkey_cargo"
	channels = list(RADIO_CHANNEL_SUPPLY = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_cargo
	greyscale_colors = "#49241a#7b3f2e"

/obj/item/encryptionkey/headset_mining
	name = "mining radio encryption key"
	icon_state = "cypherkey_cargo"
	channels = list(RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_SCIENCE = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_cargo
	greyscale_colors = "#49241a#bc4a9b"

/obj/item/encryptionkey/headset_service
	name = "service radio encryption key"
	icon_state = "cypherkey_service"
	channels = list(RADIO_CHANNEL_SERVICE = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_service
	greyscale_colors = "#3758c4#3bca5a"

/obj/item/encryptionkey/headset_cent
	name = "\improper CentCom radio encryption key"
	icon_state = "cypherkey_centcom"
	independent = TRUE
	channels = list(RADIO_CHANNEL_CENTCOM = 1)
	greyscale_config = /datum/greyscale_config/encryptionkey_centcom
	greyscale_colors = "#24a157#dca01b"

//MONKESTATION EDIT
/obj/item/encryptionkey/headset_cent/crew
	desc = "An encryption key for a radio headset. It looks like there is a bluespace chip attached to it."

/obj/item/encryptionkey/headset_cent/crew/Initialize(mapload)
	. = ..()
	GLOB.crew_cc_keys += src

/obj/item/encryptionkey/headset_cent/crew/proc/toggle_off()
	independent = FALSE
	channels = null
	playsound(src, 'sound/weapons/flash.ogg', 25, TRUE)
	do_sparks(2, FALSE, src)
	if(istype(src.loc, /obj/item/radio))
		var/obj/item/radio/our_radio  = src.loc
		our_radio.recalculateChannels()

/obj/item/encryptionkey/headset_cent/crew/proc/toggle_on()
	independent = TRUE
	channels = list(RADIO_CHANNEL_CENTCOM = 1)
	playsound(src, 'sound/weapons/flash.ogg', 25, TRUE)
	do_sparks(2, FALSE, src)
	if(istype(src.loc, /obj/item/radio))
		var/obj/item/radio/our_radio = src.loc
		our_radio.recalculateChannels()

/obj/item/encryptionkey/headset_cent/crew/Destroy()
	if(src in GLOB.crew_cc_keys)
		GLOB.crew_cc_keys -= src
	return ..()

/obj/item/encryptionkey/headset_cent/crew/service
	channels = list(
		RADIO_CHANNEL_CENTCOM = 1,
		RADIO_CHANNEL_SERVICE = 1,
	)

//MONKESTATION EDIT STOP

/obj/item/encryptionkey/ai //ported from NT, this goes 'inside' the AI.
	channels = list(
		RADIO_CHANNEL_COMMAND = 1,
		RADIO_CHANNEL_SECURITY = 1,
		RADIO_CHANNEL_ENGINEERING = 1,
		RADIO_CHANNEL_SCIENCE = 1,
		RADIO_CHANNEL_MEDICAL = 1,
		RADIO_CHANNEL_SUPPLY = 1,
		RADIO_CHANNEL_SERVICE = 1,
		RADIO_CHANNEL_AI_PRIVATE = 1,
		RADIO_CHANNEL_ENTERTAINMENT = 1,
	)

/obj/item/encryptionkey/secbot
	channels = list(RADIO_CHANNEL_AI_PRIVATE = 1, RADIO_CHANNEL_SECURITY = 1)

/obj/item/encryptionkey/moth
	name = "\improper Moffic translation key"
	desc = "An encryption key that automatically encodes moffic heard through the radio into common. The signal's a little fuzzy."
	icon_state = "translation_cypherkey"
	language_data = list(
		/datum/language/moffic = 100,
	)
	greyscale_config = null
	greyscale_colors = null

/obj/item/encryptionkey/tiziran
	name = "\improper Tiziran translation key"
	desc = "An encryption key that automatically encodes draconic heard through the radio into common. The signal's not quite to scale."
	icon_state = "translation_cypherkey"
	language_data = list(
		/datum/language/draconic = 100,
	)
	greyscale_config = null
	greyscale_colors = null

/obj/item/encryptionkey/plasmaman
	name = "\improper Calcic translation key"
	desc = "An encryption key that automatically encodes calcic heard through the radio into common. The signal lacks a bit of teeth."
	icon_state = "translation_cypherkey"
	language_data = list(
		/datum/language/calcic = 100,
	)
	greyscale_config = null
	greyscale_colors = null

/obj/item/encryptionkey/ethereal
	name = "\improper Ethereal translation key"
	desc = "An encryption key that automatically encodes ethereal heard through the radio into common. The signal's overpowering."
	icon_state = "translation_cypherkey"
	language_data = list(
		/datum/language/voltaic = 100,
	)
	greyscale_config = null
	greyscale_colors = null

/obj/item/encryptionkey/felinid
	name = "\improper Felinid translation key"
	desc = "An encryption key that automatically encodes nekomimetic heard through the radio into common. The signal's rather scratchy."
	icon_state = "translation_cypherkey"
	language_data = list(
		/datum/language/nekomimetic = 100,
	)
	greyscale_config = null
	greyscale_colors = null
