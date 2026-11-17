// Language

/datum/language/vox
	name = "Vox-pidgin"
	desc = "The common tongue of the various Vox ships making up the Shoal. It sounds like chaotic shrieking to everyone else."
	key = "V"
	syllables = list(
		"ti", "ti", "ti", "hi", "hi", "ki", "ki", "ki", "ki", "ya", "ta", "ha", "ka", "ya", "yi", "chi", "cha", "kah",
		"SKRE", "AHK", "EHK", "RAWK", "KRA", "AAA", "EEE", "KI", "II", "KRI", "KA",
	)
	default_priority = 90
	icon = 'icons/obj/species/vox/language.dmi'
	icon_state = "voxpidgin"

/datum/language_holder/vox
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/vox = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/vox = list(LANGUAGE_ATOM),
	)

// Blood

/datum/blood_type/vox
	name = BLOOD_TYPE_VOX
	dna_string = "Vox DNA"
	color = BLOOD_COLOR_VOX

// Emote

/datum/emote/living/carbon/human/quill
	key = "quill"
	key_third_person = "quills"
	message = "rustles their quills."
	message_param = "rustles their quills at %t."
	emote_type = EMOTE_AUDIBLE
	// Credit to sound-ideas (freesfx.co.uk) for the sound.
	sound = 'sound/voice/vox_species/voxrustle.ogg'

/datum/emote/living/carbon/human/quill/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE)
	return isvox(user) && ..()

// Breathing gear

/obj/item/clothing/mask/breath/vox
	name = "vox breath mask"
	desc = "A weirdly-shaped breath mask."
	icon = 'icons/obj/species/vox/items.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/mask.dmi'
	icon_state = "voxmask"
	flags_cover = NONE
	visor_flags_cover = NONE
	actions_types = null
	adjustable = FALSE

/obj/item/clothing/mask/breath/vox/respirator
	name = "vox respirator"
	desc = "A weirdly-shaped breath mask, this one seems to be designed for a vox beak."
	icon_state = "voxmask2"

/obj/item/tank/internals/emergency_oxygen/vox
	name = "vox specialized nitrogen tank"
	desc = "A high-tech nitrogen tank designed specifically for Vox."
	icon = 'icons/obj/species/vox/items.dmi'
	icon_state = "emergency_vox"
	inhand_icon_state = "emergency_vox"
	lefthand_file = 'icons/obj/species/vox/tank_lefthand.dmi'
	righthand_file = 'icons/obj/species/vox/tank_righthand.dmi'
	worn_icon = 'icons/obj/species/vox/tank_worn.dmi'
	worn_icon_state = "emergency_vox"
	volume = 35

/obj/item/tank/internals/emergency_oxygen/vox/populate_gas()
	air_contents.set_gas(/datum/gas/nitrogen, (10 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/tank/internals/emergency_oxygen/vox/empty/populate_gas()
	return

/// What a vox needs to not choke on the station's air. Jobs instead give the mask and tank from the player's preferences.
/datum/outfit/vox
	name = "Vox Internals"
	mask = /obj/item/clothing/mask/breath/vox
	r_hand = /obj/item/tank/internals/emergency_oxygen/vox
	internals_slot = ITEM_SLOT_HANDS

// Butchery results

/obj/item/food/meat/slab/human/mutant/vox
	icon = 'icons/obj/species/vox/items.dmi'
	icon_state = "voxmeat"
	desc = "Surprisingly, it doesn't actually taste like chicken."
	tastes = list("skrek" = 1)
	foodtypes = MEAT | RAW | TOXIC
	venue_value = FOOD_MEAT_MUTANT

/obj/item/stack/sheet/animalhide/vox
	name = "vox hide"
	desc = "SKREE!"
	singular_name = "vox hide piece"
	icon = 'icons/obj/species/vox/items.dmi'
	icon_state = "sheet-vox"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/animalhide/vox
