
/datum/bloodcult_ritual/sacrifice_captain
	name = "Sacrifice Captain"
	desc = "a captain...<br>an altar...<br>and a proper blade..."

	only_once = TRUE
	ritual_type = "sacrifice"
	difficulty = "hard"
	reward_faction = 500

	keys = list("altar_sacrifice_human")

/datum/bloodcult_ritual/sacrifice_captain/pre_conditions(var/datum/antagonist/cult/potential)
	if (potential)
		owner = potential
	for(var/mob/M in GLOB.player_list)
		if(M.mind && M.mind.assigned_role == "Captain")
			return TRUE
	return FALSE

/datum/bloodcult_ritual/sacrifice_captain/key_found(var/mob/living/O)
	if (istype(O) && O.mind && O.mind.assigned_role == "Captain")
		return TRUE
	return FALSE
