/proc/cmp_conntime_asc(client/a, client/b)
	return cmp_numeric_asc(a.connection_time, b.connection_time)

/proc/cmp_conntime_dsc(client/a, client/b)
	return cmp_numeric_dsc(a.connection_time, b.connection_time)
