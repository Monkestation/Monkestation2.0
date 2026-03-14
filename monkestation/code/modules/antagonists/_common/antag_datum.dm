///Call to give someone who spent an antag token this type of antag status
/datum/antagonist/proc/antag_token(datum/mind/hosts_mind, mob/spender)
	//SHOULD_CALL_PARENT(FALSE) //this is here for the sake of making it clear you should just fully override this proc, AKA dont call ..()
	if(isobserver(spender))
		var/mob/living/carbon/human/new_mob = spender.change_mob_type(/mob/living/carbon/human, delete_old_mob = TRUE)
		new_mob.equipOutfit(/datum/outfit/job/assistant)
		new_mob.mind.add_antag_datum(type)
	else
		hosts_mind.add_antag_datum(type)

/datum/antagonist/proc/get_base_preview_icon() as /icon
	RETURN_TYPE(/icon)
	return null

/datum/antagonist/proc/render_poll_preview() as /image
	RETURN_TYPE(/image)
	var/icon/base_preview = get_base_preview_icon()
	if(base_preview)
		return image(base_preview)
	if(preview_outfit)
		var/icon/rendered_outfit = render_preview_outfit(preview_outfit)
		if(rendered_outfit)
			return image(rendered_outfit)
	return image('icons/effects/effects.dmi', icon_state = "static", layer = FLOAT_LAYER)
