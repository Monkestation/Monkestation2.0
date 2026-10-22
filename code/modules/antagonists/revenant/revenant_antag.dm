/datum/antagonist/revenant
	name = "\improper Revenant"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antagpanel_category = ANTAG_GROUP_HORRORS
	antag_flags = FLAG_ANTAG_CAP_IGNORE_HUMANITY

/datum/antagonist/revenant/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/revenant/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/revenant/get_preview_icon()
	return finish_preview_icon(icon('icons/mob/simple/mob.dmi', "revenant_idle"))

/datum/antagonist/revenant/forge_objectives()
	var/datum/objective/revenant/objective = new
	objective.owner = owner
	objectives += objective
	var/datum/objective/revenant_fluff/objective2 = new
	objective2.owner = owner
	objectives += objective2

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
		QDEL_IN(hosts_mind.current, 1 SECONDS)
	var/mob/living/basic/revenant/revenant = new(spawn_loc)
	revenant.PossessByPlayer(spender_key)
	if(isobserver(spender))
		qdel(spender)
	message_admins("[ADMIN_LOOKUPFLW(revenant)] has been made into a revenant by using an antag token.")

/proc/find_possible_revenant_spawns()
	. = list()
	for(var/mob/living/carbon/human/mob in GLOB.dead_mob_list) //look for any harvestable bodies
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
