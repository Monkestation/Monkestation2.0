/datum/hud/proc/streamer_hud(ui_style = 'icons/hud/screen_midnight.dmi')
	streamer_display = new /atom/movable/screen
	streamer_display.name = "Streaming Stats"
	streamer_display.icon = null
	streamer_display.screen_loc = ui_more_under_health_and_to_the_left
	mymob.client.screen += list(streamer_display)
