GLOBAL_LIST_EMPTY(server_cabinets)

/obj/machinery/ai/server_cabinet
	name = "Server Cabinet"
	desc = "A simple cabinet of bPCIe slots for installing server racks."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "expansion_bus"
	base_icon_state = "expansion_bus"

	circuit = /obj/item/circuitboard/machine/server_cabinet

	var/list/installed_racks

	var/total_cpu = 0
	var/total_ram = 0
	//Idle power usage when no cards inserted. Not free running idle my friend
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.01
	//We manually calculate how power the cards + CPU give, so this is accounted for by that
	active_power_usage = 0

	var/cached_power_usage = 0

	var/max_racks = 2

	var/hardware_synced = FALSE

	var/was_valid_holder = FALSE
	//Atmos hasn't run at the start so this has to be set to true if you map it in
	var/roundstart = FALSE
	///How many ticks we can go without fulfilling the criteria before shutting off
	var/valid_ticks = MAX_AI_EXPANSION_TICKS
	///Heat production multiplied by this
	var/heat_modifier = 1
	///Power modifier, power modified by this. Be aware this indirectly changes heat since power => heat
	var/power_modifier = 1


/obj/machinery/ai/server_cabinet/Initialize(mapload)
	. = ..()
	roundstart = mapload
	installed_racks = list()
	GLOB.server_cabinets += src
	RefreshParts()
	update_appearance()

/obj/machinery/ai/server_cabinet/Destroy()
	installed_racks = list()
	GLOB.server_cabinets -= src
	//Recalculate all the CPUs and RAM :)
	GLOB.ai_os.update_hardware()
	return ..()

/obj/machinery/ai/server_cabinet/RefreshParts()
	. = ..()
	var/new_heat_mod = 1
	var/new_power_mod = 1
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		new_power_mod -= (C.rating - 1) / 40 //Max -15% at tier 4 parts, min -0% at tier 1

	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		new_heat_mod -= (M.rating - 1) / 30 //Max -20% at tier 4 parts, min -0% at tier 1
	//68% total heat reduction in total at tier 4

	heat_modifier = new_heat_mod
	power_modifier = new_power_mod

	idle_power_usage = initial(idle_power_usage) * power_modifier

/obj/machinery/ai/server_cabinet/process_atmos()
	valid_ticks = clamp(valid_ticks, 0, MAX_AI_EXPANSION_TICKS)
	if(valid_holder())
		var/total_usage = (cached_power_usage * power_modifier)
		use_energy(total_usage)

		var/turf/T = get_turf(src)
		var/datum/gas_mixture/env = T.return_air()
		if(env.heat_capacity())
			var/temperature_increase = (total_usage / env.heat_capacity()) * heat_modifier //1 CPU = 1000W. Heat capacity = somewhere around 3000-4000. Aka we generate 0.25 - 0.33 K per second, per CPU.
			env.temperature_share(null, OPEN_HEAT_TRANSFER_COEFFICIENT, env.return_temperature() + temperature_increase * AI_TEMPERATURE_MULTIPLIER) //assume all input power is dissipated
			T.air_update_turf()

		valid_ticks++
		if(!was_valid_holder)
			update_appearance()
		was_valid_holder = TRUE

		if(!hardware_synced)
			GLOB.ai_os.update_hardware()
			hardware_synced = TRUE
	else
		valid_ticks--
		if(was_valid_holder)
			if(valid_ticks > 0)
				return
			was_valid_holder = FALSE
			cut_overlays()
			hardware_synced = FALSE
			GLOB.ai_os.update_hardware()


/obj/machinery/ai/server_cabinet/update_overlays()
	. = ..()
	if(installed_racks.len > 0)
		. += mutable_appearance(icon, "[base_icon_state]_top")
	if(installed_racks.len > 1)
		. += mutable_appearance(icon, "[base_icon_state]_bottom")
	if(!(machine_stat & (BROKEN|NOPOWER|EMPED)))
		. += mutable_appearance(icon, "[base_icon_state]_on")
		if(!valid_ticks)
			return
		if(installed_racks.len > 0)
			. += mutable_appearance(icon, "[base_icon_state]_top_on")
		if(installed_racks.len > 1)
			. += mutable_appearance(icon, "[base_icon_state]_bottom_on")

/obj/machinery/ai/server_cabinet/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/server_rack))
		install_rack(user, W)
		return FALSE
	if(W.tool_behaviour == TOOL_CROWBAR)
		if(remove_racks(user))
			return FALSE
		else if(default_deconstruction_crowbar(W))
			return TRUE

	if(default_deconstruction_screwdriver(user, "[base_icon_state]_o", base_icon_state, W))
		return TRUE

	return ..()

/obj/machinery/ai/server_cabinet/proc/install_rack(mob/living/user, obj/item/server_rack/new_rack)
	if(installed_racks.len >= max_racks)
		if(user)
			to_chat(user, span_warning("[src] cannot fit [new_rack]!"))
		return FALSE
	if(user)
		to_chat(user, span_notice("You install [new_rack] into [src]."))
	new_rack.forceMove(src)
	LAZYADD(installed_racks, new_rack)
	total_cpu += new_rack.get_cpu()
	total_ram += new_rack.get_ram()
	cached_power_usage += new_rack.get_power_usage()
	GLOB.ai_os.update_hardware()
	use_power = ACTIVE_POWER_USE
	update_appearance()
	return TRUE

/obj/machinery/ai/server_cabinet/proc/remove_racks(mob/living/user)
	if(!length(installed_racks))
		return FALSE
	var/turf/turf_dropped = drop_location()
	for(var/obj/item/server_rack/rack as anything in installed_racks)
		rack.forceMove(turf_dropped)
		LAZYREMOVE(installed_racks, rack)
	total_cpu = 0
	total_ram = 0
	cached_power_usage = 0
	GLOB.ai_os.update_hardware()
	if(user)
		to_chat(user, span_notice("You remove all the racks from [src]"))
	use_power = IDLE_POWER_USE
	update_appearance()
	return TRUE

/obj/machinery/ai/server_cabinet/examine()
	. = ..()
	var/holder_status = get_holder_status()
	if(holder_status)
		. += span_warning("Machinery non-functional. Reason: [holder_status]")
	if(!valid_ticks)
		. += span_notice("A small screen is displaying the words 'OFFLINE.'")
	. += span_notice("The machine has [installed_racks.len] racks out of a maximum of [max_racks] installed.")
	. += span_notice("Current Power Usage Multiplier: [span_bold("[power_modifier * 100]%")]")
	. += span_notice("Current Heat Multiplier: [span_bold("[heat_modifier * 100]%")]")

	for(var/obj/item/server_rack/R in installed_racks)
		. += span_notice("There is a rack installed with a processing capacity of [R.get_cpu()]THz and a memory capacity of [R.get_ram()]TB. Uses [R.get_power_usage()]W")
	. += span_notice("Use a crowbar to remove all currently inserted racks.")

/obj/machinery/ai/server_cabinet/prefilled/Initialize(mapload)
	. = ..()
	install_rack(new_rack = new /obj/item/server_rack/roundstart(src))
