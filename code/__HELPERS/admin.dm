/// Returns if the given client is an admin, REGARDLESS of if they're deadminned or not.
/proc/is_admin(client/client)
	return !isnull(GLOB.admin_datums[client.ckey]) || !isnull(GLOB.deadmins[client.ckey])

/* Removed for TM purposes
/// MONKE EDIT Returns if the given client is a mentor, REGARDLESS of if they're dementored or not.
/// Like is_admin however limits special features and join bypasses to people with a specific rank of R_MENTOR
/// This is to prevent base mentor rank of NONE from getting any special privledges by accident.
/proc/is_mentor(client/client)
	var/datum/mentors/mentor = GLOB.mentor_datums[client.ckey]) | GLOB.dementors[client.ckey])
	if(istype(mentor) && mentor.check_for_rights(R_MENTOR))
		return TRUE
	return FALSE
*/
