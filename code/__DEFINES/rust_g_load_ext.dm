GLOBAL_REAL_VAR(__rustg_log_write)

// file I/O
GLOBAL_REAL_VAR(__rustg_file_read)
GLOBAL_REAL_VAR(__rustg_file_exists)
GLOBAL_REAL_VAR(__rustg_file_write)
GLOBAL_REAL_VAR(__rustg_file_append)
GLOBAL_REAL_VAR(__rustg_file_get_line_count)
GLOBAL_REAL_VAR(__rustg_file_seek_line)

// sql
GLOBAL_REAL_VAR(__rustg_sql_connect_pool)
GLOBAL_REAL_VAR(__rustg_sql_query_async)
GLOBAL_REAL_VAR(__rustg_sql_query_blocking)
GLOBAL_REAL_VAR(__rustg_sql_connected)
GLOBAL_REAL_VAR(__rustg_sql_disconnect_pool)
GLOBAL_REAL_VAR(__rustg_sql_check_query)

// http
GLOBAL_REAL_VAR(__rustg_http_request_blocking)
GLOBAL_REAL_VAR(__rustg_http_request_async)
GLOBAL_REAL_VAR(__rustg_http_check_request)

// encoding
GLOBAL_REAL_VAR(__rustg_url_encode)
GLOBAL_REAL_VAR(__rustg_url_decode)

// noise generation
GLOBAL_REAL_VAR(__rustg_cnoise_generate)
GLOBAL_REAL_VAR(__rustg_dbp_generate)
GLOBAL_REAL_VAR(__rustg_noise_get_at_coordinates)

// dmis
GLOBAL_REAL_VAR(__rustg_dmi_strip_metadata)
GLOBAL_REAL_VAR(__rustg_dmi_create_png)
GLOBAL_REAL_VAR(__rustg_dmi_resize_png)
GLOBAL_REAL_VAR(__rustg_dmi_icon_states)

// time
GLOBAL_REAL_VAR(__rustg_time_microseconds)
GLOBAL_REAL_VAR(__rustg_time_milliseconds)
GLOBAL_REAL_VAR(__rustg_time_reset)

// misc
GLOBAL_REAL_VAR(__rustg_unix_timestamp)
GLOBAL_REAL_VAR(__rustg_json_is_valid)
GLOBAL_REAL_VAR(__rustg_setup_acreplace)
GLOBAL_REAL_VAR(__rustg_acreplace)

/proc/try_load_ext(a, b)
	SEND_TEXT(world.log, "trying to load_ext [b] from [a]")
	return load_ext(a, b)

/proc/load_rustg()
	__rustg_log_write = try_load_ext(RUST_G, "log_write")

	// file stuff
	__rustg_file_read = try_load_ext(RUST_G, "file_read")
	__rustg_file_exists = try_load_ext(RUST_G, "file_exists")
	__rustg_file_write = try_load_ext(RUST_G, "file_write")
	__rustg_file_append = try_load_ext(RUST_G, "file_append")
	__rustg_file_get_line_count = try_load_ext(RUST_G, "file_get_line_count")
	__rustg_file_seek_line = try_load_ext(RUST_G, "file_seek_line")

	// sql
	__rustg_sql_connect_pool = try_load_ext(RUST_G, "sql_connect_pool")
	__rustg_sql_query_async = try_load_ext(RUST_G, "sql_query_async")
	__rustg_sql_query_blocking = try_load_ext(RUST_G, "sql_query_blocking")
	__rustg_sql_connected = try_load_ext(RUST_G, "sql_connected")
	__rustg_sql_disconnect_pool = try_load_ext(RUST_G, "sql_disconnect_pool")
	__rustg_sql_check_query = try_load_ext(RUST_G, "sql_check_query")

	// http
	__rustg_http_request_blocking = try_load_ext(RUST_G, "http_request_blocking")
	__rustg_http_request_async = try_load_ext(RUST_G, "http_request_async")
	__rustg_http_check_request = try_load_ext(RUST_G, "http_check_request")

	// encoding
	__rustg_url_encode = try_load_ext(RUST_G, "url_encode")
	__rustg_url_decode = try_load_ext(RUST_G, "url_decode")

	// noise generation
	__rustg_cnoise_generate = try_load_ext(RUST_G, "cnoise_generate")
	__rustg_dbp_generate = try_load_ext(RUST_G, "dbp_generate")
	__rustg_noise_get_at_coordinates = try_load_ext(RUST_G, "noise_get_at_coordinates")

	// dmis
	__rustg_dmi_strip_metadata = try_load_ext(RUST_G, "dmi_strip_metadata")
	__rustg_dmi_create_png = try_load_ext(RUST_G, "dmi_create_png")
	__rustg_dmi_resize_png = try_load_ext(RUST_G, "dmi_resize_png")
	__rustg_dmi_icon_states = try_load_ext(RUST_G, "dmi_icon_states")

	// time
	__rustg_time_microseconds = try_load_ext(RUST_G, "time_microseconds")
	__rustg_time_milliseconds = try_load_ext(RUST_G, "time_milliseconds")
	__rustg_time_reset = try_load_ext(RUST_G, "time_reset")

	// misc
	__rustg_unix_timestamp = try_load_ext(RUST_G, "unix_timestamp")
	__rustg_json_is_valid = try_load_ext(RUST_G, "json_is_valid")
	__rustg_setup_acreplace = try_load_ext(RUST_G, "setup_acreplace")
	__rustg_acreplace = try_load_ext(RUST_G, "acreplace")
