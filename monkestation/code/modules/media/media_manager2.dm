//#define MEDIA_WINDOW_ID "mediapanel2meow"
#define MEDIA_CALL(name, args...) owner << output(list2params(list(##args)), "media2:[name]")

/client
	var/datum/media_manager2/media2

/datum/media_manager2
	var/client/owner
	var/static/base_html

/datum/media_manager2/New(client/owner)
	src.owner = owner
	if(isnull(base_html))
		init_base_html()
	send()
	addtimer(CALLBACK(src, PROC_REF(open)), 2 SECONDS)

/datum/media_manager2/Destroy(force)
	owner = null
	return ..()

/datum/media_manager2/proc/send()
	set waitfor = FALSE
	sleep(0.5 SECONDS)
	if(get_asset_datum(/datum/asset/simple/media_manager2).send(owner))
		to_chat(owner, span_notice("Assets were sent!"))
	else
		to_chat(owner, span_warning("Assets were NOT sent!"))

/datum/media_manager2/proc/open()
	set waitfor = FALSE
	if(QDELETED(src))
		return
	var/html = replacetextEx(base_html, "media:href", REF(src))
	//owner << browse(null, "window=media2")
	owner << browse(html, "window=media2;size=300x300;can_minimize=0")

/datum/media_manager2/proc/init_base_html()
	get_asset_datum(/datum/asset/simple/media_manager2)
	var/js = replacetextEx(file2text("monkestation/code/modules/media/assets/media_player.js"), "media_player.wasm", SSassets.transport.get_asset_url("media_player.wasm"))
	base_html = file2text("monkestation/code/modules/media/assets/media_player.html")
	base_html = replacetextEx(base_html, "<!-- media:wasm -->", "<script type='text/javascript' src='[SSassets.transport.get_asset_url("media_player_wasm.js")]'></script>")
	base_html = replacetextEx(base_html, "<!-- media:main -->", "<script type='text/javascript'>[js]</script>")

/datum/media_manager2/proc/set_url(url)
	if(!QDELETED(src))
		MEDIA_CALL("set_url", url)

/datum/media_manager2/proc/set_position(x = 0, y = 0)
	if(!QDELETED(src))
		MEDIA_CALL("set_position", x, y)

/datum/media_manager2/proc/set_time(time)
	if(!QDELETED(src))
		MEDIA_CALL("set_time", time)

/datum/media_manager2/proc/play(url)
	if(!QDELETED(src))
		MEDIA_CALL("play", url)

/datum/media_manager2/proc/pause()
	if(!QDELETED(src))
		MEDIA_CALL("pause")

/datum/media_manager2/proc/stop()
	if(!QDELETED(src))
		MEDIA_CALL("stop")

/datum/media_manager2/Topic(href, list/href_list)
	. = ..()
	if(href_list["ready"])
		message_admins("mm2 ready for [key_name(owner)]")
		log_world("mm2 ready for [key_name(owner)]")
	else if(href_list["media_error"])
		message_admins("mm2 error: [href_list["media_error"]]")
		stack_trace(href_list["media_error"])
	message_admins("mm2 topic: [json_encode(href_list, JSON_PRETTY_PRINT)]")
	log_world("mm2 topic: [json_encode(href_list, JSON_PRETTY_PRINT)]")

/client/verb/mm2_set_url()
	set name = "MM2: Set URL"
	set category = "MM2"

	var/url = trimtext(tgui_input_text(src, "Set URL", "Media Manager 2", encode = FALSE))
	if(url)
		media2.set_url(url)
		message_admins("mm2: url set to [url]")

/client/verb/mm2_play()
	set name = "MM2: Play"
	set category = "MM2"

	media2.play()
	message_admins("mm2: playing")

/client/verb/mm2_pause()
	set name = "MM2: Pause"
	set category = "MM2"

	media2.pause()
	message_admins("mm2: paused")

/client/verb/mm2_stop()
	set name = "MM2: Stop"
	set category = "MM2"

	media2.stop()
	message_admins("mm2: stopped")

/client/verb/mm2_set_position()
	set name = "MM2: Set Position"
	set category = "MM2"

	var/x = tgui_input_number(src, "Set X Value", "Media Manager 2", default = 0, min_value = -10, max_value = 10) || 0
	var/y = tgui_input_number(src, "Set Y Value", "Media Manager 2", default = 0, min_value = -10, max_value = 10) || 0
	media2.set_position(x, y)
	message_admins("mm2: set pos to [x],[y]")

/client/verb/mm2_set_time()
	set name = "MM2: Set Time"
	set category = "MM2"

	var/time = tgui_input_number(src, "Set Time (Seconds)", "Media Manager 2", default = 0, min_value = 0, round_value = FALSE) || 0
	media2.set_time(time)
	message_admins("mm2: set time to [time]")

//#undef MEDIA_WINDOW_ID
