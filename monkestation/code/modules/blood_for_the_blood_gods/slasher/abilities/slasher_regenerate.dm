/datum/action/cooldown/slasher/regenerate
	name = "Regenerate"
	desc = "Quickly regenerate your being, restoring most if not all lost health, repairing wounds, and removing all stuns. Works much better in maintenance areas."

	button_icon_state = "regenerate"

	cooldown_time = 80 SECONDS


/datum/action/cooldown/slasher/regenerate/Activate(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/mob_target = target
		mob_target.set_timed_status_effect(5 SECONDS, /datum/status_effect/bloody_heal) // should heal most damage over 5 seconds


/datum/status_effect/bloody_heal
	id = "bloody_heal"
	alert_type = null
	tick_interval = 1 SECONDS
	show_duration = TRUE
	processing_speed = STATUS_EFFECT_PRIORITY

/datum/status_effect/bloody_heal/on_creation(mob/living/new_owner, duration = 5 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/bloody_heal/on_apply()
	if(!ishuman(owner))
		return FALSE
	ADD_TRAIT(owner, TRAIT_CANT_STAMCRIT, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/bloody_heal/on_remove()
	REMOVE_TRAIT(owner, TRAIT_CANT_STAMCRIT, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/bloody_heal/tick(seconds_between_ticks)
	var/mob/living/carbon/human/human_owner = owner
	var/heal_multiplier = seconds_between_ticks
	if(HAS_TRAIT(owner, TRAIT_HAS_CRANIAL_FISSURE))
		heal_multiplier *= 0.25
	human_owner.AdjustAllImmobility(-20 * heal_multiplier)
	human_owner.stamina.adjust(10 * heal_multiplier, TRUE)
	var/needs_health_update = FALSE
	needs_health_update += human_owner.adjustBruteLoss(-35 * heal_multiplier, updating_health = FALSE)
	needs_health_update += human_owner.adjustFireLoss(-5 * heal_multiplier, updating_health = FALSE)
	needs_health_update += human_owner.adjustOxyLoss(-10 * heal_multiplier, updating_health = FALSE)
	needs_health_update += human_owner.adjustToxLoss(-10 * heal_multiplier, forced = TRUE, updating_health = FALSE)
	needs_health_update += human_owner.adjustCloneLoss(-20 * heal_multiplier, updating_health = FALSE)
	if(needs_health_update)
		human_owner.updatehealth()
	human_owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -20 * heal_multiplier)
	if(human_owner.blood_volume < BLOOD_VOLUME_NORMAL)
		human_owner.blood_volume += 20 * heal_multiplier
	var/wounds_to_heal = 2
	while(length(human_owner.all_wounds) && wounds_to_heal > 0)
		wounds_to_heal--
		var/datum/wound/picked_wound = pick(human_owner.all_wounds)
		// cranial fissures have a 50% of not being healed at all, or a 50% chance of being healed but immediately ending the healing effect
		if(istype(picked_wound, /datum/wound/cranial_fissure))
			if(prob(50))
				return
			else
				picked_wound.remove_wound(replaced = TRUE)
				qdel(src)
				return
		picked_wound.remove_wound(replaced = TRUE)

	for(var/datum/wound/wound as anything in human_owner.all_wounds)
		wound.on_xadone(4 * REM * heal_multiplier) // plasmamen use plasma to reform their bones or whatever
