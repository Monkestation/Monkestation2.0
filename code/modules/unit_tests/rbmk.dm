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
