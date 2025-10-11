/datum/admins
	var/datum/vox_holder/admin/vox_holder

/datum/admins/disassociate()
	. = ..()
	QDEL_NULL(vox_holder)

ADMIN_VERB(AdminVOX, R_ADMIN, FALSE, "VOX", "Allows unrestricted use of the AI VOX announcement system.", ADMIN_CATEGORY_MAIN)
	if(QDELETED(user.holder.vox_holder))
		user.holder.vox_holder = new(user.holder)
	user.holder.vox_holder.ui_interact(user.mob)

	BLACKBOX_LOG_ADMIN_VERB("Show VOX Announcement")

/datum/vox_holder/admin
	cooldown = 5 SECONDS
	var/datum/admins/parent

/datum/vox_holder/admin/New(datum/admins/parent)
	. = ..()
	src.parent = parent

/datum/vox_holder/admin/Destroy(force)
	parent = null
	return ..()

/datum/vox_holder/admin/ui_status(mob/user, datum/ui_state/state)
	if(user.client == parent.owner)
		return UI_INTERACTIVE
	else
		return UI_CLOSE

/datum/vox_holder/admin/speak(mob/speaker, message, name_override, turf/origin_turf, test, check_hearing)
	. = ..()
	if(. && !test)
		message_admins("[key_name(speaker)] made a VOX announcement: \"[message]\".")
		log_admin("[key_name(speaker)] made a VOX announcement: \"[message]\".")
