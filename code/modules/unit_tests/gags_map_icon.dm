#if defined(UNIT_TESTS) // Required for icon_state_map declaration
// Test that anything with a greyscale setup creates it's own preview icon
/datum/unit_test/gags_map_icon

/datum/unit_test/gags_map_icon/Run()
	for(var/atom/thing as anything in subtypesof(/atom))
		if(!thing.greyscale_colors || !thing.greyscale_config)
			continue

		var/thing_map_icon_state = thing.icon_state_map
		if(!thing_map_icon_state)
			TEST_FAIL("[thing] has greyscale but does not properly implement SETUP_MAP_ICONS.")
			continue

		var/thing_map_icon = initial(thing.icon)
		if(!findtextEx("[thing_map_icon]", "icons/map_icons"))
			TEST_FAIL("[thing] has a map override icon_state but does not have a map_icon icon file.")
			continue

		if(!icon_exists(thing_map_icon, thing_map_icon_state))
			TEST_FAIL("[thing] has a map override icon_state set ([thing_map_icon_state]), but it is not present in [thing_map_icon].")

		if(thing.flags_1 & NO_NEW_GAGS_PREVIEW_1)
			continue

		if("[thing.type]" != thing_map_icon_state)
			TEST_FAIL("[thing] has no unique icon_state for GAGs previews, should be [thing.type].")
#endif
