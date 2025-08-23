GLOBAL_VAR(dj_broadcast)
GLOBAL_DATUM(dj_booth, /obj/machinery/dj_station)

/obj/item/clothing/ears
	//can we be used to listen to radio?
	var/radio_compat = FALSE

/obj/machinery/dj_station
	name = "Cassette Player"
	desc = "Plays Space Music Board approved cassettes for anyone in the station to listen to."

	icon = 'icons/obj/cassettes/radio_station.dmi'
	icon_state = "cassette_player"

	use_power = NO_POWER_USE
	processing_flags = NONE

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	move_resist = MOVE_FORCE_OVERPOWERING

	anchored = TRUE
	density = TRUE

	var/broadcasting = FALSE
	/// The currently inserted cassette, if any.
	var/obj/item/cassette_tape/inserted_tape
	/// The song currently being played, if any.
	var/datum/cassette_song/playing
	/// The REALTIMEOFDAY that the current song was started.
	var/song_start_time
	COOLDOWN_DECLARE(next_song_timer)

/obj/machinery/dj_station/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)
	register_context()
	if(QDELETED(GLOB.dj_booth))
		GLOB.dj_booth = src
	ADD_TRAIT(src, TRAIT_ALT_CLICK_BLOCKER, INNATE_TRAIT)

/obj/machinery/dj_station/Destroy()
	if(!QDELETED(inserted_tape))
		inserted_tape.forceMove(drop_location())
	inserted_tape = null
	playing = null
	if(GLOB.dj_booth == src)
		GLOB.dj_booth = null
	return ..()

/obj/machinery/dj_station/ui_data(mob/user)
	. = list(
		"broadcasting" = broadcasting,
		"song_cooldown" = COOLDOWN_TIMELEFT(src, next_song_timer),
		"progress" = song_start_time ? (REALTIMEOFDAY - song_start_time) : 0
	)
	if(playing)
		.["playing"] = list(
			"name" = playing.name,
			"url" = playing.url,
		)
	var/datum/cassette/cassette = inserted_tape?.cassette_data
	if(cassette)
		.["cassette"] = list(
			"name" = cassette.name,
			"desc" = cassette.desc,
			"author" = cassette.author?.name,
			"songs" = list(),
		)
		for(var/datum/cassette_song/song as anything in cassette.get_side()?.songs)
			.["cassette"]["songs"] += list(list(
				"name" = song.name,
				"url" = song.url,
			))

// It cannot be stopped.
/obj/machinery/dj_station/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	return

/obj/machinery/dj_station/emp_act(severity)
	return

// Funny.
/obj/machinery/dj_station/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit)
	SHOULD_CALL_PARENT(FALSE)
	visible_message(span_warning("[hitting_projectile] bounces harmlessly off of [src]!"))
	// doesn't actually do any damage, this is meant to annoy people when they try to shoot it bc someone played pickle rick
	hitting_projectile.damage = 0
	hitting_projectile.stamina = 0
	hitting_projectile.debilitating = FALSE
	hitting_projectile.reflect(src)
	return BULLET_ACT_FORCE_PIERCE

/*
/obj/machinery/dj_station/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(inserted_tape)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Eject Tape"
		if(!broadcasting)
			context[SCREENTIP_CONTEXT_LMB] = "Play Tape"
	return CONTEXTUAL_SCREENTIP_SET
*/
