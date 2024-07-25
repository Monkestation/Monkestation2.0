/obj/machinery/power/dataterminal
	name = "data terminal"
	icon_state = "dataterm"
	desc = "It's an underfloor data terminal, used to draw data from the grid."
	layer = WIRE_TERMINAL_LAYER //a bit above wires
	var/obj/machinery/master
	var/itemtype = /obj/item/dataterminal
	var/ipnumber
	var/trueip

/**
 * Refreshes the data terminals powernet relationship, mostly in case it becomes unsynced but also useful for first time setup
 */
/obj/machinery/power/dataterminal/proc/refresh_powernet()
	if(powernet)
		if(!powernet.dataterminals.Find(src))
			powernet.dataterminals.Add(src)
		if(!powernet.networknodes.Find(master))
			powernet.networknodes.Add(master)

/obj/machinery/power/dataterminal/disconnect_from_network()
	. = ..()
	if(powernet)
		powernet.dataterminals.Remove(src)
		powernet.networknodes.Remove(master)

/obj/machinery/power/dataterminal/connect_to_network()
	. = ..()
	refresh_powernet()


/obj/machinery/power/dataterminal/Initialize(mapload)
	. = ..()
	var/area/area = get_area(src)
	area.dataterminals.Add(src)
	SSwirednetwork.areas.Add(area)
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, use_alpha = TRUE)
	if(SSwirednetwork.initialized)
		SSwirednetwork.after_init_ip(src,get_area(src))

/**
 * Used to tell if the dataterminal can be dismantled or not, please put this before dismantle
 */
/obj/machinery/power/dataterminal/proc/can_data_dismantle()
	if(!master)
		return TRUE
	else
		return FALSE

/obj/machinery/power/dataterminal/should_have_node()
	return TRUE

/obj/machinery/power/dataterminal/wirecutter_act(mob/living/carbon/user, obj/item/I)
	..()
	if(!user.wearing_shock_proof_gloves() && powernet)
		electrocute_mob(user, powernet, src)
	else
		if(can_data_dismantle())
			dismantle(user, I)
			return TRUE

/**
 * Used to destroy the terminal o
 */
/obj/machinery/power/dataterminal/proc/dismantle(mob/living/user, obj/item/I)
	disconnect_from_network()
	user.put_in_hands(new itemtype())
	powernet.dataterminals.Remove(src)
	powernet.networknodes.Remove(master)
	del(src)

/obj/item/dataterminal
	name = "data terminal"
	icon_state = "dataterm"
	desc = "It's an underfloor data terminal, used to send data through the grid."
	var/origin_type = /obj/machinery/power/dataterminal

/obj/item/dataterminal/wirecutter_act(mob/living/user, obj/item/tool)
	. = ..()
	secure(user)

/obj/item/dataterminal/proc/secure(mob/living/carbon/user)
	var/turf/T = get_turf(loc)
	if(isgroundlessturf(T))
		to_chat(user, span_warning("You need ground to plant this on!"))
		return
	for(var/obj/A in T)
		if(istype(A, /obj/machinery/power/dataterminal))
			to_chat(user, span_warning("There is already a terminal here!"))
			return
		if(A.density && !(A.flags_1 & ON_BORDER_1))
			to_chat(user, span_warning("There is already something here!"))
			return

	user.visible_message(span_notice("[user] rights \the [src.name]."), span_notice("You right \the [name]."))
	var/obj/machinery/power/dataterminal/D = new origin_type(get_turf(loc))
	D.refresh_powernet()
	qdel(src)

/obj/machinery/power/dataterminal/proc/register_machine(var/obj/machinery/machine)
	machine.dataterminal = src
	master = machine
	refresh_powernet()

/obj/machinery/power/dataterminal/proc/unregister_machine(var/obj/machinery/machine)
	machine.dataterminal = null
	if(powernet)
		powernet.networknodes.Remove(machine)
	master = null
///////////////////////////////////////////
//editing of normal stuff past this point//
///////////////////////////////////////////
/datum/powernet
	var/list/networknodes = list()
	var/list/dataterminals = list()

/obj/machinery/wrench_act(mob/user, obj/item/wrench, time)
	if(anchored)
		var/turf/T = get_turf(loc)
		if(anchored && !dataterminal)
			for(var/obj/A in T)
				if(istype(A,/obj/machinery/power/dataterminal))
					dataterminal = A
					dataterminal.register_machine(src)
		else
			dataterminal.unregister_machine()

/obj/machinery/on_construction(mob/user)
	. = ..()
	var/turf/T = get_turf(loc)
	for(var/obj/A in T)
		if(istype(A,/obj/machinery/power/dataterminal)  && !istype(src, /obj/machinery/power/dataterminal))
			dataterminal = A
			dataterminal.register_machine(src)

/obj/machinery/on_deconstruction()
	. = ..()
	if(dataterminal)
		dataterminal.unregister_machine(src)

/obj/machinery/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(loc)
	for(var/obj/A in T)
		if(istype(A,/obj/machinery/power/dataterminal) && !istype(src, /obj/machinery/power/dataterminal))
			dataterminal = A
			dataterminal.register_machine(src)
			dataterminal.refresh_powernet()
	netpacket_rx.master = src
	netpacket_tx.master = src

/obj/machinery/proc/test_terminal()
	var/turf/T = get_turf(loc)
	for(var/obj/A in T)
		if(istype(A,/obj/machinery/power/dataterminal))
			return "works"

/obj/machinery
	var/obj/machinery/power/dataterminal/dataterminal
	var/datum/netpacketrx/netpacket_rx = new /datum/netpacketrx
	var/datum/netpackettx/netpacket_tx = new /datum/netpackettx


/area
	var/ipnumber
	var/list/dataterminals = list()
