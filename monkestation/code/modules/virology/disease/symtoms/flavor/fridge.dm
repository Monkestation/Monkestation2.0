/datum/symptom/fridge
	name = "Refridgerator Syndrome"
	desc = "Causes the infected to shiver at random."
	encyclopedia = "No matter whether the room is cold or hot. This has no effect on their body temperature."
	stage = 2
	max_multiplier = 4
	multiplier = 1
	badness = EFFECT_DANGER_FLAVOR
	severity = 1

/datum/symptom/fridge/activate(mob/living/mob)
	to_chat(mob, span_warning("[pick("You feel cold.", "You shiver.")]"))
	mob.emote("shiver")
	set_body_temp(mob)

/datum/symptom/fridge/proc/set_body_temp(mob/living/mob)
	if(multiplier >= 3) // when unsafe the shivers can cause cold damage
		mob.add_body_temperature_change("chills", -6 * power * multiplier)
	else
		// Get the max amount of change allowed before going under cold damage limit, then cap the maximum allowed temperature change from safe chills to 5 over the cold damage limit
		var/change_limit = min(mob.get_body_temp_cold_damage_limit() + 5 - mob.get_body_temp_normal(apply_change=FALSE), 0)
		mob.add_body_temperature_change("chills", max(-6 * power * multiplier, change_limit))

/datum/symptom/fridge/deactivate(mob/living/carbon/mob, datum/disease/acute/disease, safe = FALSE)
	if(mob)
		mob.remove_body_temperature_change("chills")
