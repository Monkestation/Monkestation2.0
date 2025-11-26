/datum/computer_file/program/nt_rep_comments
	filename = "ntrating"
	filedesc = "Central Command Rating"
	program_open_overlay = "generic"
	size = 1
	extended_desc = "Used by NT Representatives to rate and comment on the state of their station."
	tgui_id = "NtosNtRep"
	program_icon = "percent"

	run_access = list(ACCESS_NT_REPRESENTATVE)
	download_access = list(ACCESS_NT_REPRESENTATVE)
	can_run_on_flags = PROGRAM_ALL
	program_flags = PROGRAM_RUNS_WITHOUT_POWER

/datum/computer_file/program/nt_rep_comments/ui_data(mob/user)
	var/list/data = list()
	if(istype(computer?.computer_id_slot, /obj/item/card/id/advanced/centcom))
		data["rating"] = SSticker.nanotrasen_rep_score
		data["comment"] = SSticker.nanotrasen_rep_comments
		data["is_centcom"] = TRUE
	else
		data["rating"] = null
		data["comment"] = null
		data["is_centcom"] = FALSE
	return data

/datum/computer_file/program/nt_rep_comments/ui_static_data(mob/user)
	var/list/data = list()
	data["max_length"] = MAX_BROADCAST_LEN
	return data

/datum/computer_file/program/nt_rep_comments/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!istype(computer?.computer_id_slot, /obj/item/card/id/advanced/centcom))
		return
	switch(action)
		if("change_rating")
			var/new_rating = params["new_rating"]
			if(!isnum(new_rating))
				return FALSE
			return update_rating(new_rating)
		if("set_text")
			var/review = params["new_review"]
			if(!istext(review))
				return FALSE
			return update_comment(trim(html_decode(review), MAX_BROADCAST_LEN))

///Updates the roundend NT rep final score to what we've inputed, if the round is in progress.
/datum/computer_file/program/nt_rep_comments/proc/update_rating(new_rating)
	if(SSticker.nanotrasen_rep_score == new_rating || !SSticker.IsRoundInProgress())
		return FALSE
	SSticker.nanotrasen_rep_score = min(MAX_NT_REP_SCORE, new_rating)
	return TRUE

///Updates the roundend NT rep comment to what we've inputed, if the round is in progress.
/datum/computer_file/program/nt_rep_comments/proc/update_comment(new_review)
	if(!SSticker.IsRoundInProgress())
		return FALSE
	SSticker.nanotrasen_rep_comments = new_review
	return TRUE
