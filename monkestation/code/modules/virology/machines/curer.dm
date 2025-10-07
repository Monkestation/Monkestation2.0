/obj/machinery/computer/curer
	name = "Cure Research Machine"
	icon_state = "dna"
	var/curing
	var/virusing

	var/obj/item/reagent_containers/cup/tube/container = null

/obj/machinery/computer/curer/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/reagent_containers/cup/tube))
		if(!container && tool.forceMove(src))
			container = tool
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING

	if(isvirusdish(tool))
		if(virusing)
			to_chat(user, "<b>The pathogen materializer is still recharging..")
			return ITEM_INTERACT_BLOCKING
		var/obj/item/reagent_containers/cup/tube/product = new(loc)
		var/list/data = list("viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"viruses"=list(),"immunity"=0)
		data["viruses"] |= tool:viruses
		product.reagents.add_reagent(/datum/reagent/blood, 30,data)
		virusing = 1
		spawn(1200) virusing = 0
		return ITEM_INTERACT_SUCCESS

	src.attack_hand(user)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/curer/attack_hand(mob/user)
	if(..())
		return
	var/dat
	if(curing)
		dat = "Antibody production in progress"
	else if(virusing)
		dat = "Virus production in progress"
	else if(container)
		// see if there's any blood in the container
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in container.reagents.reagent_list

		if(B)
			dat = "Blood sample inserted."
			var/code = ""
			for(var/V in GLOB.all_antigens) if(text2num(V) & B.data["antibodies"]) code += GLOB.all_antigens[V]
			dat += "<BR>Antibodies: [code]"
			dat += "<BR><A href='byond://?src=\ref[src];antibody=1'>Begin antibody production</a>"
		else
			dat += "<BR>Please check container contents."
		dat += "<BR><A href='byond://?src=\ref[src];eject=1'>Eject container</a>"
	else
		dat = "Please insert a container."

	user << browse(HTML_SKELETON(dat), "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/curer/process()
	..()

	if(machine_stat & (NOPOWER|BROKEN))
		return
	use_energy(500)

	if(curing)
		curing -= 1
		if(curing == 0)
			if(container)
				createcure(container)
	return

/obj/machinery/computer/curer/Topic(href, href_list)
	if(..())
		return
	usr.machine = src

	if (href_list["antibody"])
		curing = 10
	else if(href_list["eject"])
		container.forceMove(src.loc)
		container = null

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/curer/proc/createcure(obj/item/reagent_containers/cup/beaker/container)
	var/obj/item/reagent_containers/cup/tube/product = new(src.loc)

	var/datum/reagent/blood/B = locate() in container.reagents.reagent_list

	var/list/data = list()
	var/list/immunity = B.data["immunity"]
	if(length(immunity))
		data["antigen"] = immunity[2]

	product.reagents.add_reagent(/datum/reagent/vaccine, 30, data)
