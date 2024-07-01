/datum/element/extra_examine/gang

/datum/element/extra_examine/gang/examine_checks(atom/source, mob/user, list/examine_texts)
	return isobserver(user) || IS_GANGMEMBER(user)
