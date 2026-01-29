#define REMOVE_TC "Remove Telecrystals"

/obj/machinery/gang_machine/fabricator
	desc = "A machine with what look to be parts for assembling something."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader-corner"
	circuit = /obj/item/circuitboard/machine/gang_fabricator
	extra_examine_text = span_syndradio("A machine that can fabricate various items from inserted telecrystals.")
	setup_tc_cost = 10
	///Static assoc list of all our fabrication design datums
	var/static/list/designs_by_name = list()
	///How much TC do we currently have stored
	var/stored_tc = 0

/obj/machinery/gang_machine/fabricator/Initialize(mapload, gang)
	. = ..()
	if(!length(designs_by_name))
		for(var/datum/gang_fabricator_design/design as anything in subtypesof(/datum/gang_fabricator_design))
			if(!initial(design.name) || !initial(design.cost))
				continue

			design = new design()
			designs_by_name[design.name] = design
		designs_by_name[REMOVE_TC] = 1

/obj/machinery/gang_machine/fabricator/deconstruct(disassembled)
	. = ..()
	if(!. || !stored_tc)
		return

	new /obj/item/stack/telecrystal(get_turf(src), stored_tc)

/obj/machinery/gang_machine/fabricator/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	var/datum/antagonist/gang_member/member_datum = IS_GANGMEMBER(user)
	if(!member_datum)
		balloon_alert(user, "you can't figure out how to use [src].")
		return

	if(!(IS_IN_GANG(user, owner)))
		balloon_alert(user, "\the [src] rejects you.")
		return

	if(!stored_tc)
		balloon_alert(user, "no stored Telecrystals.")
		return

	var/datum/gang_fabricator_design/selected_design = tgui_input_list(user, "Select a design to fabricate", "Fabricator", designs_by_name)
	if(!selected_design)
		return

	if(selected_design == REMOVE_TC)
		var/selected_amount = tgui_input_number(user, "How many Telecrystals do you want to remove?", "Fabricator", max_value = stored_tc, min_value = 0, round_value = TRUE)
		if(selected_amount)
			new /obj/item/stack/telecrystal(get_turf(src), selected_amount)
			stored_tc -= selected_amount
		return

	selected_design = designs_by_name[selected_design]
	if(selected_design.required_rank > member_datum.rank)
		balloon_alert(user, "you do not meet the rank required to produce this")
		return

	var/cost = selected_design.get_cost(owner)
	var/input = tgui_alert(user, "Are you sure you want to fabricate [selected_design.name] for [cost] Telecrystal[cost == 1 ? "" : "s"]?", "Fabricator", list("Yes", "No"))
	if(input == "Yes")
		if(stored_tc >= cost)
			selected_design.fabricate(src, owner, cost)
			stored_tc -= cost
			balloon_alert(user, "fabricated [selected_design.name].")
			return
		balloon_alert(user, "not enough stored Telecrystals.")

/obj/machinery/gang_machine/fabricator/attackby(obj/item/weapon, mob/user, params)
	if(setup && istype(weapon, /obj/item/stack/telecrystal))
		var/obj/item/stack/telecrystal/tc = weapon
		stored_tc += tc.amount
		balloon_alert(user, "inserted [tc.amount] telecrystals.")
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
	///What rank is needed to create this item
	var/required_rank = GANG_RANK_MEMBER

/datum/gang_fabricator_design/proc/get_cost(datum/team/gang/owner)
	return cost

/datum/gang_fabricator_design/proc/fabricate(obj/machinery/gang_machine/fabricator/create_at, datum/team/gang/created_for, real_cost = get_cost(created_for))
	if(fabrication_type && create_at)
		var/turf/creation_turf = get_turf(create_at)
		if(islist(fabrication_type))
			for(var/type in fabrication_type)
				create_item(type, creation_turf)
			return
		create_item(fabrication_type, creation_turf)

/datum/gang_fabricator_design/proc/create_item(created_type, turf/create_at, datum/team/gang/created_for)
	return new created_type(create_at)

/datum/gang_fabricator_design/gang_implant
	name = "Gangmember Implant"
	cost = 4
	fabrication_type = list(/obj/item/toy/crayon/spraycan/gang, /obj/item/implanter/uplink/gang)

/datum/gang_fabricator_design/gang_implant/get_cost(datum/team/gang/owner)
	if(!owner || length(owner.members) <= cost)
		return cost

	var/calculated_cost = 0
	for(var/datum/mind/member_mind in owner.members)
		if(!member_mind.current)
			continue

		if(member_mind.current.stat == DEAD)
			calculated_cost += 0.5
			continue
		calculated_cost++
	return max(cost, trunc(calculated_cost)) //each living member increases cost by 1 TC and each dead member by 0.5, cost only starts to scale after you have more members then base cost

/datum/gang_fabricator_design/gang_implant/create_item(created_type, turf/create_at, datum/team/gang/created_for)
	var/obj/item/implanter/uplink/gang/implant = ..()
	created_for?.track_implant(implant)

/datum/gang_fabricator_design/lieutenant_promoter
	name = "Lieutenant Promoter"
	cost = 10
	fabrication_type = /obj/item/gang_device/promoter

/datum/gang_fabricator_design/boss_promoter
	name = "Boss Promoter"
	cost = 20
	fabrication_type = /obj/item/gang_device/promoter/boss
	required_rank = GANG_RANK_LIEUTENANT

/datum/gang_fabricator_design/leader_pinpointer
	name = "Leader Pinpointer"
	cost = 5
	fabrication_type = /obj/item/pinpointer/gang_leader
	required_rank = GANG_RANK_LIEUTENANT

/datum/gang_fabricator_design/leader_pinpointer/create_item(created_type, turf/create_at, datum/team/gang/created_for)
	var/obj/item/pinpointer/gang_leader/pinpointer = ..()
	pinpointer.linked_to = created_for

#undef REMOVE_TC
