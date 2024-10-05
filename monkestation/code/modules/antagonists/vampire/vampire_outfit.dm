/datum/outfit/vampire
	name = "Vampire (Preview only)"
	suit = /obj/item/clothing/suit/costume/dracula

/datum/outfit/vampire/post_equip(mob/living/carbon/human/preview_target, visualsOnly = FALSE)
	preview_target.hairstyle = "Undercut"
	preview_target.hair_color = "FFF"
	preview_target.skin_tone = "african2"
	preview_target.eye_color_left = "#663300"
	preview_target.eye_color_right = "#663300"

	preview_target.update_body(is_creating = TRUE)
