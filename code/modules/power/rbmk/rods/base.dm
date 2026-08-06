/// Base item for fuel, moderator, and exotic rods accepted by an RBMK reactor.
/obj/item/rbmk/fuel_rod
	name = "Fuel Rod"
	desc = "A generic fuel rod designed for RBMK reactors."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "empty"
	layer = OBJ_LAYER + 0.02
	plane = GAME_PLANE
	/// Stable identifier used by the fuel processor and reactor telemetry.
	var/rod_type = RBMK_ROD_TYPE_EMPTY
	/// UI color associated with this rod type.
	var/rod_color = "grey"
	/// Whether this rod occupies the reactor's limited special-rod bank.
	var/uses_special_slot = FALSE
	/// Remaining usable fuel; infinite-fuel moderator rods use `INFINITY`.
	var/fuel_amount = 100
	/// Fuel consumed per second while the rod is active in a reactor.
	var/fuel_consumption = 0.5
	/// Base reaction strength used to derive all three rod outputs.
	var/reactivity = 10
	/// Multiplier applied to neutron-flux output.
	var/flux_multiplier = 1.0
	/// Multiplier applied to radiation output.
	var/radiation_multiplier = 1.0
	/// Multiplier applied to heat output.
	var/thermal_multiplier = 1.0
	/// Whether this rod can sustain reactor operation by producing direct output.
	var/contributes_to_reaction = TRUE
	/// Whether reactor exposure has made the item radioactive.
	var/irradiated = FALSE
	/// Icon state shown after this rod is depleted.
	var/depleted_icon_state = "rod_empty"
	/// Description shown after this rod is depleted.
	var/depleted_description = "An empty fuel rod ready for packing."
	/// Radius of radiation pulses emitted by the item outside a reactor.
	var/item_radiation_range = 2
	/// Exposure threshold passed to the radiation pulse helper.
	var/item_radiation_threshold = 0.55
	/// Chance parameter passed to the radiation pulse helper.
	var/item_radiation_chance = 25
	/// Radiation strength emitted by a depleted rod.
	var/item_radiation_intensity = 35
	/// Radiation strength emitted by an activated rod that still has fuel.
	var/item_radiation_intensity_activated = 15
	/// Minimum delay between item radiation pulses.
	var/item_radiation_pulse_interval = 3 SECONDS
	COOLDOWN_DECLARE(item_radiation_pulse_cooldown)

/obj/item/rbmk/fuel_rod/Initialize(mapload)
	. = ..()
	if(is_radioactive_item())
		COOLDOWN_START(src, item_radiation_pulse_cooldown, item_radiation_pulse_interval)
		START_PROCESSING(SSobj, src)

/obj/item/rbmk/fuel_rod/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/rbmk/fuel_rod/process(seconds_per_tick)
	if(!is_radioactive_item())
		STOP_PROCESSING(SSobj, src)
		return
	emit_item_radiation()

/obj/item/rbmk/fuel_rod/update_icon_state()
	. = ..()
	icon_state = is_depleted() ? depleted_icon_state : initial(icon_state)

/obj/item/rbmk/fuel_rod/update_desc(updates = ALL)
	. = ..()
	desc = is_depleted() ? depleted_description : initial(desc)

/** Returns whether this rod has exhausted its usable fuel. */
/obj/item/rbmk/fuel_rod/proc/is_depleted()
	return fuel_amount <= 0

/** Returns the rod's remaining fuel as a percentage. */
/obj/item/rbmk/fuel_rod/proc/get_fuel_percent()
	if(fuel_amount >= INFINITY)
		return 100
	var/initial_fuel_amount = initial(fuel_amount)
	if(initial_fuel_amount <= 0)
		return is_depleted() ? 0 : 100
	return clamp((fuel_amount / initial_fuel_amount) * 100, 0, 100)

/** Returns whether the rod should emit radiation outside a reactor. */
/obj/item/rbmk/fuel_rod/proc/is_radioactive_item()
	return irradiated || is_depleted()

/** Marks the rod active and transfers radiation handling to its reactor. */
/obj/item/rbmk/fuel_rod/proc/activate_in_reactor()
	if(irradiated)
		return
	irradiated = TRUE
	COOLDOWN_START(src, item_radiation_pulse_cooldown, item_radiation_pulse_interval)
	START_PROCESSING(SSobj, src)

/** Emits a cooldown-gated radiation pulse while the rod is outside a reactor. */
/obj/item/rbmk/fuel_rod/proc/emit_item_radiation()
	if(!is_radioactive_item())
		return
	if(istype(loc, /obj/machinery/rbmk/reactor))
		return
	if(!COOLDOWN_FINISHED(src, item_radiation_pulse_cooldown))
		return
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return
	COOLDOWN_START(src, item_radiation_pulse_cooldown, item_radiation_pulse_interval)
	var/current_intensity = is_depleted() ? item_radiation_intensity : item_radiation_intensity_activated
	radiation_pulse(
		src,
		item_radiation_range,
		item_radiation_threshold,
		item_radiation_chance,
		0,
		current_intensity,
		TRUE,
	)

/** Converts an exhausted rod to its depleted state and appearance. */
/obj/item/rbmk/fuel_rod/proc/deplete_rod()
	fuel_amount = 0
	irradiated = TRUE
	update_appearance(UPDATE_DESC | UPDATE_ICON_STATE)
	COOLDOWN_START(src, item_radiation_pulse_cooldown, item_radiation_pulse_interval)
	START_PROCESSING(SSobj, src)

/** Returns an empty reactor-output record for an exhausted rod. */
/obj/item/rbmk/fuel_rod/proc/get_zero_output()
	return list(
		"flux" = 0,
		"radiation" = 0,
		"heat" = 0,
	)

/** Returns this rod's reactor modifier contributions. */
/obj/item/rbmk/fuel_rod/proc/get_modifier_output()
	return list(
		"temperature_limit_bonus" = 0,
		"coolant_exchange_bonus" = 0,
		"flux_multiplier_bonus" = 0,
	)

/** Returns radiation contributed by an installed but inactive rod. */
/obj/item/rbmk/fuel_rod/proc/get_residual_radiation_output()
	if(is_depleted())
		return 0
	return reactivity * radiation_multiplier

/** Burns fuel for one reactor tick and returns its flux, radiation, and heat. */
/obj/item/rbmk/fuel_rod/proc/process_rod(seconds_per_tick = RBMK_MACHINERY_PROCESS_SECONDS)
	if(is_depleted())
		deplete_rod()
		return get_zero_output()
	activate_in_reactor()
	fuel_amount = max(0, fuel_amount - (fuel_consumption * seconds_per_tick))
	// Let the last unit of fuel still produce output this tick,
	// then mark the rod spent afterward.
	var/should_deplete_after_output = (fuel_amount <= 0)
	var/rod_flux_output = reactivity * flux_multiplier
	var/rod_radiation_output = reactivity * radiation_multiplier
	var/rod_heat_output = reactivity * thermal_multiplier
	if(should_deplete_after_output)
		deplete_rod()
	return list(
		"flux" = rod_flux_output,
		"radiation" = rod_radiation_output,
		"heat" = rod_heat_output,
	)
