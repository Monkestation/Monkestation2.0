ADMIN_VERB(spawn_mixtape, R_FUN, FALSE, "Spawn Mixtape", "Select an approved mixtape to spawn at your location.", ADMIN_CATEGORY_GAME)
	var/datum/mixtape_spawner/tgui = new(user)//create the datum
	tgui.ui_interact(user.mob)//datum has a tgui component, here we open the window

/datum/mixtape_spawner
	var/client/holder //client of whoever is using this datum

/datum/mixtape_spawner/New(user)//user can either be a client or a mob due to byondcode(tm)
	holder = user //AVD user is a client so this would be setting a client.

/datum/mixtape_spawner/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/mixtape_spawner/ui_close()
	qdel(src)

/datum/mixtape_spawner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MixtapeSpawner")
		ui.open()

/datum/mixtape_spawner/ui_data(mob/user)
	var/list/data = list()
	if(!length(SScassette_storage.cassette_datums))
		return
	for(var/datum/cassette_data/cassette in SScassette_storage.cassette_datums)
		data["approved_cassettes"] += list(list(
			"name" = cassette.cassette_name,
			"desc" = cassette.cassette_desc,
			"cassette_design_front" = cassette.cassette_design_front,
			"creator_ckey" = cassette.cassette_author_ckey,
			"creator_name" = cassette.cassette_author,
			"song_names" = cassette.song_names,
			"id" = cassette.cassette_id
		))
	return data

/datum/mixtape_spawner/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("spawn")
			if (params["id"])
				new/obj/item/device/cassette_tape(usr.loc, params["id"])
				SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Mixtape")
				log_admin("[key_name(usr)] created mixtape [params["id"]] at [usr.loc].")
