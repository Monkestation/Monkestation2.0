/proc/aneri_log_write(path, message, format = TRUE)
	return ANERI_CALL("log_write", path, message, format)

/proc/aneri_log_close_all()
	ANERI_CALL("log_close_all")
