/datum/looping_sound/cassette_track_switch
	mid_sounds = list(
		'sound/machines/djstation/machine_track_switch_loop1.ogg',
		'sound/machines/djstation/machine_track_switch_loop2.ogg',
		'sound/machines/djstation/machine_track_switch_loop3.ogg',
		'sound/machines/djstation/machine_track_switch_loop4.ogg',
		'sound/machines/djstation/machine_track_switch_loop5.ogg',
	)
	mid_length = 1.4 SECONDS
	start_sound = list(
		'sound/machines/djstation/machine_track_switch_start1.ogg',
		'sound/machines/djstation/machine_track_switch_start2.ogg',
		'sound/machines/djstation/machine_track_switch_start3.ogg',
		'sound/machines/djstation/machine_track_switch_start4.ogg',
		'sound/machines/djstation/machine_track_switch_start5.ogg',
	)
	start_length = 0.5 SECONDS
	end_sound = list(
		'sound/machines/djstation/machine_track_switch_end1.ogg',
		'sound/machines/djstation/machine_track_switch_end2.ogg',
		'sound/machines/djstation/machine_track_switch_end3.ogg',
		'sound/machines/djstation/machine_track_switch_end4.ogg',
		'sound/machines/djstation/machine_track_switch_end5.ogg',
	)
	volume = 75
	channel = CHANNEL_MACHINERY
	/// The index of the current sound being played.
	var/index = 1

// funky snowflake procs so that start1 always goes with loop1 and end1, start2 goes with loop2 and end2, etc etc etc
/datum/looping_sound/cassette_track_switch/get_start_sound()
	index = rand(1, length(start_sound))
	return start_sound[index]

/datum/looping_sound/cassette_track_switch/get_end_sound()
	return end_sound[index]

/datum/looping_sound/cassette_track_switch/get_sound(_mid_sounds)
	return mid_sounds[index]
