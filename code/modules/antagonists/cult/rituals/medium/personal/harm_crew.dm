
/datum/bloodcult_ritual/harm_crew
	name = "Harm Crew"
	desc = "wield cult weaponry...<br>spill their blood...<br>sear their skin..."

	ritual_type = "harm"
	difficulty = "medium"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list(
		"attack_tome",
		"attack_cultblade",
		"attack_blooddagger",
		"attack_construct",
		"attack_shade",
		"attack_ritualknife",
		)

	var/targets = 3
	var/list/hit_targets = list()

/datum/bloodcult_ritual/harm_crew/init_ritual()
	hit_targets = list()

/datum/bloodcult_ritual/harm_crew/update_desc()
	desc = "wield cult weaponry...<br>spill their blood...<br>sear their skin...<br>at least [targets - hit_targets.len] different individuals..."

/datum/bloodcult_ritual/harm_crew/key_found(var/mob/living/L)
	if (IS_CULTIST(L))
		return FALSE
	if (L.mind in hit_targets)
		return FALSE
	hit_targets += L.mind
	if(hit_targets.len >= targets)
		return TRUE
	return FALSE
