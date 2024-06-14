/datum/status_effect/regenerative_extract
	id = "Slime Regeneration"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 15 SECONDS
	tick_interval = 0.5 SECONDS
	alert_type = null
	var/base_healing_amt = 2
	var/multiplier = 1
	var/diminishing_multiplier = 0.75
	var/diminish_time = 45 SECONDS
	var/nutrition_heal_cap = NUTRITION_LEVEL_FED - 50
	var/list/given_traits = list(TRAIT_ANALGESIA, TRAIT_NOCRITDAMAGE)

/datum/status_effect/regenerative_extract/on_apply()
	SEND_SIGNAL(owner, COMSIG_SLIME_REGEN_CALC, &multiplier)
	owner.add_traits(given_traits, id)
	return TRUE

/datum/status_effect/regenerative_extract/on_remove()
	owner.remove_traits(given_traits, id)
	owner.apply_status_effect(/datum/status_effect/slime_regen_cooldown, diminishing_multiplier, diminish_time)

/datum/status_effect/regenerative_extract/tick(seconds_per_tick, times_fired)
	var/heal_amt = base_healing_amt * seconds_per_tick * multiplier
	heal_act(heal_amt)
	owner.updatehealth()

/datum/status_effect/regenerative_extract/proc/heal_act(heal_amt)
	if(!heal_amt)
		return
	heal_damage(heal_amt)
	heal_misc(heal_amt)
	if(iscarbon(owner))
		heal_organs(heal_amt)
		heal_wounds()

/datum/status_effect/regenerative_extract/proc/heal_damage(heal_amt)
	owner.heal_overall_damage(brute = heal_amt, burn = heal_amt, updating_health = FALSE)
	owner.stamina?.adjust(-heal_amt, forced = TRUE)
	owner.adjustOxyLoss(-heal_amt, updating_health = FALSE)
	owner.adjustToxLoss(-heal_amt, updating_health = FALSE, forced = TRUE)
	owner.adjustCloneLoss(-heal_amt, updating_health = FALSE)

/datum/status_effect/regenerative_extract/proc/heal_misc(heal_amt)
	owner.adjust_disgust(-heal_amt)
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume = min(owner.blood_volume + heal_amt, BLOOD_VOLUME_NORMAL)
	if((owner.nutrition < nutrition_heal_cap) && !HAS_TRAIT(owner, TRAIT_NOHUNGER))
		owner.nutrition = min(owner.nutrition + heal_amt, nutrition_heal_cap)

/datum/status_effect/regenerative_extract/proc/heal_organs(heal_amt)
	var/mob/living/carbon/carbon_owner = owner
	for(var/obj/item/organ/organ in carbon_owner.organs)
		organ.apply_organ_damage(-heal_amt)
	carbon_owner.cure_trauma_type(resilience = TRAUMA_RESILIENCE_MAGIC)

/datum/status_effect/regenerative_extract/proc/heal_wounds()
	var/mob/living/carbon/carbon_owner = owner
	if(length(carbon_owner.all_wounds))
		var/list/datum/wound/ordered_wounds = sort_list(carbon_owner.all_wounds, GLOBAL_PROC_REF(cmp_wound_severity_dsc))
		ordered_wounds[1]?.remove_wound()

/datum/status_effect/regenerative_extract/get_examine_text()
	return "[owner.p_They()] have a subtle, gentle glow to [owner.p_their()] skin, with slime soothing [owner.p_their()] wounds."
