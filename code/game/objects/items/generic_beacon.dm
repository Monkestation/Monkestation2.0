/obj/item/generic_beacon
	name = "A beacon for direct delivery of big things"
	desc = "delivers the thing"
	icon = 'monkestation/icons/obj/beacon.dmi'
	icon_state = "music_beacon"
	var/list/spawnables = list(/obj/item/, /obj/machinery/)
	var/used = FALSE

/obj/item/generic_beacon/attack_self()
	if(used)
		return
	loc.visible_message(span_warning("\The [src] begins to beep loudly!"))
	used = TRUE
	addtimer(CALLBACK(src, PROC_REF(launch_payload)), 4 SECONDS)

/obj/item/generic_beacon/proc/launch_payload()
	if(QDELETED(src))
		return
	podspawn(list(
		"target" = get_turf(src),
		"spawn" = spawnables,
		"style" = STYLE_CENTCOM
	))
	qdel(src)

/obj/item/generic_beacon/jukebox
	name = "jukebox beacon"
	desc = "N.T. jukebox beacon, toss it down and you will have a complementary jukebox delivered to you. It comes with a free wrench to move it after deployment."
	icon_state = "music_beacon"
	spawnables = list(/obj/item/wrench, /obj/machinery/jukebox)

/obj/item/generic_beacon/hotdog
	name = "tactical hotdog deployer"
	desc = "For the glizzy guzzler in us all."
	icon_state = "hotdog_beacon"
	spawnables = list(/obj/item/food/hotdog, /obj/vehicle/ridden/hoverdog, /obj/item/key/hoverdog)

/obj/item/generic_beacon/grill
	name = "grill beacon"
	desc = "Grillin aint easy but someones gotta do it."
	icon_state = "fire_beacon"
	spawnables = list(/obj/item/wrench, /obj/machinery/grill)
