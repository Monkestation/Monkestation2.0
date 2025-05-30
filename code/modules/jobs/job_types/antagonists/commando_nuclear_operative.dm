/datum/job/commando_nuclear_operative
	title = ROLE_COMMANDO_OPERATIVE

/datum/job/commando_nuclear_operative/get_roundstart_spawn_point()
	return pick(GLOB.commando_nukeop_start)

/datum/job/commando_nuclear_operative/get_latejoin_spawn_point()
	return pick(GLOB.commando_nukeop_start)
