/datum/unit_test/rbmk_fuel_processor_recipe_validation/Run()
	var/obj/machinery/rbmk/fuel_processor/processor = allocate(
		/obj/machinery/rbmk/fuel_processor,
		run_loc_floor_bottom_left,
	)
	TEST_ASSERT_NULL(processor.get_recipe("forged_recipe"), "Unknown recipe ID was accepted.")
	TEST_ASSERT(!processor.start_recipe("forged_recipe", null), "Unknown recipe was started.")
	TEST_ASSERT_NULL(processor.current_recipe, "Processor entered its active state for an unknown recipe.")

/datum/unit_test/rbmk_reactor_rod_insertion_nodrop/Run()
	var/obj/machinery/rbmk/reactor/reactor = allocate(
		/obj/machinery/rbmk/reactor,
		run_loc_floor_bottom_left,
	)
	var/mob/living/carbon/human/operator = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/rbmk/fuel_rod/uranium/fuel_rod = allocate(/obj/item/rbmk/fuel_rod/uranium)
	operator.forceMove(run_loc_floor_bottom_left)
	operator.put_in_hands(fuel_rod)
	ADD_TRAIT(fuel_rod, TRAIT_NODROP, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT_EQUAL( reactor.item_interaction(operator, fuel_rod, list()), ITEM_INTERACT_FAILURE, "No-drop rod was accepted." )
	TEST_ASSERT_EQUAL(fuel_rod.loc, operator, "No-drop rod left the operator's inventory.")
	TEST_ASSERT(!length(reactor.normal_slots), "No-drop rod was added to a reactor slot.")
	REMOVE_TRAIT(fuel_rod, TRAIT_NODROP, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT_EQUAL( reactor.item_interaction(operator, fuel_rod, list()), ITEM_INTERACT_SUCCESS, "Rod remained rejected after its no-drop trait was removed." )
	TEST_ASSERT_EQUAL(fuel_rod.loc, reactor, "Inserted rod was not moved into the reactor.")
	TEST_ASSERT(fuel_rod in reactor.normal_slots, "Inserted uranium rod was not added to a normal slot.")

/datum/unit_test/rbmk_coolant_transfer_pressure_limits/Run()
	var/obj/machinery/rbmk/reactor/reactor = allocate(
		/obj/machinery/rbmk/reactor,
		run_loc_floor_bottom_left,
	)
	var/datum/gas_mixture/internal_mix = reactor.coolant_internal
	var/datum/gas_mixture/inlet_mix = reactor.get_inlet_mix()
	var/datum/gas_mixture/outlet_mix = reactor.get_outlet_mix()
	TEST_ASSERT_NOTNULL(internal_mix, "The RBMK reactor initialized without an internal coolant mixture.")
	TEST_ASSERT_NOTNULL(inlet_mix, "The RBMK reactor initialized without an inlet gas mixture.")
	TEST_ASSERT_NOTNULL(outlet_mix, "The RBMK reactor initialized without an outlet gas mixture.")
	internal_mix.assert_gas(/datum/gas/nitrogen)
	inlet_mix.assert_gas(/datum/gas/nitrogen)
	outlet_mix.assert_gas(/datum/gas/nitrogen)
	var/test_temperature = 5000
	reactor.temperature = test_temperature
	reactor.operating_pressure = 0 // Isolate pressure equalization from the backpressure setting.
	internal_mix.temperature = test_temperature
	inlet_mix.temperature = test_temperature
	outlet_mix.temperature = test_temperature
	var/initial_internal_pressure = 5100
	var/initial_downstream_pressure = 5000
	internal_mix.moles[/datum/gas/nitrogen] = (initial_internal_pressure * internal_mix.volume) / (R_IDEAL_GAS_EQUATION * test_temperature)
	outlet_mix.moles[/datum/gas/nitrogen] = (initial_downstream_pressure * outlet_mix.volume) / (R_IDEAL_GAS_EQUATION * test_temperature)
	reactor.inlet_open = FALSE
	reactor.outlet_open = TRUE
	reactor.outlet_rate = RBMK_OUTLET_RATE_MAX
	reactor.last_coolant_air_cycle = SSair.times_fired - 1
	reactor.process_coolant_transfer(RBMK_ATMOS_PROCESS_SECONDS)
	TEST_ASSERT(reactor.last_outlet_moles_moved > 0, "The RBMK outlet moved no coolant across a positive pressure differential.")
	TEST_ASSERT( internal_mix.return_pressure() + ATMOS_PRESSURE_ERROR_TOLERANCE >= outlet_mix.return_pressure(), "The RBMK outlet overshot downstream pressure at maximum flow." )
	var/inlet_supply_pressure = 2000
	reactor.operating_pressure = RBMK_OPERATING_PRESSURE_DEFAULT
	var/inlet_target_pressure = inlet_supply_pressure + RBMK_INLET_PUMP_HEAD
	var/pre_injection_pressure = inlet_target_pressure - 100
	internal_mix.moles[/datum/gas/nitrogen] = (pre_injection_pressure * internal_mix.volume) / (R_IDEAL_GAS_EQUATION * test_temperature)
	inlet_mix.moles[/datum/gas/nitrogen] = (inlet_supply_pressure * inlet_mix.volume) / (R_IDEAL_GAS_EQUATION * test_temperature)
	reactor.inlet_open = TRUE
	reactor.inlet_rate = RBMK_INLET_RATE_MAX
	reactor.outlet_open = FALSE
	reactor.last_coolant_air_cycle = SSair.times_fired - 1
	reactor.process_coolant_transfer(RBMK_ATMOS_PROCESS_SECONDS)
	TEST_ASSERT(reactor.last_inlet_moles_moved > 0, "The RBMK inlet moved no coolant below its pump-head limit.")
	TEST_ASSERT( internal_mix.return_pressure() <= inlet_target_pressure + ATMOS_PRESSURE_ERROR_TOLERANCE, "The RBMK inlet overshot its pump-head pressure limit at maximum flow." )

/datum/unit_test/rbmk_fallout_weather/Run()
	var/datum/weather/rbmk_fallout/fallout = allocate(
		/datum/weather/rbmk_fallout,
		list(run_loc_floor_bottom_left.z),
	)
	TEST_ASSERT(!istype(fallout, /datum/weather/rad_storm), "Fallout inherited radiation-storm mutation effects.")
	TEST_ASSERT(!fallout.perpetual, "Fallout never ends.")
	TEST_ASSERT_EQUAL(fallout.area_type, /area/station, "Fallout is not limited to station areas.")
	TEST_ASSERT(/area/station/ai_monitored/turret_protected/aisat/maint in fallout.protected_areas, "AI satellite maintenance is exposed.")
	TEST_ASSERT(/area/station/maintenance in fallout.protected_areas, "Maintenance is exposed.")
	TEST_ASSERT(/area/station/security/prison/safe in fallout.protected_areas, "Prison radiation shelter is exposed.")
	TEST_ASSERT(/area/station/security/prison/toilet in fallout.protected_areas, "Prison toilet shelter is exposed.")

	var/mob/living/carbon/human/consistent/exposed_human = allocate(
		/mob/living/carbon/human/consistent,
		run_loc_floor_bottom_left,
	)
	fallout.impacted_areas |= get_area(exposed_human)
	TEST_ASSERT(fallout.can_weather_act(exposed_human), "Exposed mob was ignored by fallout.")
	ADD_TRAIT(exposed_human, TRAIT_RADSTORM_IMMUNE, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(!fallout.can_weather_act(exposed_human), "Radiation-weather protection did not block fallout.")
	REMOVE_TRAIT(exposed_human, TRAIT_RADSTORM_IMMUNE, TRAIT_SOURCE_UNIT_TESTS)
	fallout.weather_act(exposed_human)
	TEST_ASSERT(HAS_TRAIT(exposed_human, TRAIT_IRRADIATED), "Fallout did not irradiate an exposed mob.")

	var/mob/living/carbon/human/consistent/radiation_immune_human = allocate(
		/mob/living/carbon/human/consistent,
		run_loc_floor_bottom_left,
	)
	ADD_TRAIT(radiation_immune_human, TRAIT_RADIMMUNE, TRAIT_SOURCE_UNIT_TESTS)
	fallout.weather_act(radiation_immune_human)
	TEST_ASSERT(!HAS_TRAIT(radiation_immune_human, TRAIT_IRRADIATED), "Fallout irradiated a radiation-immune mob.")

/datum/unit_test/rbmk_slagged_core_radiation/Run()
	var/obj/machinery/rbmk/reactor/reactor = allocate(
		/obj/machinery/rbmk/reactor,
		run_loc_floor_bottom_left,
	)
	var/datum/component/radioactive_emitter/radiation_emitter = reactor.activate_slagged_core_radiation()
	TEST_ASSERT_NOTNULL(radiation_emitter, "Slagged core was not made radioactive.")
	TEST_ASSERT_EQUAL(radiation_emitter.range, RBMK_SLAGGED_CORE_RAD_RANGE, "Slagged core has the wrong radiation range.")
	TEST_ASSERT_EQUAL(reactor.activate_slagged_core_radiation(), radiation_emitter, "A second radiation emitter was created.")
	reactor.meltdown_in_progress = TRUE
	reactor.meltdown_exploded = TRUE
	reactor.radiation = 0
	reactor.process()
	TEST_ASSERT_EQUAL(reactor.radiation, RBMK_MAX_RADIATION, "Slagged core stopped reporting its radiation field.")

/datum/unit_test/rbmk_meltdown_description/Run()
	var/obj/machinery/rbmk/reactor/reactor = allocate(
		/obj/machinery/rbmk/reactor,
		run_loc_floor_bottom_left,
	)
	var/initial_description = reactor.desc
	reactor.meltdown_exploded = TRUE
	reactor.update_appearance(UPDATE_DESC)
	TEST_ASSERT_NOTEQUAL(reactor.desc, initial_description, "Slagged reactor kept its intact description.")

/datum/unit_test/rbmk_reactor_lid_bounds/Run()
	var/obj/structure/closet/supplypod/rbmk_reactor_lid/lid = allocate(
		/obj/structure/closet/supplypod/rbmk_reactor_lid,
		run_loc_floor_bottom_left,
	)
	TEST_ASSERT_EQUAL(lid.bound_width, 48, "Lid bounds do not match its width.")
	TEST_ASSERT_EQUAL(lid.bound_height, 71, "Lid bounds do not match its height.")
	TEST_ASSERT_EQUAL(lid.bound_x, -7, "Lid bounds are horizontally misaligned.")
	TEST_ASSERT_EQUAL(lid.bound_y, -24, "Lid bounds are vertically misaligned.")
	TEST_ASSERT_EQUAL(lid.mouse_opacity, MOUSE_OPACITY_ICON, "Lid accepts clicks outside its visible pixels.")
	lid.bound_width = world.icon_size
	lid.bound_height = world.icon_size
	lid.reset_lid_appearance(TRUE)
	TEST_ASSERT_EQUAL(lid.bound_width, 48, "Lid lost its width after landing.")
	TEST_ASSERT_EQUAL(lid.bound_height, 71, "Lid lost its height after landing.")

/datum/unit_test/rbmk_turbine_frame_independent_damage/Run()
	var/obj/machinery/power/rbmk_turbine/single_tick_turbine = allocate(
		/obj/machinery/power/rbmk_turbine,
		run_loc_floor_bottom_left,
	)
	var/obj/machinery/power/rbmk_turbine/split_tick_turbine = allocate(
		/obj/machinery/power/rbmk_turbine,
		run_loc_floor_bottom_left,
	)
	var/test_temperature = single_tick_turbine.generator_damage_temperature + 4000
	single_tick_turbine.update_generator_integrity(test_temperature, 1)
	split_tick_turbine.update_generator_integrity(test_temperature, 0.25)
	split_tick_turbine.update_generator_integrity(test_temperature, 0.25)
	split_tick_turbine.update_generator_integrity(test_temperature, 0.25)
	split_tick_turbine.update_generator_integrity(test_temperature, 0.25)
	TEST_ASSERT_EQUAL( single_tick_turbine.generator_integrity, split_tick_turbine.generator_integrity, "RBMK turbine generator damage changed with the number of process ticks." )

/datum/unit_test/rbmk_turbine_online_status/Run()
	var/obj/machinery/rbmk/reactor/reactor = allocate(
		/obj/machinery/rbmk/reactor,
		run_loc_floor_bottom_left,
	)
	var/obj/machinery/computer/rbmk_console/console = allocate(
		/obj/machinery/computer/rbmk_console,
		run_loc_floor_bottom_left,
	)
	var/obj/machinery/power/rbmk_turbine/turbine = allocate(
		/obj/machinery/power/rbmk_turbine,
		run_loc_floor_bottom_left,
	)
	console.linked_reactor = reactor
	console.rescan_turbines()
	TEST_ASSERT(turbine in console.linked_turbines, "The RBMK console did not discover its nearby turbine.")
	var/list/offline_summary = console.get_turbine_data()
	var/list/offline_turbine = offline_summary["turbines"][1]
	TEST_ASSERT_EQUAL(offline_turbine["online"], FALSE, "An idle RBMK turbine did not report offline.")
	TEST_ASSERT_EQUAL(offline_summary["online_turbine_count"], 0, "The RBMK console counted an idle turbine as online.")
	turbine.last_generation_time = world.time
	turbine.last_power_output = 100
	turbine.last_flow_moles = 1
	var/list/online_summary = console.get_turbine_data()
	var/list/online_turbine = online_summary["turbines"][1]
	TEST_ASSERT_EQUAL(online_turbine["online"], TRUE, "A generating RBMK turbine did not report online.")
	TEST_ASSERT_EQUAL(online_summary["online_turbine_count"], 1, "The RBMK console did not count a generating turbine as online.")

/datum/unit_test/rbmk_safe_start_and_fine_control/Run()
	var/obj/machinery/rbmk/reactor/reactor = allocate(/obj/machinery/rbmk/reactor)
	TEST_ASSERT_EQUAL(reactor.control_rod_depth, RBMK_CONTROL_ROD_MAX, "Requested rods did not start fully inserted.")
	TEST_ASSERT_EQUAL(reactor.actual_control_rod_depth, RBMK_CONTROL_ROD_MAX, "Actual rods did not start fully inserted.")
	TEST_ASSERT_EQUAL(reactor.coolant_internal.total_moles(), 0, "Reactor created coolant instead of relying on the mapped supply.")
	var/obj/item/rbmk/fuel_rod/uranium/rod = allocate(/obj/item/rbmk/fuel_rod/uranium)
	rod.forceMove(reactor)
	reactor.normal_slots += rod
	reactor.control_rod_depth = 95
	reactor.actual_control_rod_depth = 95
	reactor.process(1)
	var/full_flux = rod.reactivity * rod.flux_multiplier * RBMK_FLUX_GAIN
	TEST_ASSERT(reactor.flux > 0 && reactor.flux < full_flux * 0.01, "Five-percent withdrawal did not provide fine low-power control.")

/datum/unit_test/rbmk_offgas_conservation/Run()
	var/obj/machinery/rbmk/reactor/reactor = allocate(/obj/machinery/rbmk/reactor)
	var/datum/gas_mixture/core = reactor.coolant_internal
	var/datum/gas_mixture/downstream = reactor.get_outlet_mix()
	reactor.temperature = 700
	core.temperature = 700
	downstream.temperature = 700
	core.assert_gases(/datum/gas/water_vapor, /datum/gas/tritium)
	core.moles[/datum/gas/water_vapor] = 2000
	core.moles[/datum/gas/tritium] = 20
	reactor.inlet_open = FALSE
	reactor.outlet_open = TRUE
	reactor.operating_pressure = 0
	reactor.outlet_rate = RBMK_OUTLET_RATE_MAX
	var/total_before = core.total_moles() + downstream.total_moles()
	reactor.last_coolant_air_cycle = SSair.times_fired - 1
	reactor.process_coolant_transfer(RBMK_ATMOS_PROCESS_SECONDS)
	TEST_ASSERT(abs(core.total_moles() + downstream.total_moles() - total_before) < 0.001, "Offgas extraction created or discarded gas.")
	var/exported_tritium = downstream.moles[/datum/gas/tritium]
	TEST_ASSERT(exported_tritium && exported_tritium > 0, "The outlet exported no tritium.")
	TEST_ASSERT(exported_tritium / downstream.total_moles() > 20 / total_before, "The outlet did not prioritize tritium over working coolant.")
	TEST_ASSERT(reactor.last_outlet_flow_rate <= reactor.outlet_rate + 0.001, "Offgas bypassed the commanded outlet flow limit.")
	reactor.outlet_open = FALSE
	var/remaining_before = core.total_moles()
	reactor.last_coolant_air_cycle = SSair.times_fired - 1
	reactor.process_coolant_transfer(RBMK_ATMOS_PROCESS_SECONDS)
	TEST_ASSERT_EQUAL(core.total_moles(), remaining_before, "Gas escaped through the closed outlet.")

/datum/unit_test/rbmk_pending_meltdown_overlay/Run()
	var/obj/machinery/rbmk/reactor/reactor = allocate(/obj/machinery/rbmk/reactor)
	reactor.current_damage_stage = 3
	reactor.meltdown_in_progress = TRUE
	reactor.reactor_integrity = 0
	reactor.update_appearance(UPDATE_ICON)
	TEST_ASSERT_EQUAL(reactor.current_damage_stage, 3, "Pending explosion changed the existing damage overlay.")
	reactor.meltdown_exploded = TRUE
	reactor.update_appearance(UPDATE_ICON)
	TEST_ASSERT_EQUAL(reactor.current_damage_stage, 4, "Breached core did not switch to its final damage stage.")

/datum/unit_test/rbmk_turbine_temperature_and_energy/Run()
	var/obj/machinery/power/rbmk_turbine/turbine = allocate(/obj/machinery/power/rbmk_turbine)
	var/datum/powernet/network = allocate(/datum/powernet)
	network.add_machine(turbine)
	var/datum/gas_mixture/gas = allocate(/datum/gas_mixture)
	gas.assert_gases(/datum/gas/water_vapor)
	gas.moles[/datum/gas/water_vapor] = 100
	gas.temperature = 400
	turbine.last_inlet_pressure = 10000
	turbine.last_outlet_pressure = 1000
	turbine.update_pressure_delta()
	turbine.process_working_gas(gas, 0.5, 293)
	TEST_ASSERT_EQUAL(network.newavail, 0, "Cold compressed gas generated electricity below the operating threshold.")
	gas.temperature = 1000
	turbine.process_working_gas(gas, 0.5, 293)
	TEST_ASSERT(network.newavail > 0, "Hot working gas generated no electricity across a positive pressure and temperature drop.")
	TEST_ASSERT(abs(network.newavail - turbine.last_heat_extracted * turbine.generator_efficiency) < 0.01, "Turbine did not account for electrical output in joules.")

/datum/unit_test/rbmk_pressure_target_controls_injection/Run()
	var/obj/machinery/rbmk/reactor/reactor = allocate(/obj/machinery/rbmk/reactor)
	var/datum/gas_mixture/core = reactor.coolant_internal
	var/datum/gas_mixture/supply = reactor.get_inlet_mix()
	core.assert_gas(/datum/gas/water_vapor)
	supply.assert_gas(/datum/gas/water_vapor)
	reactor.temperature = 1000
	core.temperature = 1000
	supply.temperature = 1000
	reactor.operating_pressure = RBMK_OPERATING_PRESSURE_DEFAULT
	reactor.inlet_open = TRUE
	reactor.outlet_open = FALSE
	reactor.inlet_rate = RBMK_INLET_RATE_MAX
	var/pressure_ceiling = reactor.operating_pressure + RBMK_PRESSURE_CONTROL_BAND
	core.moles[/datum/gas/water_vapor] = (pressure_ceiling + 250) * core.volume / (R_IDEAL_GAS_EQUATION * core.temperature)
	supply.moles[/datum/gas/water_vapor] = 20000 * supply.volume / (R_IDEAL_GAS_EQUATION * supply.temperature)
	reactor.last_coolant_air_cycle = SSair.times_fired - 1
	reactor.process_coolant_transfer(RBMK_ATMOS_PROCESS_SECONDS)
	TEST_ASSERT_EQUAL(reactor.last_inlet_moles_moved, 0, "Injector kept filling above the core pressure target despite the outlet being closed.")
	core.moles[/datum/gas/water_vapor] = (pressure_ceiling - 50) * core.volume / (R_IDEAL_GAS_EQUATION * core.temperature)
	reactor.last_coolant_air_cycle = SSair.times_fired - 1
	reactor.process_coolant_transfer(RBMK_ATMOS_PROCESS_SECONDS)
	TEST_ASSERT(reactor.last_inlet_moles_moved > 0, "Injector did not resume below its pressure ceiling.")
	TEST_ASSERT(core.return_pressure() <= pressure_ceiling + ATMOS_PRESSURE_ERROR_TOLERANCE, "Injector overshot the pressure control band.")
	reactor.operating_pressure = 0
	reactor.outlet_open = TRUE
	reactor.last_coolant_air_cycle = SSair.times_fired - 1
	reactor.process_coolant_transfer(RBMK_ATMOS_PROCESS_SECONDS)
	TEST_ASSERT_EQUAL(reactor.last_inlet_moles_moved, 0, "Injector fought the operator's vent command.")
	TEST_ASSERT(reactor.last_outlet_moles_moved > 0, "Zero pressure target failed to vent available coolant.")

/// A sustained default-rate steam parcel should supply station-scale power
/// with a useful expansion ratio, without inventing electrical energy.
/datum/unit_test/rbmk_steam_station_output/Run()
	var/obj/machinery/power/rbmk_turbine/turbine = allocate(/obj/machinery/power/rbmk_turbine)
	var/datum/powernet/network = allocate(/datum/powernet)
	network.add_machine(turbine)
	var/datum/gas_mixture/steam = allocate(/datum/gas_mixture)
	steam.assert_gas(/datum/gas/water_vapor)
	steam.moles[/datum/gas/water_vapor] = RBMK_OUTLET_RATE_DEFAULT * RBMK_ATMOS_PROCESS_SECONDS
	steam.temperature = 1000
	turbine.last_inlet_pressure = RBMK_OPERATING_PRESSURE_DEFAULT
	turbine.last_outlet_pressure = 1000
	turbine.update_pressure_delta()
	turbine.process_working_gas(steam, RBMK_ATMOS_PROCESS_SECONDS, RBMK_AMBIENT_TEMP)
	TEST_ASSERT(turbine.last_power_output >= 500000 && turbine.last_power_output <= 700000, "Default-rate steam output missed the 500-700 kW operating target at 1000 K and 9:1 expansion.")
	TEST_ASSERT(abs(network.newavail - turbine.last_heat_extracted * turbine.generator_efficiency) < 0.01, "Steam output did not match the converted heat energy.")

/datum/unit_test/rbmk_private_audio_channels/Run()
	var/datum/looping_sound/rbmk_reactor/reactor_loop = allocate(/datum/looping_sound/rbmk_reactor, run_loc_floor_bottom_left)
	var/datum/looping_sound/rbmk_turbine/turbine_loop = allocate(/datum/looping_sound/rbmk_turbine, run_loc_floor_bottom_left)
	var/reactor_channel = reactor_loop.get_live_sound_channel()
	TEST_ASSERT(turbine_loop.can_native_repeat(), "Turbine audio did not use continuous native looping.")
	turbine_loop.play('sound/rbmk/turbine_mid.ogg', repeat_sound = TRUE)
	var/turbine_channel = turbine_loop.sound_token_instance.sound_channel
	TEST_ASSERT(!(reactor_channel in GLOB.used_sound_channels), "Reactor loop reserved a fixed sound channel.")
	TEST_ASSERT(!(turbine_channel in GLOB.used_sound_channels), "Turbine loop reserved a fixed sound channel.")
	TEST_ASSERT_NOTEQUAL(reactor_channel, turbine_channel, "Reactor and turbine shared a playback channel.")
	TEST_ASSERT(turbine_channel > 0, "Turbine audio did not reserve a private playback channel.")
