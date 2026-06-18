GLOBAL_LIST_EMPTY(data_cores)
GLOBAL_VAR_INIT(primary_data_core, null)

#define CELL_POWERUSE_MULTIPLIER 0.025

/obj/machinery/ai/data_core
	name = "AI data core"
	desc = "A complicated computer system capable of emulating the neural functions of an organic being at near-instantanous speeds."
	icon = 'icons/obj/machines/ai_core.dmi'
	icon_state = "core-offline"
	base_icon_state = "core"

	circuit = /obj/item/circuitboard/machine/ai_data_core
	active_power_usage = AI_DATA_CORE_POWER_USAGE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 10
	use_power = IDLE_POWER_USE
	critical_machine = TRUE

	var/disableheat = FALSE
	var/primary = FALSE
	var/valid_ticks = MAX_AI_DATA_CORE_TICKS //Limited to MAX_AI_DATA_CORE_TICKS. Decrement by 1 every time we have an invalid tick, opposite when valid
	COOLDOWN_DECLARE(warning_cooldown)

	var/TimerID //party time
	//Heat production multiplied by this
	var/heat_modifier = 1
	//Power modifier, power modified by this. Be aware this indirectly changes heat since power => heat
	var/power_modifier = 1
	var/obj/item/stock_parts/power_store/cell/integrated_battery

/obj/machinery/ai/data_core/Initialize(mapload)
	. = ..()
	GLOB.data_cores += src
	if(primary && !GLOB.primary_data_core)
		GLOB.primary_data_core = src
	if(mapload)
		integrated_battery = new /obj/item/stock_parts/power_store/cell/high(src)
	RefreshParts()
	update_appearance()
	register_context()

/obj/machinery/ai/data_core/Destroy(force)
	GLOB.data_cores -= src
	if(GLOB.primary_data_core == src)
		GLOB.primary_data_core = null

	var/list/all_ais = GLOB.ai_list.Copy()

	for(var/mob/living/silicon/ai/AI in contents)
		if(AI.is_dying)
			continue
		if(!AI.is_dying)
			AI.relocate()

	for(var/mob/living/silicon/ai/AI in all_ais)
		if(!AI.mind && AI.deployed_shell.mind)
			to_chat(AI.deployed_shell, span_userdanger("Warning! Data Core brought offline in [get_area(src)]! Please verify that no malicious actions were taken."))
		else
			to_chat(AI, span_userdanger("Warning! <A HREF=?src=[REF(AI)];go_to_machine=[REF(src)]>Data Core</A> brought offline in [get_area(src)]! Please verify that no malicious actions were taken."))

	return ..()

/obj/machinery/ai/data_core/JoinPlayerHere(mob/M, buckle)
	return

/obj/machinery/ai/data_core/get_cell()
	return integrated_battery

/obj/machinery/ai/data_core/RefreshParts()
	. = ..()
	var/new_heat_mod = 1
	var/new_power_mod = 1
	for(var/datum/stock_part/capacitor/C in component_parts)
		new_power_mod -= (C.tier - 1) / 50 //Max -24% at tier 4 parts, min -0% at tier 1

	for(var/datum/stock_part/matter_bin/M in component_parts)
		new_heat_mod -= (M.tier - 1) / 15 //Max -40% at tier 4 parts, min -0% at tier 1

	heat_modifier = new_heat_mod
	power_modifier = new_power_mod
	active_power_usage = (AI_DATA_CORE_POWER_USAGE * power_modifier)

/obj/machinery/ai/data_core/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/stock_parts/power_store/cell))
		integrated_battery = arrived

/obj/machinery/ai/data_core/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == integrated_battery)
		integrated_battery = null

/obj/machinery/ai/data_core/examine(mob/user)
	. = ..()
	var/holder_status = get_holder_status()
	if(holder_status)
		. += span_warning("Machinery non-functional. Reason: [holder_status]")
	. += span_notice("Its floor <b>bolts</b> are [anchored ? "tightened" : "loose"].")

	if(isobserver(user))
		. += "Core temperature: <b>[core_temp] K</b>"

	. += "<b>The monitor lists the following AIs:</b>"
	for(var/mob/living/silicon/ai/AI in contents)
		. += "<b>[AI.name]</b>"
		if(isobserver(user))
			. += "<b>[AI] (Core: [FOLLOW_LINK(user, AI.loc)], Eye: [FOLLOW_LINK(user, AI.eyeobj)])</b>"
		. += AI.examine(user)

/obj/machinery/ai/data_core/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[(panel_open ? "Close" : "Open")] Panel"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/stock_parts/power_store/cell))
		context[SCREENTIP_CONTEXT_LMB] = (integrated_battery) ? "Replace Batteries" : "Add Batteries"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = (anchored ? "Unanchor" : "Anchor Down")
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/ai/data_core/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/stock_parts/power_store/cell))
		return NONE
	if(!panel_open)
		balloon_alert(user, "panel closed!")
		return ITEM_INTERACT_BLOCKING
	if(integrated_battery)
		user.put_in_hands(integrated_battery)
	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "batteries swapped")
	RefreshParts()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/data_core/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	tool.play_tool_sound(src, 50)
	balloon_alert_to_viewers("screwing panel...")
	if(!tool.use_tool(src, user, 2 SECONDS))
		return .
	if(default_deconstruction_screwdriver(user, "[base_icon_state]-open", base_icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/data_core/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(!panel_open)
		balloon_alert(user, "panel closed!")
		return .
	balloon_alert_to_viewers("deconstructing...")
	if(!tool.use_tool(src, user, 4 SECONDS))
		return .
	default_deconstruction_crowbar(tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/data_core/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	balloon_alert_to_viewers("[!anchored ? "tightening" : "loosening"] bolts...")
	if(!default_unfasten_wrench(user, tool, 4 SECONDS))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai/data_core/attack_ai(mob/living/silicon/ai/user)
	if((user in src))
		return ..()
	if(!valid_data_core() || !valid_holder())
		balloon_alert(user, "not a valid core!")
		return ..()
	if(user.nuking)
		var/confirmation_alert = tgui_alert(user, "Shunting will disable the doomsday device, are you sure you wish to do this?", "Really shunt?", list("Shunt", "Cancel"))
		if(confirmation_alert != "Shunt")
			return
	if(do_after(user, 4 SECONDS, src, interaction_key = DOAFTER_SOURCE_AI_SHUNTING) && valid_data_core())
		transfer_AI(user)
		playsound(src, 'sound/items/pip.ogg', 25, FALSE, 2)
		balloon_alert(user, "shunted!")

/obj/machinery/ai/data_core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	for(var/mob/living/silicon/ai/AI in contents)
		AI.disconnect_shell()

/obj/machinery/ai/data_core/proc/valid_data_core(mob/living/silicon/ai/user)
	if(is_reebe_level(z) && !IS_CLOCK(user))
		return FALSE
	if(!is_station_level(z) && !is_station_level(get_turf(user)))
		return FALSE
	if(valid_ticks > 0)
		return TRUE
	return FALSE

/obj/machinery/ai/data_core/process()
	valid_ticks = clamp(valid_ticks, 0, MAX_AI_DATA_CORE_TICKS)

	var/ai_creating_heat
	for(var/mob/living/silicon/ai/ai_contents in contents)
		ai_creating_heat = !ai_contents.technically_unpowered
		break //don't need to check every single AI

	if(valid_holder())
		valid_ticks++
		use_power = ACTIVE_POWER_USE
		if(machine_stat & NOPOWER)
			integrated_battery.use(active_power_usage * CELL_POWERUSE_MULTIPLIER)
		COOLDOWN_RESET(src, warning_cooldown)
	else
		valid_ticks--
		if(valid_ticks <= 0)
			use_power = IDLE_POWER_USE
		if(COOLDOWN_FINISHED(src, warning_cooldown))
			COOLDOWN_START(src, warning_cooldown, AI_DATA_CORE_WARNING_COOLDOWN)
			for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
				if(!AI.mind && AI.deployed_shell.mind)
					to_chat(AI.deployed_shell, span_userdanger("<A HREF=?src=[REF(AI)];go_to_machine=[REF(src)]>Data core</A> in [get_area(src)] is on the verge of failing! Immediate action required to prevent failure."))
				else
					to_chat(AI, span_userdanger("Data core in [get_area(src)] is on the verge of failing! Immediate action required to prevent failure."))
				AI.playsound_local(AI, 'sound/machines/engine_alert2.ogg', 30)

	if(!(machine_stat & (BROKEN|EMPED)) && has_power() && !disableheat && ai_creating_heat)
		var/temp_active_usage = (machine_stat & NOPOWER) ? idle_power_usage * CELL_POWERUSE_MULTIPLIER : active_power_usage * CELL_POWERUSE_MULTIPLIER
		var/temperature_increase = (temp_active_usage / AI_HEATSINK_CAPACITY) * heat_modifier //1 CPU = 1000W. Heat capacity = somewhere around 3000-4000. Aka we generate 0.25 - 0.33 K per second, per CPU.
		core_temp += temperature_increase * AI_TEMPERATURE_MULTIPLIER

/obj/machinery/ai/data_core/process_atmos()
	for(var/mob/living/silicon/ai/ai_contents in contents)
		if(ai_contents.technically_unpowered)
			return
		else //don't need to check every single AI
			break
	return ..()

/obj/machinery/ai/data_core/has_power()
	if((machine_stat & (NOPOWER)) && integrated_battery)
		if(integrated_battery.charge > (active_power_usage * CELL_POWERUSE_MULTIPLIER))
			return TRUE
	else
		return TRUE
	return FALSE

/obj/machinery/ai/data_core/proc/can_transfer_ai()
	if(machine_stat & (BROKEN|EMPED) || !has_power())
		return FALSE
	if(!valid_data_core() || !valid_holder())
		return FALSE
	return TRUE

/obj/machinery/ai/data_core/proc/transfer_AI(mob/living/silicon/ai/AI)
	if(AI.nuking)
		AI.ShutOffDoomsdayDevice()
	AI.forceMove(src)
	if(AI.eyeobj)
		AI.eyeobj.setLoc(get_turf(src))

/obj/machinery/ai/data_core/update_icon_state()
	. = ..()
	if(!valid_data_core())
		return
	if((machine_stat & (BROKEN|EMPED)) || !has_power())
		icon_state = "[base_icon_state]-offline"
	else
		icon_state = base_icon_state

/obj/machinery/ai/data_core/can_track(mob/living/user)
	return TRUE

/obj/machinery/ai/data_core/proc/partytime()
	if(TimerID)
		return FALSE
	var/current_color = random_color()
	set_light(7, 3, current_color)
	TimerID = addtimer(CALLBACK(src, PROC_REF(partytime)), 0.5 SECONDS, TIMER_STOPPABLE)

/obj/machinery/ai/data_core/proc/stoptheparty()
	set_light(0)
	if(TimerID)
		deltimer(TimerID)

/obj/machinery/ai/data_core/primary
	name = "primary AI data core"
	desc = "A complicated computer system capable of emulating the neural functions of a human at near-instantanous speeds. This one has a scrawny and faded note saying: 'Primary AI Data Core'"
	primary = TRUE
	circuit = /obj/item/circuitboard/machine/ai_data_core/primary

/*
 * This is a good place for AI-related object verbs so I'm sticking it here.
 * If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
 * That prevents a few funky behaviors.
 */
///The type of interaction, the player performing the operation, the AI itself, and the card object, if any.
/atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	SHOULD_CALL_PARENT(TRUE)
	if(istype(card))
		if(card.flush)
			to_chat(user, span_alert("ERROR: AI flush is in progress, cannot execute transfer protocol."))
			return FALSE
	return TRUE

#undef CELL_POWERUSE_MULTIPLIER
