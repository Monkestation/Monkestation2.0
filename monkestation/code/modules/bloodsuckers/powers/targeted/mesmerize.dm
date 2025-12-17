/**
 *	MEZMERIZE
 *	 Locks a target in place for a certain amount of time.
 *
 * 	Level 3: Can be used through face protection
 */

#define MESMERIZE_GLASSES_LEVEL 3
/datum/action/cooldown/bloodsucker/targeted/mesmerize
	name = "Mesmerize"
	button_icon_state = "power_mez"
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY | VASSAL_CAN_BUY
	bloodcost = 30
	cooldown_time = 30 SECONDS
	target_range = 4
	power_activates_immediately = FALSE
	unset_after_click = FALSE
	prefire_message = "Whom will you subvert to your will?"
	///Our mesmerized target - Prevents several mesmerizes.
	var/datum/weakref/target_ref
	/// How long it takes us to mesmerize our target.
	var/mesmerize_delay = 5 SECONDS
	/// At what level this ability will blind the target at. Level 0 = never.
	var/blind_at_level = 0
	/// if the ability requires you to not have your eyes covered
	var/blocked_by_glasses = TRUE
	var/mesmerize_layer = ABOVE_ALL_MOB_LAYER
	var/mesmerize_plane = ABOVE_HUD_PLANE
	/// at this protection mesmerize will fail
	var/max_eye_protection = 2
/datum/action/cooldown/bloodsucker/targeted/mesmerize/get_power_desc_extended()
	. += "[src] a target, locking them in place for a short time and muting them.<br>"

/datum/action/cooldown/bloodsucker/targeted/mesmerize/get_power_explanation_extended()
	. = list()
	. += "Click any player to attempt to mesmerize them. If successful, will stun and mute the victim."
	. += "The victim will realize they are being mesmerized, but will be muted for the duration of the glare."
	. += "They can escape the effect if they get out of range in time."
	if(blocked_by_glasses)
		. += "[src] requires you to not be wearing glasses."
	. += "Obviously, both parties need to not be blind."
	. += "If your target is already mesmerized or a bloodsucker, the Power will fail."
	. += "Flash protection will slow down mesmerize, but welding protection will completely stop it."
	. += "Once mesmerized, the target will be unable to move or speak for [DisplayTimeText(get_power_time())], scaling with level."
	. += "At level [MESMERIZE_GLASSES_LEVEL], you will be able to use the power through items covering your face."
	. += "Additionally it works on silicon lifeforms, causing a EMP effect instead of a freeze."

/datum/action/cooldown/bloodsucker/targeted/mesmerize/can_use(mob/living/carbon/user, trigger_flags)
	. = ..()
	if(!.) // Default checks
		return FALSE
	if(!user.get_organ_slot(ORGAN_SLOT_EYES))
		// Cant use balloon alert, they've got no eyes!
		to_chat(user, span_warning("You have no eyes with which to mesmerize."))
		return FALSE
	// Check: Eyes covered?
	if(blocked_by_glasses && istype(user) && (user.is_eyes_covered() && level_current < MESMERIZE_GLASSES_LEVEL) || !isturf(user.loc))
		user.balloon_alert(user, "your eyes are concealed from sight.")
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/mesmerize/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom)

/datum/action/cooldown/bloodsucker/targeted/mesmerize/CheckCanTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/current_target = target_atom // We already know it's carbon due to CheckValidTarget()
	// No mind
#ifndef BLOODSUCKER_TESTING
	if(!current_target.mind)
		owner.balloon_alert(owner, "[current_target] is mindless.")
		return FALSE
#endif
	// Bloodsucker
	if(IS_BLOODSUCKER(current_target))
		owner.balloon_alert(owner, "bloodsuckers are immune to [src].")
		return FALSE
	// Dead/Unconscious
	if(current_target.stat > CONSCIOUS)
		owner.balloon_alert(owner, "[current_target] is not [(current_target.stat == DEAD || HAS_TRAIT(current_target, TRAIT_FAKEDEATH)) ? "alive" : "conscious"].")
		return FALSE
	// Target has eyes?
	if(!current_target.get_organ_slot(ORGAN_SLOT_EYES) && !issilicon(current_target))
		owner.balloon_alert(owner, "[current_target] has no eyes.")
		return FALSE
	// Target blind?
	if(current_target.is_blind() && !issilicon(current_target))
		owner.balloon_alert(owner, "[current_target] is blind.")
		return FALSE

	if(!(owner in view(current_target)))
		owner.balloon_alert(owner, "[current_target] has to be able to see you.")
		return FALSE

	var/eye_protection = current_target.get_eye_protection()

	if(eye_protection > max_eye_protection)
		owner.balloon_alert(owner, "[current_target] has too much eye protection to mesmerize.")
		return FALSE

	// Gone through our checks, let's mark our guy.
	target_ref = WEAKREF(current_target)
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/mesmerize/FireTargetedPower(atom/target)
	. = ..()
	var/mob/living/user = owner
	var/mob/living/carbon/mesmerized_target = target_ref?.resolve()
	if(!mesmerized_target)
		CRASH("mesmerized_target is null")

	var/modified_delay = mesmerize_delay
	var/eye_protection = mesmerized_target.get_eye_protection()
	if(eye_protection > 0)
		modified_delay += (eye_protection * 0.25) * mesmerize_delay
		to_chat(mesmerized_target, span_warning("It feels like your eye-protection is helping you resist the victim's gaze!"))
		to_chat(mesmerized_target, span_warning("But, you can still feel it making your eyes grow heavy."))
		to_chat(user, span_warning("[mesmerized_target] is wearing eye-protection, it will take longer to mesmerize them."))
		user.balloon_alert(user, "partially protected!")
	else
		to_chat(mesmerized_target, span_warning("[user]'s eyes look into yours, and [span_hypnophrase("you feel your mind slipping away")]..."))

	perform_indicators(mesmerized_target, modified_delay)

	if(issilicon(mesmerized_target))
		var/mob/living/silicon/mesmerized = mesmerized_target
		mesmerized.emp_act(EMP_HEAVY)
		owner.balloon_alert(owner, "temporarily shut [mesmerized] down.")
		power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!
		return

	mute_target(mesmerized_target, modified_delay)

	if(!do_after(user, modified_delay, mesmerized_target, IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE, TRUE, extra_checks = CALLBACK(src, PROC_REF(ContinueActive), user, mesmerized_target), hidden = TRUE))
		StartCooldown(cooldown_time * 0.5)
		DeactivatePower()
		unmute_target(mesmerized_target)
		return
	// Can't quite time it here, but oh well
	if(IS_MONSTERHUNTER(mesmerized_target))
		to_chat(mesmerized_target, span_notice("You feel your eyes burn for a while, but it passes."))
		mesmerized_target.balloon_alert(user, "resists!")
		return
	if(HAS_TRAIT_FROM_ONLY(mesmerized_target, TRAIT_NO_TRANSFORM, MESMERIZE_TRAIT))
		owner.balloon_alert(owner, "[mesmerized_target] is already in a hypnotic gaze.")
		return
	owner.balloon_alert(owner, "successfully mesmerized [mesmerized_target].")
	mesmerize_effects(user, mesmerized_target)
	power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!

/datum/action/cooldown/bloodsucker/targeted/mesmerize/proc/mesmerize_effects(mob/living/user, mob/living/mesmerized_target)
	var/power_time = get_power_time()
	mute_target(mesmerized_target, power_time)
	mesmerized_target.Immobilize(power_time)
	mesmerized_target.next_move = world.time + power_time // <--- Use direct change instead. We want an unmodified delay to their next move // mesmerized_target.changeNext_move(power_time) // check click.dm
	ADD_TRAIT(mesmerized_target, TRAIT_NO_TRANSFORM, MESMERIZE_TRAIT) // <--- Fuck it. We tried using next_move, but they could STILL resist. We're just doing a hard freeze.
	addtimer(CALLBACK(src, PROC_REF(end_mesmerize), user, mesmerized_target), power_time)

/datum/action/cooldown/bloodsucker/targeted/mesmerize/proc/get_power_time()
	return 9 SECONDS + level_current * 1 SECONDS

/datum/action/cooldown/bloodsucker/targeted/mesmerize/proc/blind_target(mob/living/mesmerized_target)
	if(!blind_at_level && level_current < blind_at_level)
		return
	mesmerized_target.become_blind(MESMERIZE_TRAIT)

/datum/action/cooldown/bloodsucker/targeted/mesmerize/proc/mute_target(mob/living/mesmerized_target, duration)
	mesmerized_target.set_silence_if_lower(duration)
	mesmerized_target.set_emote_mute_if_lower(duration)

/datum/action/cooldown/bloodsucker/targeted/mesmerize/proc/unmute_target(mob/living/mesmerized_target)
	mesmerized_target.set_silence(0)
	mesmerized_target.set_emote_mute(0)

/datum/action/cooldown/bloodsucker/targeted/mesmerize/DeactivatePower(deactivate_flags)
	. = ..()
	target_ref = null

/datum/action/cooldown/bloodsucker/targeted/mesmerize/proc/end_mesmerize(mob/living/user, mob/living/target)
	REMOVE_TRAIT(target, TRAIT_NO_TRANSFORM, MESMERIZE_TRAIT)
	target.cure_blind(MESMERIZE_TRAIT)
	// They Woke Up! (Notice if within view)
	if(istype(user) && target.stat == CONSCIOUS && (target in view(target_range, get_turf(user))))
		target.balloon_alert(owner, "[target] snapped out of their trance.")

/datum/action/cooldown/bloodsucker/targeted/mesmerize/ContinueActive(mob/living/user, mob/living/target)
	return ..() && can_use(user) && CheckCanTarget(target)

/datum/action/cooldown/bloodsucker/targeted/mesmerize/proc/perform_indicators(mob/target, duration)
	// Display an animated overlay over our head to indicate what's going on
	eldritch_eye(target, "eye_open", 1 SECONDS)
	var/main_duration = max(duration - 2 SECONDS, 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(eldritch_eye), target, "eye_flash", main_duration), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(eldritch_eye), target,  "eye_close", 1 SECONDS), main_duration + 1 SECONDS)

/// Display an animated overlay over our head to indicate what's going on
/datum/action/cooldown/bloodsucker/targeted/mesmerize/proc/eldritch_eye(mob/target, icon_state = "eye_open", duration = 1 SECONDS)
	var/image/image = image('icons/effects/eldritch.dmi', owner, icon_state, mesmerize_layer, pixel_x = -owner.pixel_x, pixel_y = 28) /// TODO make this disable cloak
	image.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	SET_PLANE_EXPLICIT(image, mesmerize_plane, owner)
	flick_overlay_global(image, list(owner?.client, target?.client), duration)

#undef MESMERIZE_GLASSES_LEVEL
