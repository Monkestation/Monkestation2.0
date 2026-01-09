SUBSYSTEM_DEF(token_manager)
	name = "Token Manager"
	flags = SS_NO_INIT | SS_NO_FIRE


	/// List of all pending token requests - list of /datum/token_request
	var/list/pending_requests = list()
	/// Count of accepted tokens this round
	var/accepted_count = 0
	/// Count of rejected tokens this round
	var/rejected_count = 0
	/// Count of timed out tokens this round
	var/timed_out_count = 0


/// Adds the request to the subsystem
/datum/controller/subsystem/token_manager/proc/add_pending_request(datum/token_request/request)
	pending_requests += request
	update_stat_panel()

/// Removes the request from the subsystem
/datum/controller/subsystem/token_manager/proc/remove_pending_request(datum/token_request/request)
	pending_requests -= request
	update_stat_panel()

/// Updates the accepted stat panel
/datum/controller/subsystem/token_manager/proc/record_accepted()
	accepted_count++
	update_stat_panel()

/// Updates the rejected stat panel
/datum/controller/subsystem/token_manager/proc/record_rejected()
	rejected_count++
	update_stat_panel()

/// Updates the timeout state panel
/datum/controller/subsystem/token_manager/proc/record_timeout()
	timed_out_count++
	update_stat_panel()

/datum/controller/subsystem/token_manager/proc/update_stat_panel()
	var/list/data = list(
		"accepted" = accepted_count,
		"pending" = length(pending_requests),
		"rejected" = rejected_count,
		"timed_out" = timed_out_count,
	)
	// Send to all admins
	for(var/client/admin_client as anything in GLOB.admins)
		admin_client << output(json_encode(data), "statbrowser:update_tokens")

/// Alerts all admins that a token request is about to timeout (1 minute warning)
/datum/controller/subsystem/token_manager/proc/alert_admins_timeout_warning(datum/token_request/request)
	if(QDELETED(request) || request.handled || !(request in pending_requests))
		return // Request was already handled

	var/admin_message = span_adminnotice("[span_adminsay("TOKEN WARNING:")] [key_name_admin(request.requester_client)]'s token request for [span_bold(request.details)] will timeout in [span_boldwarning("1 MINUTE")]!")
	var/admin_href = " (<a href='byond://?_src_=holder;[HrefToken()];token_approve=[REF(request)]'>APPROVE</a>) (<a href='byond://?_src_=holder;[HrefToken()];token_reject=[REF(request)]'>REJECT</a>) (<a href='byond://?_src_=holder;[HrefToken()];token_manager=1'>PANEL</a>)"

	for(var/client/admin_client as anything in GLOB.admins)
		to_chat(admin_client, "[admin_message][admin_href]")
		SEND_SOUND(admin_client, sound('sound/machines/buzz-sigh.ogg', volume = 50))


/// Pulls the info from the request
/datum/controller/subsystem/token_manager/proc/get_pending_requests_for_panel()
	var/list/requests_data = list()
	for(var/datum/token_request/request as anything in pending_requests)
		if(QDELETED(request))
			continue
		var/time_remaining = 0
		if(request.timeout_time)
			time_remaining = max(0, request.timeout_time - world.time)

		requests_data += list(list(
			"id" = REF(request),
			"requester_ckey" = request.requester_ckey,
			"requester_ref" = REF(request.requester_client?.mob),
			"type" = request.request_type,
			"details" = request.details,
			"tier" = request.tier,
			"is_donor" = request.is_donor_token,
			"time_submitted" = request.request_time,
			"time_remaining" = time_remaining,
			"time_remaining_text" = DisplayTimeText(time_remaining),
		))
	return requests_data

// ============================================================
// Round Statistics Gathering
// Uses SSgamemode variables directly
// ============================================================

/// Gets the current round time as a formatted string
/datum/controller/subsystem/token_manager/proc/get_round_time()
	if(!SSticker?.round_start_time)
		return "Not Started"
	var/elapsed = world.time - SSticker.round_start_time
	return DisplayTimeText(elapsed)

/// Gets the raw round time in deciseconds
/datum/controller/subsystem/token_manager/proc/get_round_time_raw()
	if(!SSticker?.round_start_time)
		return 0
	return world.time - SSticker.round_start_time

/// Compiles all round statistics into a list for TGUI. These stats are used to determine token acceptance, so is handy to have them all in the same place.
/datum/controller/subsystem/token_manager/proc/get_round_statistics()

	return list(
		// Time
		"round_time" = get_round_time(),
		"round_time_raw" = get_round_time_raw(),

		// Storyteller
		"storyteller_name" = SSgamemode?.current_storyteller?.name || "None",

		// Population from SSgamemode
		"active_players" = SSgamemode?.active_players || 0,

		// Department counts from SSgamemode
		"head_crew" = SSgamemode?.head_crew || 0,
		"sec_crew" = SSgamemode?.sec_crew || 0,
		"eng_crew" = SSgamemode?.eng_crew || 0,
		"med_crew" = SSgamemode?.med_crew || 0,

		// Antagonist points from SSgamemode
		"antag_count" = SSgamemode?.get_antag_count() || 0,
		"antag_cap" = SSgamemode?.get_antag_cap() || 0,
	)

// ============================================================
// TGUI Integration
// ============================================================

/datum/controller/subsystem/token_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TokenManager")
		ui.open()
		ui.set_autoupdate(TRUE) // Auto-update for live time display

/datum/controller/subsystem/token_manager/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/controller/subsystem/token_manager/ui_data(mob/user)
	var/list/data = list()

	// Token statistics
	data["pending_requests"] = get_pending_requests_for_panel()
	data["accepted_count"] = accepted_count
	data["rejected_count"] = rejected_count
	data["timed_out_count"] = timed_out_count
	data["total_processed"] = accepted_count + rejected_count + timed_out_count

	// Round statistics
	data["round_stats"] = get_round_statistics()

	return data

/datum/controller/subsystem/token_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	// Allows for approval/deny from the panel itself
	switch(action)
		if("approve")
			var/datum/token_request/request = locate(params["id"]) in pending_requests
			if(!request)
				to_chat(user, span_warning("That token request no longer exists."))
				return TRUE
			request.approve(user)
			log_admin("[key_name(user)] approved [request.requester_ckey]'s token request for [request.details].")
			return TRUE

		if("reject")
			var/datum/token_request/request = locate(params["id"]) in pending_requests
			if(!request)
				to_chat(user, span_warning("That token request no longer exists."))
				return TRUE
			request.reject(user)
			log_admin("[key_name(user)] rejected [request.requester_ckey]'s token request for [request.details].")
			message_admins("[key_name_admin(user)] rejected [request.requester_ckey]'s token request for [request.details].")
			return TRUE

		if("refresh")
			return TRUE
		// Vuap view on the player if the admin wants more info.
		if("view_player")
			var/datum/token_request/request = locate(params["id"]) in pending_requests
			if(!request?.requester_client?.mob)
				to_chat(user, span_warning("That player is no longer available."))
				return TRUE
			var/datum/admins/admin = GLOB.admin_datums[user.ckey]
			if(admin)
				var/mob/target = request.requester_client?.mob
				SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/vuap_personal, target)
			return TRUE

	return FALSE

// ============================================================
// Token Request Datum
// ============================================================

/datum/token_request
	/// The ckey of the requester
	var/requester_ckey
	/// Direct reference to the requester's client
	var/client/requester_client
	/// Type of request - currently only "antag"
	var/request_type = "antag"
	/// What they're requesting (antag type name)
	var/details
	/// The threat tier (HIGH_THREAT, MEDIUM_THREAT, LOW_THREAT)
	var/tier
	/// Whether this is using a donor token
	var/is_donor_token = FALSE
	/// World.time when the request was made
	var/request_time
	/// World.time when this request will timeout
	var/timeout_time
	/// Reference to the token holder that owns this request
	var/datum/meta_token_holder/holder_ref
	/// Timer ID for the timeout
	var/timeout_timer
	/// Timer ID for the 1-minute warning
	var/warning_timer
	/// Handler for not 1 minute warning tokens that have been approved or denied.
	var/handled = FALSE

/datum/token_request/New(mob/requester, datum/meta_token_holder/holder, details, tier, is_donor = FALSE)
	. = ..()
	src.requester_ckey = requester?.ckey
	src.requester_client = requester.client
	src.holder_ref = holder
	src.details = details
	src.tier = tier
	src.is_donor_token = is_donor
	src.request_time = world.time
	src.timeout_time = world.time + 5 MINUTES

	// Set up the 1-minute warning timer (fires at 4 minutes)
	warning_timer = addtimer(CALLBACK(SStoken_manager, TYPE_PROC_REF(/datum/controller/subsystem/token_manager, alert_admins_timeout_warning), src), 4 MINUTES, TIMER_STOPPABLE)

	// Set up the timeout timer
	timeout_timer = addtimer(CALLBACK(src, PROC_REF(timeout)), 5 MINUTES, TIMER_STOPPABLE)

/datum/token_request/Destroy()
	// Clean up timers, removes the pending request.
	if(warning_timer)
		deltimer(warning_timer)
		warning_timer = null
	if(timeout_timer)
		deltimer(timeout_timer)
		timeout_timer = null
	SStoken_manager.remove_pending_request(src)
	holder_ref = null
	requester_client = null
	return ..()

/datum/token_request/proc/approve(mob/admin)
	if(QDELETED(holder_ref))
		return FALSE
	handled = TRUE
	holder_ref.approve_antag_token()
	qdel(src)
	return TRUE

/datum/token_request/proc/reject(mob/admin)
	if(QDELETED(holder_ref))
		return FALSE
	handled = TRUE
	holder_ref.reject_antag_token()
	qdel(src)
	return TRUE

/datum/token_request/proc/timeout()
	timeout_timer = null // Timer has fired, clear the reference (necessary? IDK!)

	if(!QDELETED(holder_ref))
		holder_ref.timeout_antag_token()
	qdel(src)


// ============================================================
// Admin Verb
// ============================================================
ADMIN_VERB(token_manager, R_ADMIN, FALSE, "Token Manager", "TGUI Token Manager", ADMIN_CATEGORY_MAIN)
	SStoken_manager.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Token Manager")
