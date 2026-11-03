/**
	* Toggle Death Signal simply adds and removes the trait required for slimepeople to transmit a GPS signal upon core ejection.
	*/
/datum/action/innate/core_signal
	name = "Toggle Core Signal"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "core_signal"
	button_icon = SLIME_ACTIONS_ICON_FILE
	background_icon_state = "bg_alien"

/datum/action/innate/core_signal/Activate()
	var/obj/item/organ/internal/brain/slime/core = target
	if(core.gps_active)
		to_chat(owner, span_notice("You tune out the electromagnetic signals from your core so they are ignored by GPS receivers upon its ejection."))
		core.gps_active = FALSE
	else
		to_chat(owner, span_notice("You fine-tune the electromagnetic signals from your core to be picked up by GPS receivers upon its ejection."))
		core.gps_active = TRUE
