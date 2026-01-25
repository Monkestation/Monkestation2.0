/datum/action/cooldown/vampire/targeted/bloodboil
	name = "Thaumaturgy: Boil Blood"
	desc = "Boil the target's blood inside their body."
	button_icon_state = "power_thaumaturgy"
	active_background_icon_state = "tremere_power_bronze_on"
	base_background_icon_state = "tremere_power_bronze_off"
	power_explanation = "Afflict a debilitating status effect on a target within range, causing them to suffer bloodloss, burn damage, and slowing them down.\n\
						This is the only thaumaturgy ability to scale with level. It will become more powerful, last longer, gain range, and have a shorter cooldown."
	vampire_power_flags = NONE
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 30
	cooldown_time = 35 SECONDS
	target_range = 7
	power_activates_immediately = FALSE
	prefire_message = "Whom will you afflict?"

	var/powerlevel = 1

/datum/action/cooldown/vampire/targeted/bloodboil/two
	cooldown_time = 30 SECONDS
	vitaecost = 45
	target_range = 10
	powerlevel = 2

/datum/action/cooldown/vampire/targeted/bloodboil/three
	cooldown_time = 25 SECONDS
	vitaecost = 60
	target_range = 15
	powerlevel = 3

/datum/action/cooldown/vampire/targeted/bloodboil/four
	cooldown_time = 20 SECONDS
	vitaecost = 75
	target_range = 20
	powerlevel = 4

/datum/action/cooldown/vampire/targeted/bloodboil/check_valid_target(mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE

	// Must be a carbon
	if(!iscarbon(target))
		owner.balloon_alert(owner, "not a valid target.")
		return FALSE

	// Check for magic immunity
	if(target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		owner.balloon_alert(owner, "your curse was blocked.")
		return FALSE

	// Already boiled
	if(target.has_status_effect(/datum/status_effect/bloodboil))
		owner.balloon_alert(owner, "[target.p_their()] blood is already boiling!")
		return FALSE

/datum/action/cooldown/vampire/targeted/bloodboil/FireTargetedPower(mob/living/carbon/target)
	. = ..()
	// Just to make absolutely sure
	if(!iscarbon(target))
		return FALSE

	owner.whisper("Potestas Vitae...", forced = "[src]")

	if(target.apply_status_effect(/datum/status_effect/bloodboil, powerlevel))
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
	var/power = 1

/datum/status_effect/bloodboil/on_creation(mob/living/new_owner, power = 1)
	src.duration = (2 * power + 2) SECONDS
	src.power = power
	return ..()

/datum/status_effect/bloodboil/tick(seconds_between_ticks)
	var/burn_damage = 4 + (power * 2)
	var/stamina_damage = 5 * power
	var/blood_loss = 2 * power + 2

	owner.take_overall_damage(burn = burn_damage, stamina = stamina_damage)
	owner.blood_volume = max(owner.blood_volume - blood_loss, 0)

	if(SPT_PROB(50, seconds_between_ticks))
		to_chat(owner, span_warning("Oh god! IT BURNS!"))
		INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "scream")
	playsound(owner, 'sound/effects/wounds/sizzle1.ogg', 50, vary = TRUE)

/datum/status_effect/bloodboil/get_examine_text()
	return span_warning("[owner.p_They()] writhe[owner.p_s()] and squirm[owner.p_s()], [owner.p_they()] seem[owner.p_s()] weirdly red?")

/atom/movable/screen/alert/status_effect/bloodboil
	name = "Blood Boil"
	desc = "You feel an intense heat coursing through your veins. Your blood is boiling!"
	icon_state = "bloodboil"
