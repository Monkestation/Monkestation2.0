/obj/machinery/ai/server_cabinet
	name = "Server Cabinet"
	desc = "A simple cabinet of bPCIe slots for installing server racks."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "expansion_bus"
	base_icon_state = "expansion_bus"

	circuit = /obj/item/circuitboard/machine/server_cabinet

	//Idle power usage when no cards inserted. Not free running idle my friend
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.01
	//We manually calculate how power the cards + CPU give, so this is accounted for by that
	active_power_usage = 0

	var/list/installed_racks = list()

	var/total_cpu = 0
	var/total_ram = 0

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
	linked_os.update_hardware()
	RefreshParts()
	update_appearance()
	register_context()

/obj/machinery/ai/server_cabinet/Destroy(force)
	installed_racks.Cut()
	//Recalculate all the CPUs and RAM :)
	linked_os.update_hardware()
	linked_os = null
	return ..()

/obj/machinery/ai/server_cabinet/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	var/datum/ai_os/old_os = GLOB.ai_os["[old_turf.z]"]
	. = ..()
	old_os.update_hardware()

/obj/machinery/ai/server_cabinet/RefreshParts()
	. = ..()
	var/new_heat_mod = 1
	var/new_power_mod = 1
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		new_power_mod -= (capacitor.tier - 1) / 40 //Max -15% at tier 4 parts, min -0% at tier 1

	for(var/datum/stock_part/matter_bin/bin in component_parts)
		new_heat_mod -= (bin.tier - 1) / 30 //Max -20% at tier 4 parts, min -0% at tier 1
	//68% total heat reduction in total at tier 4

	heat_modifier = new_heat_mod
	power_modifier = new_power_mod

	idle_power_usage = initial(idle_power_usage) * power_modifier

/obj/machinery/ai/server_cabinet/examine(mob/user)
	. = ..()
	var/holder_status = get_holder_status()
	if(holder_status)
		. += span_warning("Machinery non-functional. Reason: [holder_status]")
	if(!valid_ticks)
		. += span_notice("A small screen is displaying the words 'OFFLINE.'")
	. += span_notice("The machine has [length(installed_racks)] racks out of a maximum of [max_racks] installed.")
	. += span_notice("Current Power Usage Multiplier: [span_bold("[power_modifier * 100]%")]")
	. += span_notice("Current Heat Multiplier: [span_bold("[heat_modifier * 100]%")]")

	for(var/obj/item/server_rack/R as anything in installed_racks)
		. += span_notice("There is a rack installed with a processing capacity of [R.get_cpu()]THz and a memory capacity of [R.get_ram()]TB. Uses [R.get_power_usage()]W")
	. += span_notice("Use a crowbar to remove all currently inserted racks.")

/obj/machinery/ai/server_cabinet/process(seconds_per_tick)
	valid_ticks = clamp(valid_ticks, 0, MAX_AI_EXPANSION_TICKS)
	if(valid_holder())
		valid_ticks++
		if(!was_valid_holder)
			update_appearance()
		was_valid_holder = TRUE

		if(!hardware_synced)
			linked_os.update_hardware()
			hardware_synced = TRUE
	else
		valid_ticks--
		if(was_valid_holder)
			if(valid_ticks > 0)
				return
			was_valid_holder = FALSE
			cut_overlays()
			hardware_synced = FALSE
			linked_os.update_hardware()

/obj/machinery/ai/server_cabinet/process_atmos()
	. = ..()
	if(!.)
		return FALSE
	if(!valid_holder())
		return FALSE
	var/total_usage = (cached_power_usage * power_modifier)
	use_energy(total_usage)
	var/temperature_increase = (total_usage / AI_HEATSINK_CAPACITY)* heat_modifier
	core_temp += temperature_increase * AI_TEMPERATURE_MULTIPLIER
	return TRUE

/obj/machinery/ai/server_cabinet/update_overlays()
	. = ..()
	if(length(installed_racks) > 0)
		. += mutable_appearance(icon, "[base_icon_state]_top")
	if(length(installed_racks) > 1)
		. += mutable_appearance(icon, "[base_icon_state]_bottom")

	if(machine_stat & (BROKEN|NOPOWER|EMPED))
		return .

	. += mutable_appearance(icon, "[base_icon_state]_on")
	if(!valid_ticks)
		return
	if(length(installed_racks) > 0)
		. += mutable_appearance(icon, "[base_icon_state]_top_on")
	if(length(installed_racks) > 1)
		. += mutable_appearance(icon, "[base_icon_state]_bottom_on")

/obj/machinery/ai/server_cabinet/valid_holder()
	. = ..()
	//if you have no racks, you generate no heat.
	if(!length(installed_racks))
		return FALSE
	return .

/obj/machinery/ai/server_cabinet/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/server_rack))
		install_rack(user, tool)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/server_cabinet/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(length(installed_racks))
		balloon_alert(user, "remove racks!")
		return .
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_o", base_icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/server_cabinet/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(remove_racks(user))
		tool.play_tool_sound(src, 50)
		return ITEM_INTERACT_SUCCESS
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/server_cabinet/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[(panel_open ? "Close" : "Open")] Panel"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/server_rack))
		context[SCREENTIP_CONTEXT_LMB] = "Insert Rack"
		return CONTEXTUAL_SCREENTIP_SET
	if(panel_open && (held_item.tool_behaviour == TOOL_CROWBAR))
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/ai/server_cabinet/proc/install_rack(mob/living/user, obj/item/server_rack/new_rack)
	if(length(installed_racks) >= max_racks)
		if(user)
			balloon_alert(user, "doesn't fit!")
		return FALSE
	if(user)
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
		balloon_alert(user, "installed rack")
	new_rack.forceMove(src)
	LAZYADD(installed_racks, new_rack)
	total_cpu += new_rack.get_cpu()
	total_ram += new_rack.get_ram()
	cached_power_usage += new_rack.get_power_usage()
	linked_os.update_hardware()
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
	linked_os.update_hardware()
	if(user)
		balloon_alert(user, "racks removed")
	use_power = IDLE_POWER_USE
	update_appearance()
	return TRUE

/obj/machinery/ai/server_cabinet/prefilled/Initialize(mapload)
	. = ..()
	install_rack(new_rack = new /obj/item/server_rack/roundstart(src))
