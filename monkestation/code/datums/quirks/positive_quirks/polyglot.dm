/datum/quirk/polyglot
	name = "Polyglot"
	desc = "Over the years you've picked up most of the common languages!"
	icon = FA_ICON_EARTH
	value = 8
	gain_text = span_notice("You've studied extremely hard, you can recall several languages.")
	lose_text = span_notice("You feel like you've forgotten some languages.")
	medical_record_text = "Patient speaks multiple languages."
	mail_goodies = list(/obj/item/taperecorder, /obj/item/clothing/head/frenchberet, /obj/item/clothing/mask/fakemoustache/italian)

/datum/quirk/polyglot/add_unique(client/client_source)
	for(var/language in GLOB.roundstart_languages)
		quirk_holder.grant_language(language, understood = TRUE, spoken = TRUE, source = LANGUAGE_QUIRK)

