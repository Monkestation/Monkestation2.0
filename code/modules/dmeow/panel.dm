ADMIN_VERB(dmeow_panel, R_DEBUG, FALSE, "dmeow (JIT) panel", "Arm and inspect the dmeow JIT.", ADMIN_CATEGORY_DEBUG)
	var/datum/dmeow_panel/panel = new()
	panel.ui_interact(user.mob)

// status_text only updates on an explicit refresh - every live read locks the
// DLL, so none of them ride the autoupdate tick.
/datum/dmeow_panel
	var/status_text
	var/last_result
	var/asm_proc_path
	var/asm_text

/datum/dmeow_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DmeowPanel")
		ui.open()

/datum/dmeow_panel/ui_state(mob/user)
	return ADMIN_STATE(R_DEBUG)

/datum/dmeow_panel/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/dmeow_panel/ui_static_data(mob/user)
	return list(
		"asm_proc_path" = asm_proc_path,
		"asm_text" = asm_text,
	)

/datum/dmeow_panel/ui_data(mob/user)
	return list(
		"loaded" = dmeow_loaded,
		"armed" = dmeow_armed,
		"hooks_enabled" = dmeow_hooks_enabled,
		"counting_threshold" = dmeow_counting_threshold,
		"status_text" = status_text,
		"last_result" = last_result,
	)

/datum/dmeow_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	// ui_state gates opening the window, not reaching this proc.
	if(!check_rights(R_DEBUG))
		return
	if(action == "load")
		if(!dmeow_init())
			last_result = "dmeow failed to load - see world log"
			return TRUE
		last_result = dmeow_rearm()
		return TRUE
	if(!dmeow_loaded)
		last_result = "dmeow is not loaded"
		return TRUE

	switch(action)
		if("refresh_status")
			status_text = "[dmeow_deopt_status()]\n[dmeow_debug_status()]"
			return TRUE
		if("toggle_hooks")
			dmeow_hooks_enabled = !!dmeow_toggle_hooks()
			last_result = "hooks [dmeow_hooks_enabled ? "enabled" : "disabled"]"
			message_admins("dmeow: [last_result]")
			world.log << "dmeow: [last_result]"
			return TRUE
		if("compile")
			return compile_one(params["proc_name"])
		if("bytecode")
			return dump_bytecode(params["proc_name"], usr)
		if("dump_asm")
			return dump_asm(params["proc_name"])
		if("analysis")
			return dump_analysis()
		if("census")
			return dump_compile_census()
		if("eligible")
			return dump_eligible()
		if("debug_flush")
			last_result = "debug log flushed to [dmeow_debug_flush()]"
			return TRUE
		if("debug_marker")
			var/marker = params["text"]
			if(!marker)
				return FALSE
			dmeow_debug_marker(marker)
			last_result = "marker written: [marker]"
			return TRUE

/datum/dmeow_panel/proc/compile_one(proc_name)
	if(!proc_name)
		return FALSE
	if(dmeow_compile(proc_name))
		last_result = "compiled [proc_name]"
	else
		last_result = "FAILED to compile [proc_name]"
	world.log << "dmeow: [last_result]"
	return TRUE

/datum/dmeow_panel/proc/dump_bytecode(proc_name, mob/user)
	if(!proc_name)
		return FALSE
	var/bytecode = dmeow_dump_bytecode(proc_name)
	world.log << "\ndmeow: dumped bytecode\n[bytecode]\n"
	to_chat(user, fieldset_block("bytecode for [proc_name]", "[bytecode]", "boxed_message"))
	last_result = "dumped bytecode for [proc_name] to chat + world log"
	return TRUE

/datum/dmeow_panel/proc/dump_asm(proc_name)
	if(!proc_name)
		return FALSE
	asm_proc_path = proc_name
	asm_text = dmeow_proc_asm(proc_name)
	last_result = "dumped assembly for [proc_name]"
	update_static_data_for_all_viewers()
	return TRUE

/datum/dmeow_panel/proc/dump_analysis()
	var/analysis = dmeow_analyze_procs()
	var/filename = "[GLOB.log_directory]/dmeow/analysis/[rustg_unix_timestamp()].txt"
	var/analysis_file = file(filename)
	analysis_file << analysis
	last_result = "wrote proc analysis to [filename]"
	message_admins("dmeow: [last_result]")
	world.log << "dmeow: [last_result]"
	return TRUE

/datum/dmeow_panel/proc/dump_compile_census()
	var/census = dmeow_compile_census()
	var/filename = "[GLOB.log_directory]/dmeow/census/[rustg_unix_timestamp()].txt"
	var/census_file = file(filename)
	census_file << census
	last_result = "wrote compile census to [filename]"
	message_admins("dmeow: [last_result]")
	world.log << "dmeow: [last_result]"
	return TRUE

/datum/dmeow_panel/proc/dump_eligible()
	var/list/eligible_procs = dmeow_list_eligible()
	fdel("eligible_procs.txt")
	rustg_file_write(json_encode(eligible_procs, JSON_PRETTY_PRINT), "eligible_procs.txt")
	last_result = "[length(eligible_procs)] eligible procs written to eligible_procs.txt"
	message_admins("dmeow: [last_result]")
	return TRUE
