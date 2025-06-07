
/datum/bloodcult_ritual/sacrifice_mouse
	name = "Sacrifice Mouse"
	desc = "a rodent...<br>an altar...<br>and a proper blade..."

	ritual_type = "sacrifice"
	difficulty = "easy"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list("altar_sacrifice_animal")

/datum/bloodcult_ritual/sacrifice_mouse/key_found(mob/living/basic/mouse/extra)
	if(istype(extra))
		return TRUE
	return FALSE
