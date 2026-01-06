/datum/unit_test/test_loadout_duplicates
	priority = TEST_DEFAULT


// TODO: Create a preferences datum that contains everything
/datum/unit_test/test_loadout_duplicates/Run()
	var/datum/client_interface/mock_client = new("ci_testing")
	var/datum/preferences/preferences_instance = new(mock_client)
	var/datum/preference_middleware/loadout/loadout_instance = new(preferences_instance)

	var/list/loadout_data = loadout_instance.get_ui_static_data()
	TEST_ASSERT(istype(loadout_data, /list), "Loadout data is not a valid list")
	TEST_ASSERT("loadout_tabs" in loadout_data, "Loadout data does not contain 'loadout_tabs' key")

	var/list/loadout_tabs = loadout_data["loadout_tabs"]
	TEST_ASSERT(istype(loadout_tabs, /list), "Loadout tabs is not a valid list")

	// Check for duplicate names across all tabs
	for (var/tab in loadout_tabs)
		var/list/contents = tab["contents"]
		if(!length(contents))
			continue

		TEST_ASSERT(istype(contents, /list), "Contents of a loadout tab ([tab["name"]]) is not a valid list")

		var/list/name_tracker = list()
		for (var/item in contents)
			if(item["name"] in name_tracker)
				TEST_FAIL("Duplicate loadout name found in the same tab: [item["name"]]")
			name_tracker += item["name"]

	qdel(loadout_instance)
