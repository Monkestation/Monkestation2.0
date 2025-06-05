//#define MM2_DEBUGGING

#ifdef MM2_DEBUGGING
#define MM2_DEBUG(x) message_admins("\[MEDIA MANAGER 2 DEBUG\] " + x)
#define MEDIA_WINDOW_ID "mm2"
#warn COMMENT OUT MM2_DEBUGGING BEFORE DEPLOYING!!!
#else
#define MM2_DEBUG(x)
#define MEDIA_WINDOW_ID "outputwindow.mediapanel"
#endif

/client
	var/datum/media_player/media_player

/datum/media_player
	/// The client that this media manager is owned by.
	VAR_FINAL/client/owner
	/// Is our window a browser control?
	VAR_FINAL/is_browser = FALSE
	/// Is the media manager ready to do stuff yet?
	VAR_FINAL/ready = FALSE
	/// The URL the media player attempting to load, if any.
	VAR_FINAL/loading_url = FALSE
	/// The current URL being played.
	VAR_FINAL/current_url
	/// The volume of the last update.
	VAR_PRIVATE/last_volume
	/// The relative X coordinate of the last update.
	VAR_PRIVATE/last_x
	/// The relative Y coordinate of the last update.
	VAR_PRIVATE/last_y
	/// The relative Z coordinate of the last update.
	VAR_PRIVATE/last_z
	/// The balance of the last update.
	VAR_PRIVATE/last_balance
	/// Callbacks to run when we get the "ready" message back fron the media manager.
	VAR_PRIVATE/list/ready_callbacks
	var/static/base_html

/datum/media_player/New(client/owner)
	src.owner = owner
	if(!isnull(owner) && owner.media_player != src && !QDELETED(owner.media_player))
		CRASH("tried to initialize a second media player for [key_name(owner)] when they already had a non-qdeleted media_player!")
	if(isnull(base_html))
		init_base_html()
	open()

/datum/media_player/Destroy(force)
	LAZYNULL(ready_callbacks)
	close()
	owner = null
	return ..()

/datum/media_player/proc/open()
	set waitfor = FALSE
	var/html = replacetextEx(base_html, "media:href", REF(src))
	close()
#ifndef MM2_DEBUGGING
	owner << browse(html, "window=" + MEDIA_WINDOW_ID)
#else
	owner << browse(html, "window=" + MEDIA_WINDOW_ID + ";size=100x100;can_minimize=0;can_close=0;")
#endif
	is_browser = winexists(owner, MEDIA_WINDOW_ID) == "BROWSER"

/datum/media_player/proc/close()
	ready = FALSE
	if(!isnull(owner))
		owner << browse(null, "window=" + MEDIA_WINDOW_ID)

/// Calls a JS function in the media manager.
/// If the media manager isn't ready yet, then the call will be queued, and all queued calls will be invoked in order when it does become ready.
/datum/media_player/proc/media_call(name, ...)
	PRIVATE_PROC(TRUE)
	if(QDELETED(src) || isnull(owner))
		return
	var/target = is_browser ? (MEDIA_WINDOW_ID + ":" + name) : (MEDIA_WINDOW_ID + ".browser:" + name)
	var/params = list2params(args.Copy(2))
	if(ready)
		MM2_DEBUG("call: target=[target], params=[json_encode(args.Copy(2))]")
		owner << output(params, target)
	else
		MM2_DEBUG("queueing ready callback: target=[target], params=[json_encode(args.Copy(2))]")
		LAZYADD(ready_callbacks, CALLBACK(src, PROC_REF(__ready_callback), target, params))

/// Wrapper proc for ready callbacks made by media_call - basically a stripped down version of media_call that won't create more ready callbacks.
/// This should NEVER be called directly.
/datum/media_player/proc/__ready_callback(target, params)
	PRIVATE_PROC(TRUE)
	if(!isnull(owner))
		MM2_DEBUG("calling ready callback: target=[target], params=[params]")
		owner << output(params, target)

/datum/media_player/proc/init_base_html()
	var/js = file2text("code/modules/media/assets/media_player.js")
	base_html = file2text("code/modules/media/assets/media_player.html")
	base_html = replacetextEx(base_html, "<!-- media:inline-js -->", "<script type='text/javascript'>\n[js]\n</script>")

/datum/media_player/proc/set_position(x = 0, y = 0, z = 0)
	if(last_x != x || last_y != y || last_z != z)
		last_x = x
		last_y = y
		last_z = z
		media_call("set_position", x, y, z)

/datum/media_player/proc/set_panning(balance = 0)
	if(last_balance != balance)
		last_balance = balance
		media_call("set_panning", balance)

/datum/media_player/proc/set_time(time = 0)
	media_call("set_time", time)

/datum/media_player/proc/set_volume(volume = 100)
	if(last_volume != volume)
		last_volume = volume
		media_call("set_volume", volume)

/datum/media_player/proc/play(url, volume = 100, x = 0, y = 0, z = 0, balance = 0)
	if(url == loading_url)
		return
	loading_url = url
	last_x = x
	last_y = y
	last_z = z
	last_volume = volume
	last_balance = balance
	media_call("play", url, volume, null, x, y, z, balance)

/datum/media_player/proc/pause()
	media_call("pause")

/datum/media_player/proc/stop()
	if(isnull(loading_url) && !isnull(current_url))
		media_call("stop")

/datum/media_player/proc/on_ready()
	if(ready)
		CRASH("readied twice")
	if(QDELETED(src) || isnull(owner))
		return
	on_clear()
	ready = TRUE
	MM2_DEBUG("ready for [key_name(owner)]")
	for(var/datum/callback/callback as anything in ready_callbacks)
		callback?.Invoke()
	LAZYNULL(ready_callbacks)

/datum/media_player/proc/on_clear()
	current_url = null
	loading_url = null
	last_volume = null
	last_x = null
	last_y = null
	last_z = null
	last_balance = null

/datum/media_player/Topic(href, list/href_list)
	. = ..()
	var/message_type = href_list["type"]
	if(!message_type)
		return
	var/list/params = isnull(href_list["params"]) ? list() : json_decode(href_list["params"]);
	if(QDELETED(src))
		return
	switch(message_type)
		if("ready")
			on_ready()
		if("clear")
			on_clear()
		if("playing")
			current_url = params["url"]
			loading_url = null
		if("error")
			MM2_DEBUG("error: [params["message"]]")
			stack_trace(params["message"])
	MM2_DEBUG("topic: [json_encode(href_list - "params", JSON_PRETTY_PRINT)]\nparams: [json_encode(params, JSON_PRETTY_PRINT)]")

/client/verb/reload_mm2()
	set name = "Force Reload Media Player"
	set desc = "Forcefully reloads your client's media player (used for lobby and jukebox music)"
	set category = "OOC"

	if(!QDELETED(media_player))
		QDEL_NULL(media_player)
	media_player = new(src)

#ifdef MM2_DEBUGGING
/client/verb/mm2_play()
	set name = "MM2: Play"
	set category = "MM2"

	var/url = trimtext(tgui_input_text(src, "What to play?", "Media Manager 2", default = "https://files.catbox.moe/29g5xp.mp3", encode = FALSE))
	if(url)
		media_player.play(url)
		MM2_DEBUG("playing")

/client/verb/mm2_pause()
	set name = "MM2: Pause"
	set category = "MM2"

	media_player.pause()
	MM2_DEBUG("paused")

/client/verb/mm2_stop()
	set name = "MM2: Stop"
	set category = "MM2"

	media_player.stop()
	MM2_DEBUG("stopped")

/client/verb/mm2_set_position()
	set name = "MM2: Set Position"
	set category = "MM2"

	var/x = tgui_input_number(src, "Set X Value", "Media Manager 2", default = 0, min_value = -10, max_value = 10) || 0
	var/y = tgui_input_number(src, "Set Y Value", "Media Manager 2", default = 0, min_value = -10, max_value = 10) || 0
	media_player.set_position(x, y)
	MM2_DEBUG("set pos to [x],[y]")

/client/verb/mm2_set_time()
	set name = "MM2: Set Time"
	set category = "MM2"

	var/time = tgui_input_number(src, "Set Time (Seconds)", "Media Manager 2", default = 0, min_value = 0, round_value = FALSE) || 0
	media_player.set_time(time)
	MM2_DEBUG("set time to [time]")

/client/verb/mm2_reload_all()
	set name = "MM2: Reload Base HTML/JS"
	set category = "MM2"

	reload_all_mm2()
	MM2_DEBUG("reloaded all")

/proc/reload_all_mm2()
	var/did_re_init = FALSE
	for(var/client/client in GLOB.clients)
		var/datum/media_player/mm2 = client?.media_player
		if(QDELETED(mm2))
			continue
		if(!did_re_init)
			mm2.base_html = null
			mm2.init_base_html()
			did_re_init = TRUE
		mm2.open()
#endif

#undef MEDIA_WINDOW_ID
