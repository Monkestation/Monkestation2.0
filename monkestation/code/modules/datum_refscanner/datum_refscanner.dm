/datum/log_category/refscanner
	category = "refscanner"

/* This comment bypasses grep checks */ /var/__refscanner
#define REFSCANNER_DLL (world.system_type == MS_WINDOWS ? "datum_refscanner.dll" : (__refscanner ||= __detect_auxtools("datum_refscanner")))

GLOBAL_VAR_INIT(datum_refscanner_ready, FALSE)
// unit tests hard delete constantly and CI runs a build the scanner was never checked on
#ifdef UNIT_TESTS
GLOBAL_VAR_INIT(datum_refscanner_enabled, FALSE)
#else
GLOBAL_VAR_INIT(datum_refscanner_enabled, TRUE)
#endif

/// Attempt to initialize datum_refscanner.dll. Returns TRUE on success.
/// Safe to call multiple times; init is only attempted once.
/proc/refscanner_ensure_ready()
	if(GLOB.datum_refscanner_ready)
		return TRUE
	try
		var/err = call_ext(REFSCANNER_DLL, "refscanner_init")()
		if(err)
			stack_trace("datum_refscanner: init error: [err]")
			return FALSE
	catch(var/exception/e)
		stack_trace("datum_refscanner: failed to load DLL: [e]")
		return FALSE
	GLOB.datum_refscanner_ready = TRUE
	refscanner_log_coverage()
	return TRUE

/// Decoded coverage report: which tables this build supports. Assoc list with
/// "build", "complete", "scanned", "forward_validated", "fallback" and
/// "unavailable" keys, or null if the scanner isn't ready.
/proc/refscanner_coverage()
	if(!GLOB.datum_refscanner_ready)
		return null
	var/json = call_ext(REFSCANNER_DLL, "refscanner_get_coverage")()
	if(json)
		return json_decode(json)

/// One-time coverage report to the log (and admins, if partial).
/proc/refscanner_log_coverage()
	var/list/coverage = refscanner_coverage()
	if(!islist(coverage))
		return
	if(coverage["complete"])
		logger.Log("refscanner", "native refscanner coverage complete on build [coverage["build"]]")
		return
	var/list/unavailable = coverage["unavailable"]
	var/skipped = islist(unavailable) ? jointext(unavailable, ", ") : "?"
	var/msg = "native refscanner has PARTIAL coverage on build [coverage["build"]] - not scanned: [skipped]. Findings for these tables will be missing."
	message_admins(msg)
	logger.Log("refscanner", msg)

/// Drain native debug output from the scanner.
/proc/refscanner_debug_drain()
	if(!GLOB.datum_refscanner_ready)
		return null
	var/raw = call_ext(REFSCANNER_DLL, "refscanner_get_debug")()
	if(!raw)
		return null
	var/list/lines = splittext(raw, "\n")
	while(length(lines) && lines[length(lines)] == "")
		lines.len--
	return length(lines) ? lines : null

/proc/refscanner_findings_json()
	if(!GLOB.datum_refscanner_ready)
		return null
	return call_ext(REFSCANNER_DLL, "refscanner_get_findings_json")()

/// Scan for everything holding `thing` right now, without deleting it. Do it
/// before del(): byond deletes an atom's contents before its own erase runs, so
/// a scan hooked on the erase never sees an item inside `thing` pointing back at it.
/// Returns "" or why it did not scan.
/proc/refscanner_scan_now(thing)
	if(!GLOB.datum_refscanner_ready)
		return "refscanner not ready"
	return call_ext(REFSCANNER_DLL, "refscanner_scan_now")(text_ref(thing))

/proc/refscanner_clear()
	if(!GLOB.datum_refscanner_ready)
		return
	call_ext(REFSCANNER_DLL, "refscanner_clear")()

/// Returns the findings from the last scan as a list of readable lines.
/proc/refscanner_report()
	. = list()
	var/json = refscanner_findings_json()
	if(!json)
		return
	var/list/findings = json_decode(json)
	for(var/list/entry in findings)
		. += _refscanner_fmt_entry(entry)

/proc/_refscanner_fmt_entry(list/f)
	var/kind = f["holder_kind"]
	switch(kind)
		if("list")
			// The list itself holds the leaked reference directly (vector slot).
			return "\[list\]       list #[f["list_id"]] \[index [f["index"]]\] (len=[f["length"]], refs=[f["ref_count"]])"

		if("list_assoc_value")
			return "\[list_assoc\]  list #[f["list_id"]] (assoc value) (len=[f["length"]], refs=[f["ref_count"]])"

		if("list_key")
			// A list keeps its keys in the same array as plain elements, so this row
			// stands in for the element row(s). More than one folded row means the
			// datum sits in several slots behind one tree node, each its own reference.
			var/folded = f["folded_vector_rows"]
			var/extra = (folded > 1) ? " in [folded] element slots" : ""
			return "\[list_key\]   list #[f["list_id"]] \[key[extra]\] (len=[f["length"]], refs=[f["ref_count"]])"

		if("alist_key")
			// an alist has no element array, so the key is the only place the ref exists
			return "\[alist_key\]  alist #[f["alist_id"]] \[key\]"

		if("list_owner")
			// A var or list slot holds a list that contains the leaked reference.
			var/owner_kind = f["owner_kind"]
			var/owner_desc
			if(owner_kind == "list")
				if(f["slot"] == "assoc_value")
					if(f["key"])
						owner_desc = "list #[f["holder_id"]] \[assoc value key \"[f["key"]]\"\]"
					else
						owner_desc = "list #[f["holder_id"]] \[assoc value\]"
				else
					owner_desc = "list #[f["holder_id"]] \[index [f["index"]]\]"
			else
				owner_desc = _refscanner_fmt_holder(owner_kind, f["holder_id"], f["typepath"], f["var_name"])
			return "\[list_owner\] [owner_desc] -> list #[f["list_id"]]"

		if("suspended_proc")
			var/proc_name = f["proc_name"] || "?proc"
			var/loc = f["filename"] ? "[f["filename"]]:[f["line"]]" : "?"
			return "\[suspended_proc\] [proc_name] [_refscanner_fmt_proc_slot(f)] @ [loc]"

		if("suspended_proc_list_owner")
			// same as above, except the slot holds a list that contains the reference
			var/owner_name = f["proc_name"] || "?proc"
			var/owner_loc = f["filename"] ? "[f["filename"]]:[f["line"]]" : "?"
			return "\[susp_owner\] [owner_name] [_refscanner_fmt_proc_slot(f)] @ [owner_loc] -> list #[f["list_id"]]"

		else
			// A datum/obj/mob/global var holds the leaked reference directly.
			return "\[finding\]    [_refscanner_fmt_holder(kind, f["holder_id"], f["typepath"], f["var_name"])]"

/// "arg#1", "loop#0", or ".usr" for a slot with no index.
/proc/_refscanner_fmt_proc_slot(list/f)
	if(isnull(f["index"]))
		return ".[f["field"]]"
	return "[f["field"]]#[f["index"]]"

/// Format "datum #42 (/datum/foo).bar" style descriptions.
/proc/_refscanner_fmt_holder(kind, holder_id, typepath, var_name)
	var/label
	switch(kind)
		if("datum")      label = "datum #[holder_id]"
		if("atom_a")     label = "obj #[holder_id]"
		if("atom_b")     label = "mob #[holder_id]"
		if("global_var") label = "global #[holder_id]"
		else             label = "[kind] #[holder_id]"
	if(typepath)
		label += " ([typepath])"
	if(var_name)
		label += ".[var_name]"
	return label

ADMIN_VERB(toggle_native_refscanner, R_DEBUG, FALSE, "Toggle Native RefScanner", "Toggle the native refscanner.", ADMIN_CATEGORY_DEBUG)
	GLOB.datum_refscanner_enabled = !GLOB.datum_refscanner_enabled
	message_admins("[key_name(user)] [GLOB.datum_refscanner_enabled ? "enabled" : "disabled"] the native refscanner.")
	log_admin("[key_name(user)] [GLOB.datum_refscanner_enabled ? "enabled" : "disabled"] the native refscanner.")
	BLACKBOX_LOG_ADMIN_VERB("Toggle Native RefScanner")

#if defined(TESTING) || defined(ABSOLUTE_MINIMUM) || defined(SPACEMAN_DMM)
/// Holder datum that deliberately does NOT null held_ref in Destroy(),
/// simulating a reference leak for the native scanner to detect.
/datum/refscanner_test_holder
	var/datum/victim/held_ref
	var/list/storedRooms

GLOBAL_VAR(meow_a)
GLOBAL_VAR(meow_b)
GLOBAL_LIST(meow_c)
GLOBAL_LIST(meow_d)
GLOBAL_LIST(meow_e)

/datum/victim

/datum/victim/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

/client
	var/datum/victim/meow

/proc/eepy_proc(a)
	var/datum/victim/victim = a
	sleep(5 SECONDS)
	return victim

/proc/_refscanner_print_results(mob/user, scenario)
	var/list/lines = refscanner_report()
	if(!length(lines))
		to_chat(user, span_warning("=== RefScanner: [scenario] - no findings ==="))
		return
	to_chat(user, span_boldnotice("=== RefScanner: [scenario] - [length(lines)] finding(s) ==="))
	for(var/line in lines)
		to_chat(user, span_notice("  [line]"))

ADMIN_VERB(refscanner_run_test, R_DEBUG, FALSE, "Test Native RefScanner", \
	"Runs three reference-leak scenarios through the native pre-erasure scanner.", \
	ADMIN_CATEGORY_DEBUG)

	if(!refscanner_ensure_ready())
		to_chat(user, span_warning("datum_refscanner could not be loaded - check the game log for details."))
		return

	// scenario 1: holder.held_ref and GLOB.meow_b both point at victim and neither
	// is nulled before the hard delete, so both should be reported
	var/datum/refscanner_test_holder/holder = new()
	var/datum/victim/victim = new()
	holder.held_ref = victim
	GLOB.meow_a = holder
	GLOB.meow_b = victim
	GLOB.meow_d = list(
		victim = "meow",
	)
	GLOB.meow_e = list(
		"hi" = victim
	)
	user.meow = victim

	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(eepy_proc), victim)

	qdel(victim)
	_refscanner_print_results(user, "scenario 1 - direct datum+global refs")

	victim = null
	GLOB.meow_a = null
	GLOB.meow_b = null
	GLOB.meow_c = null
	GLOB.meow_d = null
	GLOB.meow_e = null
	holder.held_ref = null
	user.meow = null
	qdel(holder)

	// scenario 2: victim2 -> inner_list -> outer_list -> GLOB.meow_c, so the
	// scanner has to chase the list owners up to the global
	var/datum/victim/victim2 = new()
	var/list/inner_list = list(victim2)
	var/list/outer_list = list(inner_list)
	GLOB.meow_b = victim2
	GLOB.meow_c = list(outer_list)
	GLOB.meow_d = list(
		list(victim) = "meow",
	)
	GLOB.meow_e = list(
		"hi" = list(victim)
	)
	user.meow = list(outer_list)

	qdel(victim2)
	_refscanner_print_results(user, "scenario 2 - nested vector list owners")

	victim2 = null
	inner_list = null
	outer_list = null
	GLOB.meow_b = null
	GLOB.meow_c = null
	GLOB.meow_d = null
	GLOB.meow_e = null
	user.meow = null

	// scenario 3: victim3 -> contents_list -> room_storage -> storedRooms["roomnumber"]
	// -> assoc_holder.storedRooms, through an associative value
	var/datum/refscanner_test_holder/assoc_holder = new()
	var/datum/victim/victim3 = new()
	var/list/contents_list = list(victim3)
	var/list/room_storage = list(contents_list)
	assoc_holder.storedRooms = list("roomnumber" = room_storage)
	GLOB.meow_a = assoc_holder

	qdel(victim3)
	_refscanner_print_results(user, "scenario 3 - assoc-value list owner BFS")

	victim3 = null
	contents_list = null
	room_storage = null
	assoc_holder.storedRooms = null
	GLOB.meow_a = null
	qdel(assoc_holder)
#endif
