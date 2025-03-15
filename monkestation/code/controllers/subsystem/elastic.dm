/datum/config_entry/string/elastic_endpoint
	protection = CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/metrics_api_token
	protection = CONFIG_ENTRY_HIDDEN

/datum/config_entry/flag/elastic_middleware_enabled

SUBSYSTEM_DEF(elastic)
	name = "Elastic Middleware"
	init_order = INIT_ORDER_ELASTIC
	wait = 30 SECONDS
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	flags = SS_KEEP_TIMING // This needs to ingest every 30 IRL seconds, not ingame seconds.
	///this is set in Genesis
	var/world_init_time = 0
	///this NEEDS NEEDS NEEDS NEEDS NEEDS to be assoclists when 516 is in this will be an alist
	var/list/assoc_list_data = list()
	///abstract information - basically want to keep track of spell casts over the round? do it like this
	var/list/abstract_information = list()

/datum/controller/subsystem/elastic/Initialize(start_timeofday)
	if(!CONFIG_GET(flag/elastic_middleware_enabled))
		flags |= SS_NO_FIRE // Disable firing to save CPU
		return SS_INIT_NO_NEED
	set_abstract_data_zeros()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/elastic/Shutdown()
	if(CONFIG_GET(flag/elastic_middleware_enabled))
		send_data(wait = 5 SECONDS)

/datum/controller/subsystem/elastic/Recover()
	if(!CONFIG_GET(flag/elastic_middleware_enabled))
		flags |= SS_NO_FIRE
	flags |= SS_NO_INIT
	world_init_time = SSelastic.world_init_time
	assoc_list_data = SSelastic.assoc_list_data
	abstract_information = SSelastic.abstract_information

/datum/controller/subsystem/elastic/fire(resumed)
	send_data()

/datum/controller/subsystem/elastic/proc/send_data(all_data = TRUE, wait = 0 SECONDS)
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, CONFIG_GET(string/elastic_endpoint), get_compiled_data(all_data), list(
		"Authorization" = "ApiKey [CONFIG_GET(string/metrics_api_token)]",
		"Content-Type" = "application/json"
	))
	request.begin_async()
	if(wait > 0)
		UNTIL_OR_TIMEOUT(request.is_complete(), wait)

/datum/controller/subsystem/elastic/proc/get_compiled_data(all_data)
	var/list/compiled = list()
	//DON'T CHANGE THE TIMESTAMP EVER OR THIS WILL ALL BREAK
	compiled["@timestamp"] = time2text(world.timeofday, "YYYY-MM-DDThh:mm:ss")
	compiled["cpu"] = world.cpu
	compiled["maptick"] = world.map_cpu
	compiled["elapsed_process_time"] = world.time
	compiled["elapsed_real_time"] = (REALTIMEOFDAY - world_init_time)
	compiled["client_count"] = length(GLOB.clients)
	compiled["round_id"] = text2num(GLOB.round_id)
	compiled["time_dilation_current"] = SStime_track.time_dilation_current
	compiled["time_dilation_avg"] = SStime_track.time_dilation_avg
	compiled["time_dilation_avg_slow"] = SStime_track.time_dilation_avg_slow
	compiled["time_dilation_avg_fast"] = SStime_track.time_dilation_avg_fast
	///you see why this needs to be an assoc list now?
	compiled |= assoc_list_data

	compiled["round_data"] = get_round_data()
	assoc_list_data = list()
	return json_encode(compiled)

/datum/controller/subsystem/elastic/proc/get_round_data()
	return list(
		"maint_pills_eaten" = GLOB.maint_pills_eaten,
		"deaths" = GLOB.player_deaths,
	)

/datum/controller/subsystem/elastic/proc/add_list_data(main_cat = "generic", list/assoc_data)
	if(!main_cat || !length(assoc_data))
		return

	assoc_list_data |= main_cat
	if(!length(assoc_list_data[main_cat]))
		assoc_list_data[main_cat] = list()
	assoc_list_data[main_cat] |= assoc_data

///this is best for numerical data think x event ran 12 times since you're updating the number with the total run anyway.
/proc/add_elastic_data(main_cat, list/assoc_data)
	if(!main_cat || !length(assoc_data))
		return
	SSelastic.add_list_data(main_cat, assoc_data)
	return TRUE

///this should be used for logging purposes think runtimes, or wanting to track player x does y
/proc/add_elastic_data_immediate(main_cat, list/assoc_data)
	if(!main_cat || !length(assoc_data))
		return
	SSelastic.add_list_data(main_cat, assoc_data)
	SSelastic.send_data()
	return TRUE

///this is best for numerical data think x event ran 12 times since you're updating the number with the total run anyway.
/proc/add_abstract_elastic_data(main_cat, abstract_name, abstract_value, maximum)
	if(!isnum(abstract_value))
		return
	if(!main_cat)
		return
	SSelastic.abstract_information |= abstract_name
	SSelastic.abstract_information[abstract_name] += abstract_value
	if(maximum)
		SSelastic.abstract_information[abstract_name] = min(maximum, SSelastic.abstract_information[abstract_name])

	var/list/data = list("[abstract_name]" = SSelastic.abstract_information[abstract_name])
	SSelastic.add_list_data(main_cat, data)
	return TRUE

///this really exists if you want data to start at 0 useful for timeseries data without round filtering
/proc/set_abstract_data_zeros()
	/* add_abstract_elastic_data("combat", "todo", 0) */
