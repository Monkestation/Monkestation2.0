/datum/quirk/polyglot
	name = "Polyglot"
	desc = "Over the years you've picked up most of the common languages!"
	icon = FA_ICON_EARTH
	value = 8
	gain_text = span_notice("You've studied extremely hard, you can recall several languages.")
	lose_text = span_notice("You feel like you've forgotten some languages.")
	medical_record_text = "Patient speaks multiple languages."
	mail_goodies = list(/obj/item/taperecorder, /obj/item/clothing/head/frenchberet, /obj/item/clothing/mask/fakemoustache/italian)

/datum/quirk/polyglot/add(client/client_source)
	for(var/language in GLOB.roundstart_languages)
		quirk_holder.grant_language(language, source = LANGUAGE_QUIRK)

/datum/quirk/polyglot/remove()
	if(QDELING(quirk_holder))
		return
	quirk_holder.remove_all_languages(source = LANGUAGE_QUIRK)
	quirk_holder.remove_all_partial_languages(source = LANGUAGE_QUIRK)
