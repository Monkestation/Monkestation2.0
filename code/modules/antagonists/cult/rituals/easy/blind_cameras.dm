
/datum/bloodcult_ritual/blind_cameras_multi
	name = "Blind Many Cameras"
	desc = "confusion runes and talismans...<br>darken their lenses..."

	ritual_type = "confusion"
	difficulty = "easy"
	reward_faction = 200

	keys = list("confusion_camera")

	var/target_cameras = 20

/datum/bloodcult_ritual/blind_cameras_multi/init_ritual()
	target_cameras = 20

/datum/bloodcult_ritual/blind_cameras_multi/update_desc()
	desc = "confusion runes and talismans...<br>darken their lenses...<br>[target_cameras] to go..."

/datum/bloodcult_ritual/blind_cameras_multi/key_found(var/extra)
	target_cameras--
	if(target_cameras <= 0)
		return TRUE
	return FALSE
