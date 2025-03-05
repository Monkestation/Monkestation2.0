/// Immediately finished the cooldown if there is one, making the ability available for immediate use again.
/datum/action/cooldown/proc/finish_cooldown_now()
	STOP_PROCESSING(SSfastprocess, src)
	next_use_time = 0
	build_all_button_icons(UPDATE_BUTTON_STATUS)
