/datum/quirk/language_holder
	abstract_parent_type = /datum/quirk/language_holder
	mail_goodies = list(/obj/item/taperecorder) // for translation

/datum/quirk/language_holder/proc/recreate_language_holder(client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.language_holder = new human_holder.language_holder.type(human_holder)
	human_holder.update_atom_languages()
	var/datum/quirk/bilingual/bilingual = human_holder.get_quirk(/datum/quirk/bilingual)
	if (bilingual)
		bilingual.add_unique(client_source)

/datum/quirk/language_holder/add(client/client_source)
	recreate_language_holder(client_source)

/datum/quirk/language_holder/remove(client/client_source)
	recreate_language_holder(client_source)

/datum/quirk/language_holder/uncommon
	name = "Uncommon"
	desc = "You don't understand Galactic Common having learned Galactic Uncommon instead."
	icon = FA_ICON_LANGUAGE
	value = QUIRK_COST_UNCOMMON
	gain_text = span_notice("The words being spoken around you don't make any sense.")
	lose_text = span_notice("You've developed fluency in Galactic Common.")
	medical_record_text = "Patient does not understand Galactic Common and may require an interpreter."

/datum/quirk/language_holder/outsider
	name = "Outsider"
	desc = "You don't know your species' language. If you are human you know a random language instead of Galactic Common."
	icon = FA_ICON_BAN
	value = QUIRK_COST_OUTSIDER
	gain_text = span_notice("You can't understand your species' language.")
	lose_text = span_notice("You've remembered your species' language.")

/datum/quirk/language_holder/listener
	name = "Listener"
	desc = "You are unable to speak Galactic Common though you understand it just fine."
	icon = FA_ICON_BELL_SLASH
	value = QUIRK_COST_LISTENER
	hardcore_value = QUIRK_HARDCORE_LISTENER
	gain_text = span_notice("You don't know how to speak Galactic Common.")
	lose_text = span_notice("You're able to speak Galactic Common.")
	medical_record_text = "Patient does not speak Galactic Common and may require an interpreter."
