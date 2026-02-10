// source.dm - code for a client server that wants to split population to a target server

// List of clients that will be split for pop
GLOBAL_LIST_EMPTY(pop_split_marked)
GLOBAL_VAR_INIT(pop_splitting, FALSE)

// On round end
/datum/controller/subsystem/ticker/standard_reboot()
	. = ..()

	if(!CONFIG_GET(flag/pop_split))
		return

	var/threshold = CONFIG_GET(number/pop_split_threshold)
	var/passed_threshold = length(GLOB.clients) >= threshold

	if(!passed_threshold)
		return

	// Check if the target world can reboot, if so, DO IT BITCH


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

	GLOB.pop_split_marked = marked_clients
	GLOB.pop_splitting = TRUE

	var/target = CONFIG_GET(string/pop_split_target)
	var/target_name = CONFIG_GET(string/pop_split_target_name)

	to_chat(GLOB.pop_split_marked, span_boldnotice("You have been selected for pop splitting, you will be moved over to '[target_name]' ([target])"))
	message_admins(span_bolddanger("Pop split is active (Over [threshold] players). [CONFIG_GET(flag/pop_split_exclude_admins) ? "\[Admins are exempt from pop split]" : ""]"))


/datum/controller/subsystem/server_maint/Shutdown()
	if(!CONFIG_GET(flag/pop_split))
		return ..()
	var/bailout_threshold = CONFIG_GET(number/pop_split_bailout_threshold)
	if(length(GLOB.clients) < bailout_threshold)
		GLOB.pop_splitting = FALSE
		message_admins(span_bolddanger("Pop split bailing out. (Player count below [bailout_threshold])"))
		return ..()

	if(CONFIG_GET(flag/pop_split_exclude_admins))
		for(var/client/C in GLOB.pop_split_marked)
			if(C?.holder)
				GLOB.pop_split_marked -= C

	var/target = CONFIG_GET(string/pop_split_target)
	var/target_name = CONFIG_GET(string/pop_split_target_name)

	for(var/client/C in GLOB.pop_split_marked)
		if(!QDELETED(C) && !C.holder)
			log_access("Pop Split to [target_name]: [key_name(C)]")
			to_chat(C, span_boldannounce("You are being connected to [target_name] ([target])."))
			C?.tgui_panel?.send_roundrestart()
			C << link("byond://[target]")

	return ..()






// cmp_playtime_asc
// cmp_playtime_dsc
