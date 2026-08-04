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
	TEST_ASSERT_EQUAL(
		reactor.item_interaction(operator, fuel_rod, list()),
		ITEM_INTERACT_FAILURE,
		"No-drop rod was accepted.",
	)
	TEST_ASSERT_EQUAL(fuel_rod.loc, operator, "No-drop rod left the operator's inventory.")
	TEST_ASSERT(!length(reactor.normal_slots), "No-drop rod was added to a reactor slot.")
	REMOVE_TRAIT(fuel_rod, TRAIT_NODROP, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT_EQUAL(
		reactor.item_interaction(operator, fuel_rod, list()),
		ITEM_INTERACT_SUCCESS,
		"Rod remained rejected after its no-drop trait was removed.",
	)
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
	ASSERT_GAS(/datum/gas/nitrogen, internal_mix)
	ASSERT_GAS(/datum/gas/nitrogen, inlet_mix)
	ASSERT_GAS(/datum/gas/nitrogen, outlet_mix)
	var/test_temperature = 5000
	internal_mix.temperature = test_temperature
	inlet_mix.temperature = test_temperature
	outlet_mix.temperature = test_temperature
	var/initial_internal_pressure = 5100
	var/initial_downstream_pressure = 5000
	internal_mix.gases[/datum/gas/nitrogen][MOLES] = (initial_internal_pressure * internal_mix.volume) / (R_IDEAL_GAS_EQUATION * test_temperature)
	outlet_mix.gases[/datum/gas/nitrogen][MOLES] = (initial_downstream_pressure * outlet_mix.volume) / (R_IDEAL_GAS_EQUATION * test_temperature)
	reactor.inlet_open = FALSE
	reactor.outlet_open = TRUE
	reactor.outlet_rate = RBMK_OUTLET_RATE_MAX
	reactor.last_coolant_air_cycle = SSair.times_fired - 1
	reactor.process_coolant_transfer(RBMK_ATMOS_PROCESS_SECONDS)
	TEST_ASSERT(reactor.last_outlet_moles_moved > 0, "The RBMK outlet moved no coolant across a positive pressure differential.")
	TEST_ASSERT(
		internal_mix.return_pressure() + ATMOS_PRESSURE_ERROR_TOLERANCE >= outlet_mix.return_pressure(),
		"The RBMK outlet overshot downstream pressure at maximum flow.",
	)
	var/inlet_supply_pressure = 2000
	var/inlet_target_pressure = inlet_supply_pressure + RBMK_INLET_PUMP_HEAD
	var/pre_injection_pressure = inlet_target_pressure - 100
	internal_mix.gases[/datum/gas/nitrogen][MOLES] = (pre_injection_pressure * internal_mix.volume) / (R_IDEAL_GAS_EQUATION * test_temperature)
	inlet_mix.gases[/datum/gas/nitrogen][MOLES] = (inlet_supply_pressure * inlet_mix.volume) / (R_IDEAL_GAS_EQUATION * test_temperature)
	reactor.inlet_open = TRUE
	reactor.inlet_rate = RBMK_INLET_RATE_MAX
	reactor.outlet_open = FALSE
	reactor.last_coolant_air_cycle = SSair.times_fired - 1
	reactor.process_coolant_transfer(RBMK_ATMOS_PROCESS_SECONDS)
	TEST_ASSERT(reactor.last_inlet_moles_moved > 0, "The RBMK inlet moved no coolant below its pump-head limit.")
	TEST_ASSERT(
		internal_mix.return_pressure() <= inlet_target_pressure + ATMOS_PRESSURE_ERROR_TOLERANCE,
		"The RBMK inlet overshot its pump-head pressure limit at maximum flow.",
	)

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
	TEST_ASSERT_EQUAL(
		single_tick_turbine.generator_integrity,
		split_tick_turbine.generator_integrity,
		"RBMK turbine generator damage changed with the number of process ticks.",
	)

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
	console.linked_turbines = list(turbine)
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
