/datum/command_report_menu
	var/append_update_name = TRUE
	var/custom_played_sound

/datum/command_report_menu/ui_static_data(mob/user)
	. = ..()
	.["append_update_name"] = append_update_name

/datum/command_report_menu/ui_data(mob/user)
	. = ..()
	.["append_update_name"] = append_update_name

/datum/command_report_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	switch(action)
		if("toggle_update_append")
			append_update_name = !append_update_name

	. = ..()
