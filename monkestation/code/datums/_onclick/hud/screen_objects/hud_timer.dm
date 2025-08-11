
/// UI obj holders for all your maptext needs
/atom/movable/screen/text
	name = null
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/// A screen object that shows the time left on a timer
/atom/movable/screen/text/screen_timer
	screen_loc = "CENTER-7,CENTER-7"
	/// The actual displayed content of the maptext, use ${timer}, and it'll be replaced with formatted time left
	var/maptext_string
	/// Timer ID that we're tracking, the time left of this is displayed as maptext
	var/timer_id
	/// The list of mobs in whose client.screens we are added to
	var/list/timer_mobs = list()

/atom/movable/screen/text/screen_timer/Initialize(
		mapload,
		list/mobs,
		timer,
		text,
		offset_x = 150,
		offset_y = -70,
	)
	. = ..(mapload, null)

	if(!islist(mobs) && mobs)
		mobs = list(mobs)
	// Copy the list just in case the arguments list is a list we don't want to modify
	if(length(mobs))
		mobs = mobs.Copy()
	if(!timer)
		return INITIALIZE_HINT_QDEL
	maptext_string = text
	timer_id = timer
	maptext_x = offset_x
	maptext_y = offset_y
	update_maptext()
	if(length(mobs))
		apply_to(mobs)

/atom/movable/screen/text/screen_timer/process()
	if(!timeleft(timer_id))
		qdel(src)
		return
	update_maptext()

/// Adds the object to the client.screen of all mobs in the list, and registers the needed signals
/atom/movable/screen/text/screen_timer/proc/apply_to(list/mobs)
	if(!mobs)
		return
	if(!islist(mobs))
		mobs = list(mobs)
	if(!length(timer_mobs) && length(mobs))
		START_PROCESSING(SSprocessing, src)
	for(var/player in mobs)
		if(player in timer_mobs)
			continue
		if(istype(player, /datum/weakref))
			var/datum/weakref/ref = player
			player = ref.resolve()
		attach(player)
		RegisterSignal(player, COMSIG_MOB_LOGIN, PROC_REF(attach)) // doesn't currently cleanup properly
		timer_mobs += WEAKREF(player)

/// Removes the object from the client.screen of all mobs in the list, and unregisters the needed signals, while also stopping processing if there's no more mobs in the screen timers mob list
/atom/movable/screen/text/screen_timer/proc/remove_from(list/mobs)
	if(!mobs)
		return
	if(!islist(mobs))
		mobs = list(mobs)
	for(var/player in mobs)
		// when the player is a weakref, assume it's the same pointer that we use in the timer_mobs list
		var/datum/weakref/found_weakref
		if(istype(player, /datum/weakref))
			var/datum/weakref/ref = player
			found_weakref = ref
		// otherwise we have to search through and resolve each one and compare it
		else
			for(var/datum/weakref/possible_match as anything in timer_mobs)
				if(player == possible_match.resolve())
					found_weakref = possible_match
					break
		timer_mobs -= found_weakref
		var/found_player = found_weakref.resolve()
		if(!found_player)
			return
		UnregisterSignal(found_player, COMSIG_MOB_LOGIN)
		de_attach(found_player)
	if(!length(timer_mobs))
		STOP_PROCESSING(SSprocessing, src)

/// Updates the maptext to show the current time left on the timer
/atom/movable/screen/text/screen_timer/proc/update_maptext()
	var/time_formatted = time2text(timeleft(timer_id), "mm:ss")
	var/timer_text = replacetextEx(maptext_string, "${timer}", time_formatted)
	// If we don't find ${timer} in the string, just use the time formatted
	var/result_text = MAPTEXT("[timer_text]")
	apply_change(result_text)

/atom/movable/screen/text/screen_timer/proc/apply_change(result_text)
	maptext = result_text

/// Adds the object to the client.screen of the mob, or removes it if add_to_screen is FALSE
/atom/movable/screen/text/screen_timer/proc/attach(mob/source, add_to_screen = TRUE)
	SIGNAL_HANDLER
	if(!source?.client)
		return
	var/client/client = source.client
	// this checks if the screen is already added or removed
	if(!can_attach(client, add_to_screen))
		return
	if(!ismob(source))
		CRASH("Invalid source passed to screen_timer/attach()!")
	do_attach(client, add_to_screen)

/atom/movable/screen/text/screen_timer/proc/can_attach(client/client, add_to_screen)
	return add_to_screen == (src in client.screen)

/atom/movable/screen/text/screen_timer/proc/do_attach(client/client, add_to_screen)
	if(add_to_screen)
		client.screen += src
	else
		client.screen -= src

/// Signal handler to run attach with specific args
/atom/movable/screen/text/screen_timer/proc/de_attach(mob/source)
	SIGNAL_HANDLER
	attach(source, FALSE)

/atom/movable/screen/text/screen_timer/Destroy()
	if(length(timer_mobs))
		remove_from(timer_mobs)

	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/atom/movable/screen/text/screen_timer/attached
	maptext_x = 0
	maptext_y = 16
	maptext_height = 32
	maptext_width = 32
	var/following_object
	var/image/text_image

/atom/movable/screen/text/screen_timer/attached/Initialize(
		mapload,
		list/mobs,
		timer,
		text,
		offset_x,
		offset_y,
		following_object,
	)
	if(following_object && get_turf(following_object))
		attach_self_to(following_object, offset_x, offset_y)
	else
		return INITIALIZE_HINT_QDEL
	. = ..()

/atom/movable/screen/text/screen_timer/attached/can_attach(client/client)
	return !(src in client.images)

// attached screen timers are a visible timer in the gameworld that are only visible to the mobs listed in the timer_mobs list
/atom/movable/screen/text/screen_timer/attached/do_attach(client/client, add_to_screen)
	if(add_to_screen)
		client.images += text_image
	else
		client.images -= text_image

/atom/movable/screen/text/screen_timer/attached/proc/attach_self_to(atom/movable/target, maptext_x, maptext_y)
	text_image = image(src, target)

	text_image.maptext_x = maptext_x
	text_image.maptext_y = maptext_y

	text_image.maptext_height = maptext_height
	text_image.maptext_width = maptext_width

	SET_PLANE_EXPLICIT(text_image, ABOVE_HUD_PLANE, target)

/atom/movable/screen/text/screen_timer/attached/apply_change(result_text)
	..()
	text_image?.maptext = result_text

/atom/movable/screen/text/screen_timer/attached/proc/hide_timer(atom/movable/target)
	unregister_follower()

/atom/movable/screen/text/screen_timer/attached/proc/unregister_follower()
	following_object = null
	text_image = null

/atom/movable/screen/text/screen_timer/attached/proc/update_glide_speed(atom/movable/tracked)
	set_glide_size(tracked.glide_size)

/atom/movable/screen/text/screen_timer/attached/proc/timer_follow(atom/movable/tracked, atom/mover, atom/oldloc, direction)
	abstract_move(get_turf(tracked))

/atom/movable/screen/text/screen_timer/attached/Destroy()
	if(following_object)
		unregister_follower()
	. = ..()
