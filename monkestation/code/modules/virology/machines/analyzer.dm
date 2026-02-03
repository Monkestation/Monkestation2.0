/obj/machinery/disease2/diseaseanalyser
	name = "disease analyzer"
	desc = "For analysing pathogenic dishes of sufficient growth."
	icon = 'monkestation/code/modules/virology/icons/virology.dmi'
	icon_state = "analyser"
	anchored = TRUE
	density = TRUE
	light_color = "#6496FA"
	light_outer_range = 2
	light_power = 1

	circuit = /obj/item/circuitboard/machine/diseaseanalyser

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.1 //1000 extra power once per analysis

	var/process_time = 5
	var/minimum_growth = 100
	var/obj/item/weapon/virusdish/dish = null
	var/last_scan_name = ""
	var/last_scan_info = ""

	var/processing = FALSE
	/// Reference to the mob that is currently scanning whatever virus is inserted
	var/mob/scanner = null

/obj/machinery/disease2/diseaseanalyser/RefreshParts()
	. = ..()
	var/scancount = 0
	for(var/datum/stock_part/scanning_module/M in component_parts)
		scancount += M.tier
	minimum_growth = round((initial(minimum_growth) - (scancount * 6)))

/obj/machinery/disease2/diseaseanalyser/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(machine_stat & (BROKEN))
		to_chat(user, span_warning("\The [src] is broken. Some components will have to be replaced before it can work again."))
		return NONE

	if(scanner)
		to_chat(user, span_warning("\The [scanner] is currently busy using this analyzer."))
		return ITEM_INTERACT_BLOCKING

	if(dish)
		if(isvirusdish(tool))
			to_chat(user, span_warning("There is already a dish in there. Alt+Click or perform the analysis to retrieve it first."))
			return ITEM_INTERACT_BLOCKING
		if(is_reagent_container(tool))
			// If you click on the machine with a reagent container, you can interact directly with the dish
			return dish.item_interaction(user, tool, modifiers)

	// There's no dish so lets insert one
	if(!isvirusdish(tool))
		return NONE

	var/obj/item/weapon/virusdish/inserting_dish = tool
	if(!inserting_dish.open)
		to_chat(user, span_warning("You must open the dish's lid before it can be analysed. Be sure to wear proper protection first (at least a sterile mask and latex gloves)."))
		return ITEM_INTERACT_BLOCKING
	visible_message(span_notice("\The [user] inserts \the [tool] in \the [src]."),
					span_notice("You insert \the [tool] in \the [src]."))
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	user.dropItemToGround(tool, TRUE)
	tool.forceMove(src)
	dish = tool
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/disease2/diseaseanalyser/attack_hand(mob/user)
	. = ..()
	if(machine_stat & (BROKEN))
		to_chat(user, span_notice("\The [src] is broken. Some components will have to be replaced before it can work again."))
		return
	if(machine_stat & (NOPOWER))
		to_chat(user, span_notice("Deprived of power, \the [src] is unresponsive."))
		if(dish)
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			dish.forceMove(loc)
			dish = null
			update_appearance()
		return

	if(.)
		return

	if(scanner)
		to_chat(user, span_warning("\The [scanner] is currently busy using this analyzer."))
		return

	if(!dish)
		to_chat(user, span_notice("Place an open growth dish first to analyse its pathogen."))
		return

	if(dish.growth < minimum_growth)
		say("Pathogen growth insufficient. Minimal required growth: [minimum_growth]%.")
		to_chat(user,span_notice("Add some virus food to the dish and incubate."))
		if(minimum_growth == 100)
			to_chat(user,span_notice("Replacing the machine's scanning modules with better parts will lower the growth requirement."))
		dish.forceMove(loc)
		dish = null
		update_appearance()
		return

	scanner = user
	icon_state = "analyzer_processing"
	processing = TRUE
	update_appearance()

	spawn (1)
		var/mutable_appearance/I = mutable_appearance(icon,"analyser_light",src)
		I.plane = ABOVE_LIGHTING_PLANE
		add_overlay(I)
	use_energy(1000)
	set_light(2,2)
	playsound(src, 'sound/machines/chime.ogg', 50)

	if(do_after(user, 5 SECONDS, src))
		if(machine_stat & (BROKEN|NOPOWER))
			processing = FALSE // Make sure to return the machine to normal operation if power outage
			update_appearance()
			scanner = null
			return
		if(!istype(dish.contained_virus, /datum/disease/acute))
			QDEL_NULL(dish)
			say("ERROR:Bad Pathogen detected PURGING")
			processing = FALSE // Make sure to return the machine to normal operation after purge
			update_appearance()
			scanner = null
			return
		if(dish.contained_virus.addToDB())
			say("Added new pathogen to database.")
		var/datum/data/record/v = GLOB.virusDB["[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]"]
		dish.info = dish.contained_virus.get_info()
		dish.update_desc()
		last_scan_name = dish.contained_virus.name(TRUE)
		if(v)
			last_scan_name += v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""

		dish.name = "growth dish ([last_scan_name])"
		last_scan_info = dish.info
		dish.contained_virus.Refresh_Acute()
		var/datum/browser/popup = new(user, "\ref[dish]", dish.name, 600, 500, src)
		popup.set_content(dish.info)
		popup.open()
		dish.analysed = TRUE
		dish.contained_virus.disease_flags |= DISEASE_ANALYZED
		dish.update_appearance()
		dish.forceMove(loc)
		dish = null
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25)

	processing = FALSE
	update_appearance()
	scanner = null

/obj/machinery/disease2/diseaseanalyser/update_icon()
	. = ..()
	icon_state = "analyser"
	if(processing)
		icon_state = "analyzer-processing"

	if(machine_stat & (NOPOWER))
		icon_state = "analyser0"

	if(machine_stat & (BROKEN))
		icon_state = "analyserb"

	if(machine_stat & (BROKEN|NOPOWER))
		set_light(0)
	else
		set_light(2,1)


/obj/machinery/disease2/diseaseanalyser/update_overlays()
	. = ..()
	if(processing)
		. += emissive_appearance(icon, "analyzer-processing-emissive", src)

		. += mutable_appearance(icon,"analyser_light",src)
		. += emissive_appearance(icon,"analyser_light",src)

	. += emissive_appearance(icon, "analyzer-emissive", src)
	if(dish)
		.+= mutable_appearance(icon, "smalldish-outline",src)
		if(dish.contained_virus)
			var/mutable_appearance/I = mutable_appearance(icon,"smalldish-color",src)
			I.color = dish.contained_virus.color
			.+= I
		else
			.+= mutable_appearance(icon, "smalldish-empty",src)

/obj/machinery/disease2/diseaseanalyser/verb/PrintPaper()
	set name = "Print last analysis"
	set category = "Object"
	set src in oview(1)

	if(!usr || !isturf(usr.loc))
		return

	if(machine_stat & (BROKEN))
		to_chat(usr, span_notice("\The [src] is broken. Some components will have to be replaced before it can work again."))
		return
	if(machine_stat & (NOPOWER))
		to_chat(usr, span_notice("Deprived of power, \the [src] is unresponsive."))
		return

	var/turf/T = get_turf(src)
	playsound(T, "sound/effects/fax.ogg", 50, 1)
	var/image/paper = image(icon, src, "analyser-paper")
	flick_overlay_global(paper, GLOB.clients, 3 SECONDS)
	visible_message("\The [src] prints a sheet of paper.")
	spawn(1 SECONDS)
		var/obj/item/paper/P = new(T)
		P.name = last_scan_name
		P.add_raw_text(last_scan_info)
		P.pixel_x = 8
		P.pixel_y = -8
		P.update_appearance()

/obj/machinery/disease2/diseaseanalyser/process()
	if(machine_stat & (NOPOWER|BROKEN))
		scanner = null
		return

	if(scanner && !(scanner in range(src,1)))
		update_appearance()
		processing = FALSE
		scanner = null

/obj/machinery/disease2/diseaseanalyser/click_alt(mob/user)
	if(!dish && scanner)
		return CLICK_ACTION_BLOCKING
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	dish.forceMove(loc)
	dish = null
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/machinery/disease2/diseaseanalyser/fullupgrade
	circuit = /obj/item/circuitboard/machine/diseaseanalyser/fullupgrade


/obj/machinery/disease2/diseaseanalyser/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(processing)
		to_chat(user, span_warning("\The [src] is currently processing! Please wait for process to finish"))
		return FALSE
	return default_deconstruction_screwdriver(user, "analyseru", "analyser", I)

/obj/machinery/disease2/diseaseanalyser/crowbar_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(processing)
		to_chat(user, span_warning("\The [src] is currently processing! Please wait until completion."))
		return FALSE
	return default_deconstruction_crowbar(I)


/obj/machinery/disease2/diseaseanalyser/attack_ai(mob/user)
	if(!panel_open)
		return attack_hand(user)

/obj/machinery/disease2/diseaseanalyser/attack_robot(mob/user)
	return attack_ai(user)
