GLOBAL_VAR(dj_broadcast)
GLOBAL_VAR(old_dj_booth)


/obj/item/clothing/ears
	//can we be used to listen to radio?
	var/radio_compat = FALSE

#ifndef SPACEMAN_DMM
#warn REMOVE AND CLEAN THIS UP BEFORE FULL MERGE!!!
#endif

/obj/machinery/cassette/old_dj_station
	name = "Cassette Player"
	desc = "Plays Space Music Board approved cassettes for anyone in the station to listen to "

	icon = 'monkestation/code/modules/cassettes/icons/radio_station.dmi'
	icon_state = "cassette_player"

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION

	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	density = TRUE
	var/broadcasting = FALSE
	var/obj/item/cassette_tape/inserted_tape
	var/time_left = 0
	var/current_song_duration = 0
	var/list/people_with_signals = list()
	var/list/active_listeners = list()
	var/waiting_for_yield = FALSE

	//tape stuff goes here
	var/pl_index = 0
	var/list/current_playlist = list()
	var/list/current_namelist = list()

	COOLDOWN_DECLARE(next_song_timer)
