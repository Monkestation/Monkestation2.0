ADMIN_VERB(tracy_next_round, R_DEBUG, "Toggle Tracy Next Round", "Toggle running the byond-tracy profiler next round.", ADMIN_CATEGORY_DEBUG)
#ifndef OPENDREAM
	if(!fexists(TRACY_DLL_PATH))
		to_chat(user, span_danger("byond-tracy library ([TRACY_DLL_PATH]) not present!"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
		return
	if(fexists(TRACY_ENABLE_PATH))
		fdel(TRACY_ENABLE_PATH)
	else
		rustg_file_write("[user.ckey]", TRACY_ENABLE_PATH)
	message_admins(span_adminnotice("[key_name_admin(user)] [fexists(TRACY_ENABLE_PATH) ? "enabled" : "disabled"] the byond-tracy profiler for next round."))
	log_admin("[key_name(user)] [fexists(TRACY_ENABLE_PATH) ? "enabled" : "disabled"] the byond-tracy profiler for next round.")
	BLACKBOX_LOG_ADMIN_VERB("Toggle Tracy Next Round")
#else
	to_chat(user, span_danger("byond-tracy is not supported on OpenDream, sorry!"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
#endif

ADMIN_VERB(start_tracy, R_DEBUG, "Run Tracy Now", "Start running the byond-tracy profiler immediately.", ADMIN_CATEGORY_DEBUG)
#ifndef OPENDREAM
	if(GLOB.tracy_initialized)
		to_chat(user, span_warning("byond-tracy is already running!"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
		return
	else if(GLOB.tracy_init_error)
		to_chat(user, span_danger("byond-tracy failed to initialize during an earlier attempt: [GLOB.tracy_init_error]"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
		return
	else if(!fexists(TRACY_DLL_PATH))
		to_chat(user, span_danger("byond-tracy library ([TRACY_DLL_PATH]) not present!"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
		return
	message_admins(span_adminnotice("[key_name_admin(user)] is trying to start the byond-tracy profiler."))
	log_admin("[key_name(src)] is trying to start the byond-tracy profiler.")
	GLOB.tracy_initialized = FALSE
	GLOB.tracy_init_reason = "[user.ckey]"
	world.init_byond_tracy()
	if(GLOB.tracy_init_error)
		to_chat(user, span_danger("byond-tracy failed to initialize: [GLOB.tracy_init_error]"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
		message_admins(span_adminnotice("[key_name_admin(user)] tried to start the byond-tracy profiler, but it failed to initialize ([GLOB.tracy_init_error])"))
		log_admin("[key_name(user)] tried to start the byond-tracy profiler, but it failed to initialize ([GLOB.tracy_init_error])")
		return
	to_chat(user, span_notice("byond-tracy successfully started!"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
	message_admins(span_adminnotice("[key_name_admin(user)] started the byond-tracy profiler."))
	log_admin("[key_name(user)] started the byond-tracy profiler.")
	if(GLOB.tracy_log)
		rustg_file_write("[GLOB.tracy_log]", "[GLOB.log_directory]/tracy.loc")
#else
	to_chat(user, span_danger("byond-tracy is not supported on OpenDream, sorry!"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
#endif
