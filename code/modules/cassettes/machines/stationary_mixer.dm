/obj/machinery/cassette_deck
	name = "Advanced Cassette Deck"
	desc = "A more advanced less portable Cassette Deck. Useful for recording songs from our generation, or customizing the style of your cassettes."
	icon ='icons/obj/cassettes/adv_cassette_deck.dmi'
	icon_state = "cassette_deck"
	density = TRUE
	pass_flags = PASSTABLE
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_REQUIRES_ANCHORED
	///cassette tape used in adding songs or customizing
	var/obj/item/cassette_tape/tape
	///Selection used to remove songs
	var/selection
	var/busy = FALSE

/obj/machinery/cassette_deck/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)
	register_context()

/obj/machinery/cassette_deck/Destroy()
	if(!QDELETED(tape))
		tape.forceMove(drop_location())
	tape = null
	return ..()

/obj/machinery/cassette_deck/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(istype(held_item, /obj/item/cassette_tape))
		context[SCREENTIP_CONTEXT_LMB] = "Insert Tape"
		. = CONTEXTUAL_SCREENTIP_SET
	else if(!held_item && tape)
		context[SCREENTIP_CONTEXT_LMB] = "Modify/View Tape"
		. = CONTEXTUAL_SCREENTIP_SET

	if(tape)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Eject Tape"
		. = CONTEXTUAL_SCREENTIP_SET

/obj/machinery/cassette_deck/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/cassette_deck/click_ctrl(mob/user)
	if(!can_interact(user))
		return NONE
	return eject_tape(user) ? CLICK_ACTION_SUCCESS : CLICK_ACTION_BLOCKING

/obj/machinery/cassette_deck/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/cassette_tape))
		return NONE
	if(tape)
		balloon_alert(user, "remove the current tape!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		balloon_alert(user, "failed to insert tape!")
		return ITEM_INTERACT_BLOCKING
	tape = tool
	playsound(src, 'sound/weapons/handcuffs.ogg', vol = 20, vary = TRUE, mixer_channel = CHANNEL_MACHINERY)
	balloon_alert(user, "tape inserted")
	SStgui.update_uis(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/cassette_deck/proc/eject_tape(mob/user)
	if(!tape)
		balloon_alert(user, "no tape inserted!")
		return FALSE
	if(busy)
		balloon_alert(user, "busy!")
		return FALSE
	tape.forceMove(drop_location())
	user?.put_in_hands(tape)
	tape = null
	SStgui.update_uis(src)
	return TRUE

/*
/obj/machinery/cassette_deck/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CassetteDeck", name)
		ui.set_autoupdate(FALSE)
		ui.open()
*/

/obj/machinery/cassette_deck/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!tape)
		balloon_alert(user, "no tape inserted!")
		return
	if(busy)
		balloon_alert(user, "busy!")
		return
	var/action = tgui_input_list(user, "What would you like to do with this tape?", html_decode(tape.cassette_data.name), list("Add Track", "Remove Track", "View Tracks", "Change Design", "Eject Tape"))
	if(!action || !tape || busy)
		return
	switch(action)
		if("Add Track")
			try_add_track(user)
		if("Remove Track")
			try_remove_track(user)
		if("View Tracks")
			view_tracks(user)
		if("Change Design")
			try_change_design(user)
		if("Eject Tape")
			eject_tape(user)

/obj/machinery/cassette_deck/proc/try_add_track(mob/user)
	busy = TRUE
	SStgui.update_uis(src)
	var/url = trimtext(tgui_input_text(user, "Paste the URL for the song you would like to add.", "Add Track", encode = FALSE))
	busy = FALSE
	if(!url)
		balloon_alert(user, "no URL given!")
		SStgui.update_uis(src)
		return
	if(!add_track(user, url))
		balloon_alert(user, "failed to add track")
		SStgui.update_uis(src)

/obj/machinery/cassette_deck/proc/try_remove_track(mob/user)
	var/datum/cassette_side/side = tape.get_current_side()
	if(!length(side.songs))
		balloon_alert(user, "no tracks to remove!")
		return
	var/list/tracks = list()
	for(var/idx = 1 to length(side.songs))
		var/datum/cassette_song/track = side.songs[idx]
		tracks += "([idx]) [track.name]"
	busy = TRUE
	SStgui.update_uis(src)
	var/track_to_remove = tgui_input_list(user, "Which track would you like to remove?", html_decode(tape.cassette_data.name), tracks)
	busy = FALSE
	if(!track_to_remove)
		balloon_alert(user, "no track selected!")
		SStgui.update_uis(src)
		return
	var/idx = tracks.Find(track_to_remove)
	if(idx)
		side.songs.Cut(idx, idx + 1)
		balloon_alert(user, "track removed")
		playsound(src, 'sound/weapons/handcuffs.ogg', vol = 20, vary = TRUE, mixer_channel = CHANNEL_MACHINERY)
	else
		balloon_alert(user, "error removing track?")
	SStgui.update_uis(src)

/obj/machinery/cassette_deck/proc/view_tracks(mob/user)
	if(busy)
		balloon_alert(user, "busy!")
		return
	var/datum/cassette_side/side = tape.get_current_side()
	var/list/tracks = side.songs.Copy()
	if(!length(tracks))
		balloon_alert(user, "no tracks on side!")
		return
	var/datum/cassette_song/track_to_open = tgui_input_list(user, "Select a track to open its URL in your browser.", html_decode(tape.cassette_data.name), tracks)
	if(track_to_open)
		DIRECT_OUTPUT(user, link(track_to_open.url))

/obj/machinery/cassette_deck/proc/try_change_design(mob/user)
	if(busy)
		balloon_alert(user, "busy!")
		return
	busy = TRUE
	SStgui.update_uis(src)
	var/new_design = tgui_input_list(user, "Select a sticker design to use for this side of the tape!", html_decode(tape.cassette_data.name), assoc_to_keys(GLOB.cassette_icons))
	busy = FALSE
	if(!new_design || !(new_design in GLOB.cassette_icons))
		balloon_alert(user, "no design selected!")
		SStgui.update_uis(src)
		return
	tape.get_current_side().design = GLOB.cassette_icons[new_design]
	tape.update_appearance(UPDATE_ICON_STATE)
	balloon_alert(user, "selected [new_design] design")
	SStgui.update_uis(src)

/obj/machinery/cassette_deck/proc/add_track(mob/user, url)
	if(!url)
		return FALSE
	if(busy)
		balloon_alert(user, "busy!")
		return FALSE
	var/datum/cassette_side/side = tape?.get_current_side()
	if(!side)
		balloon_alert(user, "no tape inserted!")
		return FALSE
	if(length(side.songs) >= MAX_SONGS_PER_CASSETTE_SIDE)
		balloon_alert(user, "tape side is full!")
		return FALSE
	if(!is_http_protocol(url))
		balloon_alert(user, "invalid URL!")
		return FALSE
	if(findtext(url, "spotify.com") || findtext(url, "music.apple.com") || findtext(url, "deezer.com") || findtext(url, "tidal.com"))
		balloon_alert(user, "unsupported service!")
		to_chat(user, span_warning("This URL is unsupported. Try a YouTube, Bandcamp, or Soundcloud URL."))
		return FALSE
	busy = TRUE
	SStgui.update_uis(src)
	var/list/metadata = SSfloxy.fetch_media_metadata(url)
	busy = FALSE
	if(!metadata)
		balloon_alert(user, "failed to fetch music metadata!")
		to_chat(user, span_warning("Failed to fetch music metadata. Are you trying to use an unsupported service (i.e Spotify)? Try a YouTube, Bandcamp, or Soundcloud URL if so."))
		SStgui.update_uis(src)
		return FALSE
	var/datum/cassette_song/song = new(metadata["title"], metadata["url"], metadata["duration"], metadata["artist"], metadata["album"])
	side.songs += song
	tape.cassette_data.status = CASSETTE_STATUS_UNAPPROVED // reset to unapproved
	SStgui.update_uis(src)
	balloon_alert(user, "track added!")
	to_chat(user, span_notice("Added new track \"[metadata["title"]]\" to [tape]"))
	playsound(src, 'sound/weapons/handcuffs.ogg', vol = 20, vary = TRUE, mixer_channel = CHANNEL_MACHINERY)
	return TRUE

/obj/machinery/cassette_deck/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/cassettes),
	)

/obj/machinery/cassette_deck/ui_data(mob/user)
	. = list(
		"cassette" = null,
		"busy" = busy,
	)
	var/datum/cassette/cassette = tape?.cassette_data
	if(cassette)
		var/datum/cassette_side/side = tape.get_current_side()
		.["cassette"] = list(
			"name" = html_decode(cassette.name),
			"desc" = html_decode(cassette.desc),
			"status" = cassette.status,
			"author" = cassette.author?.name,
			"design" = side?.design || /datum/cassette_side::design,
			"songs" = list(),
		)
		for(var/datum/cassette_song/song as anything in side?.songs)
			.["cassette"]["songs"] += list(list(
				"name" = song.name,
				"url" = song.url,
				"length" = song.duration * 1 SECONDS, // convert to deciseconds
				"artist" = song.artist,
				"album" = song.album,
			))

/obj/machinery/cassette_deck/ui_static_data(mob/user)
	return list("icons" = GLOB.cassette_icons)

/obj/machinery/cassette_deck/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	var/datum/cassette_side/side = tape?.get_current_side()
	if(!side)
		balloon_alert(user, "no tape inserted!")
		return
	switch(action)
		if("remove")
			. = TRUE
			var/index = params["index"]
			if(!isnum(index))
				CRASH("tried to pass non-number index ([index]) to remove??? this is prolly a bug.")
			index++
			if(index > length(side.songs))
				CRASH("tried to remove track [index] from tape while there were only [length(side.songs)] songs???")
			side.songs.Cut(index, index + 1)
			balloon_alert(user, "removed track")
			SStgui.update_uis(src)
		if("add")
			add_track(params["url"])
			return TRUE
		if("eject")
			eject_tape(user)
			return TRUE
		if("set_design")
			. = TRUE
			var/new_design = params["design"]
			if(!new_design || !(new_design in GLOB.cassette_icons))
				return
			side.design = GLOB.cassette_icons[new_design]
			tape.update_appearance(UPDATE_ICON_STATE)
			balloon_alert(user, "selected [new_design] design")
			SStgui.update_uis(src)
