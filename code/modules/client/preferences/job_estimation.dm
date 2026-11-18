/datum/preference/toggle/ready_job
	savefile_key = "ready_job"
	savefile_identifier = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = TRUE

/datum/preference/toggle/ready_job/apply_to_human(mob/living/carbon/human/target, value, /datum/preferences/preferences)
	return FALSE

/datum/preference/toggle/ready_job/apply_to_client_updated(client/client, value)
	. = ..()
	SSstatpanels.update_job_estimation(ckey = client.ckey)
