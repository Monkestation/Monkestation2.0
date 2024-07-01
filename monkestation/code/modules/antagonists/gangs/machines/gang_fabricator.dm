/obj/machinery/gang_machine/fabricator
	desc = "A machine with what look to be parts for assembling something."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader-corner"
	circuit = /obj/item/circuitboard/machine/gang_fabricator
	extra_examine_text = span_syndradio("A machine that can fabricate various items from inserted telecrystals.")
	setup_tc_cost = 10
	///Static assoc list of all our fabrication design datums
	var/static/list/designs_by_name
	///How much TC do we currently have stored
	var/stored_tc = 0

/obj/machinery/gang_machine/fabricator/Initialize(mapload, gang)
	. = ..()
	if(!designs_by_name)
		designs_by_name = list()
		for(var/datum/gang_fabricator_design/design as anything in subtypesof(/datum/gang_fabricator_design))
			if(!initial(design.name) || !initial(design.cost))
				continue

			design = new design()
			designs_by_name[design.name] = design

/obj/machinery/gang_machine/fabricator/deconstruct(disassembled)
	. = ..()
	if(!. || !stored_tc)
		return

	new /obj/item/stack/telecrystal(get_turf(src), stored_tc)

/obj/machinery/gang_machine/fabricator/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!IS_GANGMEMBER(user))
		balloon_alert(user, "You can't figure out how to use [src].")
		return

	if(!(IS_IN_GANG(user, owner)))
		balloon_alert(user, "\The [src] rejects you.")
		return

	if(!stored_tc)
		balloon_alert(user, "No stored Telecrystals.")
		return

	var/datum/gang_fabricator_design/selected_design = tgui_input_list(user, "Select a design to fabricate", "Fabricator", designs_by_name + list("Remove Telecrystals" = 1))
	if(!selected_design)
		return

	if(selected_design == "Remove Telecrystals")
		var/selected_amount = tgui_input_number(user, "How many Telecrystals do you want to remove?", "Fabricator", max_value = stored_tc, min_value = 0, round_value = TRUE)
		if(selected_amount)
			new /obj/item/stack/telecrystal(get_turf(src), selected_amount)
			stored_tc -= selected_amount
		return

	selected_design = designs_by_name[selected_design]
	var/cost = selected_design.get_cost(src)
	var/input = tgui_alert(user, "Are you sure you want to fabricate [selected_design.name] for [cost] Telecrystal[cost == 1 ? "" : "s"]?", "Fabricator", list("Yes", "No"))
	if(input == "Yes")
		if(stored_tc >= cost)
			selected_design.fabricate(src, cost)
			stored_tc -= cost
			balloon_alert(user, "Fabricated [selected_design.name].")
			return
		balloon_alert(user, "Not enough stored Telecrystals.")

/obj/machinery/gang_machine/fabricator/attackby(obj/item/weapon, mob/user, params)
	if(setup && istype(weapon, /obj/item/stack/telecrystal))
		var/obj/item/stack/telecrystal/tc = weapon
		stored_tc += tc.amount
		balloon_alert(user, "Inserted [tc.amount] telecrystals.")
		qdel(tc)
		return
	return ..()

/obj/item/circuitboard/machine/gang_fabricator
	name = "Suspicious Circuitboard"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/gang_machine/fabricator

/datum/gang_fabricator_design
	///Our name
	var/name
	///What is our base cost
	var/cost = 0
	///Type of object to create, can also be a list
	var/fabrication_type

/datum/gang_fabricator_design/proc/get_cost(obj/machinery/gang_machine/fabricator/passed_fabricator)
	return cost

/datum/gang_fabricator_design/proc/fabricate(obj/machinery/gang_machine/fabricator/create_at, real_cost = get_cost())
	if(fabrication_type && create_at)
		var/turf/creation_turf = get_turf(create_at)
		if(islist(fabrication_type))
			for(var/type in fabrication_type)
				new type(creation_turf)
			return
		new fabrication_type(creation_turf)

/datum/gang_fabricator_design/gang_implant
	name = "Gangmember Implant"
	cost = 4
	fabrication_type = list(/obj/item/toy/crayon/spraycan/gang, /obj/item/implanter/uplink/gang)

/datum/gang_fabricator_design/gang_implant/get_cost(obj/machinery/gang_machine/fabricator/passed_fabricator)
	if(!passed_fabricator?.owner || length(passed_fabricator.owner.members) <= cost)
		return cost

	var/calculated_cost = 0
	for(var/datum/mind/member_mind in passed_fabricator.owner.members)
		if(!member_mind.current)
			continue

		if(member_mind.current.stat == DEAD)
			calculated_cost += 0.5
			continue
		calculated_cost++
	return max(cost, trunc(calculated_cost)) //each living member increases cost by 1 TC and each dead member by 0.5, cost only starts to scale after you have more members then base cost

/datum/gang_fabricator_design/boss_implant
	name = "Boss Implant"
	cost = 20
	fabrication_type = /obj/item/implanter/uplink/gang/boss/fabricated

/datum/gang_fabricator_design/lieutenant_implant
	name = "Lieutenant Implant"
	cost = 10
	fabrication_type = /obj/item/implanter/uplink/gang/lieutenant/fabricated
