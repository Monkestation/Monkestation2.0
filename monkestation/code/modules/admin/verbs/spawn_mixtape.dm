/client/proc/spawn_mixtape()
	set category = "Admin.Game"
	set name = "Spawn Mixtape"
	set desc = "Select an approved mixtape to spawn at your location."

	if(!check_rights(R_ADMIN))
		return
	new /datum/mixtape_spawner(src)

/datum/mixtape_spawner
	/// The client of whoever is using this datum.
	var/client/holder

/datum/mixtape_spawner/New(user)//user can either be a client or a mob due to byondcode(tm)
	. = ..()
	holder = get_player_client(user)
	ui_interact(holder.mob)

/datum/mixtape_spawner/Destroy(force)
	holder = null
	return ..()

/datum/mixtape_spawner/ui_state(mob/user)
	return GLOB.admin_state

/datum/mixtape_spawner/ui_close()
	qdel(src)

/datum/mixtape_spawner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MixtapeSpawner")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/mixtape_spawner/ui_static_data(mob/user)
	var/list/approved_cassettes = list()
	for(var/datum/cassette/cassette as anything in SScassettes.cassettes)
		if(cassette.status != CASSETTE_STATUS_APPROVED)
			continue
		approved_cassettes += list(list(
			"name" = cassette.name,
			"desc" = cassette.desc,
			"cassette_design_front" = cassette.front.design,
			"creator_ckey" = ckey(cassette.author.ckey),
			"creator_name" = cassette.author.name,
			"song_names" = cassette.list_song_names(),
			"id" = cassette.id,
		))
	return list("approved_cassettes" = approved_cassettes)

/datum/mixtape_spawner/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("spawn")
			var/id = params["id"]
			if(!id)
				return
			var/atom/spawn_loc = user.drop_location()
			new /obj/item/cassette_tape(spawn_loc, id)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Mixtape")
			message_admins("[key_name_admin(user)] spawned mixtape [id] at [ADMIN_COORDJMP(spawn_loc)].")
			log_admin("[key_name(user)] spawned mixtape [id] at [loc_name(spawn_loc)].")
			return TRUE
