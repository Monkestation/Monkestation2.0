/datum/status_effect/ancient_caretaker
	id = "ancientcaretaker"
	alert_type = null
	remove_on_fullheal = FALSE

/datum/status_effect/ancient_caretaker/on_creation(mob/living/new_owner)
	src.duration = -1
	return ..()

/datum/status_effect/ancient_caretaker/tick(seconds_between_ticks)
	var/healed = 1 * REM * seconds_between_ticks
	owner.adjustToxLoss(-healed, FALSE, TRUE, MOB_ORGANIC)
	owner.adjustOxyLoss(-healed, FALSE, TRUE, MOB_ORGANIC, required_respiration_type = ALL)
	owner.adjustBruteLoss(-healed, FALSE, TRUE, MOB_ORGANIC)
	owner.adjustFireLoss(-healed, FALSE, TRUE, MOB_ORGANIC)
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL - healed)
		owner.blood_volume += healed
	..()
