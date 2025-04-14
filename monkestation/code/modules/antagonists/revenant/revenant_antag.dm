/datum/antagonist/revenant/antag_token(datum/mind/hosts_mind, mob/spender)
	var/spender_key = spender.key
	if(!spender_key)
		CRASH("wtf, spender had no key")
	var/turf/spawn_loc = get_turf(spender)
	if(!is_station_level(spawn_loc?.z))
		var/list/possible_spawn_locs = find_possible_revenant_spawns()
		if(!length(possible_spawn_locs))
			message_admins("Failed to find valid spawn location for [ADMIN_LOOKUPFLW(spender)], who spent a revenant antag token")
			CRASH("Failed to find valid spawn location for revenant antag token")
		spawn_loc = pick(possible_spawn_locs)
	if(isliving(spender) && hosts_mind)
		hosts_mind.current.unequip_everything()
		new /obj/effect/holy(hosts_mind.current.loc)
		QDEL_IN(hosts_mind.current, 1 SECOND)
	var/mob/living/basic/revenant/revenant = new(spawn_loc)
	revenant.PossessByPlayer(spender_key)
	if(isobserver(spender))
		qdel(spender)
	message_admins("[ADMIN_LOOKUPFLW(revenant)] has been made into a revenant by using an antag token.")

/proc/find_possible_revenant_spawns()
	. = list()
	for(var/mob/living/mob in GLOB.dead_mob_list) //look for any dead bodies
		var/turf/mob_turf = get_turf(mob)
		if(is_station_level(mob_turf?.z))
			. += mob_turf
	if(length(.) < 15) //look for any morgue trays, crematoriums, ect if there weren't alot of dead bodies on the station to pick from
		for(var/obj/structure/bodycontainer/container in GLOB.bodycontainers)
			var/turf/container_turf = get_turf(container)
			if(is_station_level(container_turf?.z))
				. += container_turf
	if(!length(.)) //If we can't find any valid spawnpoints, try the carp spawns
		. += find_space_spawn()
