
/datum/bloodcult_ritual/sacrifice_monkey
	name = "Sacrifice Monkey"
	desc = "a simian...<br>an altar...<br>and a proper blade..."

	ritual_type = "sacrifice"
	difficulty = "easy"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list("altar_sacrifice_monkey")

/datum/bloodcult_ritual/sacrifice_monkey/key_found(var/extra)
	return TRUE
