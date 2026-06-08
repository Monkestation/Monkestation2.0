// source.dm - code for a client server that wants to split population to a target server

// List of clients that will be split for pop
GLOBAL_LIST_EMPTY(pop_split_marked)
GLOBAL_VAR_INIT(pop_splitting, FALSE)
GLOBAL_VAR(pop_split_target_lastroundid)

// On round end
/datum/controller/subsystem/ticker/standard_reboot()
	. = ..()

	if(!CONFIG_GET(flag/pop_split))
		return

	if(!CONFIG_GET(string/pop_split_target))
		log_config("Pop split is enabled but no target world is set!")
		return

	var/threshold = CONFIG_GET(number/pop_split_threshold)
	var/passed_threshold = length(GLOB.clients) >= threshold

	if(!passed_threshold)
		return

	var/target = CONFIG_GET(string/pop_split_target)
	var/target_name = CONFIG_GET(string/pop_split_target_name)

	// Check if the target world can reboot, if so, DO IT BITCH
	var/target_can_reboot = world.Export("byond://[target]?can_empty_reboot", Persist = TRUE)
	if(target_can_reboot)
		message_admins(span_bolddanger("POP-SPLIT: Source and target server eligible for pop-split, rebooting target..."))
		log_game("POP-SPLIT: Source and target server eligible for pop-split, rebooting target...")
	else
		message_admins("POP-SPLIT: Target server ineligible for pop-split, pop split cancelled.")
		log_game("POP-SPLIT: Target server ineligible for pop-split, pop split cancelled")
		// Just to close any active connections.
		world.Export("byond://[target]", Persist = FALSE)
		return
	var/target_status = world.Export("byond://[target]?status", Persist = TRUE)
	if(!target_status?["round_id"])
		message_admins(span_bolddanger("POP-SPLIT: Target server did not return status info or missing round-id, pop split cancelled."))
		log_game("POP-SPLIT: Target server did not return status info or missing round-id, pop split cancelled.")
		return

	GLOB.pop_split_target_lastroundid = target_status["round_id"]

	var/target_reboot_result = world.Export("byond://[target]?reboot", Persist = FALSE)
	if(isnull(target_reboot_result))
		message_admins("POP-SPLIT: Heads up, target server returned nothing when we told it to reboot, we'll compare the round ID right before the server reboots and make our decision then.")
		log_game("POP-SPLIT: Heads up, target server returned nothing when we told it to reboot, we'll compare the round ID right before the server reboots and make our decision then")

	var/list/marked_clients = GLOB.clients.Copy()

	var/sort_method = CONFIG_GET(string/pop_split_sort_method)

	if((sort_method == POP_SPLIT_SORT_MOST_PLAYTIME || sort_method == POP_SPLIT_SORT_LEAST_PLAYTIME) && !SSdbcore.Connect())
		sort_method = sort_method == POP_SPLIT_SORT_MOST_PLAYTIME ? POP_SPLIT_SORT_MOST_CONNECTION_TIME : POP_SPLIT_SORT_LEAST_CONNECTION_TIME

	switch(sort_method)
		if(POP_SPLIT_SORT_RANDOM)
			shuffle_inplace(marked_clients)
		if(POP_SPLIT_SORT_MOST_CONNECTION_TIME)
			sortTim(marked_clients, GLOBAL_PROC_REF(cmp_conntime_dsc))
		if(POP_SPLIT_SORT_LEAST_CONNECTION_TIME)
			sortTim(marked_clients, GLOBAL_PROC_REF(cmp_conntime_asc))
		if(POP_SPLIT_SORT_MOST_PLAYTIME)
			sortTim(marked_clients, GLOBAL_PROC_REF(cmp_playtime_dsc))
		if(POP_SPLIT_SORT_LEAST_PLAYTIME)
			sortTim(marked_clients, GLOBAL_PROC_REF(cmp_playtime_asc))

	// TODO: make the divisor configurable or something. what if they want to split like.. by a certain amount? i dunno
	marked_clients.len = floor(length(marked_clients) / 2)

	GLOB.pop_split_marked = marked_clients
	GLOB.pop_splitting = TRUE

	to_chat(GLOB.pop_split_marked, span_boldnotice("POP-SPLIT: You have been selected for pop splitting, you will be moved over to '[target_name]' ([target])"))
	message_admins(span_bolddanger("POP-SPLIT: Pop split is active (Over [threshold] players). [CONFIG_GET(flag/pop_split_exclude_admins) ? "Admins are exempt from pop split" : ""]"))
	log_game("POP-SPLIT: Pop split is active (Over [threshold] players). [CONFIG_GET(flag/pop_split_exclude_admins) ? "Admins are exempt from pop split" : ""]")

/datum/controller/subsystem/server_maint/Shutdown()
	if(!CONFIG_GET(flag/pop_split))
		return ..()
	var/bailout_threshold = CONFIG_GET(number/pop_split_bailout_threshold)
	if(length(GLOB.clients) < bailout_threshold)
		GLOB.pop_splitting = FALSE
		message_admins(span_bolddanger("POP-SPLIT: Pop split bailing out. (Player count below [bailout_threshold])"))
		log_game("POP-SPLIT: Bailing out. (Player count below [bailout_threshold])")
		return ..()

	var/target = CONFIG_GET(string/pop_split_target)
	var/target_name = CONFIG_GET(string/pop_split_target_name)

	var/target_status = world.Export("byond://[target]?status")
	if(!target_status["round_id"])
		GLOB.pop_splitting = FALSE
		message_admins(span_bolddanger("POP-SPLIT: Bailing out. (Target server did not return proper status)"))
		log_game("POP-SPLIT: Bailing out. (Target server did not return proper status)")
		return ..()

	if(target_status["round_id"] == GLOB.pop_split_target_lastroundid)
		GLOB.pop_splitting = FALSE
		message_admins(span_bolddanger("POP-SPLIT: Bailing out. (Target server did not roll rounds as requested)"))
		log_game("POP-SPLIT: Bailing out. (Target server did not roll rounds as requested)")
		return ..()

	if(CONFIG_GET(flag/pop_split_exclude_admins))
		for(var/client/C in GLOB.pop_split_marked)
			if(C?.holder)
				GLOB.pop_split_marked -= C

	for(var/client/C in GLOB.pop_split_marked)
		if(!QDELETED(C) && !C.holder)
			log_access("Pop Split to [target_name]/[target]: [key_name(C)]")
			to_chat(C, span_boldannounce("You are being connected to [target_name] ([target])."))
			C?.tgui_panel?.send_roundrestart()
			C << link("byond://[target]")

	return ..()
