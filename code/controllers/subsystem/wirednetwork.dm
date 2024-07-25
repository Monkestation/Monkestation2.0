SUBSYSTEM_DEF(wirednetwork)
	name = "Wired Network"
	init_order = INIT_ORDER_DATANET
	flags = SS_NO_FIRE
	wait = 2 SECONDS
	var/areacounter = 0
	var/list/areas = list() //areas dataterminals actually exist

	///List of all dataterminals on the server.
	var/list/obj/machinery/power/dataterminal/dataterminals = list()

/datum/controller/subsystem/wirednetwork/Initialize()
	ip_setup()
	return SS_INIT_SUCCESS

/**
 * sets IPs for all terminals at initialization
 */
/datum/controller/subsystem/wirednetwork/proc/ip_setup()
	for(var/area/A in areas)
		A.ipnumber = areacounter
		areacounter += 1
		var/counter = 0
		for(var/obj/machinery/power/dataterminal/D in A.dataterminals)
			D.ipnumber = counter
			counter += 1
			D.trueip = "[A.ipnumber].[D.ipnumber]"

/**
 * sets an ip for a new terminal
 */
/datum/controller/subsystem/wirednetwork/proc/after_init_ip(var/obj/machinery/power/dataterminal/term, var/area/station/area)
	var/counter = 0
	var/areaalreadyregistered = FALSE
	if(areas.Find(area))
		areaalreadyregistered = TRUE
	if(areaalreadyregistered == FALSE) //this is kinda redundant but just in case
		areas.Add(area)
		area.ipnumber = areacounter
		areacounter += 1
	for(var/obj/machinery/power/dataterminal/D in area.dataterminals)
		counter += 1
	term.ipnumber = counter
