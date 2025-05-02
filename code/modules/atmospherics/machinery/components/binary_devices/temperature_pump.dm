/obj/machinery/atmospherics/components/binary/temperature_pump
	icon_state = "tpump_map-3"
	name = "temperature pump"
	desc = "A pump that moves heat from one pipeline to another. The input will get cooler, and the output will get hotter."
	can_unwrench = TRUE
	shift_underlay_only = FALSE
	construction_type = /obj/item/pipe/directional
	pipe_state = "tpump"
	vent_movement = NONE
	///Percent of the heat delta to transfer
	var/heat_transfer_rate = 0
	///Maximum allowed transfer percentage
	var/max_heat_transfer_rate = 100
	//Monkestation edit start
	var/target_temperature = TCMB
	///Minimum allowed temperature
	var/minimum_temperature = TCMB
	///Maximum allowed temperature to be set
	var/max_temperature = MAX_TEMPERATURE_SETTING
	// Input cooling / output heating smart mode
	var/inverted = FALSE
	// Checks if heat is being transfered from input to output
	var/is_heat_flowing = FALSE
	//Monkestation edit end

/obj/machinery/atmospherics/components/binary/temperature_pump/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/atmospherics/components/binary/temperature_pump/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Turn [on ? "off" : "on"]"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Maximize transfer rate"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/atmospherics/components/binary/temperature_pump/CtrlClick(mob/user)
	if(can_interact(user))
		on = !on
		balloon_alert(user, "turned [on ? "on" : "off"]")
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		update_appearance()
	return ..()

/obj/machinery/atmospherics/components/binary/temperature_pump/AltClick(mob/user)
	if(can_interact(user) && !(heat_transfer_rate == max_heat_transfer_rate))
		heat_transfer_rate = max_heat_transfer_rate
		investigate_log("was set to [heat_transfer_rate]% by [key_name(user)]", INVESTIGATE_ATMOS)
		balloon_alert(user, "transfer rate set to [heat_transfer_rate]%")
		update_appearance()
	return ..()

/obj/machinery/atmospherics/components/binary/temperature_pump/examine(mob/user) //Monkestation edit start
	. = ..()
	. += "This device will transfer heat if the temperature of the gas in the [inverted ? "output is lower" : "input is higher"] than the temperature set in the interface."
	if(inverted)
		. += "The device settings can be restored if a multitool is used on it."
	else
		. += "The sensor's settings can be changed by using a multitool on the device." //Monkestation edit end


/obj/machinery/atmospherics/components/binary/temperature_pump/update_icon_nopipes()
	if(on && is_operational && is_heat_flowing) //Monkestation edit start
		icon_state = "tpump_flow-[set_overlay_offset(piping_layer)]"
	else if(on && is_operational && !is_heat_flowing)
		icon_state = "tpump_on-[set_overlay_offset(piping_layer)]"
	else
		icon_state = "tpump_off-[set_overlay_offset(piping_layer)]" //Monkestation edit end

/obj/machinery/atmospherics/components/binary/temperature_pump/process_atmos()
	if(!on || !is_operational)
		return

	var/datum/gas_mixture/air_input = airs[1]
	var/datum/gas_mixture/air_output = airs[2]

	if(!QUANTIZE(air_input.total_moles()) || !QUANTIZE(air_output.total_moles()) || (heat_transfer_rate<=0)) //Monkestation edit start //Don't transfer if there's no gas or if the transfer rate is zero
		is_heat_flowing = FALSE
		update_icon_nopipes() //Monkestation edit end
		return
	var/datum/gas_mixture/remove_input = air_input.remove_ratio(0.9)
	var/datum/gas_mixture/remove_output = air_output.remove_ratio(0.9)

	var/coolant_temperature_delta = remove_input.temperature - remove_output.temperature

	if((coolant_temperature_delta > 0) && ((!inverted && (air_input.temperature>target_temperature)) || (inverted && (air_output.temperature<target_temperature)))) //Monkestation edit
		var/input_capacity = remove_input.heat_capacity()
		var/output_capacity = remove_output.heat_capacity()
		is_heat_flowing = TRUE //Monkestation edit

		var/cooling_heat_amount = (heat_transfer_rate * 0.01) * CALCULATE_CONDUCTION_ENERGY(coolant_temperature_delta, output_capacity, input_capacity)
		remove_output.temperature = max(remove_output.temperature + (cooling_heat_amount / output_capacity), TCMB)
		remove_input.temperature = max(remove_input.temperature - (cooling_heat_amount / input_capacity), TCMB)
		update_parents()
	else
		is_heat_flowing = FALSE //Monkestation edit

	update_icon_nopipes() //Monkestation edit

	var/power_usage = 200

	air_input.merge(remove_input)
	air_output.merge(remove_output)

	if(power_usage)
		use_power(power_usage)

/obj/machinery/atmospherics/components/binary/temperature_pump/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosTempPump", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/temperature_pump/ui_data()
	var/data = list()
	data["on"] = on
	data["rate"] = round(heat_transfer_rate)
	data["max_heat_transfer_rate"] = round(max_heat_transfer_rate)
	data["temperature"] = round(target_temperature) //Monkestation edit start
	data["min_temperature"] = round(minimum_temperature)
	data["max_temperature"] = round(max_temperature) //Monkestation edit end
	return data

/obj/machinery/atmospherics/components/binary/temperature_pump/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("rate")
			var/rate = params["rate"]
			if(rate == "max")
				rate = max_heat_transfer_rate
				. = TRUE
			else if(text2num(rate) != null)
				rate = text2num(rate)
				. = TRUE
			if(.)
				heat_transfer_rate = clamp(rate, 0, max_heat_transfer_rate)
				investigate_log("was set to [heat_transfer_rate]% by [key_name(usr)]", INVESTIGATE_ATMOS)
		if("temperature") //Monkestation edit start
			var/temperature = params["temperature"]
			if(temperature == "tmax")
				temperature = max_temperature
				. = TRUE
			else if(text2num(temperature) != null)
				temperature = text2num(temperature)
				. = TRUE
			if(.)
				target_temperature = clamp(minimum_temperature, temperature, max_temperature)
				investigate_log("was set to [target_temperature] K by [key_name(usr)]", INVESTIGATE_ATMOS) //Monkestation edit end
	update_appearance()

/obj/machinery/atmospherics/components/binary/temperature_pump/multitool_act(mob/living/user, obj/item/multitool/I) //Monkestation edit start
	. = ..()
	if (istype(I))
		inverted = !inverted
		if(inverted)
			to_chat(user, span_notice("You set [src]'s sensors to transfer heat when the output temperature is lower than the setted one."))
		else
			to_chat(user, span_notice("You set [src]'s sensors to transfer heat when the input temperature is higher than the setted one."))
	return TRUE
//Monkestation edit end
