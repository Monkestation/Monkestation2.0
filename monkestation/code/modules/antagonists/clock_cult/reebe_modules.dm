GLOBAL_LIST_EMPTY(abscond_markers)

/// spawn the reebe z level and map template, lazy templates dont work because we need to give this ztraits
/proc/spawn_reebe(forced = FALSE)
	if(!SSthe_ark.initialized)
		SSthe_ark.Initialize()

	var/static/reebe_loaded
	if(forced)
		message_admins("Admin forcing reebe spawn, if it has already spawned this will break things unless you know what your doing.")
	else if(reebe_loaded)
		return FALSE

	reebe_loaded = TRUE
	var/datum/space_level/reebe_z = SSmapping.add_new_zlevel("Reebe", ZTRAITS_REEBE)
	if(!reebe_z)
		reebe_loaded = FALSE
		CRASH("Failed to create the Reebe Z level.")

	SSmapping.initialize_reserved_level(reebe_z.z_value)
	if(!SSmapping.reservation_ready["[reebe_z.z_value]"]) //if this is not true then the block reservation will sleep forever
		reebe_loaded = FALSE
		CRASH("Reebe Z level not in SSmapping.reservation_ready.")

	var/datum/turf_reservation/reservation = SSmapping.request_turf_block_reservation(101, 101, z_reservation = reebe_z.z_value)
	if(!reservation)
		reebe_loaded = FALSE
		CRASH("Failed to reserve a block for Reebe.")

	var/datum/map_template/reebe_template = new(path = REEBE_MAP_PATH, cache = TRUE)
	if(!reebe_template.cached_map) //might not be needed, im just copying lazy template code and I cant figure out what cached maps are for in this case
		reebe_loaded = FALSE
		CRASH("Failed to cache template for loading Reebe.")

	if(!reebe_template.load(reservation.bottom_left_turfs[1]))
		reebe_loaded = FALSE
		CRASH("Failed to load the Reebe template.")

	for(var/area/reebe_area as anything in typesof(/area/ruin/powered/reebe))
		reebe_area = GLOB.areas_by_type[reebe_area]
		if(reebe_area)
			SSthe_ark.reebe_areas[reebe_area] = 1
	return TRUE

///Send a pod full of helpful items to the station's bridge, you can give items number values to make that many of them be spawned
/proc/send_station_support_package(list/additional_items, sent_message = "We are sending a support package to the bridge to help deal with the threats to the station.")
	var/turf/bridge_turf = pick(GLOB.areas_by_type[/area/station/command/bridge].get_turfs_from_all_zlevels())
	if(!bridge_turf)
		return

	var/list/spawned_list = list(
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/storage/medkit/brute = 1,
		/obj/item/storage/medkit/fire = 1,
		/obj/item/storage/medkit/regular = 1,
		/obj/item/gun/medbeam = 1,
		/obj/item/storage/part_replacer/cargo = 1,
		/obj/item/storage/box/recharger_parts = 1,
		/obj/item/storage/toolbox/mechanical = 3,
	)

	if(additional_items)
		spawned_list += additional_items
	fill_with_ones(spawned_list)
	for(var/spawned_object in spawned_list)
		var/value = spawned_list[spawned_object]
		if(value < 0)
			stack_trace("a spawned_object([spawned_object]) in send_station_support_package() has a value < 0.")
		while(value > 0)
			value--
			spawned_list += new spawned_object()
		spawned_list -= spawned_object

	priority_announce(sent_message, has_important_message = TRUE)
	podspawn(list("target" = bridge_turf, "style" = STYLE_CENTCOM, "spawn" = spawned_list, "bluespace" = FALSE, "stay_after_drop" = TRUE))

/obj/item/storage/box/recharger_parts
	name = "Recharger Parts"

/obj/item/storage/box/recharger_parts/PopulateContents()
	. = ..() //there is actually a helper for this but I cant remember the name
	var/list/spawned_list = list(/obj/item/circuitboard/machine/recharger = 5, /obj/item/stack/cable_coil = 1, /obj/item/stack/sheet/iron/fifty = 1)
	for(var/type in spawned_list)
		for(var/i in 1 to spawned_list[type])
			new type(src)

/obj/effect/mob_spawn/corpse/human/blood_cultist
	name = "Blood Cultist"
	outfit = /datum/outfit/blood_cultist

/datum/outfit/blood_cultist
	name = "Blood Cultist"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/cultrobes/alt
	shoes = /obj/item/clothing/shoes/cult/alt

/datum/outfit/blood_cultist/post_equip(mob/living/carbon/human/equipped, visualsOnly)
	equipped.eye_color_left = BLOODCULT_EYE
	equipped.eye_color_right = BLOODCULT_EYE
	equipped.update_body()

	var/obj/item/clothing/suit/hooded/hooded = locate() in equipped
	hooded.ToggleHood()

/obj/effect/mob_spawn/corpse/human/clock_cultist
	name = "Clock Cultist"
	outfit = /datum/outfit/clock

/obj/effect/landmark/late_cog_portals
	name = "reebe crew portal spawn"

//for the portal from the outpost to reebe
/obj/effect/landmark/abscond_marker
	name = "abscond marker"
	icon = 'monkestation/icons/effects/landmarks_static.dmi'
	icon_state = "clockwork_orange"

/obj/effect/landmark/abscond_marker/Initialize(mapload)
	. = ..()
	GLOB.abscond_markers += src

/obj/effect/landmark/abscond_marker/Destroy()
	. = ..()
	GLOB.abscond_markers -= src

/obj/effect/servant_blocker
	name = "servant Blocker"
	icon = 'monkestation/icons/obj/clock_cult/clockwork_effects.dmi'
	icon_state = "servant_blocker"
	anchored = TRUE

/obj/effect/servant_blocker/CanPass(atom/movable/mover, border_dir)
	for(var/mob/held_mob in mover.get_all_contents())
		if(IS_CLOCK(held_mob))
			return FALSE
	return ..()

/obj/effect/spawner/structure/window/clockwork
	name = "brass window spawner"
	icon_state = "bronzewindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/clockwork/fulltile)
