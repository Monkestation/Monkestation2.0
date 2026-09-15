/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			TG OVERWRITES

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Used when analyzing a Bloodsucker, Masquerade will hide brain traumas (Unless you're a Beefman)
/mob/living/carbon/get_traumas(ignore_flags = NONE)
	if(QDELETED(mind))
		return ..()
	if(IS_BLOODSUCKER(src) && HAS_TRAIT(src, TRAIT_MASQUERADE))
		return
	return ..()

/datum/outfit/bloodsucker_outfit
	name = "Bloodsucker outfit (Preview only)"
	suit = /obj/item/clothing/suit/costume/dracula

/datum/outfit/bloodsucker_outfit/post_equip(mob/living/carbon/human/enrico, visualsOnly=FALSE)
	enrico.hairstyle = "Undercut"
	enrico.hair_color = "FFF"
	enrico.skin_tone = "african2"
	enrico.eye_color_left = "#663300"
	enrico.eye_color_right = "#663300"

	enrico.update_body(is_creating = TRUE)
