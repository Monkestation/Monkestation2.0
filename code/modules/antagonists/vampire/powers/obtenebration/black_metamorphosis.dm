#define METAMORPHOSIS_OUTLINE "black_metamorphosis_outline"
#define METAMORPHOSIS_SHADOW "black_metamorphosis_shadow"
/// Choking stops here, since 50 oxyloss knocks people out and that'd be a hard stun.
#define METAMORPHOSIS_MAX_OXYLOSS 40

/datum/action/cooldown/vampire/black_metamorphosis
	name = "Black Metamorphosis"
	desc = "Wear nullspace like armor. Your fists drag the breath out of whoever they hit, and the people watching start to panic."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "shadow_skin"
	power_explanation = "Toggle a fighting form wreathed in living shadow.\n\
		Your punches also choke the target, though never enough to knock them out on their own.\n\
		Mortals who can see you within 4 tiles are filled with dread: they shake, stutter, and their vision blurs. It never knocks anyone down."
	vampire_power_flags = BP_AM_TOGGLE
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 75
	constant_vitaecost = 5
	cooldown_time = 20 SECONDS
	costs_double_in_light = TRUE
	/// How far the dread reaches, in tiles.
	var/dread_range = 4

/datum/action/cooldown/vampire/black_metamorphosis/activate_power()
	. = ..()
	var/mob/living/user = owner
	RegisterSignal(user, COMSIG_HUMAN_PUNCHED, PROC_REF(on_punch))
	user.add_shared_particles(/particles/lasombra_shadow/dense)
	user.add_filter(METAMORPHOSIS_OUTLINE, 2, outline_filter(size = 2, color = "#000000"))
	user.add_filter(METAMORPHOSIS_SHADOW, 3, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#6b0014aa"))
	var/shadow = user.get_filter(METAMORPHOSIS_SHADOW)
	animate(shadow, size = 7, time = 0.8 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	animate(size = 4, time = 0.8 SECONDS, easing = SINE_EASING)
	apply_wibbly_filters(user)
	playsound(user, 'sound/effects/nightmare_poof.ogg', 60, TRUE)
	user.visible_message(
		span_danger("Darkness boils up out of [user]'s skin and wraps around [user.p_them()] like armor!"),
		span_notice("You pull nullspace over yourself like a second skin."),
	)

/datum/action/cooldown/vampire/black_metamorphosis/deactivate_power()
	var/mob/living/user = owner
	UnregisterSignal(user, COMSIG_HUMAN_PUNCHED)
	user.remove_shared_particles(/particles/lasombra_shadow/dense)
	animate(user.get_filter(METAMORPHOSIS_SHADOW))
	user.remove_filter(list(METAMORPHOSIS_OUTLINE, METAMORPHOSIS_SHADOW))
	remove_wibbly_filters(user, 1 SECONDS)
	return ..()

/datum/action/cooldown/vampire/black_metamorphosis/use_power()
	. = ..()
	if(!. || owner.stat != CONSCIOUS)
		return
	for(var/mob/living/carbon/witness in oviewers(dread_range, owner))
		if(vampiredatum_power.is_mortal_witness(witness))
			witness.apply_status_effect(/datum/status_effect/lasombra_dread)

/datum/action/cooldown/vampire/black_metamorphosis/proc/on_punch(mob/living/carbon/human/source, mob/living/carbon/human/target, damage)
	SIGNAL_HANDLER
	var/choke = min(10, METAMORPHOSIS_MAX_OXYLOSS - target.getOxyLoss())
	if(choke <= 0)
		return
	target.adjustOxyLoss(choke)
	to_chat(target, span_warning("Shadow forces its way down your throat!"))

/datum/status_effect/lasombra_dread
	id = "lasombra_dread"
	status_type = STATUS_EFFECT_REFRESH
	duration = 4 SECONDS
	tick_interval = 1 SECONDS
	alert_type = null

/datum/status_effect/lasombra_dread/on_apply()
	owner.add_mood_event("lasombra_dread", /datum/mood_event/lasombra_dread)
	to_chat(owner, span_warning("There's something wrong with that darkness. It's looking at you."))
	return TRUE

/datum/status_effect/lasombra_dread/tick(seconds_between_ticks)
	owner.adjust_jitter_up_to(2 SECONDS * seconds_between_ticks, 6 SECONDS)
	owner.adjust_stutter_up_to(2 SECONDS * seconds_between_ticks, 6 SECONDS)
	owner.adjust_eye_blur_up_to(1 SECONDS * seconds_between_ticks, 3 SECONDS)

/datum/status_effect/lasombra_dread/get_examine_text()
	return span_warning("[owner.p_They()] look[owner.p_s()] absolutely terrified.")

#undef METAMORPHOSIS_OUTLINE
#undef METAMORPHOSIS_SHADOW
#undef METAMORPHOSIS_MAX_OXYLOSS
