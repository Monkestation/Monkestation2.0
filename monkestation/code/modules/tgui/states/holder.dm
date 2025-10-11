/**
 * tgui state: holder
 *
 * Checks that the user is an admin
 */

GLOBAL_DATUM_INIT(holder_state, /datum/ui_state/holder_state, new)

/datum/ui_state/holder_state/can_use_topic(src_object, mob/user)
	return user.client.holder ? UI_INTERACTIVE : UI_CLOSE
