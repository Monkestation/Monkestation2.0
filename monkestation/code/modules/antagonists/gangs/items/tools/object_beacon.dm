/obj/item/gang_device/object_beacon
	name = "suspicious device"
	icon_state = "gangtool-white"
	gang_examine = "A device used to call down a %TYPE% in a stylish drop pod."
	///Object type to call down
	var/atom/created_type
	///Areas we are restricted to being activated in, if any
	var/list/allowed_areas

/obj/item/gang_device/object_beacon/Initialize(mapload)
	if(created_type)
		gang_examine = replacetext(gang_examine, "%TYPE%", "[initial(created_type.name)]")

	if(allowed_areas)
		for(var/type in allowed_areas) //maybe I should try and cache this, ehh
			allowed_areas += GLOB.areas_by_type[type]
			allowed_areas -= type
		gang_examine += " This one can only be used in [english_list(allowed_areas)]."
	return ..()

/obj/item/gang_device/object_beacon/Destroy(force)
	allowed_areas = null
	return ..()

/obj/item/gang_device/object_beacon/attack_self(mob/user, modifiers)
	var/datum/antagonist/gang_member/antag_datum = IS_GANGMEMBER(user)
	if(!antag_datum)
		balloon_alert(user, "You can't figure out how to use [src].")
		return

	if(allowed_areas && !(get_area(src) in allowed_areas))
		balloon_alert(user, "[src] can't be used here.")
		return

	call_down_object(antag_datum)

/obj/item/gang_device/object_beacon/proc/call_down_object(datum/antagonist/gang_member/user_datum, spawn_override, location_override)
	if(!created_type)
		return

	podspawn(list(
		"target" = location_override || get_turf(src),
		"style" = STYLE_SYNDICATE,
		"spawn" = spawn_override || created_type,
		"explosionSize" = list(0,0,0,0),
		"bluespace" = TRUE
	))
	qdel(src)

/obj/item/gang_device/object_beacon/gang_machine

/obj/item/gang_device/object_beacon/gang_machine/call_down_object(datum/antagonist/gang_member/user_datum, spawn_override, location_override)
	var/turf/our_turf = get_turf(src)
	var/obj/machinery/gang_machine/created_machine = new created_type(our_turf)
	created_machine.alpha = 0 //to hopefully avoid any flashing before coming down
	created_machine.owner = user_datum.gang_team
	created_machine.do_setup()
	. = ..(user_datum, created_machine, our_turf) //yes its a parent call with args, dont worry about it
	created_machine.alpha = 255

/obj/item/gang_device/object_beacon/gang_machine/credit_converter
	icon_state = "gangtool-blue"
	created_type = /obj/machinery/gang_machine/credit_converter

/obj/item/gang_device/object_beacon/gang_machine/fabricator
	icon_state = "gangtool-red"
	created_type = /obj/machinery/gang_machine/fabricator
