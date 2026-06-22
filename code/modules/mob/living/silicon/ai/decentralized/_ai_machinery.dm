#define AI_MACHINE_TOO_HOT "Environment too hot"
#define AI_MACHINE_NO_MOLES "Environment lacks an atmosphere"

/obj/machinery/ai
	name = "You shouldn't see this!"
	desc = "You shouldn't see this!"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	density = TRUE
	///Temperature of the ai core itself, this will share with air in the enviroment
	var/core_temp = CELCIUS_TO_KELVIN(-80)

/obj/machinery/ai/Initialize(mapload)
	. = ..()
	SSair.start_processing_machine(src)

/obj/machinery/ai/Destroy(force)
	SSair.stop_processing_machine(src)
	return ..()

//Cooling happens here
/obj/machinery/ai/process_atmos()
	if((machine_stat & (BROKEN|EMPED)) || !has_power())
		return FALSE
	var/turf/T = get_turf(src)
	if(!T || isspaceturf(T))
		return FALSE
	var/datum/gas_mixture/env = T.return_air()
	if(!env.total_moles())
		return FALSE
	var/new_temp = env.temperature_share(null, AI_HEATSINK_COEFF, core_temp, AI_HEATSINK_CAPACITY)
	core_temp = new_temp
	T.air_update_turf(FALSE, FALSE)
	return TRUE

/obj/machinery/ai/proc/valid_holder()
	if(machine_stat & (BROKEN|EMPED) || !has_power())
		return FALSE

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	if(!env)
		return FALSE
	var/total_moles = env.total_moles()
	if(isspaceturf(T) || total_moles < 10)
		return FALSE
	var/datum/ai_os/os_using = GLOB.ai_os[z]

	if(core_temp > os_using.get_temp_limit())
		return FALSE
	return TRUE

/obj/machinery/ai/proc/has_power()
	return !(machine_stat & (NOPOWER))

/obj/machinery/ai/proc/get_holder_status()
	if(machine_stat & (BROKEN|NOPOWER|EMPED))
		return FALSE

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	if(!env)
		return AI_MACHINE_NO_MOLES
	var/total_moles = env.total_moles()
	if(istype(T, /turf/open/space) || total_moles < 10)
		return AI_MACHINE_NO_MOLES

	var/datum/ai_os/os_using = GLOB.ai_os[z]
	if(core_temp > os_using.get_temp_limit())
		return AI_MACHINE_TOO_HOT

#undef AI_MACHINE_TOO_HOT
#undef AI_MACHINE_NO_MOLES
