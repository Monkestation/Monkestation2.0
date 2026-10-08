/datum/unit_test/test_loadout_duplicates
	priority = TEST_DEFAULT

/datum/unit_test/test_loadout_duplicates/Run()
	var/datum/asset/json/loadout_items/loadout_items_json = load_asset_datum(/datum/asset/json/loadout_items)
	var/list/loadout_tabs = loadout_items_json.generate()

	TEST_ASSERT(islist(loadout_tabs), "Loadout tabs data is not a valid list")

	// Check for duplicate names across all tabs
	for(var/tab in loadout_tabs)
		var/list/contents = tab["contents"]
		if(!length(contents))
			continue

		TEST_ASSERT(islist(contents), "Contents of a loadout tab ([tab["name"]]) is not a valid list")

		var/list/name_tracker = list()
		for(var/item in contents)
			if(item["name"] in name_tracker)
				TEST_FAIL("Duplicate loadout name found in the same tab: [item["name"]]")
			name_tracker += item["name"]

/datum/unit_test/test_loadout_store_duplicates
	priority = TEST_DEFAULT

/datum/unit_test/test_loadout_store_duplicates/Run()
	var/datum/asset/json/loadout_store/loadout_store_json = load_asset_datum(/datum/asset/json/loadout_store)
	var/list/loadout_store_data = loadout_store_json.generate()

	TEST_ASSERT(islist(loadout_store_data), "Loadout store data is not a valid list")

	// Check for duplicate names across all tabs
	for(var/tab in loadout_store_data)
		var/list/contents = tab["contents"]
		if(!length(contents))
			continue

		TEST_ASSERT(islist(contents), "Contents of a loadout store tab ([tab["name"]]) is not a valid list")

		var/list/name_tracker = list()
		for (var/item in contents)
			if(item["name"] in name_tracker)
				TEST_FAIL("Duplicate loadout store name found in the same tab: [item["name"]]")
			name_tracker += item["name"]
