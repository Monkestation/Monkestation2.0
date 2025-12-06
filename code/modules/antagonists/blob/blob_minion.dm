/datum/antagonist/blob_minion
	name = "\improper Blob Minion"
	antagpanel_category = ANTAG_GROUP_BIOHAZARDS
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	show_in_antagpanel = FALSE
	antag_flags = FLAG_ANTAG_CAP_IGNORE // monkestation addition
	/// The blob team that this minion is attached to
	var/datum/team/blob/blob_team

/datum/antagonist/blob_minion/New(datum/team/blob/blob_team)
	src.blob_team = blob_team
	return ..()

/datum/antagonist/blob_minion/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/blob_minion/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/blob_minion/forge_objectives()
	var/datum/objective/blob_minion/objective = new
	objective.owner = owner
	objective.blob_team = blob_team
	objectives += objective

/datum/objective/blob_minion
	name = "protect the blob core"
	explanation_text = "Protect the blob core at all costs."
	/// The blob team that this objective is attached to
	var/datum/team/blob/blob_team

/datum/objective/blob_minion/check_completion()
	return blob_team?.main_overmind?.stat != DEAD
