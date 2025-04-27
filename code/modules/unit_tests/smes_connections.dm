/// Unit test that checks to ensure that SMESes don't have their input connected to their output.
/datum/unit_test/smes_connections

/datum/unit_test/smes_connections/Run()
	for(var/obj/machinery/power/smes/smes as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/smes))
		if(QDELETED(smes) || QDELETED(smes.powernet) || QDELETED(smes.terminal) || QDELETED(smes.terminal.powernet))
			continue
		if(smes.powernet == smes.terminal.powernet)
			TEST_FAIL("SMES at [AREACOORD(smes)] has identical input and output powernets")
