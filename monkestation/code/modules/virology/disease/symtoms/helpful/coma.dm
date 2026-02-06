#define COMA_COOLDOWN (40 SECONDS)
/datum/symptom/coma
	name = "Regenerative Coma"
	desc = "The virus causes the host to fall into a death-like coma when severely damaged, then rapidly fixes the damage. Waking the host up some time later."
	max_multiplier = 6
	max_chance = 100
	stage = 3
	badness = EFFECT_DANGER_HELPFUL
	severity = 0

	var/passive_message = span_notice("The pain from your wounds makes you feel oddly sleepy...")
	var/added_to_mob = FALSE
	var/active_coma = FALSE //to prevent multiple coma procs
	COOLDOWN_DECLARE(last_coma)
	var/cooldown_alert = FALSE // To give some mechanical signal that it's back online

/datum/symptom/coma/activate(mob/living/carbon/mob, datum/disease/acute/disease)
	. = ..()
	if (!COOLDOWN_FINISHED(src, last_coma))
		cooldown_alert = FALSE
		return
	if(!added_to_mob && max_multiplier >= 4)
		added_to_mob = TRUE
		ADD_TRAIT(mob, TRAIT_NOCRITDAMAGE, type)
	if(!cooldown_alert)
		cooldown_alert = !cooldown_alert
		INVOKE_ASYNC(mob, TYPE_PROC_REF(/mob, emote), "yawn")
		to_chat(mob, span_warning("You can't help the urge to yawn."))
	var/effectiveness = CanHeal(mob)
	if(!effectiveness)
		return
	if(passive_message_condition(mob))
		to_chat(mob, passive_message)
	Heal(mob, effectiveness)
	return

/datum/symptom/coma/side_effect(mob/living/mob)
	if(active_coma)
		uncoma()
	if(!added_to_mob)
		return
	REMOVE_TRAIT(mob, TRAIT_NOCRITDAMAGE, type)

/datum/symptom/coma/proc/CanHeal(mob/living/victim)
	if(!iscarbon(victim))
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_NO_HEALS))
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_DEATHCOMA))
		return multiplier
	if(victim.IsSleeping())
		return multiplier * 0.3 //Voluntary unconsciousness yields lower healing.
	switch(victim.stat)
		if(UNCONSCIOUS, HARD_CRIT)
			return multiplier * 0.9
		if(SOFT_CRIT)
			return multiplier * 0.5
	if((victim.getBruteLoss() + victim.getFireLoss()) >= 80 && !active_coma)
		to_chat(victim, span_warning("You feel yourself slip into a regenerative coma..."))
		active_coma = TRUE
		addtimer(CALLBACK(src, PROC_REF(coma), victim), 6 SECONDS)
	return FALSE

/datum/symptom/coma/proc/coma(mob/living/victim)
	if(QDELETED(victim) || victim.stat == DEAD)
		return
	victim.fakedeath("regenerative_coma", TRUE)
	addtimer(CALLBACK(src, PROC_REF(uncoma), victim), 20 SECONDS)

/datum/symptom/coma/proc/uncoma(mob/living/victim)
	if(QDELETED(victim) || !active_coma)
		return
	addtimer(CALLBACK(victim, TYPE_PROC_REF(/mob/living, cure_fakedeath), "regenerative_coma"), 15 SECONDS)
	active_coma = FALSE
	COOLDOWN_START(src, last_coma, COMA_COOLDOWN)

/datum/symptom/coma/proc/Heal(mob/living/carbon/victim, actual_power)
	var/list/parts = victim.get_damaged_bodyparts(brute = TRUE, burn = TRUE)
	if(!length(parts))
		return
	var/heal_amt = (4 * actual_power) / length(parts)
	victim.heal_overall_damage(brute = heal_amt, burn = heal_amt)
	if(active_coma && (victim.getBruteLoss() + victim.getFireLoss()) == 0)
		uncoma(victim)
	return TRUE

/datum/symptom/coma/proc/passive_message_condition(mob/living/victim)
	if((victim.getBruteLoss() + victim.getFireLoss()) > 30)
		return TRUE
	return FALSE

#undef COMA_COOLDOWN
