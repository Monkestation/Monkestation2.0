/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			TG OVERWRITES

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/carbon/transfer_blood_to(atom/movable/AM, amount, forced)
	. = ..()

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = mind?.has_antag_datum(/datum/antagonist/bloodsucker)
	bloodsuckerdatum?.bloodsucker_blood_volume -= amount

/// Prevents using a Memento Mori
/obj/item/clothing/neck/necklace/memento_mori/memento(mob/living/carbon/human/user)
	if(IS_BLOODSUCKER(user))
		to_chat(user, span_warning("The Memento notices your undead soul, and refuses to react.."))
		return
	return ..()

/obj/item/clothing/neck/necklace/memento_mori/check_health(mob/living/source)
	if(source.health <= HEALTH_THRESHOLD_DEAD && IS_BLOODSUCKER(source))
		to_chat(source, span_warning("The Memento notices your undead soul and is enraged by your trickery"))
		mori()
		return
	return ..()

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
