/// Assoc list of review IDs -> /datum/cassette_review instances
GLOBAL_ALIST_EMPTY(cassette_reviews)

/datum/cassette_review
	/// The actual cassette data
	var/datum/cassette/cassette_data
	/// The cassette tape item that was given to the postbox.
	var/obj/item/cassette_tape/tape
	/// Ckey of the original submitter
	var/submitter_ckey
	/// Weakref to the mob that originally submitted the tape.
	var/datum/weakref/original_submitter_mob
	/// Just used as an "ID" for the review itself.
	var/review_id = 0
	var/action_taken = FALSE

/datum/cassette_review/New(mob/submitter, obj/item/cassette_tape/tape)
	. = ..()
	var/static/last_review_id = 0

	src.cassette_data = tape.cassette_data
	src.tape = tape
	src.submitter_ckey = submitter.ckey
	src.original_submitter_mob = WEAKREF(submitter)
	src.review_id = ++last_review_id
	GLOB.cassette_reviews[review_id] = src

/datum/cassette_review/Destroy(force)
	GLOB.cassette_reviews -= review_id
	return_tape_to_submitter()
	cassette_data = null
	original_submitter_mob = null
	return ..()

/datum/cassette_review/proc/return_tape_to_submitter()
	if(QDELETED(tape))
		return
	var/mob/living/submitter_mob = original_submitter_mob?.resolve()
	if(istype(submitter_mob))
		tape.forceMove(submitter_mob.drop_location())
		if(iscarbon(submitter_mob))
			var/mob/living/carbon/submitter_carbon = submitter_mob
			var/static/list/slots = list(
				"hands" = ITEM_SLOT_HANDS,
				"backpack" = ITEM_SLOT_BACKPACK,
				"right pocket" = ITEM_SLOT_RPOCKET,
				"left pocket" = ITEM_SLOT_LPOCKET,
			)
			submitter_carbon.equip_in_one_of_slots(tape, slots, qdel_on_fail = FALSE)
		tape = null
	else
		QDEL_NULL(tape)

/datum/cassette_review/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CassetteReview", "[submitter_ckey]'s Cassette")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/cassette_review/ui_static_data(mob/user)
	return list(
		"cassette" = cassette_data.export(),
		"can_approve" = check_rights_for(user.client, R_FUN),
	)

/datum/cassette_review/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/cassette_review/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_FUN))
		return
	var/mob/user = ui.user
	switch(action)
		if("approve")
			. = TRUE
			action_taken = TRUE
			cassette_data.id = "[random_string(16, GLOB.hex_characters)]_[submitter_ckey]"
			cassette_data.status = CASSETTE_STATUS_APPROVED
			cassette_data.save_to_file()
			SScassettes.cassettes[cassette_data.id] = cassette_data
			tape.cassette_data = cassette_data.copy()
			SScassettes.save_ids_json()
			log_admin("[key_name(user)] has APPROVED [submitter_ckey]'s submitted tape \"[cassette_data.name]\" ([cassette_data.id])")
			message_admins("[key_name(user)] has APPROVED [submitter_ckey]'s submitted tape \"[cassette_data.name]\" ([cassette_data.id])")
			var/datum/persistent_client/original_submitter = GLOB.persistent_clients_by_ckey[submitter_ckey]
			to_chat(original_submitter.mob, span_big(span_notice("You can feel the Space Board of Music has <b>approved</b> your cassette: [cassette_data.name].")))
			qdel(src)
		if("deny")
			. = TRUE
			action_taken = TRUE
			cassette_data.status = CASSETTE_STATUS_DENIED
			tape.cassette_data = cassette_data.copy()
			log_admin("[key_name(user)] has DENIED [submitter_ckey]'s submitted tape \"[cassette_data.name]\" ([cassette_data.id])")
			message_admins("[key_name(user)] has DENIED [submitter_ckey]'s submitted tape \"[cassette_data.name]\" ([cassette_data.id])")
			var/datum/persistent_client/original_submitter = GLOB.persistent_clients_by_ckey[submitter_ckey]
			if(original_submitter)
				to_chat(original_submitter.mob, span_big(span_notice("You feel a wave of disappointment wash over you, the Space Board of Music has <b>rejected</b> your cassette: [cassette_data.name].")))
				original_submitter.client?.prefs?.adjust_metacoins(
					submitter_ckey,
					amount = 5000,
					reason = "Cassette Tape Rejected",
					announces = TRUE,
					donator_multiplier = FALSE,
				)
			qdel(src)

/datum/cassette_review/proc/operator""()
	return "[submitter_ckey]: \"[html_decode(cassette_data.name)]\" (#[review_id])"

#define ADMIN_OPEN_REVIEW(id) "(<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];open_music_review=[id]'>Open Review</a>)"

/proc/submit_cassette_for_review(mob/user, obj/item/cassette_tape/tape)
	if(!user.client || !istype(tape))
		return

	tape.cassette_data.author.name = user.real_name
	tape.cassette_data.author.ckey = user.ckey

	var/datum/cassette_review/new_review = new(user, tape)

	SEND_NOTFIED_ADMIN_MESSAGE('sound/items/bikehorn.ogg', "[span_big(span_admin("[span_prefix("MUSIC APPROVAL:")] <EM>[key_name(user)]</EM> [ADMIN_OPEN_REVIEW(new_review.review_id)] \
															has requested a review on their cassette."))]")
	to_chat(user, span_big(span_notice("Your Cassette has been sent to the Space Board of Music for review, you will be notified when an outcome has been made.")))
	tape.moveToNullspace()

#undef ADMIN_OPEN_REVIEW

ADMIN_VERB(cassette_reviews, R_ADMIN, FALSE, "Cassette Reviews", "Review submitted cassettes", ADMIN_CATEGORY_GAME)
	if(!length(GLOB.cassette_reviews))
		to_chat(user, span_warning("No cassettes are currently pending for review!"), type = MESSAGE_TYPE_ADMINLOG)
		return
	var/list/options = list()
	for(var/_id, review in GLOB.cassette_reviews)
		options += review
	var/datum/cassette_review/review = tgui_input_list(user, "Which cassette review would you like to open?", "Cassette Reviews", options, ui_state = ADMIN_STATE(R_ADMIN))
	if(!review)
		return
	review.ui_interact(user.mob)
