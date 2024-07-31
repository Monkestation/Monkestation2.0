GLOBAL_LIST_INIT(pathogen_clouds, list())
GLOBAL_LIST_INIT(science_goggles_wearers, list())

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
	var/source_is_carrier = TRUE
	var/list/viruses = list()
	var/lifetime = 10 SECONDS //how long until we naturally disappear, humans breath about every 8 seconds, so it has to survive at least this long to have a chance to infect
	var/turf/target = null //when created, we'll slowly move toward this turf
	var/core = FALSE
	var/modified = FALSE
	var/moving = TRUE
	var/list/id_list = list()
	var/death = 0

/obj/effect/pathogen_cloud/Initialize(mob/source, list/viruses, is_carrier = TRUE, is_core = TRUE)
	. = ..()
	if (QDELETED(loc) || !length(viruses))
		return INITIALIZE_HINT_QDEL
	src.source = source
	src.viruses = viruses
	src.source_is_carrier = is_carrier
	src.core = is_core

	for(var/datum/disease/advanced/virus as anything in viruses)
		id_list += "[virus.uniqueID]-[virus.subID]"

	if(!core)
		var/obj/effect/pathogen_cloud/core/existing_core = locate(/obj/effect/pathogen_cloud/core) in src.loc
		if(!QDELETED(existing_core))
			for(var/datum/disease/advanced/virus as anything in viruses)
				if("[virus.uniqueID]-[virus.subID]" in existing_core.id_list)
					continue
				existing_core.viruses |= virus.Copy()
				existing_core.modified = TRUE
			return INITIALIZE_HINT_QDEL

	GLOB.pathogen_clouds += src
	register()

	pathogen = image('monkestation/code/modules/virology/icons/96x96.dmi', src, "pathogen_airborne")
	pathogen.plane = HUD_PLANE
	pathogen.appearance_flags = RESET_COLOR | RESET_ALPHA
	for (var/mob/living/wearer in GLOB.science_goggles_wearers)
		wearer.client?.images |= pathogen

	if(lifetime)
		QDEL_IN(src, lifetime)

/obj/effect/pathogen_cloud/Destroy()
	GLOB.pathogen_clouds -= src
	unregister()
	if(pathogen)
		for(var/mob/living/wearer in GLOB.science_goggles_wearers)
			wearer.client?.images -= pathogen
		pathogen = null
	source = null
	viruses = null
	target = null
	return ..()

/obj/effect/pathogen_cloud/proc/register()
	SSpathogen_clouds.clouds += src

/obj/effect/pathogen_cloud/proc/unregister()
	SSpathogen_clouds.clouds -= src
	SSpathogen_clouds.current_run_clouds -= src

/obj/effect/pathogen_cloud/core
	core = TRUE

/obj/effect/pathogen_cloud/core/Initialize(mapload, list/viruses, is_carrier = TRUE, is_core = TRUE)
	. = ..()
	if(.)
		return
	var/strength = 0
	for (var/datum/disease/advanced/virus as anything in viruses)
		strength += virus.infectionchance
	strength = round(strength / length(viruses))
	var/spread_range = max(0, (strength / 20) - 1)
	if(spread_range > 0)
		var/list/possible_turfs = list()
		for(var/turf/open/turf as anything in RANGE_TURFS(spread_range, loc)) //stronger viruses can reach turfs further away.
			if(!isopenturf(turf) || QDELING(turf))
				continue
			possible_turfs += turf
		if(length(possible_turfs))
			target = pick(possible_turfs)
	START_PROCESSING(SSpathogen_processing, src)

/obj/effect/pathogen_cloud/core/Destroy()
	STOP_PROCESSING(SSpathogen_processing, src)
	return ..()

/obj/effect/pathogen_cloud/core/register()
	SSpathogen_clouds.cores += src

/obj/effect/pathogen_cloud/core/unregister()
	SSpathogen_clouds.cores -= src
	SSpathogen_clouds.current_run_cores -= src

/obj/effect/pathogen_cloud/core/process(seconds_per_tick)
	if(!moving)
		return PROCESS_KILL
	var/turf/open/turf = get_turf(src)
	if(!istype(turf) || QDELING(turf))
		qdel(src)
		return PROCESS_KILL
	if ((turf != target) && moving)
		if(!QDELETED(target) && SPT_PROB(75, seconds_per_tick))
			if(!step_towards(src, target)) // we hit a wall and our momentum is shattered
				moving = FALSE
		else
			step_rand(src)
		var/obj/effect/pathogen_cloud/new_cloud = new(turf, source, viruses, source_is_carrier, FALSE)
		new_cloud.modified = src.modified
		new_cloud.moving = FALSE
