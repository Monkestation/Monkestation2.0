/**
 *	MEZMERIZE
 *	 Locks a target in place for a certain amount of time.
 *
 * 	Level 2: Additionally mutes
 * 	Level 3: Can be used through face protection
 * 	Level 5: Doesn't need to be facing you anymore
 */
/datum/action/cooldown/vampire/targeted/mesmerize
	name = "Mesmerize"
	desc = "Transfix the mind of a mortal after a few seconds, freezing them in place."
	button_icon_state = "power_mez"
	power_explanation = "Click any player to attempt to mesmerize them, and freeze them in place.\n\
		You cannot wear anything covering your face.\n\
		This will take a few seconds, and they may attempt to flee - the spell will fail if they exit the range.\n\
		If your target is already mesmerized or a Curator, you will fail.\n\
		Once mesmerized, the target will be unable to move or speak for a certain amount of time, scaling with level.\n\
		At level 3, you will be able to use the power through masks and helmets.\n\
		At level 4, you will be able to mesmerize regardless of your target's direction."
	vampire_power_flags = NONE
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 75
	cooldown_time = 20 SECONDS
	target_range = 4
	power_activates_immediately = FALSE
	prefire_message = "Whom will you submit to your will?"
	level_current = 1
	ranged_mousepointer = 'icons/effects/mouse_pointers/vampire_mesmerize.dmi'

	/// Reference to the target
	var/datum/weakref/target_ref
	/// How long it takes us to mesmerize our target.
	var/mesmerize_delay = 5 SECONDS

/datum/action/cooldown/vampire/targeted/mesmerize/Destroy()
	target_ref = null
	return ..()

/datum/action/cooldown/vampire/targeted/mesmerize/two
	vitaecost = 45
	level_current = 2

/datum/action/cooldown/vampire/targeted/mesmerize/three
	vitaecost = 60
	level_current = 3

/datum/action/cooldown/vampire/targeted/mesmerize/four
	vitaecost = 85
	level_current = 4
	target_range = 6

/datum/action/cooldown/vampire/targeted/mesmerize/can_use()
	. = ..()
	if(!.)
		return FALSE

	// Must have eyes
	if(!owner.get_organ_slot(ORGAN_SLOT_EYES))
		to_chat(owner, span_warning("You have no eyes with which to mesmerize."), type = MESSAGE_TYPE_COMBAT)
		return FALSE

	// Must have eyes unobstructed
	var/mob/living/carbon/carbon_owner = owner
	if((carbon_owner.is_eyes_covered() && level_current <= 2) || !isturf(carbon_owner.loc))
		// stupid workaround for a weird edge case with prescription glasses
		if(HAS_TRAIT(carbon_owner, TRAIT_NEARSIGHTED_CORRECTED) && !carbon_owner.is_eyes_covered(~ITEM_SLOT_EYES))
			return TRUE
		owner.balloon_alert(owner, "your eyes are concealed from sight.")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/targeted/mesmerize/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Must be a carbon or silicon
	if(!iscarbon(target_atom) && !issilicon(target_atom))
		return FALSE
	var/mob/living/living_target = target_atom

	// No mind
	if(!living_target.mind)
		owner.balloon_alert(owner, "[living_target] is mindless.")
		return FALSE

	// Vampire/Curator check
	if(IS_VAMPIRE(living_target) || IS_CURATOR(living_target) || HAS_MIND_TRAIT(living_target, TRAIT_UNCONVERTABLE))
		owner.balloon_alert(owner, "too powerful.")
		return FALSE

	// Is our target alive or unconcious?
	if(living_target.stat != CONSCIOUS)
		owner.balloon_alert(owner, "[living_target] is not [(living_target.stat == DEAD || HAS_TRAIT(living_target, TRAIT_FAKEDEATH)) ? "alive" : "conscious"].")
		return FALSE

	// Is our target blind?
	if((!living_target.get_organ_slot(ORGAN_SLOT_EYES) || living_target.is_blind()) && !issilicon(living_target))
		owner.balloon_alert(owner, "[living_target] is blind.")
		return FALSE

	// Already mesmerized?
	if(living_target.has_status_effect(/datum/status_effect/mesmerized))
		owner.balloon_alert(owner, "[living_target] is already in a hypnotic gaze.")
		return FALSE

/datum/action/cooldown/vampire/targeted/mesmerize/fire_targeted_power(atom/target_atom)
	. = ..()
	var/mob/living/living_target = target_atom
	target_ref = WEAKREF(living_target)

	// Mesmerizing silicons is instant
	if(issilicon(living_target))
		var/mob/living/silicon/silicon_target = living_target
		silicon_target.emp_act(EMP_HEAVY)
		owner.balloon_alert(owner, "temporarily shut [silicon_target] down.")
		power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!
		return

	var/modified_delay = mesmerize_delay
	var/eye_protection = living_target.get_eye_protection()
	to_chat(living_target, span_warning("[owner]'s eyes look into yours, and [span_awe("you feel your mind slipping away")]..."), type = MESSAGE_TYPE_COMBAT)
	if(eye_protection > 0)
		modified_delay += (eye_protection * 0.25) * mesmerize_delay
		to_chat(living_target, span_warning("It feels like your eye-protection is helping you resist the gaze!"), type = MESSAGE_TYPE_COMBAT)
		to_chat(living_target, span_warning("But, you can still feel it making your eyes grow heavy."), type = MESSAGE_TYPE_COMBAT)
		to_chat(owner, span_warning("[living_target] is wearing eye-protection, it will take longer to mesmerize [living_target.p_them()]."), type = MESSAGE_TYPE_COMBAT)
		owner.balloon_alert(owner, "attempting to hypnotize [living_target], but [living_target.p_they()] [living_target.p_are()] partially protected!")
	else
		owner.balloon_alert(owner, "attempting to hypnotize [living_target]...")

	perform_indicators(living_target, modified_delay)

	if(!do_after(owner, modified_delay, living_target, IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(continue_active)), hidden = TRUE))
		deactivate_power()
		return

	owner.balloon_alert(owner, "successfully mesmerized [living_target].")

	//Actually mesmerize them now
	var/power_time = 9 SECONDS + level_current * 1.5 SECONDS
	living_target.apply_status_effect(/datum/status_effect/mesmerized, owner, power_time)

	power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!

/datum/action/cooldown/vampire/targeted/mesmerize/continue_active()
	. = ..()
	if(!.)
		return FALSE

	if(!can_use())
		return FALSE

	var/mob/living/living_target = target_ref?.resolve()
	if(!living_target || !check_valid_target(living_target))
		return FALSE

/datum/action/cooldown/vampire/targeted/mesmerize/deactivate_power()
	. = ..()
	target_ref = null

/datum/action/cooldown/vampire/targeted/mesmerize/proc/perform_indicators(mob/target, duration)
	// Display an animated overlay over our head to indicate what's going on
	eldritch_eye(target, "eye_open", 1 SECONDS)
	var/main_duration = max(duration - 2 SECONDS, 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(eldritch_eye), target, "eye_flash", main_duration), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(eldritch_eye), target,  "eye_close", 1 SECONDS), main_duration + 1 SECONDS)

/// Display an animated overlay over our head to indicate what's going on
/datum/action/cooldown/vampire/targeted/mesmerize/proc/eldritch_eye(mob/target, icon_state = "eye_open", duration = 1 SECONDS)
	var/image/image = image('icons/effects/eldritch.dmi', owner, icon_state, ABOVE_ALL_MOB_LAYER)
	image.pixel_w = -(owner.pixel_x + owner.pixel_w)
	image.pixel_z = 28
	image.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	SET_PLANE_EXPLICIT(image, ABOVE_HUD_PLANE, owner)
	flick_overlay_global(image, list(owner?.client, target?.client), duration)

/datum/status_effect/mesmerized
	id = "mesmerized"
	duration = 15 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	/// The mob that mesmerized the victim.
	var/mob/living/caster
	/// Traits given to the mesmerized victim.
	var/list/mesmerized_traits = list(
		TRAIT_HANDS_BLOCKED,
		TRAIT_IMMOBILIZED,
		TRAIT_INCAPACITATED,
		TRAIT_MUTE,
	)

/datum/status_effect/mesmerized/Destroy()
	. = ..()
	caster = null

/datum/status_effect/mesmerized/on_creation(mob/living/new_owner, mob/living/caster, duration)
	src.caster = caster
	src.duration = duration
	return ..()

/datum/status_effect/mesmerized/on_apply()
	owner.add_client_colour(/datum/client_colour/glass_colour/pink)
	owner.add_traits(mesmerized_traits, TRAIT_STATUS_EFFECT(id))
	to_chat(owner, span_awe("[caster]'s eyes glitter so beautifully... You're mesmerized!"), type = MESSAGE_TYPE_COMBAT)
	owner.playsound_local(null, 'sound/vampires/mesmerize.ogg', 100, FALSE, pressure_affected = FALSE)
	return TRUE

/datum/status_effect/mesmerized/on_remove()
	owner.remove_client_colour(/datum/client_colour/glass_colour/pink)
	owner.remove_traits(mesmerized_traits, TRAIT_STATUS_EFFECT(id))
	to_chat(owner, span_awe(span_big("With the spell waning, so does your memory of being mesmerized.")), type = MESSAGE_TYPE_COMBAT)
	if(CAN_THEY_SEE(owner, caster))
		owner.balloon_alert(caster, "snapped out of [owner.p_their()] trance!")
