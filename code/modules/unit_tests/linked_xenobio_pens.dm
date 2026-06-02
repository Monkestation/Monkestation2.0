/// This test ensures that any mapped xenobiology pens properly have a unique mapping ID set between each ooze sucker and slime pen management console.
/datum/unit_test/linked_xenobio_pens

/datum/unit_test/linked_xenobio_pens/Run()
	for(var/obj/machinery/slime_pen_controller/pen as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/slime_pen_controller))
		if(!pen.mapping_id)
			TEST_FAIL("Found a slime pen management console without a mapping ID at [AREACOORD(pen)]!")

