GLOBAL_LIST_INIT(pathogen_clouds, list())
GLOBAL_LIST_INIT(virus_viewers, list())

/obj/effect/pathogen_cloud
	name = ""
	icon = 'monkestation/code/modules/virology/icons/96x96.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon_state = ""
	color = COLOR_GREEN
	pixel_x = -32
	pixel_y = -32
	opacity = 0
	anchored = 0
	density = 0
	var/mob/source = null
	var/sourceIsCarrier = TRUE
	var/list/viruses = list()
	var/lifetime = 10 SECONDS //how long until we naturally disappear, humans breath about every 8 seconds, so it has to survive at least this long to have a chance to infect
	var/turf/target = null //when created, we'll slowly move toward this turf
	var/core = FALSE
	var/modified = FALSE
	var/moving = TRUE
	var/list/id_list = list()

/obj/effect/pathogen_cloud/Initialize(mapload, mob/sourcemob, list/virus, isCarrier = TRUE, isCore = TRUE)
	. = ..()
	if (!loc || length(virus) <= 0)
		return INITIALIZE_HINT_QDEL
	if(!SSpathogen_clouds.can_fire) // presumably an admin has manually disabled this bc it's being laggy as shit
		return INITIALIZE_HINT_QDEL
	core = isCore
	sourceIsCarrier = isCarrier
	GLOB.pathogen_clouds += src

	viruses = virus

	for(var/datum/disease/acute/D as anything in viruses)
		id_list += "[D.uniqueID]-[D.subID]"

	if(!core)
		var/obj/effect/pathogen_cloud/core/core = locate(/obj/effect/pathogen_cloud/core) in src.loc
		if(get_turf(core) == get_turf(src))
			core.add_virus(viruses)
			return INITIALIZE_HINT_QDEL

	if(istype(src, /obj/effect/pathogen_cloud/core))
		SSpathogen_clouds.cores += src
	else
		SSpathogen_clouds.clouds += src

	pathogen = image('monkestation/code/modules/virology/icons/96x96.dmi',src,"pathogen_airborne")
	pathogen.plane = HUD_PLANE
	pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
	for (var/mob/living/wearer as anything in GLOB.virus_viewers)
		if(QDELETED(wearer) || QDELETED(wearer.client))
			continue
		wearer.client.images |= pathogen

	source = sourcemob

	QDEL_IN(src, lifetime)

/obj/effect/pathogen_cloud/proc/add_virus(list/viruses)
	. = FALSE
	if(!islist(viruses))
		viruses = list(viruses)
	for(var/datum/disease/acute/virus as anything in viruses)
		var/id = "[virus.uniqueID]-[virus.subID]"
		if(id in id_list)
			continue
		viruses += virus.Copy()
		id_list += id
		. = TRUE
	if(.)
		modified = TRUE

/obj/effect/pathogen_cloud/core
	core = TRUE

/obj/effect/pathogen_cloud/Destroy()
	if(istype(src, /obj/effect/pathogen_cloud/core))
		SSpathogen_clouds.cores -= src
		SSpathogen_clouds.current_run_cores -= src
	else
		SSpathogen_clouds.clouds -= src
		SSpathogen_clouds.current_run_clouds -= src

	if (pathogen)
		for (var/mob/living/wearer as anything in GLOB.virus_viewers)
			if(QDELETED(wearer) || QDELETED(wearer.client))
				continue
			wearer.client.images -= pathogen
		pathogen = null
	GLOB.pathogen_clouds -= src
	source = null
	viruses = list()
	lifetime = 3
	target = null
	return ..()

/obj/effect/pathogen_cloud/core/Initialize(mapload, mob/sourcemob, list/virus)
	. = ..()
	if(.)
		return

	var/strength = 0
	for (var/datum/disease/acute/V as anything in viruses)
		strength += V.infectionchance
	strength = round(strength / length(viruses))
	var/list/possible_turfs = list()
	var/max_range = clamp((strength / 20) - 1, 0, 7)
	for (var/turf/open/T in range(max_range, loc))//stronger viruses can reach turfs further away.
		possible_turfs += T
	if(!length(possible_turfs))
		return INITIALIZE_HINT_QDEL
	target = pick(possible_turfs)
	START_PROCESSING(SSpathogen_processing, src)

/obj/effect/pathogen_cloud/core/Destroy()
	STOP_PROCESSING(SSpathogen_processing, src)
	return ..()

/obj/effect/pathogen_cloud/core/process(seconds_per_tick)
	var/turf/open/turf = get_turf(src)
	if ((turf != target) && moving)
		if (prob(75))
			if(!step_towards(src,target)) // we hit a wall and our momentum is shattered
				moving = FALSE
		else
			step_rand(src)
		var/obj/effect/pathogen_cloud/C = new /obj/effect/pathogen_cloud(turf, source, viruses, sourceIsCarrier, FALSE)
		C.modified = modified
		C.moving = FALSE
