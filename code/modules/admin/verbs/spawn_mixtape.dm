ADMIN_VERB(spawn_mixtape, R_FUN, FALSE, "Spawn Mixtape", "Select an approved mixtape to spawn at your location.", ADMIN_CATEGORY_GAME)
	new /datum/mixtape_spawner(user.mob)

/datum/mixtape_spawner

/datum/mixtape_spawner/New(mob/user)
	ui_interact(user)

/datum/mixtape_spawner/ui_state(mob/user)
	return ADMIN_STATE(R_FUN)

/datum/mixtape_spawner/ui_close()
	qdel(src)

/datum/mixtape_spawner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MixtapeSpawner")
		ui.set_autoupdate(FALSE) // everything's in ui_static_data anyways
		ui.open()

/datum/mixtape_spawner/ui_static_data(mob/user)
	var/list/cassettes = list()
	for(var/id, value in SScassettes.cassettes)
		var/datum/cassette/cassette = value
		if(cassette.status != CASSETTE_STATUS_APPROVED)
			continue
		var/list/sides = list()
		for(var/datum/cassette_side/side as anything in list(cassette.front, cassette.back))
			var/list/songs = list()
			for(var/datum/cassette_song/song as anything in side.songs)
				songs += list(list(
					"name" = song.name,
					"url" = song.url,
					"duration" = song.duration * 1 SECONDS,
					"artist" = song.artist,
					"album" = song.album,
				))
			sides += list(list(
				"design" = side.design || /datum/cassette_side::design,
				"songs" = songs,
			))
		cassettes += list(list(
			"id" = id,
			"name" = html_decode(cassette.name),
			"desc" = html_decode(cassette.desc),
			"author" = list(
				"ckey" = cassette.author.ckey,
				"name" = cassette.author.name,
			),
			"sides" = sides,
		))

	return list("cassettes" = cassettes)

/datum/mixtape_spawner/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(action == "spawn")
		. = TRUE
		var/id = params["id"]
		if(!id)
			to_chat(user, span_warning("No cassette ID given!"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
			return
		var/datum/cassette/cassette = SScassettes.load_cassette(id)
		if(!cassette)
			to_chat(user, span_warning("Could not load a cassette with the id of '[id]'"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
			return
		new /obj/item/cassette_tape(user.drop_location(), cassette)
		log_admin("[key_name(user)] created mixtape [id] at [AREACOORD(user)].")
