
/datum/bloodcult_ritual/blind_cameras
	name = "Blind Cameras"
	desc = "confusion runes and talismans...<br>darken their lenses..."

	ritual_type = "confusion"
	difficulty = "easy"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list("confusion_camera")

	var/target_cameras = 3

/datum/bloodcult_ritual/blind_cameras/init_ritual()
	target_cameras = 3

//Called when a cultist is about to hover the corresponding ritual UI button
/datum/bloodcult_ritual/blind_cameras/update_desc()
	desc = "confusion runes and talismans...<br>darken their lenses...<br>[target_cameras] to go..."

/datum/bloodcult_ritual/blind_cameras/key_found(var/extra)
	target_cameras--
	if(target_cameras <= 0)
		return TRUE
	return FALSE
