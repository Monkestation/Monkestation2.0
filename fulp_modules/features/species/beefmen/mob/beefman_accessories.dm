/datum/sprite_accessory/beef
	icon = 'fulp_modules/icons/species/mob/beefman_bodyparts.dmi'

// Eyes //
//Currently only used by mutantparts so don't worry about hair and stuff.
//This is the source that this accessory will get its color from. Default is MUTCOLOR, but can also be HAIR, FACEHAIR, EYECOLOR and 0 if none.
/datum/sprite_accessory/beef/eyes
	color_src = FALSE

/datum/sprite_accessory/beef/eyes/capers
	name = BEEF_EYES_CAPERS
	icon_state = "capers"

/datum/sprite_accessory/beef/eyes/olives
	name = BEEF_EYES_OLIVES
	icon_state = "olives"

/datum/sprite_accessory/beef/eyes/cloves
	name = BEEF_EYES_CLOVES
	icon_state = "cloves"

/datum/sprite_accessory/beef/eyes/peppercorns
	name = BEEF_EYES_PEPPERCORNS
	icon_state = "peppercorns"

// Mouth //

/datum/sprite_accessory/beef/mouth
	use_static = TRUE
	color_src = FALSE

/datum/sprite_accessory/beef/mouth/frown
	name = BEEF_MOUTH_FROWN
	icon_state = "frown"

/datum/sprite_accessory/beef/mouth/disappointed
	name = BEEF_MOUTH_DISAPPOINTED
	icon_state = "disappointing"

/datum/sprite_accessory/beef/mouth/grit
	name = BEEF_MOUTH_GRIT
	icon_state = "grit"

/datum/sprite_accessory/beef/mouth/grittingsmile
	name = BEEF_MOUTH_GRITTING_SMILE
	icon_state = "grittingsmile"

/datum/sprite_accessory/beef/mouth/smile
	name = BEEF_MOUTH_SMILE
	icon_state = "smile"

/datum/sprite_accessory/beef/mouth/smirk
	name = BEEF_MOUTH_SMIRK
	icon_state = "smirk"

/datum/bodypart_overlay/simple/body_marking/beefman_eyes
	dna_feature_key = "beef_eyes"
	applies_to = list(/obj/item/bodypart/head)

/datum/bodypart_overlay/simple/body_marking/beefman_eyes/get_accessory(name)
	return SSaccessories.eyes_beefman_list[name]

/datum/bodypart_overlay/simple/body_marking/beefman_mouth
	dna_feature_key = "beef_mouth"
	applies_to = list(/obj/item/bodypart/head)

/datum/bodypart_overlay/simple/body_marking/beefman_mouth/get_accessory(name)
	return SSaccessories.mouths_beefman_list[name]
