//#define MM2_DEBUGGING

#ifdef MM2_DEBUGGING
#define MM2_DEBUG(x) message_admins(x)
#warn COMMENT OUT MM2_DEBUGGING BEFORE DEPLOYING!!!
#else
#define MM2_DEBUG(x)
#endif

#define MEDIA_WINDOW_ID "outputwindow.mediapanel2"
#define MEDIA_CALL(name, args...) owner << output(list2params(list(##args)), is_browser ? (MEDIA_WINDOW_ID + ":" + name) : (MEDIA_WINDOW_ID + ".browser:" + name))
#define WAIT_UNTIL_READY \
	if(QDELETED(src)) { \
		return; \
	}; \
	if(!ready) { \
		var/__end_time = REALTIMEOFDAY + (5 SECONDS); \
		while(!ready && (REALTIMEOFDAY < __end_time)) { \
			stoplag(); \
			if(QDELETED(src)) { \
				return; \
			}; \
		}; \
		if(!ready) { \
			return; \
		}; \
	};

/client
	var/datum/media_manager2/media2

/datum/media_manager2
	var/client/owner
	var/is_browser = FALSE
	var/ready = FALSE
	var/static/base_html

/datum/media_manager2/New(client/owner)
	src.owner = owner
	if(isnull(base_html))
		init_base_html()
	open()

/datum/media_manager2/Destroy(force)
	close()
	owner = null
	return ..()

/datum/media_manager2/proc/open()
	set waitfor = FALSE
#ifdef MM2_DEBUGGING
	if(get_asset_datum(/datum/asset/simple/media_manager2).send(owner))
		to_chat(owner, span_notice("Assets were sent!"))
	else
		to_chat(owner, span_warning("Assets were NOT sent!"))
#else
	get_asset_datum(/datum/asset/simple/media_manager2).send(owner)
#endif
	var/html = replacetextEx(base_html, "media:href", REF(src))
	close()
	owner << browse(html, "window=" + MEDIA_WINDOW_ID)
	is_browser = winexists(owner, MEDIA_WINDOW_ID) == "BROWSER"

/datum/media_manager2/proc/close()
	ready = FALSE
	if(!isnull(owner))
		owner << browse(null, "window=" + MEDIA_WINDOW_ID)

/datum/media_manager2/proc/init_base_html()
	get_asset_datum(/datum/asset/simple/media_manager2) // ensure that asset datum is loaded
	var/js = replacetextEx(file2text("monkestation/code/modules/media/assets/media_player.js"), "media_player.wasm", SSassets.transport.get_asset_url("media_player.wasm"))
	base_html = file2text("monkestation/code/modules/media/assets/media_player.html")
	base_html = replacetextEx(base_html, "<!-- media:wasm -->", "<script type='text/javascript' src='[SSassets.transport.get_asset_url("media_player_wasm.js")]'></script>")
	base_html = replacetextEx(base_html, "<!-- media:main -->", "<script type='text/javascript'>[js]</script>")

/datum/media_manager2/proc/set_url(url)
	WAIT_UNTIL_READY
	MEDIA_CALL("set_url", url)

/datum/media_manager2/proc/set_position(x = 0, y = 0)
	WAIT_UNTIL_READY
	MEDIA_CALL("set_position", x, y)

/datum/media_manager2/proc/set_time(time = 0)
	WAIT_UNTIL_READY
	MEDIA_CALL("set_time", time)

/datum/media_manager2/proc/set_volume(volume = 1)
	WAIT_UNTIL_READY
	MEDIA_CALL("set_volume", volume)

/datum/media_manager2/proc/play(url)
	WAIT_UNTIL_READY
	MEDIA_CALL("play", url)

/datum/media_manager2/proc/pause()
	if(ready) // don't even bother waiting if we're not ready, bc that means there's nothing TO pause
		MEDIA_CALL("pause")

/datum/media_manager2/proc/stop()
	if(ready) // don't even bother waiting if we're not ready, bc that means there's nothing TO stop
		MEDIA_CALL("stop")

/datum/media_manager2/Topic(href, list/href_list)
	. = ..()
	var/message_type = href_list["type"]
	if(!message_type)
		return
	var/list/params = isnull(href_list["params"]) ? list() : json_decode(href_list["params"]);
	if(QDELETED(src))
		return
	switch(message_type)
		if("ready")
			ready = TRUE
			MM2_DEBUG("mm2 ready for [key_name(owner)]")
		if("error")
			MM2_DEBUG("mm2 error: [params["message"]]")
			stack_trace(params["message"])
	MM2_DEBUG("mm2 topic: [json_encode(href_list, JSON_PRETTY_PRINT)]")

#ifdef MM2_DEBUGGING
/client/verb/mm2_set_url()
	set name = "MM2: Set URL"
	set category = "MM2"

	var/url = trimtext(tgui_input_text(src, "Set URL", "Media Manager 2", default = "https://files.catbox.moe/29g5xp.mp3", encode = FALSE))
	if(url)
		media2.set_url(url)
		MM2_DEBUG("mm2: url set to [url]")

/client/verb/mm2_play()
	set name = "MM2: Play"
	set category = "MM2"

	media2.play()
	MM2_DEBUG("mm2: playing")

/client/verb/mm2_pause()
	set name = "MM2: Pause"
	set category = "MM2"

	media2.pause()
	MM2_DEBUG("mm2: paused")

/client/verb/mm2_stop()
	set name = "MM2: Stop"
	set category = "MM2"

	media2.stop()
	MM2_DEBUG("mm2: stopped")

/client/verb/mm2_set_position()
	set name = "MM2: Set Position"
	set category = "MM2"

	var/x = tgui_input_number(src, "Set X Value", "Media Manager 2", default = 0, min_value = -10, max_value = 10) || 0
	var/y = tgui_input_number(src, "Set Y Value", "Media Manager 2", default = 0, min_value = -10, max_value = 10) || 0
	media2.set_position(x, y)
	MM2_DEBUG("mm2: set pos to [x],[y]")

/client/verb/mm2_set_time()
	set name = "MM2: Set Time"
	set category = "MM2"

	var/time = tgui_input_number(src, "Set Time (Seconds)", "Media Manager 2", default = 0, min_value = 0, round_value = FALSE) || 0
	media2.set_time(time)
	MM2_DEBUG("mm2: set time to [time]")

/client/verb/mm2_reload_all()
	set name = "MM2: Reload Base HTML/JS"
	set category = "MM2"

	reload_all_mm2()
	MM2_DEBUG("mm2: reloaded all")

/proc/reload_all_mm2()
	var/did_re_init = FALSE
	for(var/client/client in GLOB.clients)
		var/datum/media_manager2/mm2 = client?.media2
		if(QDELETED(mm2))
			continue
		if(!did_re_init)
			mm2.base_html = null
			mm2.init_base_html()
			did_re_init = TRUE
		mm2.open()
#endif

#undef WAIT_UNTIL_READY
#undef MEDIA_CALL
#undef MEDIA_WINDOW_ID
