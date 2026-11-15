
/// Logs a message to the fishing log category
/proc/log_fish(text, list/data)
	logger.Log(LOG_CATEGORY_FISHING, text, data)
