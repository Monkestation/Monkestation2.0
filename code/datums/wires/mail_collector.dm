/datum/wires/mail_collector
	holder_type = /obj/machinery/mail_collector
	proper_name = "Mail Collector"

/datum/wires/mail_collector/New(atom/holder)
	wires = list(WIRE_SHOCK, WIRE_IDSCAN, WIRE_RESET)
	return ..()

/datum/wires/mail_collector/interactable(mob/user)
	. = ..()
	if(!.)
		return FALSE
	var/obj/machinery/mail_collector/machine = holder
	if(!issilicon(user) && machine.seconds_electrified && machine.shock(user, 100))
		return FALSE
	if(machine.panel_open || machine.machine_stat & MAINT)
		return TRUE
	return FALSE

/datum/wires/mail_collector/get_status()
	var/obj/machinery/mail_collector/machine = holder
	var/list/status = list()
	status += "A red light is [machine.seconds_electrified ? "blinking" : "off"]."
	status += "The magnetic strip light is [machine.can_collect ? "on" : "off"]."
	status += "The disk is [(machine.obj_flags & EMAGGED) ? "spinning rapidly" : "spinning"]."
	return status

/datum/wires/mail_collector/on_pulse(wire)
	var/obj/machinery/mail_collector/machine = holder
	switch(wire)
		if(WIRE_SHOCK)
			machine.seconds_electrified = MACHINE_DEFAULT_ELECTRIFY_TIME
		if(WIRE_IDSCAN)
			machine.can_collect = !machine.can_collect
		if(WIRE_RESET)
			machine.obj_flags &= ~EMAGGED

/datum/wires/mail_collector/on_cut(wire, mend, source)
	var/obj/machinery/mail_collector/machine = holder
	switch(wire)
		if(WIRE_SHOCK)
			machine.seconds_electrified = (mend) ? MACHINE_NOT_ELECTRIFIED : MACHINE_ELECTRIFIED_PERMANENT
		if(WIRE_IDSCAN)
			machine.can_collect = mend
