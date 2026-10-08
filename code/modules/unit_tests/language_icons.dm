/// This test ensures that all languages have a valid icon
/datum/unit_test/language_icons

/datum/unit_test/language_icons/Run()
	for(var/datum/language/language as anything in subtypesof(/datum/language))
		if(!icon_exists(language::icon, language::icon_state))
			TEST_FAIL("[language::name] ([language]) does not have a valid icon! (icon = [language::icon || "null"], icon_state = [language::icon_state || "null"])")
