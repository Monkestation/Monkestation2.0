/datum/sprite_accessory
	///the body slots outside of the main slot this accessory exists in, so we can draw to those spots seperately
	var/list/body_slots = list()
	/// the list of external organs covered
	var/list/external_slots = list()

/datum/sprite_accessory/body_markings
	color_src = MUTCOLORS_SECONDARY

/datum/sprite_accessory/body_markings/light_belly
	name = "Light Belly"
	body_slots = list(BODY_ZONE_HEAD)
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'monkestation/icons/mob/species/lizard/multipart.dmi'
	icon_state = "lbelly"
	gender_specific = TRUE

/datum/sprite_accessory/body_markings/glow_belly
	name = "Glow Belly"
	body_slots = list(BODY_ZONE_HEAD)
	external_slots = list(ORGAN_SLOT_EXTERNAL_TAIL)
	icon = 'monkestation/icons/mob/species/lizard/multipart.dmi'
	icon_state = "lbelly"
	gender_specific = TRUE
	is_emissive = TRUE
