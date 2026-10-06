/// writes the end-of-round JIT stats the CI summary step picks up, and echoes
/// them to the world log so they show in the Run Tests output too. runtimes are
/// in here because the no-JIT baseline round exists to be compared against them.
/proc/dmeow_write_ci_stats()
	var/list/lines = list("runtimes: [GLOB.total_runtimes]")
	if(!dmeow_loaded)
		lines += "dmeow: not loaded"
	else
		lines += "dmeow: loaded, JIT [dmeow_armed ? "armed" : "NOT armed"], hooks [dmeow_hooks_enabled ? "on" : "off"]"
		lines += "eligible procs: [length(dmeow_list_eligible())]"

		// merges this run's verdicts into the cache file, which is what the counts below read
		dmeow_cache_save()
		var/list/cache = json_decode(dmeow_cache_status())
		var/list/counts = cache["file_counts"]
		if(counts)
			lines += "compiled whole: [counts["full_jit"]]"
			lines += "compiled partly (bail to interpreter): [counts["partial_jit"]]"
			lines += "compile failed: [counts["compile_failed"]]"
			lines += "demoted after deopts: [counts["demoted"]]"
			lines += "refused for sleeping underneath: [counts["sleep_unsafe"]]"
			lines += "ineligible: [counts["ineligible"]]"
		lines += "deopt + symbol status:\n[dmeow_deopt_status()]"

	var/report = lines.Join("\n")
	rustg_file_write(report, "[GLOB.log_directory]/dmeow_stats.txt")
	log_world("DMEOW STATS\n[report]")
