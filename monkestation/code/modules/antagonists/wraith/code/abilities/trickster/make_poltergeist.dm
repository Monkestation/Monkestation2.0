/datum/action/cooldown/spell/wraith/make_poltergeist
	name = "Make poltergeist"
	desc = "Make a spirit into a lesser version of yourself, being able to sow chaos in a greater area at once. You can only have 2 at a time."
	button_icon_state = "make_poltergeist"

	essence_cost = 600
	cooldown_time = 5 MINUTES

	/// The maximum amount of poltergeists this spell can support
	var/maximum_ghosts = 2
	/// The current amount of poltergeists we have
	var/current_ghosts = 0

/datum/action/cooldown/spell/wraith/make_poltergeist/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE

	if(current_ghosts >= maximum_ghosts)
		if(feedback)
			to_chat(owner, span_revennotice("You cannot make anymore poltergeists at the moment, 2 is already stretching you too thin."))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/wraith/make_poltergeist/before_cast(atom/cast_on)
	. = ..()
	var/list/candidates = SSpolling.poll_ghost_candidates(
		role = ROLE_WRAITH,
		ignore_category = POLL_IGNORE_WRAITH,
		alert_pic = /mob/living/basic/wraith/poltergeist,
	)

	if(!length(candidates))
		to_chat(owner, span_revennotice("Yet no spirit answered to your call for revenge..."))
		return . | SPELL_CANCEL_CAST

	var/mob/dead/observer/chosen_ghost = pick(candidates)
	var/mob/living/basic/wraith/poltergeist/ghostie = new(get_turf(owner), chosen_ghost, src)
	notify_ghosts(
		"[owner.name] has chosen its new poltergeist: [ghostie]!",
		source = ghostie,
		action = NOTIFY_ORBIT,
		header = "Something's Spooky!",
	)
	message_admins("[ADMIN_LOOKUPFLW(ghostie)] has been made into poltergeist by a wraith ([ADMIN_LOOKUPFLW(owner)]).")
	log_game("[key_name(chosen_ghost)] was spawned as a poltergeist by a wraith ([key_name(owner)]).")
	to_chat(ghostie, span_revennotice("You are a poltergeist! Help your master fulfill their objectives and sow chaos in the station."))
