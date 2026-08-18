// Test that anything with a greyscale setup creates it's own preview icon
/datum/unit_test/gags_map_icon

/datum/unit_test/gags_map_icon/Run()
	for(var/atom/thing as anything in subtypesof(/atom))
		if(!thing.greyscale_colors || !thing.greyscale_config)
			continue
		if(thing.flags_1 & NO_NEW_GAGS_PREVIEW_1)
			continue
		var/type_string = "[thing.type]"
		if(type_string != thing.icon_state)
			TEST_FAIL("[thing] does not override icon_state for GAGs previews. Should be [type_string].")
