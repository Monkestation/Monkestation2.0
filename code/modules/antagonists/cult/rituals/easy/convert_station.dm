
/datum/bloodcult_ritual/convert_station
	name = "Cultify the Station"
	desc = "convert the floors...<br>convert the walls..."

	ritual_type = "constructs"
	difficulty = "easy"
	reward_faction = 200

	keys = list(
		"convert_floor",
		"convert_wall",
		)

	var/target = 30
	var/list/turfs = list()

/datum/bloodcult_ritual/convert_station/init_ritual()
	turfs = list()

/datum/bloodcult_ritual/convert_station/update_desc()
	desc = "convert the floors...<br>convert the walls...<br>need [target - turfs.len] more..."

/datum/bloodcult_ritual/convert_station/key_found(turf/T)
	if (T in turfs)
		return FALSE
	turfs += T
	if(turfs.len >= target)
		return TRUE
	return FALSE
