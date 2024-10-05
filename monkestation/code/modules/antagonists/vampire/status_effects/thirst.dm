/datum/status_effect/vampire/thirst
	id = "vampire_thirst"
	duration = 1 MINUTE // good luck, you're on borrowed time
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/vampire/thirst
	var/cleared = FALSE
	var/stasis_start_time

/datum/status_effect/vampire/thirst/on_creation(mob/living/new_owner, datum/antagonist/vampire/new_vampire_datum)
	if(new_vampire_datum) // has to be done before the parent proc call
		duration *= 1 + (new_vampire_datum.get_stat_modified(VAMPIRE_STAT_TENACITY) / VAMPIRE_SP_MAXIMUM) * 4 // 5x thirst duration at max so 5 minutes as of writing this
	. = ..()
	RegisterSignal(vampire, COMSIG_VAMPIRE_LIFEFORCE_CHANGED, PROC_REF(on_lifeforce_changed))

/datum/status_effect/vampire/thirst/on_apply()
	. = ..()
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_STASIS), PROC_REF(on_stasis_entered))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_STASIS), PROC_REF(on_stasis_exited))

	owner.balloon_alert(owner, "out of lifeforce!")
	to_chat(owner, span_userdanger("Your body begins to crumble!\nDrink blood or get to a stasis bed!")) // this is your last chance

/datum/status_effect/vampire/thirst/on_remove()
	UnregisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_STASIS), SIGNAL_REMOVETRAIT(TRAIT_STASIS)))
	UnregisterSignal(vampire, COMSIG_VAMPIRE_LIFEFORCE_CHANGED)

	if(cleared)
		return ..()

	owner.visible_message(
		message = span_danger("[owner] lets out a scream of pure terror and turns to dust right before your eyes!"),
		self_message = span_userdanger("Your body turns to dust as the last shreds of your strength fade away!"),
		blind_message = span_hear("You hear a scream of pure terror!")
	)
	owner.emote("scream")
	owner.investigate_log("has been dusted by a lack of lifeforce. (vampire)", INVESTIGATE_DEATHS)
	owner.dust(drop_items = TRUE)

	return ..()

/datum/status_effect/vampire/thirst/tick(seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(5, seconds_per_tick))
		owner.emote("shiver")

/datum/status_effect/vampire/thirst/proc/on_lifeforce_changed(datum/source, old_amount, new_amount)
	SIGNAL_HANDLER
	if(new_amount <= 0)
		return
	cleared = TRUE
	qdel(src)

/datum/status_effect/vampire/thirst/proc/on_stasis_entered()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSfastprocess, src)
	stasis_start_time = world.time

/datum/status_effect/vampire/thirst/proc/on_stasis_exited()
	SIGNAL_HANDLER
	duration += world.time - stasis_start_time
	START_PROCESSING(SSfastprocess, src)

/atom/movable/screen/alert/status_effect/vampire/thirst
	name = "Thirst"
	desc = "Your body shivers and your mind is fogging up..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash" // please take the hint
	alerttooltipstyle = "cult"
