///Assoc list of ["z_level"] = ai_os
GLOBAL_LIST_EMPTY(ai_os)

/datum/ai_os
	var/name = "Decentralized Resource Management System (DRMS)"

	var/total_cpu = 0
	var/total_ram = 0

	var/previous_ram = 0

	var/list/cpu_assigned
	var/list/ram_assigned

	var/temp_limit = AI_TEMP_LIMIT

	var/list/obj/machinery/ai/server_cabinet/cabinets = list()
	var/list/mob/living/silicon/ai/ai_list = list()

/datum/ai_os/New(obj/machinery/ai/data_core/creator)
	update_list(creator)
	update_hardware()
	cpu_assigned = list()
	ram_assigned = list()

//Taken from gravity generator
/datum/ai_os/proc/update_list(obj/machinery/ai/data_core/creator)
	var/turf/creator_turf = get_turf(creator)
	if(!creator_turf)
		return
	var/list/z_list = list()
	// take multi-z into account.
	if(SSmapping.level_trait(creator_turf.z, ZTRAIT_STATION))
		for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
			z_list += z
	else
		z_list += creator_turf.z

	for(var/z in z_list)
		if(QDELETED(src))
			LAZYREMOVE(GLOB.ai_os["[z]"], src)
		else
			LAZYADD(GLOB.ai_os["[z]"], src)

/datum/ai_os/proc/add_ai(mob/living/silicon/ai/AI)
	if(AI in ai_list)
		return
	ai_list |= AI
	RegisterSignal(AI, COMSIG_QDELETING, PROC_REF(on_ai_deleted))

/datum/ai_os/proc/remove_ai(mob/living/silicon/ai/AI)
	cpu_assigned.Remove(AI)
	ram_assigned.Remove(AI)
	update_allocations()

/datum/ai_os/proc/on_ai_deleted(datum/source)
	SIGNAL_HANDLER
	remove_ai(source)

/datum/ai_os/proc/total_cpu_assigned()
	var/total = 0
	for(var/N in cpu_assigned)
		total += cpu_assigned[N]
	return total

/datum/ai_os/proc/total_ram_assigned()
	var/total = 0
	for(var/mob/living/silicon/ai/AI in ram_assigned)
		total += (ram_assigned[AI] - AI.dashboard.free_ram)
	return total

/datum/ai_os/proc/update_hardware()
	previous_ram = total_ram
	total_ram = 0
	total_cpu = 0
	for(var/obj/machinery/ai/server_cabinet/C as anything in SSmachines.get_machines_by_type(/obj/machinery/ai/server_cabinet))
		if(!C.valid_holder() && !C.roundstart)
			continue
		total_ram += C.total_ram
		total_cpu += C.total_cpu

	update_allocations()

/datum/ai_os/proc/update_allocations()
	//Do we have the same amount or more RAM than before? Do nothing
	if(total_ram >= previous_ram)
		return

	//Find out how much is actually assigned. We can have more total_cpu than the sum of cpu_assigned. Same with RAM
	var/total_assigned_ram = total_ram_assigned()
	//If we have less assigned  ram than we have cpu and ram, just return, everything is fine.
	if(total_assigned_ram < total_ram)
		return

	//Copy the lists of assigned resources so we don't manipulate the list prematurely.
	var/list/ram_assigned_copy = ram_assigned.Copy()

	//List of touched AIs so we can notify them at the end.
	var/list/affected_AIs = list()

	if(total_assigned_ram > total_ram)
		var/needed_amount = total_assigned_ram - total_ram
		for(var/A in ram_assigned_copy)
			var/mob/living/silicon/ai/AI = A
			if((ram_assigned_copy[AI] - AI.dashboard.free_ram) >= needed_amount)
				ram_assigned_copy[AI] -= needed_amount
				total_assigned_ram -= needed_amount
				affected_AIs |= AI
				break
			else if(ram_assigned_copy[AI])
				var/amount = ram_assigned_copy[AI] - AI.dashboard.free_ram
				ram_assigned_copy[AI] -= amount
				affected_AIs |= AI
				needed_amount -= amount
				total_assigned_ram -= amount
				if(total_ram >= total_assigned_ram)
					break
	//Set the actual values of the assigned to our manipulated copies. Bypass helper procs as we assume we're correct.
	ram_assigned = ram_assigned_copy

	to_chat(affected_AIs, span_warning("You have been deducted processing capabilities. Please contact your network administrator if you believe this to be an error."))

/datum/ai_os/proc/set_cpu(mob/living/silicon/ai/AI, amount)
	if(!AI)
		return
	if(amount < 0)
		return
	if(!istype(AI))
		return
	//total cpu - (current AIs CPU + CPU we're giving) > total_cpu
	if(total_cpu_assigned() - (cpu_assigned[AI] + amount) > total_cpu)
		return
	cpu_assigned[AI] = amount
	update_allocations()

/datum/ai_os/proc/add_ram(mob/living/silicon/ai/AI, amount)
	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	ram_assigned[AI] += amount

	update_allocations()

/datum/ai_os/proc/remove_ram(mob/living/silicon/ai/AI, amount)
	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	if(ram_assigned[AI] - amount < 0)
		ram_assigned[AI] = 0
	else
		ram_assigned[AI] -= amount

	update_allocations()

/datum/ai_os/proc/clear_ai_resources(mob/living/silicon/ai/AI)
	if(!AI || !istype(AI))
		return

	remove_ram(AI, ram_assigned[AI])
	cpu_assigned[AI] = 0

	update_allocations()

/datum/ai_os/proc/get_temp_limit()
	return temp_limit
