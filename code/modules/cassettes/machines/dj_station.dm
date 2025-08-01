GLOBAL_VAR(dj_broadcast)
GLOBAL_DATUM(dj_booth, /obj/machinery/cassette/dj_station)

/obj/item/clothing/ears
	//can we be used to listen to radio?
	var/radio_compat = FALSE

/obj/machinery/cassette/dj_station
	name = "Cassette Player"
	desc = "Plays Space Music Board approved cassettes for anyone in the station to listen to."

	icon = 'icons/obj/cassettes/radio_station.dmi'
	icon_state = "cassette_player"

	use_power = NO_POWER_USE

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	move_resist = MOVE_FORCE_OVERPOWERING

	anchored = TRUE
	density = TRUE

	var/broadcasting = FALSE
	COOLDOWN_DECLARE(next_song_timer)

/obj/machinery/cassette/dj_station/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)
	register_context()
	if(QDELETED(GLOB.dj_booth))
		GLOB.dj_booth = src
	ADD_TRAIT(src, TRAIT_ALT_CLICK_BLOCKER, INNATE_TRAIT)

/obj/machinery/cassette/dj_station/Destroy()
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
