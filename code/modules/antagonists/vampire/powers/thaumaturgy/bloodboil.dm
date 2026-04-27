/datum/action/cooldown/vampire/targeted/bloodboil
	name = "Thaumaturgy: Boil Blood"
	desc = "Boil the target's blood inside their body."
	button_icon_state = "power_bloodboil"
	active_background_icon_state = "tremere_power_bronze_on"
	base_background_icon_state = "tremere_power_bronze_off"
	power_explanation = "Afflict a debilitating status effect on a target within range, causing them to suffer bloodloss and burn damage.\n\
						The effect weakens if the target is further than 5 tiles away from you, or if you are also draining their blood.\n\
						This is the only thaumaturgy ability to scale with level. It will become more powerful, last longer, gain range, and have a shorter cooldown."
	vampire_power_flags = NONE
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 30
	cooldown_time = 35 SECONDS
	target_range = 7
	power_activates_immediately = FALSE
	prefire_message = "Whom will you afflict?"
	ranged_mousepointer = 'icons/effects/mouse_pointers/vampire_bloodboil.dmi'

	var/powerlevel = 1
	/// How much burn damage is done to the victim per second.
	var/burn_damage = 8
	/// How much blood is taken from the victim per second.
	var/blood_loss = 8
	/// How long the blood boil effect lasts.
	var/effect_duration = 8 SECONDS

/datum/action/cooldown/vampire/targeted/bloodboil/two
	cooldown_time = 30 SECONDS
	vitaecost = 45
	target_range = 10
	powerlevel = 2
	burn_damage = 9
	blood_loss = 10
	effect_duration = 10 SECONDS

/datum/action/cooldown/vampire/targeted/bloodboil/check_valid_target(mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE

	// Must be a carbon
	if(!iscarbon(target))
		owner.balloon_alert(owner, "not a valid target.")
		return FALSE

	if(HAS_TRAIT(target, TRAIT_NOBLOOD))
		owner.balloon_alert(owner, "[target.p_they()] [target.p_have()] no blood anyways!")
		return FALSE

	// Check for magic immunity
	if(target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		owner.balloon_alert(owner, "your curse was blocked.")
		return FALSE

	// Already boiled
	if(target.has_status_effect(/datum/status_effect/bloodboil))
		owner.balloon_alert(owner, "[target.p_their()] blood is already boiling!")
		return FALSE

/datum/action/cooldown/vampire/targeted/bloodboil/fire_targeted_power(mob/living/carbon/target)
	. = ..()
	// Just to make absolutely sure
	if(!iscarbon(target))
		return FALSE

	owner.whisper("Potestas Vitae...", forced = "[src]")

	if(target.apply_status_effect(/datum/status_effect/bloodboil, owner, effect_duration, burn_damage, blood_loss))
		to_chat(owner, span_warning("You cause [target]'s blood to boil inside [target.p_their()] body!"))
		owner.log_message("used [name] (level [powerlevel]) on [key_name(target)]", LOG_ATTACK)
		target.log_message("was hit by [key_name(owner)] with [name] (level [powerlevel])", LOG_VICTIM, log_globally = FALSE)
		power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!
	else
		to_chat(owner, span_warning("Your thaumaturgy fails to take hold."))
		deactivate_power()

/datum/status_effect/bloodboil
	id = "bloodboil"
	duration = 4 SECONDS
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	processing_speed = STATUS_EFFECT_PRIORITY
	alert_type = /atom/movable/screen/alert/status_effect/bloodboil
	/// How much burn damage is dealt per second.
	var/burn_damage = 8
	/// How much blood is lost per second.
	var/blood_loss = 8
	/// The vampire that casted blood boil.
	var/mob/living/caster

/datum/status_effect/bloodboil/Destroy()
	caster = null
	return ..()

/datum/status_effect/bloodboil/on_creation(mob/living/new_owner, mob/living/caster, duration, burn_damage, blood_loss)
	src.caster = caster
	src.duration = duration
	src.burn_damage = burn_damage
	src.blood_loss = blood_loss
	return ..()

/datum/status_effect/bloodboil/on_apply()
	if(!iscarbon(owner) || HAS_TRAIT(owner, TRAIT_NOBLOOD))
		return FALSE
	return TRUE

/datum/status_effect/bloodboil/tick(seconds_between_ticks)
	var/multiplier = 1
	// if their blood is also being drained, halve the damage.
	if(owner.has_status_effect(/datum/status_effect/blood_drain))
		multiplier *= 0.5

	if(get_dist(owner, caster) > 5)
		multiplier *= 0.5

	owner.take_overall_damage(burn = round(burn_damage * multiplier, 1))
	owner.blood_volume = max(owner.blood_volume - round(blood_loss * multiplier, 1), 0)

	if(SPT_PROB(50, seconds_between_ticks))
		to_chat(owner, span_warning("Oh god! IT BURNS!"))
		INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "scream")
	playsound(owner, pick('sound/effects/wounds/sizzle1.ogg', 'sound/effects/wounds/sizzle2.ogg'), 50, vary = TRUE)

/datum/status_effect/bloodboil/get_examine_text()
	return span_warning("[owner.p_They()] writhe[owner.p_s()] and squirm[owner.p_s()], [owner.p_they()] seem[owner.p_s()] weirdly red?")

/atom/movable/screen/alert/status_effect/bloodboil
	name = "Blood Boil"
	desc = "You feel an intense heat coursing through your veins. Your blood is boiling!"
	icon_state = "bloodboil"
