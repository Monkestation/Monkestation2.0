#define OWNER 0
#define STRANGER 1

/datum/brain_trauma/special/intrusive_thoughts
	name = "Intrusive Thoughts"
	desc = "Patient's suffers from seemingly random and intrusive thoughts."
	scan_desc = "brain in conflict with self"
	gain_text = span_warning("You feel like there's a voice in your head...")
	resilience = TRAUMA_RESILIENCE_ABSOLUTE
	lose_text = span_notice("You feel once more at peace with your thoughts.")
	/// Boolean value of whether the original personality is in control
	var/current_controller = OWNER
	/// To prevent personalities deleting themselves while we wait for ghosts
	var/initialized = FALSE
	/// Ride along mob to hold the ghost player's client when not in control
	var/mob/living/intrusive_thoughts/stranger_backseat
	/// Ride along mob to hold the main player's client when not in control
	var/mob/living/intrusive_thoughts/owner_backseat
	///The role to display when polling ghost
	var/poll_role = "intrusive thoughts"

/datum/brain_trauma/special/intrusive_thoughts/on_gain()
	/// mob the brain belongs to (the body)
	var/mob/living/brain_owner = owner
	if(!GET_CLIENT(brain_owner) || istype(get_area(brain_owner), /area/deathmatch)) //No use assigning people to braindead
		qdel(src)
		return FALSE
	. = ..()
	make_backseats()
	get_ghost()

/datum/brain_trauma/special/intrusive_thoughts/on_lose()
	if(current_controller != OWNER) //it would be funny to cure a guy only to be left with the other personality, but it seems too cruel
		switch_personalities(TRUE)
	QDEL_NULL(stranger_backseat)
	QDEL_NULL(owner_backseat)
	return ..()

/datum/brain_trauma/special/intrusive_thoughts/on_life(seconds_per_tick, times_fired)
	if(owner.stat == DEAD)
		if(current_controller == STRANGER)
			switch_personalities(TRUE)
	else if((SPT_PROB(1.5, seconds_per_tick) && current_controller == OWNER) || (SPT_PROB(20.0, seconds_per_tick) && current_controller != OWNER))
		switch_personalities()
	return ..()
	// VERY HIGH chance to swap back to owner control (20.0%)
	// Very LOW chance to swap to intrusive thoughts control (1.5%)

/**
 * Creates invisible "body"s for non controller
 *
 * Creates two invisible mobs that are attached to the main body,
 * used for storing the client control during swaps and giving
 * communion spell to the backseat.
*/
/datum/brain_trauma/special/intrusive_thoughts/proc/make_backseats()
	stranger_backseat = new(owner, src)
	var/datum/action/intrude_thought/stranger_spell = new(src)
	stranger_spell.Grant(stranger_backseat)

	owner_backseat = new(owner, src)
	var/datum/action/intrude_thought/owner_spell = new(src)
	owner_spell.Grant(owner_backseat)

/**
 * Attempts to get a ghost to play the intrusive thoughts
 *
 * Runs a ghost poll to get an observer/ghost to play the alternate personalty/intrusive thoughts.
 *
 * Calls schism after the poll concludes.
*/
/datum/brain_trauma/special/intrusive_thoughts/proc/get_ghost()
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(
		question = "Do you want to play as [span_danger("[owner.real_name]'s")] [span_notice(poll_role)]?",
		check_jobban = ROLE_PAI,
		poll_time = 120 SECONDS,
		checked_target = owner,
		ignore_category = POLL_IGNORE_SPLITPERSONALITY,
		alert_pic = owner,
		role_name_text = poll_role,
	)
	schism(chosen_one)

/**
 * Assigns ghost to the backseat of the trauma
 *
 * Runs after the ghost poll concludes, deletes the trauma if no ghost
 * or assigns the ghost to the backseat mob if one was found
 *
 * Arguments
 * * mob/dead/observer/ghost - observer/ghost player, assigns ghost's (c)key to backseat mob
*/
/datum/brain_trauma/special/intrusive_thoughts/proc/schism(mob/dead/observer/ghost)
	if(isnull(ghost))
		qdel(src)
		return

	stranger_backseat.PossessByPlayer(ghost.key)
	stranger_backseat.log_message("became [key_name(owner)]'s intrusive thoughts.", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(stranger_backseat)] became [ADMIN_LOOKUPFLW(owner)]'s intrusive thoughts.")


/**
 * Swaps control of the body to the other personality
 *
 * Handles swapping the two clients sharing the body between three mobs:
 * main body, active backseat, and inactive backseat.
 * Moves client currently controling the body to the inactive backseat mob
 * then moves active backseat client to control the main body.
 *
 * Arguments:
 * * reset_to_owner - Boolean, if true will attempt to return control to original client rather than blind swap
*/
/datum/brain_trauma/special/intrusive_thoughts/proc/switch_personalities(reset_to_owner = FALSE)
	if(QDELETED(owner) || QDELETED(stranger_backseat) || QDELETED(owner_backseat))
		return

	var/mob/living/intrusive_thoughts/current_backseat
	var/mob/living/intrusive_thoughts/new_backseat
	if(current_controller == STRANGER || reset_to_owner)
		current_backseat = owner_backseat
		new_backseat = stranger_backseat
	else
		current_backseat = stranger_backseat
		new_backseat = owner_backseat

	if(!current_backseat.client) //Make sure we never switch to a logged off mob.
		return

	current_backseat.log_message("assumed control of [key_name(owner)] due to [src]. (Original owner: [current_controller == OWNER ? owner.key : current_backseat.key])", LOG_GAME)
	if(current_controller == OWNER)
		to_chat(owner, span_userdanger("You listen to the voices...."))
		to_chat(current_backseat, span_userdanger("Go time."))
	else
		to_chat(current_backseat, span_userdanger("You manage to shake the voices out."))
		to_chat(owner, span_userdanger("—!"))

	//Body to backseat

	var/h2b_id = owner.computer_id
	var/h2b_ip= owner.lastKnownIP
	owner.computer_id = null
	owner.lastKnownIP = null

	new_backseat.PossessByPlayer(owner.ckey)

	new_backseat.name = owner.name

	if(owner.mind)
		new_backseat.mind = owner.mind

	if(!new_backseat.computer_id)
		new_backseat.computer_id = h2b_id

	if(!new_backseat.lastKnownIP)
		new_backseat.lastKnownIP = h2b_ip

	if(reset_to_owner && new_backseat.mind)
		new_backseat.ghostize(FALSE)

	//Backseat to body

	var/s2h_id = current_backseat.computer_id
	var/s2h_ip= current_backseat.lastKnownIP
	current_backseat.computer_id = null
	current_backseat.lastKnownIP = null

	owner.PossessByPlayer(current_backseat.ckey)
	owner.mind = current_backseat.mind

	if(!owner.computer_id)
		owner.computer_id = s2h_id

	if(!owner.lastKnownIP)
		owner.lastKnownIP = s2h_ip

	// !current_controller = 0 if controlled by OWNER or 1 if controlled by other.
	current_controller = !current_controller
	// Swaps current_controller from 0 to 1 or 1 to 0

/// ride along invisible body used for switching and assigning communion spells
/mob/living/intrusive_thoughts
	name = "intrusive thoughts"
	real_name = "unknown conscience"
	/// The main body this mob is attached to
	var/mob/living/carbon/body
	/// The trauma that created this mob
	var/datum/brain_trauma/special/intrusive_thoughts/trauma

/mob/living/intrusive_thoughts/Initialize(mapload, _trauma)
	if(iscarbon(loc))
		body = loc
		name = body.real_name
		real_name = body.real_name
		trauma = _trauma
	return ..()

/mob/living/intrusive_thoughts/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(QDELETED(body))
		qdel(src) //in case trauma deletion doesn't already do it


	// if dead and the owner isn't in control
	if((body.stat == DEAD && trauma.current_controller != OWNER))
		trauma.switch_personalities()

	return ..()

/mob/living/intrusive_thoughts/Login()
	. = ..()
	if(!. || !client)
		return FALSE

/// Forces the body to say something
/mob/living/intrusive_thoughts/say(message, bubble_type, list/spans = list(), \
									sanitize = TRUE, datum/language/language = null, \
									ignore_spam = FALSE, forced = null, filterproof = null, \
									message_range = 7,	datum/saymode/saymode = null)
	trauma.owner.say(message)
	var/turf/human_turf = get_turf(trauma.owner)
	var/logging_text = "[key_name(src)] forced [key_name(trauma.owner)] to say [message] at [loc_name(human_turf)]"
	trauma.owner.log_message(logging_text, LOG_GAME)
	return


/mob/living/intrusive_thoughts/emote(act, m_type = null, message = null, intentional = FALSE, force_silence = FALSE)
	return FALSE



#undef OWNER
#undef STRANGER
