#ifndef OPENDREAM
// These procs don't work on OD.
SUBSYSTEM_DEF(memory_stats)
	name = "Mem Stats"
	init_order = INIT_ORDER_AIR
	priority = FIRE_PRIORITY_AIR
	wait = 5 MINUTES
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/datum/regex/parse_regex
	var/list/stats

/datum/controller/subsystem/memory_stats/Initialize()
	if(!aneri_file_exists(MEMORYSTATS_DLL_PATH))
		flags |= SS_NO_FIRE
		return SS_INIT_NO_NEED
	parse_regex = new(@"(?m)^\s*(?P<key>[^:]+):\s*(?P<size>[\d.]+)\s*(?P<unit>(?:B|KB|MB|GB))\s*\((?P<count>[,\d]+)\)$")
	if(!get_memory_stats()) // populate stats
		return SS_INIT_FAILURE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/memory_stats/Shutdown()
	QDEL_NULL(parse_regex)

/datum/controller/subsystem/memory_stats/fire(resumed)
	var/memory_summary = get_memory_stats()
	if(memory_summary)
		var/timestamp = time2text(world.timeofday, "YYYY-MM-DD_hh-mm-ss")
		aneri_file_write(json_encode(stats), "[GLOB.log_directory]/profiler/memstat-[timestamp].json")

/datum/controller/subsystem/memory_stats/proc/get_memory_stats()
	if(!aneri_file_exists(MEMORYSTATS_DLL_PATH))
		return
	. = trimtext(call_ext(MEMORYSTATS_DLL_PATH, "memory_stats")())
	if(.)
		stats = parse_memory_stats(.)

/datum/controller/subsystem/memory_stats/proc/parse_memory_stats(text)
	if(!istext(text))
		CRASH("passed non-text stat info: [text]")
	var/list/datum/regex_match/parsed_stats = parse_regex.find(text)
	if(!islist(parsed_stats))
		CRASH("parsed_stats was non-list object: [parsed_stats]")
	else if(!length(parsed_stats))
		CRASH("parsed_stats had no captures")
	. = list()
	var/total = 0
	for(var/datum/regex_match/stat as anything in parsed_stats)
		if(length(stat.captures) != 5)
			CRASH("invalid capture: match=\"[stat.match]\"")
		var/key = replacetext(stat.get_named_group("key")?.value, " ", "_")
		var/size = text2num(replacetext(stat.get_named_group("size")?.value, ",", ""))
		var/unit = stat.get_named_group("unit")?.value
		var/count = text2num(replacetext(stat.get_named_group("count")?.value, ",", ""))
		var/size_bytes = text2bytes(size, unit)
		if(isnull(size_bytes))
			CRASH("[key] had invalid size ([size]) or unit ([unit])")
		total += size_bytes
		.["[key]_memory"] = size_bytes
		.["[key]_count"] = count
	.["total_memory"] = total

/datum/controller/subsystem/memory_stats/get_metrics()
	. = ..()
	if(length(stats))
		.["custom"] = stats.Copy()
#endif

/client/proc/server_memory_stats()
	set name = "Server Memory Stats"
	set category = "Debug"
	set desc = "Print various statistics about the server's current memory usage (does not work on OpenDream)"

	if(!check_rights(R_DEBUG))
		return
#ifndef OPENDREAM
	var/result = span_danger("Error fetching memory statistics!")
	var/memory_stats = SSmemory_stats.get_memory_stats()
	if(memory_stats)
		result = trimtext(replacetext(memory_stats, "Server mem usage:", ""))
#else
	var/result = span_danger("Memory statistics not supported on OpenDream, sorry!")
#endif
	to_chat(src, fieldset_block("Memory Statistics", result, "boxed_message purple_box"), avoid_highlighting = TRUE, type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
