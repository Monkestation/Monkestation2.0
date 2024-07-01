/datum/element/extra_examine/clockwork_description

/datum/element/extra_examine/clockwork_description/examine_checks(atom/source, mob/user, list/examine_texts)
	return isobserver(user) || IS_CLOCK(user)
