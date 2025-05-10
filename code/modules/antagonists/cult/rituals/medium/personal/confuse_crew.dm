
/datum/bloodcult_ritual/confuse_crew
	name = "Confuse Crew"
	desc = "confusion runes and talismans...<br>bring their nightmares to life..."

	ritual_type = "confusion"
	difficulty = "medium"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list(
		"confusion_carbon",
		"confusion_papered",
		)

/datum/bloodcult_ritual/confuse_crew/key_found(var/mob/living/extra)
	if (!extra.client)
		return FALSE
	return TRUE
