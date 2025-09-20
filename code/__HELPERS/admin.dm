/// Returns if the given client is an admin, REGARDLESS of if they're deadminned or not.
/proc/is_admin(client/client)
	return !isnull(GLOB.admin_datums[client.ckey]) || !isnull(GLOB.deadmins[client.ckey])

/// Returns if the given client is a mentor, REGARDLESS of if they're dementored or not.
/proc/is_mentor(client/client)
	return !isnull(GLOB.mentor_datums[client.ckey]) || !isnull(GLOB.dementors[client.ckey])
