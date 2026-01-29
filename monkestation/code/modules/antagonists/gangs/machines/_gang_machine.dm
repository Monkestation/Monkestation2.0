PROCESSING_SUBSYSTEM_DEF(gang_machines) //temp SS
	name = "Gang Machines"
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING|SS_NO_INIT|SS_KEEP_TIMING
	wait = 10 SECONDS

//CONVERT THIS TO A COMPONENT
/obj/machinery/gang_machine
	name = "suspicious machine"
	desc = "You should not be seeing this!"
	density = TRUE
	idle_power_usage = 0
	processing_flags = START_PROCESSING_MANUALLY
	subsystem_type = /datum/controller/subsystem/processing/gang_machines
	///Additional text to give to gang members on examine
	var/extra_examine_text = ""
	///How much TC do we cost to set up
	var/setup_tc_cost = 0
	///Ref to the gang that owns this machine
	VAR_PROTECTED/datum/team/gang/owner
	///Have we been setup
	var/setup = FALSE

/obj/machinery/gang_machine/Initialize(mapload, gang)
	. = ..()
	owner = gang

/obj/machinery/gang_machine/Destroy()
	owner = null
	return ..()

/obj/machinery/gang_machine/attackby(obj/item/weapon, mob/user, params)
	var/area/our_area = get_area(src)
	if(!setup && setup_tc_cost && istype(weapon, /obj/item/stack/telecrystal) && setup_checks(user, our_area) && IS_GANGMEMBER(user))
		var/obj/item/stack/telecrystal/tc = weapon
		if(!tc.use(setup_tc_cost))
			balloon_alert(user, "you need at least [setup_tc_cost] telecrystals to setup \the [src].")
			return ..()
		do_setup(our_area, user)
		return
	return ..()

//yet another case of we need a dynamic description so the element wont work
/obj/machinery/gang_machine/examine(mob/user)
	. = ..()
	if(isobserver(user) || IS_GANGMEMBER(user))
		. += extra_examine_text
		. += span_syndradio("It is currently owned by the [owner?.gang_tag] Gang.")
		if(!setup && setup_tc_cost)
			. += span_syndradio("It needs [setup_tc_cost] telecrystals in order to be setup.")

///Put any checks you want to do before setup here, already checks if we are on the station
/obj/machinery/gang_machine/proc/setup_checks(mob/user, area/passed_area)
	var/area/our_area = passed_area || get_area(src)
	if(!our_area || !(our_area.type in GLOB.the_station_areas))
		if(user)
			balloon_alert(user, "\the [src] must be on the station.")
		return FALSE
	return TRUE

///Fully setup the machine
/obj/machinery/gang_machine/proc/do_setup(area/passed_area, mob/living/user)
	setup = TRUE
	if(!owner)
		var/datum/antagonist/gang_member/antag_datum = IS_GANGMEMBER(user)
		set_owner(antag_datum?.gang_team)

///getter proc for our owner
/obj/machinery/gang_machine/proc/get_owner() as /datum/team/gang
	return owner

///set our owner
/obj/machinery/gang_machine/proc/set_owner(datum/team/gang/new_owner)
	if(!istype(new_owner))
		new_owner = GLOB.all_gangs_by_tag[new_owner]

	if(isnull(new_owner))
		return

	SEND_SIGNAL(src, COMSIG_GANG_MACHINE_CHANGED_OWNER, new_owner, owner)
	owner = new_owner

///used by objectives
/obj/machinery/gang_machine/proc/attempt_activation(should_del = FALSE)
	if(QDELETED(src))
		return

	say("Activated")
	send_gang_message(list(owner), "Activated", src, "<span class='alertsyndie'>")
	SEND_SIGNAL(src, COMSIG_GANG_MACHINE_ACTIVATED)
	activate()
	if(should_del)
		do_sparks(4, FALSE, src)
		qdel(src)

/obj/machinery/gang_machine/proc/activate()
	return
