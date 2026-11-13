/datum/ai_controller/chicken/gary
	behavior_tree_json = "monkestation/code/modules/ranching/chickens/ai/gary/gary.bt.json"
	ai_movement = /datum/ai_movement/jps/gary
	max_target_distance = 250

/datum/ai_controller/chicken/gary/get_access()
	return REGION_ACCESS_ALL_STATION

/datum/ai_controller/chicken/gary/proc/set_home(turf/open/new_home)
	if(QDELETED(new_home))
		return
	set_blackboard_key(BB_GARY_HIDEOUT, list(new_home.x, new_home.y, new_home.z))
	set_blackboard_key(BB_GARY_HIDEOUT_SETTING_UP, TRUE)
	set_blackboard_key(BB_GARY_COME_HOME, TRUE)

/// Where gary's hideout is, if he's got one
/datum/ai_controller/chicken/gary/proc/get_hideout()
	var/list/turf_coords = blackboard[BB_GARY_HIDEOUT]
	if(length(turf_coords) != 3)
		return null
	return locate(turf_coords[1], turf_coords[2], turf_coords[3])

/datum/ai_movement/jps/gary
	max_pathing_attempts = 25
	maximum_length = 175
	diagonal_flags = DIAGONAL_REMOVE_ALL
