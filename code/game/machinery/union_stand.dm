/obj/machinery/union_stand
	name = "\improper holographic union stand"
	desc = "A holographic stand that allows Union members to vote on new demands."
	icon = 'monkestation/icons/obj/structures/signboards.dmi'
	icon_state = "holographic_sign"
	base_icon_state = "holographic_sign"

	req_one_access = list(ACCESS_UNION, ACCESS_UNION_LEADER)
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.1
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	circuit = /obj/item/circuitboard/machine/union_stand

	///What union we're a union stand for.
	var/datum/union/union_stand_for

/obj/machinery/union_stand/Initialize(mapload)
	. = ..()
	union_stand_for = GLOB.cargo_union

/obj/machinery/union_stand/Destroy()
	union_stand_for = null
	return ..()

/obj/machinery/union_stand/update_icon_state()
	icon_state = base_icon_state
	if(machine_stat & NOPOWER)
		icon_state += "_blank"
	return ..()

/obj/machinery/union_stand/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	union_stand_for.ui_interact(user, source = src)
