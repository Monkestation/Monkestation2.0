ADMIN_VERB(tracy_next_round, R_DEBUG, "Toggle Tracy Next Round", "Toggle running the byond-tracy profiler next round.", ADMIN_CATEGORY_DEBUG)
#ifndef OPENDREAM_REAL
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
#ifndef OPENDREAM_REAL
	if(Tracy.enabled)
		to_chat(user, span_warning("byond-tracy is already running!"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
		return
	else if(Tracy.error)
		to_chat(user, span_danger("byond-tracy failed to initialize during an earlier attempt: [Tracy.error]"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
		return
	else if(!fexists(TRACY_DLL_PATH))
		to_chat(user, span_danger("byond-tracy library ([TRACY_DLL_PATH]) not present!"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
		return
	message_admins(span_adminnotice("[key_name_admin(user)] is trying to start the byond-tracy profiler."))
	log_admin("[key_name(user)] is trying to start the byond-tracy profiler.")
	if(!Tracy.enable("[user.ckey]"))
		to_chat(user, span_danger("byond-tracy failed to initialize: [Tracy.error]"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
		message_admins(span_adminnotice("[key_name_admin(user)] tried to start the byond-tracy profiler, but it failed to initialize ([Tracy.error])"))
		log_admin("[key_name(user)] tried to start the byond-tracy profiler, but it failed to initialize ([Tracy.error])")
		return
	to_chat(user, span_notice("byond-tracy successfully started!"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
	message_admins(span_adminnotice("[key_name_admin(user)] started the byond-tracy profiler."))
	log_admin("[key_name(user)] started the byond-tracy profiler.")
	if(Tracy.trace_path)
		rustg_file_write("[Tracy.trace_path]", "[GLOB.log_directory]/tracy.loc")
#else
	to_chat(user, span_danger("byond-tracy is not supported on OpenDream, sorry!"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
#endif
