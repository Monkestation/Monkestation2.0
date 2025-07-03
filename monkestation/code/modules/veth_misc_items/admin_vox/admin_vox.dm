/datum/admins
	var/datum/vox_holder/admin/vox_holder

/datum/admins/disassociate()
	. = ..()
	QDEL_NULL(vox_holder)

/client/proc/AdminVOX()
	set name = "VOX"
	set category = "Admin"
	set desc = "Allows unrestricted use of the AI VOX announcement system."

	if(!check_rights(NONE))
		message_admins("[key_name(usr)] attempted to use AdminVOX without sufficient rights.")
		return

	if(QDELETED(holder.vox_holder))
		holder.vox_holder = new(holder)
	holder.vox_holder.ui_interact(usr)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show VOX Announcement")

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
