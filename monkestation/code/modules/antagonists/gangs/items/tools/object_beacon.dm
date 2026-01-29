/obj/item/gang_device/object_beacon
	name = "suspicious device"
	icon_state = "gangtool-white"
	gang_examine = "A device used to call down a %TYPE% in a stylish drop pod."
	///Object type to call down
	var/atom/created_type
	///Typecache of areas we are restricted to being activated in, if any
	var/list/allowed_areas
	///What does %TYPE% get replaced with on init, if unset then just use created_type's name
	var/description_name

/obj/item/gang_device/object_beacon/Initialize(mapload, passed_type, list/passed_allowed_areas)
	created_type ||= passed_type
	if(created_type)
		gang_examine = replacetext(gang_examine, "%TYPE%", "[description_name ? "[description_name]" : initial(created_type.name)]")

	allowed_areas = passed_allowed_areas
	if(length(allowed_areas))
		var/list/area_names = list()
		for(var/area/area_type in allowed_areas) //maybe I should try and cache this, ehh
			area_names += area_type::name
		gang_examine += " This one can only be used in [english_list(area_names)]."
		allowed_areas = typecacheof(allowed_areas, TRUE)
	return ..()

/obj/item/gang_device/object_beacon/Destroy(force)
	allowed_areas = null
	return ..()

/obj/item/gang_device/object_beacon/attack_self(mob/user, modifiers)
	var/datum/antagonist/gang_member/antag_datum = IS_GANGMEMBER(user)
	if(!antag_datum)
		balloon_alert(user, "you can't figure out how to use [src].")
		return

	var/area/our_area = get_area(src)
	if(allowed_areas && !is_type_in_typecache(our_area.type, allowed_areas))
		balloon_alert(user, "[src] can't be used here.")
		return

	call_down_object(antag_datum)

/obj/item/gang_device/object_beacon/proc/call_down_object(datum/antagonist/gang_member/user_datum, spawn_override, location_override)
	if(!created_type)
		return

	var/obj/structure/closet/supplypod/pod_spawn = podspawn(list(
		"target" = location_override || get_turf(src),
		"style" = STYLE_SYNDICATE,
		"spawn" = spawn_override || created_type,
		"explosionSize" = list(0,0,0,0),
		"bluespace" = TRUE
	))
	spawn_override ||= locate(created_type) in pod_spawn.contents
	SEND_SIGNAL(src, COMSIG_GANG_OBJECT_BEACON_ACTIVATED, spawn_override)
	qdel(src)


/obj/item/gang_device/object_beacon/gang_machine

/obj/item/gang_device/object_beacon/gang_machine/call_down_object(datum/antagonist/gang_member/user_datum, spawn_override, location_override)
	var/turf/our_turf = get_turf(src)
	var/obj/machinery/gang_machine/created_machine = new created_type(our_turf)
	created_machine.alpha = 0 //to hopefully avoid any flashing before coming down
	created_machine.set_owner(user_datum.gang_team)
	created_machine.do_setup()
	. = ..(user_datum, created_machine, our_turf) //yes its a parent call with args, dont worry about it
	created_machine.alpha = 255

/obj/item/gang_device/object_beacon/gang_machine/credit_converter
	icon_state = "gangtool-blue"
	created_type = /obj/machinery/gang_machine/credit_converter
	description_name = "Credit Converter"

/obj/item/gang_device/object_beacon/gang_machine/fabricator
	icon_state = "gangtool-red"
	created_type = /obj/machinery/gang_machine/fabricator
	description_name = "Gang Fabricator"
