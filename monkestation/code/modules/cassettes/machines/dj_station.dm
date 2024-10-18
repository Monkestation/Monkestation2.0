GLOBAL_DATUM(dj_booth, /obj/machinery/cassette/dj_station)

/obj/machinery/cassette/dj_station
	name = "Cassette Player"
	desc = "Plays Space Music Board approved cassettes for anyone in the station to listen to."

	icon = 'monkestation/code/modules/cassettes/icons/radio_station.dmi'
	icon_state = "cassette_player"

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	anchored = TRUE
	density = TRUE
	move_resist = INFINITY

	/// The currently playing song, if any.
	var/datum/internet_audio/current_song
	/// The currently inserted cassette tape.
	var/obj/item/cassette_tape/inserted_tape

/obj/machinery/cassette/dj_station/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, 1)
	if(QDELETED(GLOB.dj_booth))
		GLOB.dj_booth = src
	// register_context()

/obj/machinery/cassette/dj_station/Destroy()
	current_song = null
	if(inserted_tape)
		inserted_tape.forceMove(drop_location())
		inserted_tape = null
	if(GLOB.dj_booth == src)
		GLOB.dj_booth = null
	return ..()

/*
/obj/machinery/cassette/dj_station/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(inserted_tape)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Eject Tape"
		if(!broadcasting)
			context[SCREENTIP_CONTEXT_LMB] = "Play Tape"
	return CONTEXTUAL_SCREENTIP_SET
*/
