/// Verifies that the fuel processor cannot start recipes outside its server-side registry.
/datum/unit_test/rbmk_fuel_processor_recipe_validation/Run()
	var/obj/machinery/rbmk/fuel_processor/processor = allocate(
		/obj/machinery/rbmk/fuel_processor,
		run_loc_floor_bottom_left,
	)
	TEST_ASSERT(isnull(processor.get_recipe("forged_recipe")), "The RBMK fuel processor accepted an unknown recipe ID.")
	TEST_ASSERT(!processor.start_recipe("forged_recipe", null), "The RBMK fuel processor started an unknown recipe.")
	TEST_ASSERT(isnull(processor.current_recipe), "The RBMK fuel processor entered its processing state for an unknown recipe.")

/// Verifies no-drop rod insertion behavior.
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
		"The RBMK reactor reported successful insertion for a no-drop fuel rod.",
	)
	TEST_ASSERT_EQUAL(fuel_rod.loc, operator, "The RBMK reactor removed a no-drop fuel rod from its operator.")
	TEST_ASSERT(!length(reactor.normal_slots), "The RBMK reactor recorded a no-drop fuel rod as installed.")
	REMOVE_TRAIT(fuel_rod, TRAIT_NODROP, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT_EQUAL(
		reactor.item_interaction(operator, fuel_rod, list()),
		ITEM_INTERACT_SUCCESS,
		"The RBMK reactor rejected a held fuel rod after its no-drop restriction was removed.",
	)
	TEST_ASSERT_EQUAL(fuel_rod.loc, reactor, "The RBMK reactor did not take ownership of an inserted fuel rod.")
	TEST_ASSERT(fuel_rod in reactor.normal_slots, "The RBMK reactor did not record an inserted uranium rod in its normal slot bank.")

/// Verifies that RBMK coolant flow respects native atmos pressure limits.
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

/// Verifies that RBMK meltdown objects retain their breached presentation.
/datum/unit_test/rbmk_meltdown_presentation/Run()
	var/obj/machinery/rbmk/reactor/reactor = allocate(
		/obj/machinery/rbmk/reactor,
		run_loc_floor_bottom_left,
	)
	var/initial_description = reactor.desc
	reactor.meltdown_exploded = TRUE
	reactor.update_appearance(UPDATE_DESC)
	TEST_ASSERT_NOTEQUAL(reactor.desc, initial_description, "The breached RBMK reactor retained its intact description.")
	var/obj/structure/closet/supplypod/rbmk_reactor_lid/lid = allocate(
		/obj/structure/closet/supplypod/rbmk_reactor_lid,
		run_loc_floor_bottom_left,
	)
	TEST_ASSERT_EQUAL(lid.bound_width, 48, "The RBMK lid did not match the visible sprite width.")
	TEST_ASSERT_EQUAL(lid.bound_height, 71, "The RBMK lid did not match the visible sprite height.")
	TEST_ASSERT_EQUAL(lid.bound_x, -7, "The RBMK lid was not aligned with the visible sprite horizontally.")
	TEST_ASSERT_EQUAL(lid.bound_y, -24, "The RBMK lid was not aligned with the visible sprite vertically.")
	TEST_ASSERT_EQUAL(lid.mouse_opacity, MOUSE_OPACITY_ICON, "The RBMK lid accepted clicks outside its visible pixels.")
	lid.bound_width = world.icon_size
	lid.bound_height = world.icon_size
	lid.reset_lid_appearance(TRUE)
	TEST_ASSERT_EQUAL(lid.bound_width, 48, "The RBMK lid lost its sprite width after landing.")
	TEST_ASSERT_EQUAL(lid.bound_height, 71, "The RBMK lid lost its sprite height after landing.")

/// Verifies that turbine generator wear is based on elapsed time rather than process frequency.
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

TEST_FOCUS(/datum/unit_test/rbmk_coolant_transfer_pressure_limits)
TEST_FOCUS(/datum/unit_test/rbmk_meltdown_presentation)
