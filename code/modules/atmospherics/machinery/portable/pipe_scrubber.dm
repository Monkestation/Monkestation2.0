#define PORTABLE_ATMOS_IGNORE_ATMOS_LIMIT 0

/obj/machinery/portable_atmospherics/pipe_scrubber
	name = "pipe scrubber"
	desc = "A machine for cleaning out pipes of lingering gases. It is a huge tank with a pump attached to it."
	icon_state = "pipe_scrubber"
	density = TRUE
	max_integrity = 250
	volume = 200
	///Secondary tank gas mixture
	var/datum/gas_mixture/secondary_tank_contents
	///Secondary tank volume
	var/secondary_tank_volume = 2000
	///Is the machine on?
	var/on = FALSE
	///What direction is the machine pumping to (into scrubber or out to the port)?
	var/direction = PUMP_IN
	///the rate the machine will scrub air
	var/volume_rate = 1000
	///List of gases that can be scrubbed
	var/list/scrubbing = list(
		/datum/gas/plasma,
		/datum/gas/carbon_dioxide,
		/datum/gas/nitrous_oxide,
		/datum/gas/bz,
		/datum/gas/nitrium,
		/datum/gas/tritium,
		/datum/gas/hypernoblium,
		/datum/gas/water_vapor,
		/datum/gas/freon,
		/datum/gas/hydrogen,
		/datum/gas/healium,
		/datum/gas/proto_nitrate,
		/datum/gas/zauker,
		/datum/gas/halon,
	)

/obj/machinery/portable_atmospherics/pipe_scrubber/Initialize(mapload)
	. = ..()
	secondary_tank_contents = new
	secondary_tank_contents.volume = secondary_tank_volume
	secondary_tank_contents.temperature = T20C

/obj/machinery/portable_atmospherics/pipe_scrubber/Destroy()
	var/turf/my_turf = get_turf(src)
	my_turf.assume_air(air_contents)
	my_turf.assume_air(secondary_tank_contents)
	secondary_tank_contents = null
	return ..()

/obj/machinery/portable_atmospherics/pipe_scrubber/return_analyzable_air()
	return list(
		air_contents,
		secondary_tank_contents
	)

/obj/machinery/portable_atmospherics/pipe_scrubber/AltClick(mob/living/user)
	. = ..()
	return

/obj/machinery/portable_atmospherics/pipe_scrubber/replace_tank(mob/living/user, close_valve, obj/item/tank/new_tank)
	return FALSE

/obj/machinery/portable_atmospherics/pipe_scrubber/update_icon_state()
	icon_state = on ? "[initial(icon_state)]_active" : initial(icon_state)
	return ..()

/obj/machinery/portable_atmospherics/pipe_scrubber/process_atmos()
	if(take_atmos_damage())
		excited = TRUE

	if(on)
		excited = TRUE
		if(direction == PUMP_IN)
			scrub(air_contents)
		else
			secondary_tank_contents.pump_gas_to(air_contents, PUMP_MAX_PRESSURE)

	if(!suppress_reactions)
		if(max(air_contents.react(src), secondary_tank_contents.react(src)))
			excited = TRUE

	if(!excited)
		return PROCESS_KILL
	excited = FALSE

/obj/machinery/portable_atmospherics/pipe_scrubber/take_atmos_damage()
	var/taking_damage = FALSE

	var/temp_damage = 1
	var/pressure_damage = 1

	if(temp_limit != PORTABLE_ATMOS_IGNORE_ATMOS_LIMIT)
		temp_damage = max(air_contents.temperature, secondary_tank_contents.temperature) / temp_limit
		taking_damage = temp_damage > 1

	if(pressure_limit != PORTABLE_ATMOS_IGNORE_ATMOS_LIMIT)
		pressure_damage = max(air_contents.return_pressure(), secondary_tank_contents.return_pressure()) / pressure_limit
		taking_damage = taking_damage || pressure_damage > 1

	if(!taking_damage)
		return FALSE

	take_damage(clamp(temp_damage * pressure_damage, 5, 50), BURN, 0)
	return TRUE

/// Scrub gasses from own air_contents into secondary_tank_contents
/obj/machinery/portable_atmospherics/pipe_scrubber/proc/scrub()
	if(secondary_tank_contents.return_pressure() >= PUMP_MAX_PRESSURE)
		return

	var/transfer_moles = min(1, volume_rate / air_contents.volume) * air_contents.total_moles()

	var/datum/gas_mixture/filtering = air_contents.remove(transfer_moles) // Remove part of the mixture to filter.
	var/datum/gas_mixture/filtered = new
	if(!filtering)
		return

	filtered.temperature = filtering.temperature
	for(var/gas in filtering.gases & scrubbing)
		filtered.add_gas(gas)
		filtered.gases[gas][MOLES] = filtering.gases[gas][MOLES] // Shuffle the "bad" gasses to the filtered mixture.
		filtering.gases[gas][MOLES] = 0
	filtering.garbage_collect() // Now that the gasses are set to 0, clean up the mixture.

	secondary_tank_contents.merge(filtered) // Store filtered out gasses.
	air_contents.merge(filtering) // Returned the cleaned gas.

/obj/machinery/portable_atmospherics/pipe_scrubber/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PipeScrubber", name)
		ui.open()

/obj/machinery/portable_atmospherics/pipe_scrubber/ui_data()
	var/data = list()
	data["on"] = on
	data["direction"] = direction
	data["connected"] = connected_port ? 1 : 0
	data["pressureTank"] = round(secondary_tank_contents.return_pressure() ? secondary_tank_contents.return_pressure() : 0)
	data["pressurePump"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["hasHypernobCrystal"] = nob_crystal_inserted
	data["reactionSuppressionEnabled"] = suppress_reactions

	data["filterTypes"] = list()
	for(var/gas_path in GLOB.meta_gas_info)
		var/list/gas = GLOB.meta_gas_info[gas_path]
		data["filterTypes"] += list(list("gasId" = gas[META_GAS_ID], "gasName" = gas[META_GAS_NAME], "enabled" = (gas_path in scrubbing)))

	return data

/obj/machinery/portable_atmospherics/pipe_scrubber/ui_static_data()
	var/list/data = list()
	data["pressureLimitPump"] = pressure_limit
	data["pressureLimitTank"] = pressure_limit
	return data

/obj/machinery/portable_atmospherics/pipe_scrubber/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			if(on)
				SSair.start_processing_machine(src)
			. = TRUE
		if("direction")
			direction = !direction
			. = TRUE
		if("toggle_filter")
			scrubbing ^= gas_id2path(params["val"])
			. = TRUE
		if("reaction_suppression")
			if(!nob_crystal_inserted)
				message_admins("[ADMIN_LOOKUPFLW(usr)] tried to toggle reaction suppression on a pipe scrubber without a noblium crystal inside, possible href exploit attempt.")
				return
			suppress_reactions = !suppress_reactions
			SSair.start_processing_machine(src)
			message_admins("[ADMIN_LOOKUPFLW(usr)] turned [suppress_reactions ? "on" : "off"] the [src] reaction suppression.")
			usr.investigate_log("turned [suppress_reactions ? "on" : "off"] the [src] reaction suppression.", INVESTIGATE_ATMOS)
			. = TRUE
	update_appearance()

#undef PORTABLE_ATMOS_IGNORE_ATMOS_LIMIT
